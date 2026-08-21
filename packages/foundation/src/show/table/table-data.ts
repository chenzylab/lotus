/**
 * Table 核心数据结构与列/行处理纯函数。移植自 Semi
 * semi-foundation/table/{foundation.ts,utils.ts,bodyFoundation.ts} 的算法
 * 思路（对齐参考实现 chenzy.design 已验证的双 table 架构设计）。
 *
 * 摊平 props 风格对齐 Semi（expandedRowKeys/rowSelection 等独立顶层字段，
 * 不做 antd 式的 expandable 聚合对象）；行选择只支持 checkbox 多选——
 * Semi 源码没有 radio 单选模式，不臆造。
 */

export type SortOrder = 'ascend' | 'descend' | false;
export type Align = 'left' | 'center' | 'right';
export type FixedSide = 'left' | 'right' | boolean;

export interface FilterOption {
  value: string | number | boolean;
  text: string;
}

export interface ColumnDef<T = any> {
  title?: any;
  dataIndex?: string;
  key?: string;
  width?: number;
  fixed?: FixedSide;
  align?: Align;
  className?: string;
  render?: (text: any, record: T, index: number) => any;
  sorter?: boolean | ((a: T, b: T) => number);
  sortOrder?: SortOrder;
  defaultSortOrder?: SortOrder;
  filters?: FilterOption[];
  filteredValue?: Array<string | number | boolean>;
  defaultFilteredValue?: Array<string | number | boolean>;
  filterMultiple?: boolean;
  onFilter?: (value: string | number | boolean, record: T) => boolean;
  children?: ColumnDef<T>[];
}

/** 取一列的稳定标识：优先 key，否则退回 dataIndex（对齐 Semi getColumnKey）。 */
export function getColumnKey(column: ColumnDef, index: number): string {
  return column.key ?? column.dataIndex ?? String(index);
}

/** 取一行的原始值：支持字符串 dataIndex 直接取字段，也支持缺省时用整行。 */
export function getCellValue<T = any>(record: T, dataIndex: string | undefined): any {
  if (dataIndex === undefined) return record;
  return (record as any)[dataIndex];
}

/** 把多级表头（column.children 嵌套）打平成叶子列的一维数组，供渲染 colgroup/body 用。 */
export function flattenLeafColumns<T = any>(columns: ColumnDef<T>[]): ColumnDef<T>[] {
  const result: ColumnDef<T>[] = [];
  for (const col of columns) {
    if (col.children && col.children.length > 0) {
      result.push(...flattenLeafColumns(col.children));
    } else {
      result.push(col);
    }
  }
  return result;
}

/** 表头行数：多级表头的最大嵌套深度（对齐 Semi 表头分组渲染所需的行数）。 */
export function getHeaderRowCount<T = any>(columns: ColumnDef<T>[]): number {
  let maxDepth = 1;
  for (const col of columns) {
    if (col.children && col.children.length > 0) {
      maxDepth = Math.max(maxDepth, 1 + getHeaderRowCount(col.children));
    }
  }
  return maxDepth;
}

export function resolveRowKey<T = any>(record: T, index: number, rowKey: string | ((record: T) => string | number) | undefined): string | number {
  if (typeof rowKey === 'function') return rowKey(record);
  if (typeof rowKey === 'string') return (record as any)[rowKey] ?? index;
  return (record as any).key ?? index;
}
