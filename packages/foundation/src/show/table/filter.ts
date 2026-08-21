import type { ColumnDef } from './table-data.js';

export type FilterValue = Array<string | number | boolean>;

export interface FilterState {
  [columnKey: string]: FilterValue;
}

/** 切换某列筛选值集合里的一项：已存在则移除，否则加入（对齐 Semi 多选 OR 语义）。 */
export function toggleFilterValue(current: FilterValue, value: string | number | boolean, multiple: boolean): FilterValue {
  if (!multiple) return current.includes(value) ? [] : [value];
  return current.includes(value) ? current.filter((v) => v !== value) : [...current, value];
}

/**
 * 应用全部列的筛选：每列各自的候选值用 OR 语义（任一候选值匹配即保留），
 * 多列之间用 AND 语义（全部列都要通过），对齐 Semi onFilter 逐值调用的
 * 行为——onFilter(value, record) 对该列 filteredValue 里每个候选值各调用
 * 一次，任一次返回 true 就保留该行。
 */
export function filterData<T = any>(data: T[], columns: ColumnDef<T>[], filterState: FilterState): T[] {
  const activeFilters = columns
    .map((col, i) => ({ col, key: col.key ?? col.dataIndex ?? String(i) }))
    .filter(({ col, key }) => col.onFilter && filterState[key] && filterState[key]!.length > 0);

  if (activeFilters.length === 0) return data;

  return data.filter((record) =>
    activeFilters.every(({ col, key }) => filterState[key]!.some((value) => col.onFilter!(value, record))),
  );
}
