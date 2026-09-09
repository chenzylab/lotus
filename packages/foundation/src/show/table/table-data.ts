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
  /** 对齐 Semi ResizableHeaderCellProps.resize：单列关闭列宽调整，默认 true（跟随 Table.resizable 总开关）。 */
  resize?: boolean;
  minWidth?: number;
  maxWidth?: number;
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

/** column.render 返回值里承载 rowSpan/colSpan 的「非法」对象形态（对齐 Semi
 * isInvalidRenderCellText：普通 plain object，不是合法渲染节点也不是字符串/数字/
 * 数组），用于单元格合并——rowSpan/colSpan 为 0 时该格完全不渲染（被前一个
 * rowSpan/colSpan > 1 的格子吞并）。 */
export interface RenderCellObject {
  children: any;
  props?: { rowSpan?: number; colSpan?: number };
}

function isPlainRenderObject(value: any): value is RenderCellObject {
  if (value === null || typeof value !== 'object') return false;
  if (Array.isArray(value)) return false;
  if ('children' in value === false) return false;
  return Object.getPrototypeOf(value) === Object.prototype || Object.getPrototypeOf(value) === null;
}

/** 解析 column.render 的返回值：普通值原样透传（rowSpan/colSpan 都是 1，正常渲染）；
 * `{ children, props: { rowSpan, colSpan } }` 形态拆出跨行/跨列声明。 */
export function resolveRenderCell(value: any): { content: any; rowSpan: number; colSpan: number } {
  if (isPlainRenderObject(value)) {
    return {
      content: value.children,
      rowSpan: value.props?.rowSpan ?? 1,
      colSpan: value.props?.colSpan ?? 1,
    };
  }
  return { content: value, rowSpan: 1, colSpan: 1 };
}

export interface ResolvedCell {
  content: any;
  rowSpan: number;
  colSpan: number;
  /** 被前一行同列的 rowSpan（或前一列同行的 colSpan）吞并，本格完全不渲染。 */
  skip: boolean;
}

/** 对一批可见行（rowSpan 只在「相邻渲染行」之间生效——虚拟滚动截断可见区间后
 * 不追溯窗口外的行，与 Semi 只在真实相邻 DOM 行间做 rowSpan 合并的行为一致）
 * 批量算出每行每列的渲染结果与跳过标记。用二维「剩余跨行计数」网格跟踪每列
 * 还剩几行需要跳过（colSpan 只在本行内向右吞并，不需要跨行状态）。 */
export function resolveRowSpans<T = any>(
  rows: T[],
  leafColumns: ColumnDef<T>[],
  renderValue: (record: T, col: ColumnDef<T>, rowIndex: number, colIndex: number) => any,
): ResolvedCell[][] {
  const pendingRowSpan = new Array(leafColumns.length).fill(0);
  return rows.map((record, rowIndex) => {
    const cells: ResolvedCell[] = [];
    let colIndex = 0;
    while (colIndex < leafColumns.length) {
      const col = leafColumns[colIndex]!;
      if (pendingRowSpan[colIndex] > 0) {
        pendingRowSpan[colIndex] -= 1;
        cells.push({ content: undefined, rowSpan: 1, colSpan: 1, skip: true });
        colIndex += 1;
        continue;
      }
      const resolved = resolveRenderCell(renderValue(record, col, rowIndex, colIndex));
      cells.push({ ...resolved, skip: false });
      if (resolved.rowSpan > 1) pendingRowSpan[colIndex] = resolved.rowSpan - 1;
      for (let c = 1; c < resolved.colSpan; c++) {
        if (colIndex + c < leafColumns.length) cells.push({ content: undefined, rowSpan: 1, colSpan: 1, skip: true });
      }
      colIndex += resolved.colSpan;
    }
    return cells;
  });
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
