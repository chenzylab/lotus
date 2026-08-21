import { describe, it, expect } from 'vitest';
import {
  generateDataByType,
  generateSelectedItems,
  getValuesAndItemsFromMap,
  resolveValue,
  type BasicDataItem,
  type GroupItem,
  type TreeItem,
} from './transfer-data.js';

describe('transfer-data', () => {
  describe('resolveValue', () => {
    it('value 存在时返回 value', () => {
      expect(resolveValue({ key: 'k1', value: 'v1' })).toBe('v1');
    });

    it('value 缺省时 fallback 到 key（修正 Semi 已知缺陷）', () => {
      expect(resolveValue({ key: 'k1' })).toBe('k1');
    });
  });

  describe('generateDataByType', () => {
    it('type=list：原样返回（浅拷贝）', () => {
      const data: BasicDataItem[] = [{ key: 'a' }, { key: 'b' }];
      const result = generateDataByType(data, 'list');
      expect(result).toEqual(data);
      expect(result).not.toBe(data);
    });

    it('type=groupList：打平并注入 _parent', () => {
      const data: GroupItem[] = [
        { title: '分组A', children: [{ key: 'a1' }, { key: 'a2' }] },
        { title: '分组B', children: [{ key: 'b1' }] },
      ];
      const result = generateDataByType(data, 'groupList');
      expect(result).toHaveLength(3);
      expect(result[0]).toMatchObject({ key: 'a1', _parent: { title: '分组A' } });
      expect(result[2]).toMatchObject({ key: 'b1', _parent: { title: '分组B' } });
    });

    it('type=treeList：DFS 打平并注入 path/isLeaf', () => {
      const data: TreeItem[] = [
        {
          key: 'root',
          children: [
            { key: 'child1', children: [{ key: 'grandchild1' }] },
            { key: 'child2' },
          ],
        },
      ];
      const result = generateDataByType(data, 'treeList');
      expect(result.map((r) => r.key)).toEqual(['root', 'child1', 'grandchild1', 'child2']);
      const root = result.find((r) => r.key === 'root')!;
      expect(root.isLeaf).toBe(false);
      expect(root.path).toEqual([{ key: 'root' }]);
      const grandchild = result.find((r) => r.key === 'grandchild1')!;
      expect(grandchild.isLeaf).toBe(true);
      expect(grandchild.path).toEqual([{ key: 'root' }, { key: 'child1' }, { key: 'grandchild1' }]);
      const leaf2 = result.find((r) => r.key === 'child2')!;
      expect(leaf2.isLeaf).toBe(true);
    });
  });

  describe('generateSelectedItems / getValuesAndItemsFromMap', () => {
    const data = [
      { key: 'k1', value: 'v1', label: 'A' },
      { key: 'k2', value: 'v2', label: 'B' },
      { key: 'k3', label: 'C' },
    ];

    it('generateSelectedItems：按 value 匹配（含 fallback key 的项）', () => {
      const selected = generateSelectedItems(['v1', 'k3'], data);
      expect([...selected.keys()]).toEqual(['k1', 'k3']);
    });

    it('generateSelectedItems：匹配不上的值被忽略', () => {
      const selected = generateSelectedItems(['nonexistent'], data);
      expect(selected.size).toBe(0);
    });

    it('getValuesAndItemsFromMap：往返一致', () => {
      const selected = generateSelectedItems(['v1', 'v2'], data);
      const { values, items } = getValuesAndItemsFromMap(selected);
      expect(values).toEqual(['v1', 'v2']);
      expect(items.map((i) => i.key)).toEqual(['k1', 'k2']);
    });
  });
});
