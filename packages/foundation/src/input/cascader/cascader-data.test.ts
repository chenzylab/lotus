import { describe, it, expect } from 'vitest';
import {
  buildCascaderEntities,
  joinValuePath,
  isLeafEntity,
  findKeyByValuePath,
  findAncestorKeys,
  getPathData,
  computeColumns,
  type CascaderNodeData,
} from './cascader-data.js';

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

describe('joinValuePath / buildCascaderEntities', () => {
  it('同一 value 在不同分支下生成不同 key', () => {
    const entities = buildCascaderEntities([
      { value: 'a', label: 'A1', children: [{ value: 'x', label: 'X' }] },
      { value: 'b', label: 'A2', children: [{ value: 'x', label: 'X' }] },
    ]);
    const key1 = joinValuePath(['a', 'x']);
    const key2 = joinValuePath(['b', 'x']);
    expect(key1).not.toBe(key2);
    expect(entities[key1]).toBeDefined();
    expect(entities[key2]).toBeDefined();
  });

  it('entity.level/parent/children 正确构建', () => {
    const entities = buildCascaderEntities(DATA);
    const root = entities[joinValuePath(['zhejiang'])];
    expect(root.level).toBe(0);
    expect(root.parent).toBeNull();
    expect(root.children.length).toBe(2);

    const leaf = entities[joinValuePath(['zhejiang', 'hangzhou', 'xihu'])];
    expect(leaf.level).toBe(2);
    expect(leaf.parent?.key).toBe(joinValuePath(['zhejiang', 'hangzhou']));
    expect(leaf.valuePath).toEqual(['zhejiang', 'hangzhou', 'xihu']);
  });
});

describe('isLeafEntity', () => {
  it('无 children 视为叶子', () => {
    const entities = buildCascaderEntities(DATA);
    expect(isLeafEntity(entities[joinValuePath(['zhejiang', 'hangzhou', 'xihu'])])).toBe(true);
  });

  it('有 children 视为非叶子', () => {
    const entities = buildCascaderEntities(DATA);
    expect(isLeafEntity(entities[joinValuePath(['zhejiang'])])).toBe(false);
  });

  it('显式 isLeaf:true 即使有 children 也视为叶子（懒加载场景）', () => {
    const entities = buildCascaderEntities([{ value: 'a', label: 'A', isLeaf: true, children: [] }]);
    expect(isLeafEntity(entities[joinValuePath(['a'])])).toBe(true);
  });
});

describe('findKeyByValuePath', () => {
  it('完整路径存在时返回 key', () => {
    const entities = buildCascaderEntities(DATA);
    expect(findKeyByValuePath(['zhejiang', 'hangzhou'], entities)).toBe(joinValuePath(['zhejiang', 'hangzhou']));
  });

  it('路径不存在时返回 null', () => {
    const entities = buildCascaderEntities(DATA);
    expect(findKeyByValuePath(['zhejiang', 'unknown'], entities)).toBeNull();
  });
});

describe('findAncestorKeys', () => {
  it('返回从叶子到根的完整祖先链（含自身）', () => {
    const entities = buildCascaderEntities(DATA);
    const leafKey = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const ancestors = findAncestorKeys([leafKey], entities, true);
    expect(new Set(ancestors)).toEqual(
      new Set([leafKey, joinValuePath(['zhejiang', 'hangzhou']), joinValuePath(['zhejiang'])]),
    );
  });

  it('self=false 时不含自身', () => {
    const entities = buildCascaderEntities(DATA);
    const leafKey = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const ancestors = findAncestorKeys([leafKey], entities, false);
    expect(ancestors).not.toContain(leafKey);
  });
});

describe('getPathData', () => {
  it('返回从根到自身的完整节点数据数组', () => {
    const entities = buildCascaderEntities(DATA);
    const leafKey = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const path = getPathData(leafKey, entities);
    expect(path.map((d) => d.label)).toEqual(['浙江', '杭州', '西湖区']);
  });

  it('key 不存在时返回空数组', () => {
    const entities = buildCascaderEntities(DATA);
    expect(getPathData('not-exist', entities)).toEqual([]);
  });
});

describe('computeColumns', () => {
  it('activeKeys 为空时只返回第一列（根节点列表）', () => {
    const entities = buildCascaderEntities(DATA);
    const columns = computeColumns(DATA, new Set(), entities);
    expect(columns.length).toBe(1);
    expect(columns[0].map((e) => e.data.label)).toEqual(['浙江', '江苏']);
  });

  it('激活到第二级时返回两列', () => {
    const entities = buildCascaderEntities(DATA);
    const activeKeys = new Set(findAncestorKeys([joinValuePath(['zhejiang'])], entities, true));
    const columns = computeColumns(DATA, activeKeys, entities);
    expect(columns.length).toBe(2);
    expect(columns[1].map((e) => e.data.label)).toEqual(['杭州', '宁波']);
  });

  it('激活到叶子节点时列数等于路径深度', () => {
    const entities = buildCascaderEntities(DATA);
    const leafKey = joinValuePath(['zhejiang', 'hangzhou', 'xihu']);
    const activeKeys = new Set(findAncestorKeys([leafKey], entities, true));
    const columns = computeColumns(DATA, activeKeys, entities);
    expect(columns.length).toBe(3);
    expect(columns[2].map((e) => e.data.label)).toEqual(['西湖区', '滨江区']);
  });
});
