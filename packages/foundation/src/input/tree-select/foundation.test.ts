import { describe, it, expect } from 'vitest';
import { buildKeyEntities, type TreeNodeData } from '../../navigation/tree/tree-data.js';
import { TreeSelectFoundation, type TreeSelectState } from './foundation.js';

const DATA: TreeNodeData[] = [
  {
    key: 'zhejiang',
    label: '浙江',
    children: [
      {
        key: 'hangzhou',
        label: '杭州',
        children: [
          { key: 'xihu', label: '西湖区' },
          { key: 'binjiang', label: '滨江区' },
        ],
      },
      { key: 'ningbo', label: '宁波', children: [{ key: 'yinzhou', label: '鄞州区' }] },
    ],
  },
  { key: 'jiangsu', label: '江苏', children: [{ key: 'nanjing', label: '南京' }] },
];

function makeFoundation(initial: Partial<TreeSelectState> = {}) {
  let state: TreeSelectState = {
    expandedKeys: new Set(),
    checkedKeys: new Set(),
    halfCheckedKeys: new Set(),
    independentCheckedKeys: new Set(),
    selectedKey: null,
    searchInput: '',
    loadedKeys: new Set(),
    loadingKeys: new Set(),
    ...initial,
  };
  const foundation = new TreeSelectFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('handleExpand', () => {
  it('切换展开状态', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleExpand('zhejiang');
    expect(getState().expandedKeys.has('zhejiang')).toBe(true);
    foundation.handleExpand('zhejiang');
    expect(getState().expandedKeys.has('zhejiang')).toBe(false);
  });
});

describe('handleSelect（单选）', () => {
  it('选中后再次点击同一 key 取消选中', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleSelect('xihu', false);
    expect(getState().selectedKey).toBe('xihu');
    foundation.handleSelect('xihu', false);
    expect(getState().selectedKey).toBeNull();
  });

  it('选中不同 key 直接替换', () => {
    const { foundation, getState } = makeFoundation({ selectedKey: 'xihu' });
    foundation.handleSelect('nanjing', false);
    expect(getState().selectedKey).toBe('nanjing');
  });

  it('回归防护：isControlled=true 时不写 selectedKey，只返回本次点击结果供 onChange 使用', () => {
    const { foundation, getState } = makeFoundation();
    const next = foundation.handleSelect('xihu', true);
    expect(next).toBe('xihu');
    expect(getState().selectedKey).toBeNull();
  });
});

describe('handleCheck（related，默认）', () => {
  it('勾选父节点级联选中全部子孙', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation } = makeFoundation();
    const result = foundation.handleCheck('hangzhou', entities, 'related', false);
    expect(result.checkedKeys.has('xihu')).toBe(true);
    expect(result.checkedKeys.has('binjiang')).toBe(true);
  });

  it('再次点击已选中节点走取消勾选分支', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleCheck('xihu', entities, 'related', false);
    expect(getState().checkedKeys.has('xihu')).toBe(true);
    foundation.handleCheck('xihu', entities, 'related', false);
    expect(getState().checkedKeys.has('xihu')).toBe(false);
  });

  it('回归防护：isControlled=true 时不写 checkedKeys/halfCheckedKeys', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const result = foundation.handleCheck('hangzhou', entities, 'related', true);
    expect(result.checkedKeys.has('xihu')).toBe(true);
    expect(getState().checkedKeys.size).toBe(0);
  });

  it('取消勾选父节点后子孙节点同步取消勾选（级联方向的另一半，勾选方向已在上面覆盖）', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'related', false);
    expect(getState().checkedKeys.has('hangzhou')).toBe(true);
    expect(getState().checkedKeys.has('xihu')).toBe(true);
    expect(getState().checkedKeys.has('binjiang')).toBe(true);

    foundation.handleCheck('hangzhou', entities, 'related', false);
    expect(getState().checkedKeys.has('hangzhou')).toBe(false);
    expect(getState().checkedKeys.has('xihu')).toBe(false);
    expect(getState().checkedKeys.has('binjiang')).toBe(false);
  });
});

describe('handleCheck（unRelated）', () => {
  it('勾选/取消只影响当前 key，不做三态级联传播', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'unRelated', false);
    expect(getState().independentCheckedKeys).toEqual(new Set(['hangzhou']));
    expect(getState().independentCheckedKeys.has('xihu')).toBe(false);
    expect(getState().checkedKeys.size).toBe(0);
  });

  it('unRelated 模式下 checkedKeys/halfCheckedKeys 完全不受影响', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'unRelated', false);
    foundation.handleCheck('xihu', entities, 'unRelated', false);
    expect(getState().independentCheckedKeys).toEqual(new Set(['hangzhou', 'xihu']));
    expect(getState().halfCheckedKeys.size).toBe(0);
  });

  it('再次点击取消勾选', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'unRelated', false);
    foundation.handleCheck('hangzhou', entities, 'unRelated', false);
    expect(getState().independentCheckedKeys.size).toBe(0);
  });

  it('回归防护：isControlled=true 时不写 independentCheckedKeys', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const result = foundation.handleCheck('hangzhou', entities, 'unRelated', true);
    expect(result.checkedKeys).toEqual(new Set(['hangzhou']));
    expect(getState().independentCheckedKeys.size).toBe(0);
  });
});

describe('syncCheckedKeysFromValue', () => {
  it('related：从外部 keys 反推 checkedKeys（含三态级联半选标记）', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.syncCheckedKeysFromValue(['xihu'], entities);
    expect(getState().checkedKeys.has('xihu')).toBe(true);
    expect(getState().halfCheckedKeys.has('hangzhou')).toBe(true);
    expect(getState().halfCheckedKeys.has('zhejiang')).toBe(true);
  });

  it('unRelated：直接替换 independentCheckedKeys，不做三态重算', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.syncCheckedKeysFromValue(['xihu', 'nanjing'], entities, 'unRelated');
    expect(getState().independentCheckedKeys).toEqual(new Set(['xihu', 'nanjing']));
    expect(getState().halfCheckedKeys.size).toBe(0);
  });

  it('不存在的 key 被忽略，不报错', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.syncCheckedKeysFromValue(['not-exist'], entities);
    expect(getState().checkedKeys.size).toBe(0);
  });
});

describe('resolveValue', () => {
  it('related：基于当前 checkedKeys 折叠出对外 value（默认 autoMergeValue）', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'related', false);
    expect(foundation.resolveValue(entities)).toEqual(['hangzhou']);
  });

  it('unRelated：直接返回 independentCheckedKeys，不经过折叠', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation } = makeFoundation();
    foundation.handleCheck('hangzhou', entities, 'unRelated', false);
    expect(foundation.resolveValue(entities, 'unRelated')).toEqual(['hangzhou']);
  });
});

describe('handleSearch', () => {
  it('更新 searchInput 并展开匹配节点的祖先链', () => {
    const entities = buildKeyEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.handleSearch('西湖', entities, true);
    expect(getState().searchInput).toBe('西湖');
    expect(getState().expandedKeys.has('hangzhou')).toBe(true);
    expect(getState().expandedKeys.has('zhejiang')).toBe(true);
  });
});

describe('handleLoadStart / handleLoadEnd', () => {
  it('loadStart 加入 loadingKeys', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleLoadStart('k1');
    expect(getState().loadingKeys.has('k1')).toBe(true);
  });

  it('loadEnd 成功时移出 loadingKeys 并加入 loadedKeys', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleLoadStart('k1');
    foundation.handleLoadEnd('k1', true);
    expect(getState().loadingKeys.has('k1')).toBe(false);
    expect(getState().loadedKeys.has('k1')).toBe(true);
  });

  it('loadEnd 失败时移出 loadingKeys 但不加入 loadedKeys（允许重试）', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleLoadStart('k1');
    foundation.handleLoadEnd('k1', false);
    expect(getState().loadingKeys.has('k1')).toBe(false);
    expect(getState().loadedKeys.has('k1')).toBe(false);
  });
});
