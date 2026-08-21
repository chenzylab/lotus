import { describe, it, expect } from 'vitest';
import { calcFixedOffsets, hasFixedColumns } from './fixed-column.js';
import type { ColumnDef } from './table-data.js';

describe('calcFixedOffsets', () => {
  it('无固定列：全部为 null', () => {
    const columns: ColumnDef[] = [{ dataIndex: 'a' }, { dataIndex: 'b' }];
    const result = calcFixedOffsets(columns, [100, 100]);
    expect(result.left).toEqual([null, null]);
    expect(result.right).toEqual([null, null]);
  });

  it('左固定列：累加前面列宽度', () => {
    const columns: ColumnDef[] = [{ fixed: 'left' }, { fixed: 'left' }, { dataIndex: 'c' }];
    const result = calcFixedOffsets(columns, [100, 80, 120]);
    expect(result.left).toEqual([0, 100, null]);
  });

  it('右固定列：从右往左累加', () => {
    const columns: ColumnDef[] = [{ dataIndex: 'a' }, { fixed: 'right' }, { fixed: 'right' }];
    const result = calcFixedOffsets(columns, [100, 80, 60]);
    expect(result.right).toEqual([null, 60, 0]);
  });

  it('左右固定列混合', () => {
    const columns: ColumnDef[] = [{ fixed: 'left' }, { dataIndex: 'b' }, { fixed: 'right' }];
    const result = calcFixedOffsets(columns, [100, 200, 80]);
    expect(result.left).toEqual([0, null, null]);
    expect(result.right).toEqual([null, null, 0]);
  });

  it('固定列不连续（中断后不再累加，对齐 Semi 从边界向内扫描直到第一个非固定列为止）', () => {
    const columns: ColumnDef[] = [{ fixed: 'left' }, { dataIndex: 'b' }, { fixed: 'left' }];
    const result = calcFixedOffsets(columns, [100, 200, 80]);
    expect(result.left).toEqual([0, null, null]);
  });
});

describe('hasFixedColumns', () => {
  it('无固定列：false', () => {
    expect(hasFixedColumns([{ dataIndex: 'a' }])).toBe(false);
  });

  it('有固定列：true', () => {
    expect(hasFixedColumns([{ dataIndex: 'a', fixed: 'left' }])).toBe(true);
  });
});
