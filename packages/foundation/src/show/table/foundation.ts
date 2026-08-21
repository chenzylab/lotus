import { Foundation, type Adapter } from '../../base/adapter.js';
import { flattenLeafColumns, resolveRowKey, type ColumnDef } from './table-data.js';
import { applySortClick, sortData, type SortState } from './sort.js';
import { toggleFilterValue, filterData, type FilterState, type FilterValue } from './filter.js';
import {
  buildRowEntities,
  toggleRowSelection,
  syncRowSelection,
  toggleAllRowSelection,
  calcAllSelectedStatus,
  type CheckRelation,
  type SelectionResult,
} from './row-selection.js';
import { flattenRows, toggleExpandedRow, type FlatRow } from './expand.js';
import { calcFixedOffsets, hasFixedColumns, type FixedOffsets } from './fixed-column.js';
import { calcResizedWidth } from './resize-column.js';

export * from './table-data.js';
export * from './sort.js';
export * from './filter.js';
export * from './row-selection.js';
export * from './expand.js';
export * from './fixed-column.js';
export * from './resize-column.js';

export interface TableState<T = any> {
  sortState: SortState;
  filterState: FilterState;
  selectedRowKeys: Set<string>;
  halfSelectedRowKeys: Set<string>;
  expandedRowKeys: Set<string>;
  currentPage: number;
  pageSize: number;
  columnWidths: Record<string, number>;
}

export interface TableFoundationOptions<T = any> {
  rowKey: string | ((record: T, index: number) => string | number);
  childrenKey: string;
  checkRelation: CheckRelation;
  hasExpandedRowRender: boolean;
}

export interface ChangeInfo<T = any> {
  currentPage: number;
  pageSize: number;
  sortState: SortState;
  filterState: FilterState;
}

/**
 * Table 状态机：排序/筛选/行选择/展开行/树形数据/固定列/分页/列宽调整的
 * 统一入口，各算法委托给独立纯函数模块（table-data/sort/filter/
 * row-selection/expand/fixed-column/resize-column）。真正的 DOM 测量
 * （表头/单元格实测宽度）和横向 scrollLeft 同步留给 .tsrx 组件层，
 * Foundation 只做纯状态转换和数据管线（排序→筛选→分页→打平）。
 *
 * 摊平 props 风格对齐 Semi（不做 antd 式 expandable 聚合对象）；行选择
 * 只支持 checkbox 多选；不做方向键单元格导航/roving tabindex——Semi 和
 * 参考实现 chenzy.design 两方都验证过判定不需要（chenzy.design 甚至有
 * 一次"先实现后主动移除"的真实决策记录），维持原生 Tab 序即可，但要
 * 修正 Semi 排序/展开触发器 tabIndex=-1 导致 Tab 不可达的缺口。
 */
export class TableFoundation<T = any> extends Foundation<TableState<T>> {
  private opts: TableFoundationOptions<T>;

  constructor(adapter: Adapter<TableState<T>>, opts: TableFoundationOptions<T>) {
    super(adapter);
    this.opts = opts;
  }

  resolveKey(record: T, index: number): string {
    return String(resolveRowKey(record, index, this.opts.rowKey as any));
  }

  // ===================== 排序 =====================

  handleSortClick(columnKey: string): SortState {
    const { sortState } = this.getState();
    const next = applySortClick(sortState, columnKey);
    this.setState({ sortState: next, currentPage: 1 });
    return next;
  }

  // ===================== 筛选 =====================

  handleFilterToggle(columnKey: string, value: string | number | boolean, multiple: boolean): FilterValue {
    const { filterState } = this.getState();
    const current = filterState[columnKey] ?? [];
    const next = toggleFilterValue(current, value, multiple);
    this.setState({ filterState: { ...filterState, [columnKey]: next }, currentPage: 1 });
    return next;
  }

  // ===================== 数据管线：排序 → 筛选 =====================

  processData(data: T[], columns: ColumnDef<T>[]): T[] {
    const { sortState, filterState } = this.getState();
    const leafColumns = flattenLeafColumns(columns);
    const filtered = filterData(data, leafColumns, filterState);
    return sortData(filtered, leafColumns, sortState);
  }

  // ===================== 分页 =====================

  paginate(data: T[]): { pageData: T[]; total: number } {
    const { currentPage, pageSize } = this.getState();
    const total = data.length;
    const start = (currentPage - 1) * pageSize;
    return { pageData: data.slice(start, start + pageSize), total };
  }

  setCurrentPage(page: number): void {
    this.setState({ currentPage: page });
  }

  setPageSize(pageSize: number): void {
    this.setState({ pageSize, currentPage: 1 });
  }

  // ===================== 行选择 =====================

  toggleRow(record: T, index: number, checked: boolean, allData: T[], isControlled: boolean): SelectionResult {
    const { selectedRowKeys, halfSelectedRowKeys } = this.getState();
    const key = this.resolveKey(record, index);
    const entities = buildRowEntities(allData, (r, i) => this.resolveKey(r, i), this.opts.childrenKey);
    const result = toggleRowSelection(key, checked, { selectedRowKeys, halfSelectedRowKeys }, this.opts.checkRelation, entities);
    if (!isControlled) this.setState({ selectedRowKeys: result.selectedRowKeys, halfSelectedRowKeys: result.halfSelectedRowKeys });
    return result;
  }

  toggleAllRows(visibleData: T[], wantAllChecked: boolean, isControlled: boolean, disabledKeys: Set<string> = new Set()): Set<string> {
    const { selectedRowKeys } = this.getState();
    const visibleKeys = visibleData.map((r, i) => this.resolveKey(r, i));
    const next = toggleAllRowSelection(visibleKeys, disabledKeys, wantAllChecked, selectedRowKeys);
    if (!isControlled) this.setState({ selectedRowKeys: next });
    return next;
  }

  getAllSelectedStatus(visibleData: T[], disabledKeys: Set<string> = new Set()): { allChecked: boolean; hasSelectable: boolean } {
    const { selectedRowKeys } = this.getState();
    const visibleKeys = visibleData.map((r, i) => this.resolveKey(r, i));
    return calcAllSelectedStatus(visibleKeys, disabledKeys, selectedRowKeys);
  }

  syncSelectedRowKeys(keys: Array<string | number>, allData: T[]): void {
    const entities = buildRowEntities(allData, (r, i) => this.resolveKey(r, i), this.opts.childrenKey);
    const result = syncRowSelection(keys.map(String), this.opts.checkRelation, entities);
    this.setState({ selectedRowKeys: result.selectedRowKeys, halfSelectedRowKeys: result.halfSelectedRowKeys });
  }

  // ===================== 展开行 / 树形数据 =====================

  flattenForRender(data: T[]): FlatRow<T>[] {
    const { expandedRowKeys } = this.getState();
    return flattenRows(data, {
      rowKey: (r, i) => this.resolveKey(r, i),
      childrenKey: this.opts.childrenKey,
      expandedRowKeys,
      hasExpandedRowRender: this.opts.hasExpandedRowRender,
    });
  }

  toggleExpand(key: string, isControlled: boolean): Set<string> {
    const { expandedRowKeys } = this.getState();
    const next = toggleExpandedRow(expandedRowKeys, key);
    if (!isControlled) this.setState({ expandedRowKeys: next });
    return next;
  }

  syncExpandedRowKeys(keys: string[]): void {
    this.setState({ expandedRowKeys: new Set(keys) });
  }

  // ===================== 固定列 =====================

  getFixedOffsets(columns: ColumnDef<T>[], widths: number[]): FixedOffsets {
    return calcFixedOffsets(columns, widths);
  }

  static hasFixedColumns<T = any>(columns: ColumnDef<T>[]): boolean {
    return hasFixedColumns(columns);
  }

  // ===================== 列宽调整 =====================

  resizeColumn(columnKey: string, startWidth: number, deltaX: number, minWidth?: number, maxWidth?: number): number {
    const width = calcResizedWidth(startWidth, deltaX, minWidth, maxWidth);
    const { columnWidths } = this.getState();
    this.setState({ columnWidths: { ...columnWidths, [columnKey]: width } });
    return width;
  }

  // ===================== 统一 onChange 聚合信息 =====================

  getChangeInfo(): ChangeInfo<T> {
    const { currentPage, pageSize, sortState, filterState } = this.getState();
    return { currentPage, pageSize, sortState, filterState };
  }
}
