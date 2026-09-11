import { describe, it, expect } from 'vitest';
import { buildKeyEntities, type TreeNodeData } from './tree-data.js';
import { computeSearchResult } from './search.js';

const TREE: TreeNodeData[] = [
  {
    key: 'a',
    label: '开发部',
    children: [
      { key: 'a1', label: '前端组', children: [{ key: 'a1a', label: '张三' }] },
      { key: 'a2', label: '后端组' },
    ],
  },
  { key: 'b', label: '产品部', children: [{ key: 'b1', label: '李四' }] },
];

describe('computeSearchResult', () => {
  it('输入为空时返回全空结果', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('', entities, true);

    expect(result.filteredKeys.size).toBe(0);
  });

  it('filterTreeNode=false 时不做任何过滤，返回全空结果', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('前端', entities, false);

    expect(result.filteredKeys.size).toBe(0);
  });

  it('默认匹配：大小写不敏感的子串包含匹配', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('前端', entities, true);

    expect(result.filteredKeys.has('a1')).toBe(true);
    expect(result.filteredKeys.has('a2')).toBe(false);
  });

  it('匹配深层叶子节点时，展开祖先链（不含自己）', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('张三', entities, true);

    expect(result.filteredKeys.has('a1a')).toBe(true);
    expect(result.expandedAncestorKeys.has('a1')).toBe(true);
    expect(result.expandedAncestorKeys.has('a')).toBe(true);
    expect(result.expandedAncestorKeys.has('a1a')).toBe(false);
  });

  it('filteredShownKeys 包含匹配节点、其后代、其祖先链的并集', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('前端', entities, true);

    // a1（前端组）匹配 -> 白名单应含 a1 自己、其后代 a1a、其祖先 a
    expect(result.filteredShownKeys.has('a1')).toBe(true);
    expect(result.filteredShownKeys.has('a1a')).toBe(true);
    expect(result.filteredShownKeys.has('a')).toBe(true);
    expect(result.filteredShownKeys.has('a2')).toBe(false);
    expect(result.filteredShownKeys.has('b')).toBe(false);
  });

  it('支持自定义匹配函数', () => {
    const entities = buildKeyEntities(TREE);
    const customMatch = (input: string, label: string) => label === input;
    const result = computeSearchResult('产品部', entities, customMatch);

    expect(result.filteredKeys.has('b')).toBe(true);
    expect(result.filteredKeys.has('a')).toBe(false);
  });

  it('无匹配结果时返回空集合', () => {
    const entities = buildKeyEntities(TREE);
    const result = computeSearchResult('不存在的部门', entities, true);

    expect(result.filteredKeys.size).toBe(0);
    expect(result.filteredShownKeys.size).toBe(0);
  });

  it('传入 keyMaps 时默认匹配按自定义字段名读取 label（对齐 Semi Tree/Cascader keyMaps）', () => {
    const customTree: TreeNodeData[] = [
      { key: 'unused', label: 'unused', id: 'x1', name: '开发部', items: [{ key: 'unused', label: 'unused', id: 'x1a', name: '前端组' }] },
    ];
    const entities = buildKeyEntities(customTree, { key: 'id', children: 'items' });
    const result = computeSearchResult('前端', entities, true, undefined, { label: 'name' });

    expect(result.filteredKeys.has('x1a')).toBe(true);
  });
});
