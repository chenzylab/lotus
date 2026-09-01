import { describe, it, expect } from 'vitest';
import { buildCascaderEntities, joinValuePath, type CascaderNodeData, type CascaderState } from './foundation.js';
import { CascaderFoundation } from './foundation.js';

const DATA: CascaderNodeData[] = [
  {
    value: 'zhejiang',
    label: '浙江',
    children: [
      {
        value: 'hangzhou',
        label: '杭州',
        children: [
          { value: 'xihu', label: '西湖区' },
          { value: 'binjiang', label: '滨江区' },
        ],
      },
      { value: 'ningbo', label: '宁波', children: [{ value: 'yinzhou', label: '鄞州区' }] },
    ],
  },
  { value: 'jiangsu', label: '江苏', children: [{ value: 'nanjing', label: '南京' }] },
];

function makeFoundation(initial: Partial<CascaderState> = {}) {
  let state: CascaderState = {
    activeKeys: new Set(),
    selectedKey: null,
    checkedKeys: new Set(),
    halfCheckedKeys: new Set(),
    searchInput: '',
    loadingKeys: new Set(),
    loadedKeys: new Set(),
    ...initial,
  };
  const foundation = new CascaderFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('handleActivate', () => {
  it('把 activeKeys 设为该节点的完整祖先路径', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou']);
    foundation.handleActivate(key, entities);
    expect(getState().activeKeys).toEqual(new Set([joinValuePath(['zhejiang']), key]));
  });
});

describe('handleSingleSelect', () => {
  it('非叶子节点默认不可选中，只展开（changeOnSelect=false）', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou']);
    const result = foundation.handleSingleSelect(key, entities, false, false);
    expect(result.selectedKey).toBeNull();
    expect(result.canClose).toBe(false);
    expect(getState().selectedKey).toBeNull();
    expect(getState().activeKeys.has(key)).toBe(true);
  });

  it('changeOnSelect=true 时非叶子节点可直接选中', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou']);
    const result = foundation.handleSingleSelect(key, entities, true, false);
    expect(result.selectedKey).toBe(key);
    expect(result.canClose).toBe(false);
    expect(getState().selectedKey).toBe(key);
  });

  it('叶子节点选中后 canClose=true', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const result = foundation.handleSingleSelect(key, entities, false, false);
    expect(result.selectedKey).toBe(key);
    expect(result.canClose).toBe(true);
  });

  it('key 不存在时返回 null/false', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation } = makeFoundation();
    const result = foundation.handleSingleSelect('not-exist', entities, false, false);
    expect(result).toEqual({ selectedKey: null, canClose: false });
  });

  it('回归防护：isControlled=true 时不写 selectedKey，只返回本次点击结果供 onChange 使用', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const result = foundation.handleSingleSelect(key, entities, false, true);
    expect(result.selectedKey).toBe(key);
    expect(result.canClose).toBe(true);
    // state.selectedKey 必须保持原值不变——受控模式下只有 value prop 真正
    // 变化（经由 resync effect）才能改变已选值，点击本身不能直接写 state，
    // 否则父组件拒绝更新时 UI 会永久停留在这次点击产生的中间态。
    expect(getState().selectedKey).toBeNull();
  });
});

describe('handleMultipleCheck', () => {
  it('related（默认）：勾选父节点会级联选中全部子孙', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou']);
    const result = foundation.handleMultipleCheck(key, entities, 'related', false);
    expect(result.checkedKeys.has(joinValuePath(['zhejiang', 'hangzhou', 'xihu']))).toBe(true);
    expect(result.checkedKeys.has(joinValuePath(['zhejiang', 'hangzhou', 'binjiang']))).toBe(true);
  });

  it('related：再次点击已选中节点走取消勾选分支', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    foundation.handleMultipleCheck(key, entities, 'related', false);
    expect(getState().checkedKeys.has(key)).toBe(true);
    foundation.handleMultipleCheck(key, entities, 'related', false);
    expect(getState().checkedKeys.has(key)).toBe(false);
  });

  it('related：取消勾选父节点后子孙节点同步取消勾选（级联方向的另一半，勾选方向已在上面覆盖）', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const parentKey = joinValuePath(['zhejiang', 'hangzhou']);
    const xihuKey = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const binjiangKey = joinValuePath(['zhejiang', 'hangzhou', 'binjiang']);

    foundation.handleMultipleCheck(parentKey, entities, 'related', false);
    expect(getState().checkedKeys.has(xihuKey)).toBe(true);
    expect(getState().checkedKeys.has(binjiangKey)).toBe(true);

    foundation.handleMultipleCheck(parentKey, entities, 'related', false);
    expect(getState().checkedKeys.has(parentKey)).toBe(false);
    expect(getState().checkedKeys.has(xihuKey)).toBe(false);
    expect(getState().checkedKeys.has(binjiangKey)).toBe(false);
  });

  it('unRelated：勾选/取消只影响当前 key，不做三态级联传播', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const parentKey = joinValuePath(['zhejiang', 'hangzhou']);
    foundation.handleMultipleCheck(parentKey, entities, 'unRelated', false);
    expect(getState().checkedKeys).toEqual(new Set([parentKey]));
    expect(getState().checkedKeys.has(joinValuePath(['zhejiang', 'hangzhou', 'xihu']))).toBe(false);
  });

  it('回归防护：isControlled=true 时不写 checkedKeys/halfCheckedKeys', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou']);
    const result = foundation.handleMultipleCheck(key, entities, 'related', true);
    expect(result.checkedKeys.has(joinValuePath(['zhejiang', 'hangzhou', 'xihu']))).toBe(true);
    expect(getState().checkedKeys.size).toBe(0);
    expect(getState().halfCheckedKeys.size).toBe(0);
  });

  it('disableStrictly：已勾选节点再次点击不会被取消勾选', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    foundation.handleMultipleCheck(key, entities, 'related', false, { disableStrictly: true });
    expect(getState().checkedKeys.has(key)).toBe(true);

    foundation.handleMultipleCheck(key, entities, 'related', false, { disableStrictly: true });
    expect(getState().checkedKeys.has(key)).toBe(true);
  });

  it('disableStrictly：未勾选节点仍可正常勾选', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const key = joinValuePath(['jiangsu', 'nanjing']);
    foundation.handleMultipleCheck(key, entities, 'related', false, { disableStrictly: true });
    expect(getState().checkedKeys.has(key)).toBe(true);
  });
});

describe('CascaderFoundation.resolveVisibleTags', () => {
  const items = [{ key: 'a' }, { key: 'b' }, { key: 'c' }, { key: 'd' }];

  it('maxTagCount 未设置时不折叠，返回全部', () => {
    const result = CascaderFoundation.resolveVisibleTags(items, undefined);
    expect(result.visible).toEqual(items);
    expect(result.restCount).toBe(0);
  });

  it('超出 maxTagCount 时截断，返回剩余数量与剩余项', () => {
    const result = CascaderFoundation.resolveVisibleTags(items, 2);
    expect(result.visible).toEqual(items.slice(0, 2));
    expect(result.restCount).toBe(2);
    expect(result.rest).toEqual(items.slice(2));
  });
});

describe('syncCheckedKeysFromValue', () => {
  it('从外部 valuePaths 反推 checkedKeys（含三态级联半选标记）', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.syncCheckedKeysFromValue([['zhejiang', 'hangzhou', 'xihu']], entities);
    expect(getState().checkedKeys.has(joinValuePath(['zhejiang', 'hangzhou', 'xihu']))).toBe(true);
    expect(getState().halfCheckedKeys.has(joinValuePath(['zhejiang', 'hangzhou']))).toBe(true);
    expect(getState().halfCheckedKeys.has(joinValuePath(['zhejiang']))).toBe(true);
  });

  it('不存在的 valuePath 被忽略，不报错', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    foundation.syncCheckedKeysFromValue([['unknown', 'path']], entities);
    expect(getState().checkedKeys.size).toBe(0);
  });
});

describe('resolveValue', () => {
  it('基于当前 checkedKeys 折叠出对外 value（默认 autoMergeValue）', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation } = makeFoundation();
    foundation.handleMultipleCheck(joinValuePath(['zhejiang', 'hangzhou']), entities, 'related', false);
    const value = foundation.resolveValue(entities);
    expect(value).toEqual([['zhejiang', 'hangzhou']]);
  });
});

describe('computeColumns', () => {
  it('基于当前 activeKeys 计算多列面板数据', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation } = makeFoundation();
    foundation.handleActivate(joinValuePath(['zhejiang']), entities);
    const columns = foundation.computeColumns(DATA, entities);
    expect(columns.length).toBe(2);
    expect(columns[1].map((e) => e.data.label)).toEqual(['杭州', '宁波']);
  });
});

describe('handleSearch', () => {
  it('更新 searchInput 并返回匹配结果', () => {
    const entities = buildCascaderEntities(DATA);
    const { foundation, getState } = makeFoundation();
    const result = foundation.handleSearch('西湖', entities, true);
    expect(getState().searchInput).toBe('西湖');
    expect(result.length).toBe(1);
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

  it('loadEnd 成功时返回值携带新增的 newLoadedKeys（对齐 Semi onLoad 回调参数）', () => {
    const { foundation } = makeFoundation();
    foundation.handleLoadStart('k1');
    const result = foundation.handleLoadEnd('k1', true);
    expect(result.newLoadedKeys).toEqual(new Set(['k1']));
    expect(result.loadedKeys.has('k1')).toBe(true);
  });

  it('loadEnd 失败时返回值 newLoadedKeys 为空集合', () => {
    const { foundation } = makeFoundation();
    foundation.handleLoadStart('k1');
    const result = foundation.handleLoadEnd('k1', false);
    expect(result.newLoadedKeys.size).toBe(0);
  });
});
