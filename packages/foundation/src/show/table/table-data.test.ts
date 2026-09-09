import { describe, it, expect } from 'vitest';
import { getColumnKey, getCellValue, flattenLeafColumns, getHeaderRowCount, resolveRowKey, resolveRenderCell, resolveRowSpans, type ColumnDef } from './table-data.js';

describe('getColumnKey', () => {
  it('优先使用 key', () => {
    expect(getColumnKey({ key: 'k1', dataIndex: 'name' }, 0)).toBe('k1');
  });

  it('key 缺省时用 dataIndex', () => {
    expect(getColumnKey({ dataIndex: 'name' }, 0)).toBe('name');
  });

  it('都缺省时用索引', () => {
    expect(getColumnKey({}, 2)).toBe('2');
  });
});

describe('getCellValue', () => {
  it('dataIndex 存在：取对应字段', () => {
    expect(getCellValue({ name: 'Tom', age: 18 }, 'name')).toBe('Tom');
  });

  it('dataIndex 缺省：返回整行', () => {
    const record = { name: 'Tom' };
    expect(getCellValue(record, undefined)).toBe(record);
  });
});

describe('flattenLeafColumns', () => {
  it('无嵌套：原样返回', () => {
    const columns: ColumnDef[] = [{ dataIndex: 'a' }, { dataIndex: 'b' }];
    expect(flattenLeafColumns(columns)).toEqual(columns);
  });

  it('多级表头：只保留叶子列', () => {
    const columns: ColumnDef[] = [
      { title: '分组', children: [{ dataIndex: 'a' }, { dataIndex: 'b' }] },
      { dataIndex: 'c' },
    ];
    const result = flattenLeafColumns(columns);
    expect(result.map((c) => c.dataIndex)).toEqual(['a', 'b', 'c']);
  });

  it('嵌套多层：递归打平', () => {
    const columns: ColumnDef[] = [
      { title: '外层', children: [{ title: '内层', children: [{ dataIndex: 'x' }] }] },
    ];
    expect(flattenLeafColumns(columns).map((c) => c.dataIndex)).toEqual(['x']);
  });
});

describe('getHeaderRowCount', () => {
  it('无嵌套：1 行', () => {
    expect(getHeaderRowCount([{ dataIndex: 'a' }])).toBe(1);
  });

  it('一层嵌套：2 行', () => {
    expect(getHeaderRowCount([{ title: '分组', children: [{ dataIndex: 'a' }] }])).toBe(2);
  });

  it('多列时取最大深度', () => {
    const columns: ColumnDef[] = [
      { dataIndex: 'a' },
      { title: '分组', children: [{ title: '子分组', children: [{ dataIndex: 'b' }] }] },
    ];
    expect(getHeaderRowCount(columns)).toBe(3);
  });
});

describe('resolveRowKey', () => {
  it('rowKey 为函数：调用取值', () => {
    const record = { id: 'x1' };
    expect(resolveRowKey(record, 0, (r: any) => r.id)).toBe('x1');
  });

  it('rowKey 为字符串：取对应字段', () => {
    expect(resolveRowKey({ id: 'x1' }, 0, 'id')).toBe('x1');
  });

  it('rowKey 未设置：默认取 record.key，缺省回退 index', () => {
    expect(resolveRowKey({ key: 'k1' }, 0, undefined)).toBe('k1');
    expect(resolveRowKey({}, 3, undefined)).toBe(3);
  });
});

describe('resolveRenderCell', () => {
  it('普通值：原样透传，rowSpan/colSpan 都是 1', () => {
    expect(resolveRenderCell('Tom')).toEqual({ content: 'Tom', rowSpan: 1, colSpan: 1 });
    expect(resolveRenderCell(42)).toEqual({ content: 42, rowSpan: 1, colSpan: 1 });
    expect(resolveRenderCell(null)).toEqual({ content: null, rowSpan: 1, colSpan: 1 });
  });

  it('数组：原样透传（不是 rowSpan 声明对象）', () => {
    const arr = ['a', 'b'];
    expect(resolveRenderCell(arr)).toEqual({ content: arr, rowSpan: 1, colSpan: 1 });
  });

  it('{ children, props } 形态：拆出 rowSpan/colSpan', () => {
    expect(resolveRenderCell({ children: 'Tom', props: { rowSpan: 3 } })).toEqual({
      content: 'Tom',
      rowSpan: 3,
      colSpan: 1,
    });
    expect(resolveRenderCell({ children: 'x', props: { rowSpan: 0 } })).toEqual({
      content: 'x',
      rowSpan: 0,
      colSpan: 1,
    });
    expect(resolveRenderCell({ children: 'x', props: { colSpan: 2 } })).toEqual({
      content: 'x',
      rowSpan: 1,
      colSpan: 2,
    });
  });

  it('{ children } 无 props：默认 rowSpan/colSpan 都是 1', () => {
    expect(resolveRenderCell({ children: 'x' })).toEqual({ content: 'x', rowSpan: 1, colSpan: 1 });
  });
});

describe('resolveRowSpans', () => {
  it('无合并：每格 rowSpan/colSpan 都是 1，都不跳过', () => {
    const rows = [{ a: 1 }, { a: 2 }];
    const columns: ColumnDef[] = [{ dataIndex: 'a' }];
    const result = resolveRowSpans(rows, columns, (record: any, col) => (record as any)[col.dataIndex!]);
    expect(result).toEqual([
      [{ content: 1, rowSpan: 1, colSpan: 1, skip: false }],
      [{ content: 2, rowSpan: 1, colSpan: 1, skip: false }],
    ]);
  });

  it('rowSpan 合并：后续行同列标记 skip', () => {
    const rows = [{ g: 'A' }, { g: 'A' }, { g: 'B' }];
    const columns: ColumnDef[] = [{ dataIndex: 'g' }];
    const result = resolveRowSpans(rows, columns, (record: any, _col, rowIndex) => {
      if (record.g === 'A' && rowIndex === 0) return { children: 'A', props: { rowSpan: 2 } };
      if (record.g === 'A') return { children: 'A', props: { rowSpan: 0 } };
      return record.g;
    });
    expect(result[0]![0]).toEqual({ content: 'A', rowSpan: 2, colSpan: 1, skip: false });
    expect(result[1]![0]).toEqual({ content: undefined, rowSpan: 1, colSpan: 1, skip: true });
    expect(result[2]![0]).toEqual({ content: 'B', rowSpan: 1, colSpan: 1, skip: false });
  });

  it('colSpan 合并：本行内向右吞并后续列', () => {
    const rows = [{ a: 1, b: 2, c: 3 }];
    const columns: ColumnDef[] = [{ dataIndex: 'a' }, { dataIndex: 'b' }, { dataIndex: 'c' }];
    const result = resolveRowSpans(rows, columns, (record: any, col) =>
      col.dataIndex === 'a' ? { children: 'merged', props: { colSpan: 2 } } : (record as any)[col.dataIndex!],
    );
    expect(result[0]).toEqual([
      { content: 'merged', rowSpan: 1, colSpan: 2, skip: false },
      { content: undefined, rowSpan: 1, colSpan: 1, skip: true },
      { content: 3, rowSpan: 1, colSpan: 1, skip: false },
    ]);
  });
});
