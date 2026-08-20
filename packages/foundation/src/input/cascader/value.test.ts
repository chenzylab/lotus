import { describe, it, expect } from 'vitest';
import { buildCascaderEntities, joinValuePath, type CascaderNodeData } from './cascader-data.js';
import { collapseCheckedKeysToValuePaths } from './value.js';

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

describe('collapseCheckedKeysToValuePaths', () => {
  it('autoMergeValue（默认）：父节点全部子孙选中时只保留父路径', () => {
    const entities = buildCascaderEntities(DATA);
    // 模拟"杭州"下两个区都被选中 + 杭州自己也被三态级联标记为选中
    const checkedKeys = new Set([
      joinValuePath(['zhejiang', 'hangzhou']),
      joinValuePath(['zhejiang', 'hangzhou', 'xihu']),
      joinValuePath(['zhejiang', 'hangzhou', 'binjiang']),
    ]);
    const result = collapseCheckedKeysToValuePaths(checkedKeys, entities);
    expect(result).toEqual([['zhejiang', 'hangzhou']]);
  });

  it('autoMergeValue=false：逐一列出全部选中路径，不合并', () => {
    const entities = buildCascaderEntities(DATA);
    const checkedKeys = new Set([
      joinValuePath(['zhejiang', 'hangzhou']),
      joinValuePath(['zhejiang', 'hangzhou', 'xihu']),
      joinValuePath(['zhejiang', 'hangzhou', 'binjiang']),
    ]);
    const result = collapseCheckedKeysToValuePaths(checkedKeys, entities, { autoMergeValue: false });
    expect(result.length).toBe(3);
  });

  it('leafOnly=true：只保留叶子节点路径，非叶子（父节点）一律过滤掉', () => {
    const entities = buildCascaderEntities(DATA);
    const checkedKeys = new Set([
      joinValuePath(['zhejiang', 'hangzhou']),
      joinValuePath(['zhejiang', 'hangzhou', 'xihu']),
      joinValuePath(['zhejiang', 'hangzhou', 'binjiang']),
    ]);
    const result = collapseCheckedKeysToValuePaths(checkedKeys, entities, { leafOnly: true });
    expect(result).toEqual(
      expect.arrayContaining([
        ['zhejiang', 'hangzhou', 'xihu'],
        ['zhejiang', 'hangzhou', 'binjiang'],
      ]),
    );
    expect(result.length).toBe(2);
  });

  it('未合并场景（不同子树各自部分选中）：各自独立列出', () => {
    const entities = buildCascaderEntities(DATA);
    const checkedKeys = new Set([
      joinValuePath(['zhejiang', 'hangzhou', 'xihu']),
      joinValuePath(['jiangsu', 'nanjing']),
    ]);
    const result = collapseCheckedKeysToValuePaths(checkedKeys, entities);
    expect(result).toEqual(
      expect.arrayContaining([
        ['zhejiang', 'hangzhou', 'xihu'],
        ['jiangsu', 'nanjing'],
      ]),
    );
    expect(result.length).toBe(2);
  });

  it('空 checkedKeys 返回空数组', () => {
    const entities = buildCascaderEntities(DATA);
    expect(collapseCheckedKeysToValuePaths(new Set(), entities)).toEqual([]);
  });
});
