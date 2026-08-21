import { describe, it, expect } from 'vitest';
import { flattenRows, toggleExpandedRow } from './expand.js';

describe('flattenRows', () => {
  it('无展开：只返回顶层行', () => {
    const data = [{ id: 'a' }, { id: 'b' }];
    const result = flattenRows(data, { rowKey: (r: any) => r.id, childrenKey: 'children', expandedRowKeys: new Set(), hasExpandedRowRender: false });
    expect(result.map((r) => r.key)).toEqual(['a', 'b']);
  });

  it('树形数据展开：递归打平子行', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }, { id: 'a2' }] }];
    const result = flattenRows(data, { rowKey: (r: any) => r.id, childrenKey: 'children', expandedRowKeys: new Set(['a']), hasExpandedRowRender: false });
    expect(result.map((r) => r.key)).toEqual(['a', 'a1', 'a2']);
    expect(result[1]!.level).toBe(1);
  });

  it('树形数据未展开：不打平子行', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }] }];
    const result = flattenRows(data, { rowKey: (r: any) => r.id, childrenKey: 'children', expandedRowKeys: new Set(), hasExpandedRowRender: false });
    expect(result.map((r) => r.key)).toEqual(['a']);
    expect(result[0]!.hasChildren).toBe(true);
  });

  it('expandedRowRender 场景：无子节点时插入合成展开内容行', () => {
    const data = [{ id: 'a' }];
    const result = flattenRows(data, { rowKey: (r: any) => r.id, childrenKey: 'children', expandedRowKeys: new Set(['a']), hasExpandedRowRender: true });
    expect(result).toHaveLength(2);
    expect(result[1]!.isExpandedContent).toBe(true);
    expect(result[1]!.key).toBe('a__expanded');
  });

  it('hasExpandedRowRender=false 且无子节点：展开态不产生额外行', () => {
    const data = [{ id: 'a' }];
    const result = flattenRows(data, { rowKey: (r: any) => r.id, childrenKey: 'children', expandedRowKeys: new Set(['a']), hasExpandedRowRender: false });
    expect(result).toHaveLength(1);
  });
});

describe('toggleExpandedRow', () => {
  it('未展开 -> 展开', () => {
    expect(toggleExpandedRow(new Set(), 'a')).toEqual(new Set(['a']));
  });

  it('已展开 -> 收起', () => {
    expect(toggleExpandedRow(new Set(['a']), 'a')).toEqual(new Set());
  });
});
