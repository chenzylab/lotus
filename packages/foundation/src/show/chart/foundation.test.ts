import { describe, it, expect } from 'vitest';
import { resolveChartSpec, isChartDataEmpty } from './foundation.js';

describe('resolveChartSpec', () => {
  it('组装 type/data 与透传 spec 字段', () => {
    const result = resolveChartSpec({
      type: 'bar',
      data: [{ id: 'id0', values: [{ x: 'a', y: 1 }] }],
      spec: { xField: 'x', yField: 'y', title: { text: '标题' } },
    });
    expect(result.type).toBe('bar');
    expect(result.data).toEqual([{ id: 'id0', values: [{ x: 'a', y: 1 }] }]);
    expect(result.xField).toBe('x');
    expect(result.title).toEqual({ text: '标题' });
  });

  it('spec 里同名 type/data 字段不会覆盖显式 props', () => {
    const result = resolveChartSpec({
      type: 'line',
      data: [{ id: 'id0', values: [] }],
      spec: { type: 'pie', data: [{ id: 'evil', values: [] }] } as any,
    });
    expect(result.type).toBe('line');
    expect(result.data).toEqual([{ id: 'id0', values: [] }]);
  });

  it('不传 spec 时只组装 type/data', () => {
    const result = resolveChartSpec({ type: 'pie', data: [] });
    expect(result).toEqual({ type: 'pie', data: [] });
  });
});

describe('isChartDataEmpty', () => {
  it('data 为空数组时判定为空', () => {
    expect(isChartDataEmpty([])).toBe(true);
  });

  it('所有数据系列的 values 都为空数组时判定为空', () => {
    expect(isChartDataEmpty([{ id: 'a', values: [] }, { id: 'b', values: [] }])).toBe(true);
  });

  it('任一数据系列的 values 非空时判定为非空', () => {
    expect(isChartDataEmpty([{ id: 'a', values: [] }, { id: 'b', values: [{ x: 1 }] }])).toBe(false);
  });

  it('单一数据系列有值时判定为非空', () => {
    expect(isChartDataEmpty([{ id: 'a', values: [{ x: 1, y: 2 }] }])).toBe(false);
  });
});
