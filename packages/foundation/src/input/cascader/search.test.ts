import { describe, it, expect } from 'vitest';
import { buildCascaderEntities, type CascaderNodeData } from './cascader-data.js';
import { computeCascaderSearchResult } from './search.js';

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

describe('computeCascaderSearchResult', () => {
  it('filterTreeNode=false 时不返回任何结果', () => {
    const entities = buildCascaderEntities(DATA);
    expect(computeCascaderSearchResult('西湖', entities, false)).toEqual([]);
  });

  it('input 为空字符串时不返回任何结果', () => {
    const entities = buildCascaderEntities(DATA);
    expect(computeCascaderSearchResult('', entities, true)).toEqual([]);
  });

  it('filterTreeNode=true：默认只匹配叶子节点的完整路径文本', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('西湖', entities, true);
    expect(result.length).toBe(1);
    expect(result[0].pathLabel).toBe('浙江 / 杭州 / 西湖区');
  });

  it('搜索非叶子节点关键词（如"杭州"）默认不出现在结果里（filterLeafOnly 默认 true）', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('杭州', entities, true);
    // "杭州"本身不是叶子，但它的两个子节点路径文本都含"杭州"，应该匹配到子节点
    expect(result.length).toBe(2);
    expect(result.every((r) => r.pathLabel.includes('杭州'))).toBe(true);
  });

  it('filterLeafOnly=false 时非叶子节点也能出现在结果里', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('杭州', entities, true, { filterLeafOnly: false });
    // 杭州自己 + 西湖区 + 滨江区，三条路径都含"杭州"
    expect(result.length).toBe(3);
  });

  it('大小写不敏感匹配', () => {
    const entities = buildCascaderEntities([{ value: 'a', label: 'HangZhou' }]);
    const result = computeCascaderSearchResult('hangzhou', entities, true);
    expect(result.length).toBe(1);
  });

  it('自定义 filterTreeNode 函数：完全交给用户判断', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('xxx', entities, () => true);
    // 用户函数永远返回 true，应该匹配所有叶子节点
    expect(result.length).toBe(4); // 西湖区/滨江区/鄞州区/南京
  });

  it('separator 自定义拼接符', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('西湖', entities, true, { separator: '-' });
    expect(result[0].pathLabel).toBe('浙江-杭州-西湖区');
  });

  it('pathData 是完整路径的节点数据数组', () => {
    const entities = buildCascaderEntities(DATA);
    const result = computeCascaderSearchResult('西湖', entities, true);
    expect(result[0].pathData.map((d) => d.label)).toEqual(['浙江', '杭州', '西湖区']);
  });
});
