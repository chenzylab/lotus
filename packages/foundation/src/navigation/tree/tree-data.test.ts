import { describe, it, expect } from 'vitest';
import {
  buildKeyEntities,
  flattenTreeData,
  findAncestorKeys,
  findDescendantKeys,
  findSiblingKeys,
  type TreeNodeData,
} from './tree-data.js';

const TREE: TreeNodeData[] = [
  {
    key: 'a',
    label: 'A',
    children: [
      { key: 'a1', label: 'A1', children: [{ key: 'a1a', label: 'A1a' }] },
      { key: 'a2', label: 'A2' },
    ],
  },
  { key: 'b', label: 'B', children: [{ key: 'b1', label: 'B1' }] },
  { key: 'c', label: 'C' },
];

describe('buildKeyEntities', () => {
  it('每个节点都被索引，level 从 0 开始按深度递增', () => {
    const entities = buildKeyEntities(TREE);

    expect(entities.a!.level).toBe(0);
    expect(entities.a1!.level).toBe(1);
    expect(entities.a1a!.level).toBe(2);
    expect(entities.c!.level).toBe(0);
  });

  it('parent/children 引用正确建立', () => {
    const entities = buildKeyEntities(TREE);

    expect(entities.a1!.parent!.key).toBe('a');
    expect(entities.a!.children.map((c) => c.key)).toEqual(['a1', 'a2']);
    expect(entities.c!.parent).toBeNull();
  });
});

describe('flattenTreeData', () => {
  it('全部收起时只展示顶层节点', () => {
    const flat = flattenTreeData(TREE, new Set());
    expect(flat.map((n) => n.key)).toEqual(['a', 'b', 'c']);
  });

  it('展开的节点会摊平其直接子节点，未展开分支的子孙完全不出现', () => {
    const flat = flattenTreeData(TREE, new Set(['a']));
    expect(flat.map((n) => n.key)).toEqual(['a', 'a1', 'a2', 'b', 'c']);
  });

  it('多层展开时递归摊平，level 字段正确反映深度', () => {
    const flat = flattenTreeData(TREE, new Set(['a', 'a1']));
    const a1a = flat.find((n) => n.key === 'a1a');

    expect(flat.map((n) => n.key)).toEqual(['a', 'a1', 'a1a', 'a2', 'b', 'c']);
    expect(a1a!.level).toBe(2);
  });

  it('叶子节点的 isLeaf 根据是否有 children 自动推断', () => {
    const flat = flattenTreeData(TREE, new Set());
    expect(flat.find((n) => n.key === 'a')!.isLeaf).toBe(false);
    expect(flat.find((n) => n.key === 'c')!.isLeaf).toBe(true);
  });

  it('filteredShownKeys 白名单存在时，只保留白名单内的节点', () => {
    const flat = flattenTreeData(TREE, new Set(['a']), new Set(['a', 'a1']));
    expect(flat.map((n) => n.key)).toEqual(['a', 'a1']);
  });
});

describe('findAncestorKeys', () => {
  it('返回指定 key 的完整祖先链，self=true 时含自己', () => {
    const entities = buildKeyEntities(TREE);
    const result = findAncestorKeys(['a1a'], entities, true);
    expect(new Set(result)).toEqual(new Set(['a1a', 'a1', 'a']));
  });

  it('self=false 时不含自己', () => {
    const entities = buildKeyEntities(TREE);
    const result = findAncestorKeys(['a1a'], entities, false);
    expect(new Set(result)).toEqual(new Set(['a1', 'a']));
  });

  it('顶层节点没有祖先，self=false 时返回空', () => {
    const entities = buildKeyEntities(TREE);
    expect(findAncestorKeys(['a'], entities, false)).toEqual([]);
  });
});

describe('findDescendantKeys', () => {
  it('返回指定 key 的全部后代，self=true 时含自己', () => {
    const entities = buildKeyEntities(TREE);
    const result = findDescendantKeys(['a'], entities, true);
    expect(new Set(result)).toEqual(new Set(['a', 'a1', 'a1a', 'a2']));
  });

  it('叶子节点没有后代，self=false 时返回空', () => {
    const entities = buildKeyEntities(TREE);
    expect(findDescendantKeys(['c'], entities, false)).toEqual([]);
  });
});

describe('findSiblingKeys', () => {
  it('返回同一父节点下的全部兄弟，含自己', () => {
    const entities = buildKeyEntities(TREE);
    const result = findSiblingKeys('a1', entities, true);
    expect(new Set(result)).toEqual(new Set(['a1', 'a2']));
  });

  it('顶层节点的兄弟是其它顶层节点', () => {
    const entities = buildKeyEntities(TREE);
    const result = findSiblingKeys('a', entities, true);
    expect(new Set(result)).toEqual(new Set(['a', 'b', 'c']));
  });
});
