import { describe, it, expect } from 'vitest';
import { groupDataSource, buildGroupSections, flattenGroupedRows } from './group.js';
import { flattenRows } from './expand.js';

const resolveKey = (r: any, i: number) => String(r.id ?? i);

describe('groupDataSource', () => {
  it('未设置 groupBy：原样返回，无分组', () => {
    const data = [{ id: 'a' }, { id: 'b' }];
    const result = groupDataSource(data, undefined, resolveKey);
    expect(result.groupKeys).toEqual([]);
    expect(result.dataSource).toBe(data);
  });

  it('字符串 groupBy：按字段值分组，同组数据重排到一起', () => {
    const data = [
      { id: '1', type: 'fruit', name: 'apple' },
      { id: '2', type: 'veg', name: 'carrot' },
      { id: '3', type: 'fruit', name: 'banana' },
    ];
    const result = groupDataSource(data, 'type', resolveKey);
    expect(result.groupKeys).toEqual(['fruit', 'veg']);
    expect(result.dataSource.map((r) => r.name)).toEqual(['apple', 'banana', 'carrot']);
    expect(result.groups.get('fruit')).toEqual(new Set(['1', '3']));
    expect(result.groups.get('veg')).toEqual(new Set(['2']));
  });

  it('函数 groupBy：调用函数取分组键', () => {
    const data = [{ id: '1', score: 85 }, { id: '2', score: 45 }];
    const result = groupDataSource(data, (r: any) => (r.score >= 60 ? 'pass' : 'fail'), resolveKey);
    expect(result.groupKeys).toEqual(['pass', 'fail']);
  });

  it('分组键为 null/undefined/空字符串：不进入任何组，保留在结果末尾', () => {
    const data = [
      { id: '1', type: 'fruit' },
      { id: '2', type: null },
      { id: '3', type: undefined },
      { id: '4', type: '' },
    ];
    const result = groupDataSource(data, 'type', resolveKey);
    expect(result.groupKeys).toEqual(['fruit']);
    expect(result.dataSource.map((r) => r.id)).toEqual(['1', '2', '3', '4']);
  });

  it('全部无分组键：groups 为空，dataSource 原样返回', () => {
    const data = [{ id: '1', type: null }];
    const result = groupDataSource(data, 'type', resolveKey);
    expect(result.groupKeys).toEqual([]);
    expect(result.groups.size).toBe(0);
  });
});

describe('buildGroupSections', () => {
  it('按 groupKeys 顺序拆出分段，每段带组内成员记录', () => {
    const data = [
      { id: '1', type: 'fruit', name: 'apple' },
      { id: '2', type: 'veg', name: 'carrot' },
      { id: '3', type: 'fruit', name: 'banana' },
    ];
    const grouped = groupDataSource(data, 'type', resolveKey);
    const sections = buildGroupSections(grouped, resolveKey);
    expect(sections).toHaveLength(2);
    expect(sections[0]!.groupKey).toBe('fruit');
    expect(sections[0]!.members.map((r) => r.name)).toEqual(['apple', 'banana']);
    expect(sections[1]!.groupKey).toBe('veg');
    expect(sections[1]!.members.map((r) => r.name)).toEqual(['carrot']);
  });

  it('无分组：返回空数组', () => {
    const data = [{ id: '1' }];
    const grouped = groupDataSource(data, undefined, resolveKey);
    expect(buildGroupSections(grouped, resolveKey)).toEqual([]);
  });
});

const flattenMembers = (members: any[]) =>
  flattenRows(members, { rowKey: resolveKey, childrenKey: 'children', expandedRowKeys: new Set(), hasExpandedRowRender: false });

describe('flattenGroupedRows', () => {
  it('未展开的组：只插入标题行，不展开组内成员', () => {
    const data = [
      { id: '1', type: 'fruit', name: 'apple' },
      { id: '2', type: 'veg', name: 'carrot' },
    ];
    const grouped = groupDataSource(data, 'type', resolveKey);
    const rows = flattenGroupedRows(grouped, resolveKey, { expandedRowKeys: new Set(), flattenMembers });
    expect(rows).toHaveLength(2);
    expect(rows.every((r) => r.isGroupSection)).toBe(true);
    expect(rows.map((r) => r.groupKey)).toEqual(['fruit', 'veg']);
  });

  it('展开的组：标题行后紧跟组内成员行', () => {
    const data = [
      { id: '1', type: 'fruit', name: 'apple' },
      { id: '2', type: 'veg', name: 'carrot' },
      { id: '3', type: 'fruit', name: 'banana' },
    ];
    const grouped = groupDataSource(data, 'type', resolveKey);
    const rows = flattenGroupedRows(grouped, resolveKey, {
      expandedRowKeys: new Set(['fruit']),
      flattenMembers,
    });
    expect(rows.map((r) => r.isGroupSection ? `section:${r.groupKey}` : r.record.name)).toEqual([
      'section:fruit',
      'apple',
      'banana',
      'section:veg',
    ]);
  });

  it('组内成员仍支持树形数据（正交能力，分组不影响树形展开）', () => {
    const data = [
      { id: '1', type: 'a', name: 'p1', children: [{ id: '1-1', type: 'a', name: 'c1' }] },
    ];
    const grouped = groupDataSource(data, 'type', resolveKey);
    const rows = flattenGroupedRows(grouped, resolveKey, {
      expandedRowKeys: new Set(['a', '1']),
      flattenMembers: (members) =>
        flattenRows(members, { rowKey: resolveKey, childrenKey: 'children', expandedRowKeys: new Set(['a', '1']), hasExpandedRowRender: false }),
    });
    expect(rows.map((r) => r.isGroupSection ? `section:${r.groupKey}` : r.record.name)).toEqual([
      'section:a',
      'p1',
      'c1',
    ]);
  });
});
