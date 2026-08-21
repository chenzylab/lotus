import { describe, it, expect } from 'vitest';
import { nextSortOrder, applySortClick, sortData } from './sort.js';
import type { ColumnDef } from './table-data.js';

describe('nextSortOrder', () => {
  it('三态循环：false -> ascend -> descend -> false', () => {
    expect(nextSortOrder(false)).toBe('ascend');
    expect(nextSortOrder('ascend')).toBe('descend');
    expect(nextSortOrder('descend')).toBe(false);
  });
});

describe('applySortClick', () => {
  it('点击目标列推进状态，其它列清空', () => {
    const result = applySortClick({ age: 'ascend' }, 'name');
    expect(result).toEqual({ name: 'ascend' });
  });

  it('再次点击同一列：推进到下一态', () => {
    const result = applySortClick({ name: 'ascend' }, 'name');
    expect(result).toEqual({ name: 'descend' });
  });
});

describe('sortData', () => {
  const data = [{ name: 'Bob', age: 30 }, { name: 'Alice', age: 25 }, { name: 'Carl', age: 20 }];
  const columns: ColumnDef[] = [{ key: 'age', dataIndex: 'age', sorter: (a, b) => a.age - b.age }];

  it('无排序状态：原样返回', () => {
    expect(sortData(data, columns, {})).toEqual(data);
  });

  it('ascend：升序', () => {
    const result = sortData(data, columns, { age: 'ascend' });
    expect(result.map((r) => r.age)).toEqual([20, 25, 30]);
  });

  it('descend：降序', () => {
    const result = sortData(data, columns, { age: 'descend' });
    expect(result.map((r) => r.age)).toEqual([30, 25, 20]);
  });

  it('不修改原数组', () => {
    sortData(data, columns, { age: 'ascend' });
    expect(data.map((r) => r.age)).toEqual([30, 25, 20]);
  });

  it('sorter 不是函数（仅 boolean 占位）：原样返回', () => {
    const cols: ColumnDef[] = [{ key: 'age', dataIndex: 'age', sorter: true }];
    expect(sortData(data, cols, { age: 'ascend' })).toEqual(data);
  });
});
