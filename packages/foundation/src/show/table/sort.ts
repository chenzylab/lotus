import type { ColumnDef, SortOrder } from './table-data.js';

/**
 * 单列排序循环：ascend → descend → false，对齐 Semi SORT_DIRECTIONS 三态
 * 循环。点击某列排序时，其它列的排序态强制清空——Semi 交互上只支持单列
 * 排序（多列排序只能靠编程式受控叠加多个 sortOrder，不能通过连续点击
 * 累加，调研已核实），lotus 忠实对齐这个真实行为。
 */
const SORT_CYCLE: SortOrder[] = ['ascend', 'descend', false];

export function nextSortOrder(current: SortOrder): SortOrder {
  const idx = SORT_CYCLE.indexOf(current);
  return SORT_CYCLE[(idx + 1) % SORT_CYCLE.length]!;
}

export interface SortState {
  [columnKey: string]: SortOrder;
}

/** 点击某列排序：目标列推进到下一个排序态，其它列清空。 */
export function applySortClick(sortState: SortState, columnKey: string): SortState {
  const next: SortState = {};
  const current = sortState[columnKey] ?? false;
  next[columnKey] = nextSortOrder(current);
  return next;
}

/** 根据当前排序态对数据排序；sortOrder=false 或 sorter 未定义时原样返回。 */
export function sortData<T = any>(
  data: T[],
  columns: ColumnDef<T>[],
  sortState: SortState,
): T[] {
  const activeColumn = columns.find((col, i) => {
    const key = col.key ?? col.dataIndex ?? String(i);
    return sortState[key] && typeof col.sorter === 'function';
  });
  if (!activeColumn || typeof activeColumn.sorter !== 'function') return data;
  const key = activeColumn.key ?? activeColumn.dataIndex ?? '';
  const order = sortState[key];
  if (!order) return data;
  const sorted = [...data].sort(activeColumn.sorter);
  return order === 'ascend' ? sorted : sorted.reverse();
}
