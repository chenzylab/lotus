import { describe, it, expect } from 'vitest';
import { getColumnKey, getCellValue, flattenLeafColumns, getHeaderRowCount, resolveRowKey, type ColumnDef } from './table-data.js';

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
