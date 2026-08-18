import { describe, it, expect } from 'vitest';
import { buildKeyEntities, type TreeNodeData } from './tree-data.js';
import { calcExpandedKeys, calcAllExpandedKeys, toggleExpanded } from './expand.js';

const TREE: TreeNodeData[] = [
  {
    key: 'a',
    label: 'A',
    children: [{ key: 'a1', label: 'A1', children: [{ key: 'a1a', label: 'A1a' }] }],
  },
  { key: 'b', label: 'B' },
];

describe('calcExpandedKeys', () => {
  it('autoExpandParent=true 时展开传入 key 的完整祖先链', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcExpandedKeys(['a1a'], entities, true);

    expect(result.has('a1a')).toBe(true);
    expect(result.has('a1')).toBe(true);
    expect(result.has('a')).toBe(true);
  });

  it('autoExpandParent=false 时只展开传入的 key 本身', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcExpandedKeys(['a1a'], entities, false);

    expect(result).toEqual(new Set(['a1a']));
  });
});

describe('calcAllExpandedKeys', () => {
  it('只包含有子节点的 key，叶子节点不出现', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcAllExpandedKeys(entities);

    expect(result.has('a')).toBe(true);
    expect(result.has('a1')).toBe(true);
    expect(result.has('a1a')).toBe(false);
    expect(result.has('b')).toBe(false);
  });
});

describe('toggleExpanded', () => {
  it('未展开的 key 切换后加入集合', () => {
    const result = toggleExpanded('a', new Set());
    expect(result.has('a')).toBe(true);
  });

  it('已展开的 key 切换后移出集合', () => {
    const result = toggleExpanded('a', new Set(['a']));
    expect(result.has('a')).toBe(false);
  });

  it('不修改传入的原始集合（返回新集合）', () => {
    const original = new Set(['a']);
    toggleExpanded('a', original);
    expect(original.has('a')).toBe(true);
  });
});
