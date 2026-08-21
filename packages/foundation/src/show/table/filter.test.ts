import { describe, it, expect } from 'vitest';
import { toggleFilterValue, filterData } from './filter.js';
import type { ColumnDef } from './table-data.js';

describe('toggleFilterValue', () => {
  it('multiple=true：追加不存在的值', () => {
    expect(toggleFilterValue([], 'a', true)).toEqual(['a']);
    expect(toggleFilterValue(['a'], 'b', true)).toEqual(['a', 'b']);
  });

  it('multiple=true：移除已存在的值', () => {
    expect(toggleFilterValue(['a', 'b'], 'a', true)).toEqual(['b']);
  });

  it('multiple=false：单选切换，重复点击清空', () => {
    expect(toggleFilterValue([], 'a', false)).toEqual(['a']);
    expect(toggleFilterValue(['a'], 'a', false)).toEqual([]);
    expect(toggleFilterValue(['a'], 'b', false)).toEqual(['b']);
  });
});

describe('filterData', () => {
  const data = [
    { name: 'Alice', dept: 'eng' },
    { name: 'Bob', dept: 'sales' },
    { name: 'Carl', dept: 'eng' },
  ];
  const columns: ColumnDef[] = [
    { key: 'dept', dataIndex: 'dept', onFilter: (value, record) => record.dept === value },
  ];

  it('无筛选状态：原样返回', () => {
    expect(filterData(data, columns, {})).toEqual(data);
  });

  it('单值筛选：只保留匹配行', () => {
    const result = filterData(data, columns, { dept: ['eng'] });
    expect(result.map((r) => r.name)).toEqual(['Alice', 'Carl']);
  });

  it('多值筛选同列：OR 语义', () => {
    const result = filterData(data, columns, { dept: ['eng', 'sales'] });
    expect(result).toHaveLength(3);
  });

  it('多列筛选：AND 语义', () => {
    const cols: ColumnDef[] = [
      { key: 'dept', dataIndex: 'dept', onFilter: (v, r) => r.dept === v },
      { key: 'name', dataIndex: 'name', onFilter: (v, r) => r.name === v },
    ];
    const result = filterData(data, cols, { dept: ['eng'], name: ['Alice'] });
    expect(result.map((r) => r.name)).toEqual(['Alice']);
  });

  it('空数组筛选值：视为未激活该列筛选', () => {
    expect(filterData(data, columns, { dept: [] })).toEqual(data);
  });
});
