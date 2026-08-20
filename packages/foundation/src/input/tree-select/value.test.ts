import { describe, it, expect } from 'vitest';
import { buildKeyEntities, type TreeNodeData } from '../../navigation/tree/tree-data.js';
import { normalizeCheckedKeysToValue } from './value.js';

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

describe('normalizeCheckedKeysToValue', () => {
  it('autoMergeValue（默认）：父节点全部子孙选中时只保留父 key', () => {
    const entities = buildKeyEntities(DATA);
    const checkedKeys = new Set(['hangzhou', 'xihu', 'binjiang']);
    expect(normalizeCheckedKeysToValue(checkedKeys, entities)).toEqual(['hangzhou']);
  });

  it('autoMergeValue=false：逐一列出全部选中 key，不合并', () => {
    const entities = buildKeyEntities(DATA);
    const checkedKeys = new Set(['hangzhou', 'xihu', 'binjiang']);
    const result = normalizeCheckedKeysToValue(checkedKeys, entities, { autoMergeValue: false });
    expect(result.length).toBe(3);
  });

  it('leafOnly=true：只保留叶子节点 key，非叶子过滤掉', () => {
    const entities = buildKeyEntities(DATA);
    const checkedKeys = new Set(['hangzhou', 'xihu', 'binjiang']);
    const result = normalizeCheckedKeysToValue(checkedKeys, entities, { leafOnly: true });
    expect(result).toEqual(expect.arrayContaining(['xihu', 'binjiang']));
    expect(result.length).toBe(2);
  });

  it('未合并场景（不同子树各自部分选中）：各自独立列出', () => {
    const entities = buildKeyEntities(DATA);
    const checkedKeys = new Set(['xihu', 'nanjing']);
    const result = normalizeCheckedKeysToValue(checkedKeys, entities);
    expect(result).toEqual(expect.arrayContaining(['xihu', 'nanjing']));
    expect(result.length).toBe(2);
  });

  it('空 checkedKeys 返回空数组', () => {
    const entities = buildKeyEntities(DATA);
    expect(normalizeCheckedKeysToValue(new Set(), entities)).toEqual([]);
  });
});
