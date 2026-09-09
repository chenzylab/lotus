import { track, effect, untrack } from 'ripple';
import {
    TableFoundation,
    flattenLeafColumns,
    getColumnKey,
    getCellValue,
    resolveRenderCell,
    getHeaderRowCount,
    sortData,
    filterData,
    flattenRows,
    calcAllSelectedStatus,
    calcFixedOffsets,
    hasFixedColumns,
    resolveRowSpans,
    groupDataSource,
    flattenGroupedRows,
    resolveRowKey,
    type ResolvedCell,
    type TableState,
    type ColumnDef,
    type SortOrder,
    type FlatRow,
    type ChangeInfo,
    type FixedOffsets,
} from '@lotus/foundation/show/table';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { Checkbox } from '../../input/checkbox/index.tsrx';
import { Spin } from '../../feedback/spin/index.tsrx';
import { Empty } from '../empty/index.tsrx';
import { Pagination, type PaginationProps } from '../../navigation/pagination/index.tsrx';
import { Popover } from '../popover/index.tsrx';
import { IconCaretup, IconCaretdown, IconFilter, IconChevronRight } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ColumnDef, SortOrder };

export interface TableRowSelection<T = any> {
    selectedRowKeys?: Array<string | number>;
    onChange?: (selectedRowKeys: Array<string | number>, selectedRows: T[]) => void;
    onSelect?: (record: T, selected: boolean, selectedRows: T[]) => void;
    onSelectAll?: (selected: boolean, selectedRows: T[]) => void;
    getCheckboxProps?: (record: T) => { disabled?: boolean };
    checkStrictly?: boolean;
    fixed?: boolean;
}

export interface TableExpandable<T = any> {
    expandedRowRender?: (record: T, index: number) => any;
    expandedRowKeys?: Array<string | number>;
    defaultExpandedRowKeys?: Array<string | number>;
    onExpand?: (expanded: boolean, record: T) => void;
    onExpandedRowsChange?: (expandedRowKeys: Array<string | number>) => void;
    rowExpandable?: (record: T) => boolean;
}

export type TableSize = 'default' | 'middle' | 'small';

export interface TableProps<T = any> {
    columns: ColumnDef<T>[];
    dataSource?: T[];
    rowKey?: string | ((record: T, index: number) => string | number);
    childrenRecordName?: string;
    loading?: boolean;
    bordered?: boolean;
    size?: TableSize;
    scroll?: { x?: number | string; y?: number | string };
    pagination?: boolean | (Partial<PaginationProps> & { position?: 'top' | 'bottom' | 'both' });
    rowSelection?: TableRowSelection<T>;
    expandRowByClick?: boolean;
    hideExpandedColumn?: boolean;
    rowExpandable?: (record: T) => boolean;
    expandedRowRender?: (record: T, index: number) => any;
    expandedRowKeys?: Array<string | number>;
    defaultExpandedRowKeys?: Array<string | number>;
    onExpand?: (expanded: boolean, record: T) => void;
    onExpandedRowsChange?: (expandedRowKeys: Array<string | number>) => void;
    onChange?: (info: ChangeInfo & { pagination: { currentPage: number; pageSize: number } }) => void;
    onRow?: (record: T, index: number) => Record<string, any>;
    onHeaderRow?: (columns: ColumnDef<T>[], index: number) => Record<string, any>;
    empty?: any;
    title?: () => any;
    footer?: () => any;
    virtualize?: { itemSize: number };
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
    showHeader?: boolean;
    indentSize?: number;
    sticky?: boolean | { top?: number };
    resizable?: boolean | {
        onResize?: (column: ColumnDef<T>) => void;
        onResizeStart?: (column: ColumnDef<T>) => void;
        onResizeStop?: (column: ColumnDef<T>) => void;
    };
    /** hover 合并单元格（rowSpan > 1）时联动高亮所有被跨越的行。 */
    rowSpanHover?: boolean;
    /** 收起的子行/展开内容是否仍保留 DOM（视觉隐藏而非不渲染），避免反复挂载卸载丢状态。 */
    keepDOM?: boolean;
    groupBy?: string | ((record: T) => string | number);
    renderGroupSection?: (groupKey: string, group: string[]) => any | { children: any; [key: string]: any };
    onGroupedRow?: (record: T | undefined, index: number) => Record<string, any>;
    clickGroupedRowToExpand?: boolean;
    defaultExpandAllGroupRows?: boolean;
    expandAllGroupRows?: boolean;
}

function toKeySet(v: Array<string | number> | undefined): Set<string> {
    const arr: string[] = (v ?? []).map(String);
    return new Set(arr);
}

/** 表头网格：把多级 columns.children 铺成 行×格 的二维数组，叶子列的 rowSpan 补齐到总行数。 */
interface HeaderCell<T = any> {
    column: ColumnDef<T>;
    colSpan: number;
    rowSpan: number;
    isLeaf: boolean;
}

function countLeaves<T = any>(col: ColumnDef<T>): number {
    if (!col.children || col.children.length === 0) return 1;
    return col.children.reduce((sum, c) => sum + countLeaves(c), 0);
}

function buildHeaderRows<T = any>(columns: ColumnDef<T>[], totalRows: number): HeaderCell<T>[][] {
    const rows: HeaderCell<T>[][] = Array.from({ length: totalRows }, () => []);
    function walk(cols: ColumnDef<T>[], depth: number) {
        for (const col of cols) {
            if (col.children && col.children.length > 0) {
                rows[depth]!.push({ column: col, colSpan: countLeaves(col), rowSpan: 1, isLeaf: false });
                walk(col.children, depth + 1);
            } else {
                rows[depth]!.push({ column: col, colSpan: 1, rowSpan: totalRows - depth, isLeaf: true });
            }
        }
    }
    walk(columns, 0);
    return rows;
}

/** 排序图标：升序/降序两个小三角，当前生效方向高亮。 */
function SortIcon(&{ order }: { order: SortOrder }) @{
    <span class="lotus-table-sort-icons">
        <IconCaretup class={order === 'ascend' ? 'lotus-table-sort-icon-active' : 'lotus-table-sort-icon'} />
        <IconCaretdown class={order === 'descend' ? 'lotus-table-sort-icon-active' : 'lotus-table-sort-icon'} />
    </span>
}

interface TableRowProps<T = any> {
    flat: FlatRow<T>;
    leafColumns: ColumnDef<T>[];
    resolvedCells: ResolvedCell[] | undefined;
    rowSelection: TableRowSelection<T> | undefined;
    showExpandColumn: boolean;
    hasExpandedRowRender: boolean;
    rowExpandable: ((record: T) => boolean) | undefined;
    expandedRowRender: ((record: T, index: number) => any) | undefined;
    expandRowByClick: boolean;
    selected: boolean;
    halfSelected: boolean;
    disabled: boolean;
    expanded: boolean;
    onRow: ((record: T, index: number) => Record<string, any>) | undefined;
    onRowToggle: (record: T, index: number, checked: boolean) => void;
    onExpandToggle: (key: string, record: T) => void;
    fixedCellStyle: (index: number) => Record<string, any> | undefined;
    fixedCellClass: (index: number) => string;
    indentSize: number;
    onRowHover: ((isHover: boolean, rowKey: string) => void) | undefined;
    renderGroupSection: ((groupKey: string, group: string[]) => any) | undefined;
    onGroupedRow: ((record: any, index: number) => Record<string, any>) | undefined;
    clickGroupedRowToExpand: boolean;
    groupExpanded: boolean;
    onGroupToggle: ((groupKey: string) => void) | undefined;
}

/** 单行 `<tr>` 的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用，避免
 * 重复维护 selection/expand/普通列三段拼装逻辑。 */
function TableRow<T = any>(&{
    flat,
    leafColumns,
    resolvedCells,
    rowSelection,
    showExpandColumn,
    hasExpandedRowRender,
    rowExpandable,
    expandedRowRender,
    expandRowByClick,
    selected,
    halfSelected,
    disabled,
    expanded,
    onRow,
    onRowToggle,
    onExpandToggle,
    fixedCellStyle,
    fixedCellClass,
    indentSize,
    onRowHover,
    renderGroupSection,
    onGroupedRow,
    clickGroupedRowToExpand,
    groupExpanded,
    onGroupToggle,
}: TableRowProps<T>) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    @if (flat.isGroupSection) {
        <tr
            class={['lotus-table-row-section', groupExpanded ? 'lotus-table-row-section-open' : ''].filter(Boolean).join(' ')}
            role="row"
            aria-expanded={groupExpanded}
            {...(onGroupedRow ? onGroupedRow(undefined, 0) : {})}
            onClick={(e: MouseEvent) => { if (clickGroupedRowToExpand) onGroupToggle?.(flat.groupKey!); }}
        >
            <td
                class="lotus-table-cell lotus-table-section-cell"
                colSpan={leafColumns.length + (rowSelection ? 1 : 0) + (showExpandColumn ? 1 : 0)}
            >
                <span class="lotus-table-section-inner">
                    <span
                        class={['lotus-table-expand-btn', groupExpanded ? 'lotus-table-expand-btn-open' : ''].filter(Boolean).join(' ')}
                        tabIndex={0}
                        role="button"
                        onClick={(e: MouseEvent) => { e.stopPropagation(); onGroupToggle?.(flat.groupKey!); }}
                        onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); e.stopPropagation(); onGroupToggle?.(flat.groupKey!); } }}
                    >
                        <IconChevronRight />
                    </span>
                    {renderGroupSection ? resolveRenderCell(renderGroupSection(flat.groupKey!, [])).content : flat.groupKey}
                </span>
            </td>
        </tr>
    } @else {
        @if (flat.isExpandedContent) {
            <tr class="lotus-table-expanded-row" role="row" style={flat.displayNone ? { display: 'none' } : undefined}>
                <td
                    class="lotus-table-cell lotus-table-expanded-cell"
                    colSpan={leafColumns.length + (rowSelection ? 1 : 0) + (showExpandColumn ? 1 : 0)}
                >
                    {expandedRowRender?.(flat.record, 0)}
                </td>
            </tr>
        } @else {
            <tr
                class={['lotus-table-row', flat.level > 0 ? 'lotus-table-row-child' : ''].filter(Boolean).join(' ')}
                role="row"
                data-row-key={flat.key}
                aria-expanded={(flat.hasChildren || (hasExpandedRowRender && (!rowExpandable || rowExpandable(flat.record)))) ? expanded : undefined}
                style={flat.displayNone ? { display: 'none' } : undefined}
                onMouseEnter={() => onRowHover?.(true, flat.key)}
                onMouseLeave={() => onRowHover?.(false, flat.key)}
                {...(onRow ? onRow(flat.record, 0) : {})}
            >
                @if (rowSelection) {
                    <td class="lotus-table-cell lotus-table-selection-cell">
                        @if (!disabled) {
                            <Checkbox
                                checked={selected}
                                indeterminate={halfSelected}
                                onChange={(checked: boolean) => onRowToggle(flat.record, 0, checked)}
                                aria-label={locale.Table.selectRow}
                            />
                        }
                    </td>
                }
                @if (showExpandColumn) {
                    <td class="lotus-table-cell lotus-table-expand-cell" style={flat.level > 0 ? { paddingLeft: `${flat.level * indentSize}px` } : undefined}>
                        @if (flat.hasChildren || (hasExpandedRowRender && (!rowExpandable || rowExpandable(flat.record)))) {
                            <span
                                class={['lotus-table-expand-btn', expanded ? 'lotus-table-expand-btn-open' : ''].filter(Boolean).join(' ')}
                                tabIndex={0}
                                role="button"
                                onClick={() => onExpandToggle(flat.key, flat.record)}
                                onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onExpandToggle(flat.key, flat.record); } }}
                            >
                                <IconChevronRight />
                            </span>
                        }
                    </td>
                }
                @for (const col of leafColumns; index colIndex) {
                    @if (!resolvedCells || !resolvedCells[colIndex]?.skip) {
                        <td
                            class={['lotus-table-cell', col.align ? `lotus-table-align-${col.align}` : '', col.className ?? '', fixedCellClass(colIndex)].filter(Boolean).join(' ')}
                            role="gridcell"
                            style={fixedCellStyle(colIndex)}
                            rowSpan={resolvedCells && resolvedCells[colIndex]!.rowSpan > 1 ? resolvedCells[colIndex]!.rowSpan : undefined}
                            colSpan={resolvedCells && resolvedCells[colIndex]!.colSpan > 1 ? resolvedCells[colIndex]!.colSpan : undefined}
                            onClick={() => { if (expandRowByClick && (flat.hasChildren || hasExpandedRowRender)) onExpandToggle(flat.key, flat.record); }}
                        >
                            {resolvedCells ? resolvedCells[colIndex]!.content : (col.render ? col.render(getCellValue(flat.record, col.dataIndex), flat.record, 0) : getCellValue(flat.record, col.dataIndex))}
                        </td>
                    }
                }
            </tr>
        }
    }

    <style>
        .lotus-table-cell {
            padding: 12px 16px;
            text-align: start;
            border-bottom: 1px solid var(--lotus-color-border);
            box-sizing: border-box;
        }

        .lotus-table-size-middle .lotus-table-cell {
            padding: 8px 16px;
        }

        .lotus-table-size-small .lotus-table-cell {
            padding: 4px 12px;
        }

        .lotus-table-bordered .lotus-table-cell {
            border-inline-end: 1px solid var(--lotus-color-border);
        }

        .lotus-table-bordered .lotus-table-cell:last-child {
            border-inline-end: none;
        }

        .lotus-table-align-left { text-align: left; }
        .lotus-table-align-center { text-align: center; }
        .lotus-table-align-right { text-align: right; }

        .lotus-table-row:hover .lotus-table-cell,
        .lotus-table-row-hovered .lotus-table-cell {
            background: var(--lotus-color-fill-0);
        }

        .lotus-table-selection-cell,
        .lotus-table-expand-cell {
            width: 1%;
            white-space: nowrap;
        }

        .lotus-table-expand-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 16px;
            height: 16px;
            cursor: pointer;
            transition: transform 0.2s ease;
            color: var(--lotus-color-text-2);
        }

        .lotus-table-expand-btn-open {
            transform: rotate(90deg);
        }

        .lotus-table-row-child .lotus-table-cell:first-of-type {
            color: var(--lotus-color-text-1);
        }

        .lotus-table-expanded-row .lotus-table-expanded-cell {
            background: var(--lotus-color-fill-0);
        }

        .lotus-table-row-section {
            cursor: pointer;
        }

        .lotus-table-row-section .lotus-table-section-cell {
            background: var(--lotus-color-fill-0);
            font-weight: 600;
        }

        .lotus-table-section-inner {
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .lotus-table-cell-fixed {
            background: var(--lotus-color-bg-1);
        }

        .lotus-table-row:hover .lotus-table-cell-fixed {
            background: var(--lotus-color-fill-0);
        }

        .lotus-table-cell-fixed-left-last {
            box-shadow: 4px 0 8px -4px rgba(0, 0, 0, 0.12);
        }

        .lotus-table-cell-fixed-right-first {
            box-shadow: -4px 0 8px -4px rgba(0, 0, 0, 0.12);
        }
    </style>
    </>
}

/**
 * Table：单 table 架构（本期不含固定表头/固定列的双 table 架构、列宽
 * 调整——这些在后续迭代中叠加）。数据管线（排序 → 筛选 → 分页）与行
 * 选择/展开/树形三态级联全部委托给 TableFoundation，组件层只做 DOM
 * 渲染与事件转发。多级表头用 buildHeaderRows 摊平成行×格网格再渲染，
 * 叶子列的 rowSpan 补齐到表头总行数（对齐 Semi 的分组表头渲染）。
 * 全面验收审计后补充：新增 `virtualize?: { itemSize }` prop，仅在同时声明
 * `scroll.y`（固定容器高度）且没有 `expandedRowRender`（展开行内容任意
 * 高度，与固定行高假设冲突）时生效——`flatRows` 已经是 Foundation 层把
 * 树形展开态摊平好的定长数组（与 TreeSelect 的 flatNodes 同一模式），直接
 * 复用 `base/virtual-list.ts` 做区间截取；HTML `<table>` 不能像 Select/
 * TreeSelect 那样在容器内嵌一层 `translateY` 的 div 包裹可见区间（`<tbody>`
 * 只能直接包含 `<tr>`），改用两个高度分别为 offsetY / 剩余总高度的占位
 * `<tr>` 撑开滚动条长度，模拟"可见区间之外的行仍占据布局空间"的效果；
 * 调研 Semi 源码确认其虚拟滚动用 react-window 的 VariableSizeList 整体
 * 替换 tbody，固定列（若声明）靠 CSS position:sticky 与滚动内容同属
 * 一行 `<tr>` 天然对齐、不需要独立同步机制——但 lotus 当前 Table 的
 * `fixed` 列配置本身也是从未实现的死 prop，本次不需要处理固定列共存。
 */
export function Table<T = any>(&{
    columns,
    dataSource = [],
    rowKey = 'key',
    childrenRecordName = 'children',
    loading = false,
    bordered = false,
    size = 'default',
    scroll,
    pagination = true,
    rowSelection,
    expandRowByClick = false,
    hideExpandedColumn = false,
    rowExpandable,
    expandedRowRender,
    expandedRowKeys: expandedRowKeysProp,
    defaultExpandedRowKeys,
    onExpand,
    onExpandedRowsChange,
    onChange,
    onRow,
    onHeaderRow,
    empty,
    title,
    footer,
    virtualize,
    style,
    class: className,
    'aria-label': ariaLabel,
    showHeader = true,
    indentSize = 20,
    sticky,
    resizable,
    rowSpanHover = false,
    keepDOM = false,
    groupBy,
    renderGroupSection,
    onGroupedRow,
    clickGroupedRowToExpand = false,
    defaultExpandAllGroupRows = false,
    expandAllGroupRows,
}: TableProps<T>) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isSelectionControlled = rowSelection?.selectedRowKeys !== undefined;
    const isExpandControlled = expandedRowKeysProp !== undefined;
    const hasExpandedRowRender = expandedRowRender !== undefined;

    const paginationOpts = pagination === true ? {} : pagination === false ? null : pagination;
    const initialPageSize = paginationOpts?.pageSize ?? 10;
    const initialPage = paginationOpts?.currentPage ?? paginationOpts?.defaultCurrentPage ?? 1;

    const isGroupExpandControlled = expandAllGroupRows !== undefined;

    function computeInitialGroupKeys(): string[] {
        if (!groupBy) return [];
        const grouped = groupDataSource(dataSource, groupBy, (r, i) => resolveRowKey(r, i, rowKey as any) as any as string);
        return grouped.groupKeys;
    }

    const initialExpandedRowKeys = new Set(toKeySet(expandedRowKeysProp ?? defaultExpandedRowKeys));
    if (groupBy && (expandAllGroupRows ?? defaultExpandAllGroupRows)) {
        computeInitialGroupKeys().forEach((k) => initialExpandedRowKeys.add(k));
    }

    let &[state] = track<TableState<T>>({
        sortState: {},
        filterState: {},
        selectedRowKeys: toKeySet(rowSelection?.selectedRowKeys),
        halfSelectedRowKeys: new Set<string>(),
        expandedRowKeys: initialExpandedRowKeys,
        currentPage: initialPage,
        pageSize: initialPageSize,
        columnWidths: {},
    });

    const foundation = new TableFoundation<T>(
        {
            getState: () => untrack(() => state),
            setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
        },
        {
            rowKey,
            childrenKey: childrenRecordName,
            checkRelation: rowSelection?.checkStrictly ? 'unRelated' : 'related',
            hasExpandedRowRender,
        },
    );

    effect(() => {
        if (rowSelection?.selectedRowKeys !== undefined) {
            untrack(() => foundation.syncSelectedRowKeys(rowSelection.selectedRowKeys!, dataSource));
        }
    });

    effect(() => {
        if (expandedRowKeysProp !== undefined) {
            untrack(() => foundation.syncExpandedRowKeys(expandedRowKeysProp.map(String)));
        }
    });

    effect(() => {
        if (!groupBy || expandAllGroupRows === undefined) return;
        const wantExpanded = expandAllGroupRows;
        const groupKeys = computeInitialGroupKeys();
        const next = new Set(untrack(() => state).expandedRowKeys);
        if (wantExpanded) {
            groupKeys.forEach((k) => next.add(k));
        } else {
            groupKeys.forEach((k) => next.delete(k));
        }
        untrack(() => { state = { ...untrack(() => state), expandedRowKeys: next }; });
    });

    let &[openFilterKey] = track<string | null>(null);
    let &[draftFilterValues] = track<Array<string | number | boolean>>([]);

    // rowSpanHover：hover 时纯 DOM 查询计算需要联动高亮的行 key 集合（跨行合并
    // 单元格靠 <td rowspan> 声明，同一 rowspan 覆盖的所有 <tr> 都要高亮），不
    // 走响应式 state——这是 hover 期间的高频瞬态交互，直接操作 DOM class 比
    // 触发整棵响应式树重算更轻量（对齐 Semi rowSpanHover 的纯 DOM 实现）。
    let tbodyNode: HTMLElement | null = null;
    let hoveredRowKeys: Set<string> = new Set();

    function updateRowHoverClass(nextKeys: string[]) {
        const tbody = tbodyNode;
        if (!tbody) { hoveredRowKeys.clear(); return; }
        const nextSet = new Set(nextKeys);
        for (const key of hoveredRowKeys) {
            if (!nextSet.has(key)) {
                tbody.querySelectorAll(`tr[data-row-key="${CSS.escape(key)}"]`).forEach((r) => r.classList.remove('lotus-table-row-hovered'));
            }
        }
        for (const key of nextSet) {
            if (!hoveredRowKeys.has(key)) {
                tbody.querySelectorAll(`tr[data-row-key="${CSS.escape(key)}"]`).forEach((r) => r.classList.add('lotus-table-row-hovered'));
            }
        }
        hoveredRowKeys = nextSet;
    }

    function getHoveredRowKeysFromDOM(currentRowKey: string): string[] {
        const keys = new Set<string>([currentRowKey]);
        const tbody = tbodyNode;
        if (!tbody) return Array.from(keys);
        const currentRow = tbody.querySelector(`tr[data-row-key="${CSS.escape(currentRowKey)}"]`);
        if (!currentRow) return Array.from(keys);
        const allRows = Array.from(tbody.querySelectorAll('tr[data-row-key]'));
        const currentIndex = allRows.indexOf(currentRow);
        if (currentIndex === -1) return Array.from(keys);
        allRows.forEach((row, rowIndex) => {
            row.querySelectorAll('td[rowspan]').forEach((cell) => {
                const span = parseInt(cell.getAttribute('rowspan') || '1', 10);
                if (span <= 1) return;
                const endIndex = rowIndex + span - 1;
                if (currentIndex < rowIndex || currentIndex > endIndex) return;
                allRows.slice(rowIndex, endIndex + 1).forEach((spannedRow) => {
                    const spannedKey = spannedRow.getAttribute('data-row-key');
                    if (spannedKey) keys.add(spannedKey);
                });
            });
        });
        return Array.from(keys);
    }

    function handleRowHover(isHover: boolean, rowKey: string) {
        if (!rowSpanHover) return;
        if (isHover) {
            updateRowHoverClass(getHoveredRowKeysFromDOM(rowKey));
        } else {
            updateRowHoverClass([]);
        }
    }

    let &[leafColumns] = track<ColumnDef<T>[]>(() => flattenLeafColumns(columns));
    let &[headerRowCount] = track<number>(() => getHeaderRowCount(columns));
    let &[headerRows] = track<HeaderCell<T>[][]>(() => buildHeaderRows(columns, headerRowCount));

    // 固定列偏移量计算：Semi 的做法是给固定列单元格手动写 style.left/right
    // （不是纯 CSS position:sticky 一步到位），偏移量是"同侧固定列的实测宽度
    // 累加"——不能用声明的 column.width，因为实际渲染宽度可能因 padding/
    // 内容溢出/用户拖拽调整过而与声明值不同。用 <th> 的 ref 收集真实测量值，
    // 在 leafColumns 结构变化或列宽调整后重新测量一次；不用 ResizeObserver
    // 逐列监听（管理成本高，且列宽变化本身不改变 <th> 尺寸只改变 left/right，
    // 观察 <th> 尺寸不会形成响应式循环，但没有必要为此维护 N 个 observer 实例）。
    let theadNode: HTMLElement | null = null;
    let &[measuredWidths] = track<number[]>(() => leafColumns.map(() => 0));

    function remeasureColumnWidths() {
        const thead = untrack(() => theadNode);
        if (!thead) return;
        const cells = thead.querySelectorAll<HTMLElement>('th.lotus-table-header-cell');
        const widths = Array.from(cells).map((cell) => cell.offsetWidth);
        measuredWidths = widths;
    }

    effect(() => {
        void leafColumns;
        void state.columnWidths;
        queueMicrotask(remeasureColumnWidths);
    });

    let &[fixedOffsets] = track<FixedOffsets>(() => calcFixedOffsets(leafColumns, measuredWidths));
    let &[tableHasFixedColumns] = track<boolean>(() => hasFixedColumns(leafColumns));

    function fixedCellStyle(index: number): Record<string, any> | undefined {
        if (!tableHasFixedColumns) return undefined;
        const left = fixedOffsets.left[index];
        const right = fixedOffsets.right[index];
        if (left !== null && left !== undefined) return { position: 'sticky', left: `${left}px`, zIndex: 2 };
        if (right !== null && right !== undefined) return { position: 'sticky', right: `${right}px`, zIndex: 2 };
        return undefined;
    }

    // 列宽调整：拖拽手柄在最后一个叶子列单元格右边界注入，pointer 事件序列
    // 里只在 pointerdown 时读取起始宽度快照，move 阶段用 deltaX 换算（不逐帧
    // 重新测量 DOM），松开时触发用户的 onResizeStop 回调——对齐 Semi
    // ResizableProps 的三段回调时机（Start/中途多次 onResize/Stop 各一次）。
    let resizingColumnKey: string | null = null;
    let resizingStartX = 0;
    let resizingStartWidth = 0;

    function columnWidth(col: ColumnDef<T>, index: number): number | undefined {
        const key = getColumnKey(col, index);
        return state.columnWidths[key] ?? col.width;
    }

    function canResizeColumn(col: ColumnDef<T>): boolean {
        return !!resizable && col.resize !== false && typeof (col.width ?? columnWidth(col, leafColumns.indexOf(col))) === 'number';
    }

    function handleResizeStart(e: PointerEvent, col: ColumnDef<T>, index: number) {
        e.preventDefault();
        e.stopPropagation();
        const key = getColumnKey(col, index);
        const startWidth = columnWidth(col, index) ?? 100;
        resizingColumnKey = key;
        resizingStartX = e.clientX;
        resizingStartWidth = startWidth;
        (e.target as HTMLElement).setPointerCapture(e.pointerId);
        const resizeOpts = typeof resizable === 'object' ? resizable : undefined;
        resizeOpts?.onResizeStart?.({ ...col, width: startWidth });
    }

    function handleResizeMove(e: PointerEvent, col: ColumnDef<T>, index: number) {
        if (resizingColumnKey === null) return;
        const key = getColumnKey(col, index);
        const deltaX = e.clientX - resizingStartX;
        const width = foundation.resizeColumn(key, resizingStartWidth, deltaX, col.minWidth, col.maxWidth);
        const resizeOpts = typeof resizable === 'object' ? resizable : undefined;
        resizeOpts?.onResize?.({ ...col, width });
    }

    function handleResizeEnd(e: PointerEvent, col: ColumnDef<T>, index: number) {
        if (resizingColumnKey === null) return;
        resizingColumnKey = null;
        const key = getColumnKey(col, index);
        const width = untrack(() => state).columnWidths[key] ?? col.width;
        const resizeOpts = typeof resizable === 'object' ? resizable : undefined;
        resizeOpts?.onResizeStop?.({ ...col, width });
    }

    function fixedCellClass(index: number): string {
        if (!tableHasFixedColumns) return '';
        const col = leafColumns[index];
        if (!col) return '';
        const isLastLeftFixed = (col.fixed === 'left' || col.fixed === true)
            && leafColumns[index + 1]?.fixed !== 'left' && leafColumns[index + 1]?.fixed !== true;
        const isFirstRightFixed = col.fixed === 'right'
            && leafColumns[index - 1]?.fixed !== 'right';
        return [
            (col.fixed === 'left' || col.fixed === true || col.fixed === 'right') ? 'lotus-table-cell-fixed' : '',
            isLastLeftFixed ? 'lotus-table-cell-fixed-left-last' : '',
            isFirstRightFixed ? 'lotus-table-cell-fixed-right-first' : '',
        ].filter(Boolean).join(' ');
    }

    let &[processed] = track<T[]>(() => {
        const filtered = filterData(dataSource, leafColumns, state.filterState);
        return sortData(filtered, leafColumns, state.sortState);
    });
    // groupBy 只重排数据（同组聚在一起），分页按重排后的整体顺序切——一页内
    // 可能只含某个组的一部分，忠实对齐 Semi getCurrentPageData 的真实行为
    // （分组不改变分页粒度，是打平后再切页，不是"每组独立占若干整页"）。
    let &[groupedResult] = track(() => groupDataSource(processed, groupBy, (r, i) => foundation.resolveKey(r, i)));
    let &[pageResult] = track<{ pageData: T[]; total: number }>(() => {
        const source = groupedResult.dataSource;
        if (!paginationOpts) return { pageData: source, total: source.length };
        const start = (state.currentPage - 1) * state.pageSize;
        return { pageData: source.slice(start, start + state.pageSize), total: source.length };
    });
    let &[flatRows] = track<FlatRow<T>[]>(() => {
        const flattenMembers = (members: T[]) =>
            flattenRows(members, {
                rowKey: (r, i) => foundation.resolveKey(r, i),
                childrenKey: childrenRecordName,
                expandedRowKeys: state.expandedRowKeys,
                hasExpandedRowRender,
                keepDOM,
            });
        if (!groupBy) return flattenMembers(pageResult.pageData);
        // 分页只切了本页的数据，但分组信息（groups 里存的是全量成员 key）来自
        // groupedResult——按本页出现过的 key 交集限定每组成员，保证「组标题只
        // 在该组至少有一条数据落在本页时才出现」。
        const pageKeys = new Set(pageResult.pageData.map((r, i) => foundation.resolveKey(r, i)));
        const limitedGroups = new Map<string, Set<string>>();
        groupedResult.groups.forEach((memberKeys, groupKey) => {
            const limited = new Set([...memberKeys].filter((k) => pageKeys.has(k)));
            if (limited.size > 0) limitedGroups.set(groupKey, limited);
        });
        const limitedGroupKeys = groupedResult.groupKeys.filter((k) => limitedGroups.has(k));
        return flattenGroupedRows(
            { groupKeys: limitedGroupKeys, groups: limitedGroups, dataSource: pageResult.pageData },
            (r, i) => foundation.resolveKey(r, i),
            { expandedRowKeys: state.expandedRowKeys, flattenMembers },
        );
    });

    // 虚拟滚动仅在声明了固定高度（scroll.y）且没有展开行内容（expandedRowRender 渲染任意
    // 高度内容，与固定行高假设冲突）时生效，对齐 Semi 用 scroll.y 驱动虚拟滚动容器高度的设计。
    const isVirtualized = !!virtualize && scroll?.y !== undefined && !hasExpandedRowRender;
    let &[virtualScrollTop] = track<number>(0);
    function handleVirtualScroll(event: Event) {
        const scrollTop = (event.target as HTMLElement).scrollTop;
        untrack(() => { virtualScrollTop = scrollTop; });
    }
    let &[virtualRange] = track(() => {
        if (!isVirtualized) return null;
        return calcVirtualRange({
            itemCount: flatRows.length,
            itemHeight: virtualize!.itemSize,
            containerHeight: typeof scroll!.y === 'number' ? scroll!.y : parseFloat(String(scroll!.y)),
            scrollTop: virtualScrollTop,
        });
    });
    let &[visibleFlatRows] = track<FlatRow<T>[]>(() => {
        if (!virtualRange) return flatRows;
        return flatRows.slice(virtualRange.startIndex, virtualRange.endIndex + 1);
    });

    // rowSpan 只在「相邻的真实数据行」之间生效，展开内容行（isExpandedContent）
    // 不参与列结构，用 null 占位保持下标与 visibleFlatRows 对齐，resolveRowSpans
    // 只喂真实数据行进去、按原下标写回结果矩阵。
    let &[resolvedCellsByRow] = track<(ResolvedCell[] | undefined)[]>(() => {
        const dataFlatRows: T[] = [];
        const dataFlatIndexes: number[] = [];
        visibleFlatRows.forEach((flat, i) => {
            if (!flat.isExpandedContent && !flat.isGroupSection) {
                dataFlatRows.push(flat.record);
                dataFlatIndexes.push(i);
            }
        });
        const resolved = resolveRowSpans(dataFlatRows, leafColumns, (record: T, col: ColumnDef<T>) =>
            col.render ? col.render(getCellValue(record, col.dataIndex), record, 0) : getCellValue(record, col.dataIndex),
        );
        const byRow: (ResolvedCell[] | undefined)[] = new Array(visibleFlatRows.length).fill(undefined);
        dataFlatIndexes.forEach((rowIndex, i) => { byRow[rowIndex] = resolved[i]; });
        return byRow;
    });

    let &[disabledKeys] = track<Set<string>>(() => {
        if (!rowSelection?.getCheckboxProps) return new Set<string>();
        const set = new Set<string>();
        for (let i = 0; i < dataSource.length; i++) {
            const r = dataSource[i]!;
            if (rowSelection.getCheckboxProps(r)?.disabled) set.add(foundation.resolveKey(r, i));
        }
        return set;
    });

    let &[allSelectedStatus] = track<{ allChecked: boolean; hasSelectable: boolean }>(() => {
        const visibleKeys = pageResult.pageData.map((r, i) => foundation.resolveKey(r, i));
        return calcAllSelectedStatus(visibleKeys, disabledKeys, state.selectedRowKeys);
    });

    function fireChange() {
        onChange?.({ ...foundation.getChangeInfo(), pagination: { currentPage: untrack(() => state).currentPage, pageSize: untrack(() => state).pageSize } });
    }

    function handleSortClick(col: ColumnDef<T>, index: number) {
        if (!col.sorter) return;
        foundation.handleSortClick(getColumnKey(col, index));
        fireChange();
    }

    function collectSelectedRows(keys: Set<string>): T[] {
        const rows: T[] = [];
        function walk(list: T[]) {
            for (let i = 0; i < list.length; i++) {
                const r = list[i]!;
                if (keys.has(foundation.resolveKey(r, i))) rows.push(r);
                const children = (r as any)[childrenRecordName];
                if (children) walk(children);
            }
        }
        walk(dataSource);
        return rows;
    }

    function handleRowToggle(record: T, index: number, checked: boolean) {
        const result = foundation.toggleRow(record, index, checked, dataSource, isSelectionControlled);
        const rows = collectSelectedRows(result.selectedRowKeys);
        rowSelection?.onSelect?.(record, checked, rows);
        rowSelection?.onChange?.(Array.from(result.selectedRowKeys), rows);
    }

    function handleToggleAll(checked: boolean) {
        const next = foundation.toggleAllRows(pageResult.pageData, checked, isSelectionControlled, disabledKeys);
        const rows = collectSelectedRows(next);
        rowSelection?.onSelectAll?.(checked, rows);
        rowSelection?.onChange?.(Array.from(next), rows);
    }

    function handleExpandToggle(key: string, record: T) {
        const next = foundation.toggleExpand(key, isExpandControlled);
        const expanded = next.has(key);
        onExpand?.(expanded, record);
        onExpandedRowsChange?.(Array.from(next));
    }

    function handleGroupToggle(groupKey: string) {
        const next = foundation.toggleExpand(groupKey, isExpandControlled || isGroupExpandControlled);
        const expanded = next.has(groupKey);
        onExpand?.(expanded, { groupKey } as any);
        onExpandedRowsChange?.(Array.from(next));
    }

    function openFilter(columnKey: string, col: ColumnDef<T>) {
        openFilterKey = columnKey;
        draftFilterValues = untrack(() => state).filterState[columnKey] ?? [];
    }

    function toggleFilterDraft(value: string | number | boolean) {
        const multiple = true;
        if (draftFilterValues.includes(value)) {
            draftFilterValues = draftFilterValues.filter((v) => v !== value);
        } else {
            draftFilterValues = multiple ? [...draftFilterValues, value] : [value];
        }
    }

    function confirmFilter(columnKey: string) {
        const current = untrack(() => state).filterState;
        const nextFilterState = { ...current, [columnKey]: draftFilterValues };
        state = { ...untrack(() => state), filterState: nextFilterState, currentPage: 1 };
        openFilterKey = null;
        fireChange();
    }

    function resetFilter(columnKey: string) {
        draftFilterValues = [];
        const current = untrack(() => state).filterState;
        const nextFilterState = { ...current, [columnKey]: [] };
        state = { ...untrack(() => state), filterState: nextFilterState, currentPage: 1 };
        openFilterKey = null;
        fireChange();
    }

    function handlePageChange(page: number) {
        foundation.setCurrentPage(page);
        fireChange();
    }

    function handlePageSizeChange(size: number) {
        foundation.setPageSize(size);
        fireChange();
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-table-wrapper',
            bordered ? 'lotus-table-bordered' : '',
            `lotus-table-size-${size}`,
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[showPaginationBottom] = track<boolean>(() => !!paginationOpts && (paginationOpts.position ?? 'bottom') !== 'top');
    let &[showPaginationTop] = track<boolean>(() => !!paginationOpts && (paginationOpts.position === 'top' || paginationOpts.position === 'both'));

    <div class={classes} style={style} aria-label={ariaLabel}>
        @if (title) {
            <div class="lotus-table-title">{title()}</div>
        }

        @if (showPaginationTop) {
            <div class="lotus-table-pagination lotus-table-pagination-top">
                <Pagination
                    {...paginationOpts}
                    total={pageResult.total}
                    currentPage={state.currentPage}
                    pageSize={state.pageSize}
                    onPageChange={handlePageChange}
                    onPageSizeChange={handlePageSizeChange}
                />
            </div>
        }

        <div
            class="lotus-table-scroll"
            style={{
                ...(scroll?.x ? { overflowX: 'auto' } : {}),
                ...(scroll?.y !== undefined
                    ? { overflowY: 'auto', maxHeight: typeof scroll.y === 'number' ? `${scroll.y}px` : scroll.y }
                    : {}),
            }}
            onScroll={isVirtualized ? handleVirtualScroll : undefined}
        >
            <table class={['lotus-table', resizable ? 'lotus-table-resizable' : ''].filter(Boolean).join(' ')} role="grid" style={scroll?.x ? { minWidth: typeof scroll.x === 'number' ? `${scroll.x}px` : scroll.x } : undefined}>
                <thead
                    class={['lotus-table-thead', sticky ? 'lotus-table-thead-sticky' : '', !showHeader ? 'lotus-table-thead-hidden' : ''].filter(Boolean).join(' ')}
                    style={
                        scroll?.y !== undefined
                            ? { position: 'sticky', top: 0, zIndex: 1 }
                            : sticky ? { position: 'sticky', top: `${typeof sticky === 'object' ? (sticky.top ?? 0) : 0}px`, zIndex: 2 } : undefined
                    }
                    ref={(node: HTMLElement | null) => { theadNode = node; if (node) queueMicrotask(remeasureColumnWidths); }}
                >
                    @for (const row of headerRows; index rowIndex) {
                        <tr role="row" {...(onHeaderRow ? onHeaderRow(leafColumns, rowIndex) : {})}>
                            @if (rowSelection && row === headerRows[0]) {
                                <th class="lotus-table-cell lotus-table-selection-cell" rowSpan={headerRowCount}>
                                    @if (allSelectedStatus.hasSelectable) {
                                        <Checkbox
                                            checked={allSelectedStatus.allChecked}
                                            indeterminate={!allSelectedStatus.allChecked && state.selectedRowKeys.size > 0}
                                            onChange={handleToggleAll}
                                            aria-label={locale.Table.selectAll}
                                        />
                                    }
                                </th>
                            }
                            @if ((expandedRowRender || rowExpandable) && !hideExpandedColumn && row === headerRows[0]) {
                                <th class="lotus-table-cell lotus-table-expand-cell" rowSpan={headerRowCount}></th>
                            }
                            @for (const cell of row) {
                                <th
                                    class={['lotus-table-cell', 'lotus-table-header-cell', cell.column.align ? `lotus-table-align-${cell.column.align}` : '', cell.column.className ?? '', cell.isLeaf ? fixedCellClass(leafColumns.indexOf(cell.column)) : ''].filter(Boolean).join(' ')}
                                    role="columnheader"
                                    colSpan={cell.colSpan > 1 ? cell.colSpan : undefined}
                                    rowSpan={cell.rowSpan > 1 ? cell.rowSpan : undefined}
                                    style={{
                                        ...(cell.isLeaf ? columnWidth(cell.column, leafColumns.indexOf(cell.column)) : cell.column.width) !== undefined
                                            ? { width: `${cell.isLeaf ? columnWidth(cell.column, leafColumns.indexOf(cell.column)) : cell.column.width}px` }
                                            : {},
                                        ...(cell.isLeaf ? fixedCellStyle(leafColumns.indexOf(cell.column)) : {}),
                                    }}
                                >
                                    @if (cell.isLeaf && cell.column.sorter) {
                                        <span
                                            class="lotus-table-header-sortable"
                                            tabIndex={0}
                                            role="button"
                                            onClick={() => handleSortClick(cell.column, leafColumns.indexOf(cell.column))}
                                            onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleSortClick(cell.column, leafColumns.indexOf(cell.column)); } }}
                                        >
                                            <span>{cell.column.title}</span>
                                            <SortIcon order={state.sortState[getColumnKey(cell.column, leafColumns.indexOf(cell.column))] ?? false} />
                                        </span>
                                    } @else {
                                        <span>{cell.column.title}</span>
                                    }
                                    @if (cell.isLeaf && cell.column.filters) {
                                        <Popover
                                            trigger="custom"
                                            visible={openFilterKey === getColumnKey(cell.column, leafColumns.indexOf(cell.column))}
                                            onVisibleChange={(v: boolean) => { if (!v) openFilterKey = null; }}
                                            content={
                                                <div class="lotus-table-filter-menu">
                                                    <ul class="lotus-table-filter-list">
                                                        @for (const opt of cell.column.filters ?? []; key String(opt.value)) {
                                                            <li class="lotus-table-filter-item">
                                                                <Checkbox checked={draftFilterValues.includes(opt.value)} onChange={() => toggleFilterDraft(opt.value)}>
                                                                    {opt.text}
                                                                </Checkbox>
                                                            </li>
                                                        }
                                                    </ul>
                                                    <div class="lotus-table-filter-footer">
                                                        <button type="button" class="lotus-table-filter-btn" onClick={() => resetFilter(getColumnKey(cell.column, leafColumns.indexOf(cell.column)))}>{locale.Table.filterReset}</button>
                                                        <button type="button" class="lotus-table-filter-btn lotus-table-filter-btn-primary" onClick={() => confirmFilter(getColumnKey(cell.column, leafColumns.indexOf(cell.column)))}>{locale.Table.filterConfirm}</button>
                                                    </div>
                                                </div>
                                            }
                                        >
                                            <span
                                                class="lotus-table-filter-trigger"
                                                tabIndex={0}
                                                role="button"
                                                aria-label={locale.Table.filterLabel}
                                                onClick={() => openFilter(getColumnKey(cell.column, leafColumns.indexOf(cell.column)), cell.column)}
                                            >
                                                <IconFilter />
                                            </span>
                                        </Popover>
                                    }
                                    @if (cell.isLeaf && canResizeColumn(cell.column)) {
                                        <span
                                            class="lotus-table-resize-handle"
                                            onPointerDown={(e: PointerEvent) => handleResizeStart(e, cell.column, leafColumns.indexOf(cell.column))}
                                            onPointerMove={(e: PointerEvent) => handleResizeMove(e, cell.column, leafColumns.indexOf(cell.column))}
                                            onPointerUp={(e: PointerEvent) => handleResizeEnd(e, cell.column, leafColumns.indexOf(cell.column))}
                                        ></span>
                                    }
                                </th>
                            }
                        </tr>
                    }
                </thead>
                <tbody class="lotus-table-tbody" ref={(node: HTMLElement | null) => { tbodyNode = node; }}>
                    @if (loading) {
                        <tr>
                            <td class="lotus-table-loading-cell" colSpan={leafColumns.length + (rowSelection ? 1 : 0) + ((expandedRowRender || rowExpandable) && !hideExpandedColumn ? 1 : 0)}>
                                <Spin spinning={true} />
                            </td>
                        </tr>
                    } @else {
                        <>
                        @if (flatRows.length === 0) {
                            <tr>
                                <td class="lotus-table-empty-cell" colSpan={leafColumns.length + (rowSelection ? 1 : 0) + ((expandedRowRender || rowExpandable) && !hideExpandedColumn ? 1 : 0)}>
                                    {empty ?? <Empty title={locale.Table.emptyTitle} />}
                                </td>
                            </tr>
                        }
                        @if (virtualRange && virtualRange.offsetY > 0) {
                            <tr class="lotus-table-virtual-spacer" aria-hidden="true" style={{ height: `${virtualRange.offsetY}px` }}><td colSpan={leafColumns.length + (rowSelection ? 1 : 0) + ((expandedRowRender || rowExpandable) && !hideExpandedColumn ? 1 : 0)} /></tr>
                        }
                        @for (const flat of visibleFlatRows; index rowIdx; key flat.key) {
                            <TableRow
                                flat={flat}
                                leafColumns={leafColumns}
                                resolvedCells={resolvedCellsByRow[rowIdx]}
                                rowSelection={rowSelection}
                                showExpandColumn={!!((expandedRowRender || rowExpandable) && !hideExpandedColumn)}
                                hasExpandedRowRender={hasExpandedRowRender}
                                rowExpandable={rowExpandable}
                                expandedRowRender={expandedRowRender}
                                expandRowByClick={expandRowByClick}
                                selected={state.selectedRowKeys.has(flat.key)}
                                halfSelected={state.halfSelectedRowKeys.has(flat.key)}
                                disabled={disabledKeys.has(flat.key)}
                                expanded={state.expandedRowKeys.has(flat.key)}
                                onRow={onRow}
                                onRowToggle={handleRowToggle}
                                onExpandToggle={handleExpandToggle}
                                fixedCellStyle={fixedCellStyle}
                                fixedCellClass={fixedCellClass}
                                indentSize={indentSize}
                                onRowHover={rowSpanHover ? handleRowHover : undefined}
                                renderGroupSection={renderGroupSection}
                                onGroupedRow={onGroupedRow as any}
                                clickGroupedRowToExpand={clickGroupedRowToExpand}
                                groupExpanded={flat.groupKey !== undefined && state.expandedRowKeys.has(flat.groupKey)}
                                onGroupToggle={handleGroupToggle}
                            />
                        }
                        @if (virtualRange && (virtualRange.totalHeight - virtualRange.offsetY - (virtualRange.endIndex - virtualRange.startIndex + 1) * virtualize!.itemSize) > 0) {
                            <tr
                                class="lotus-table-virtual-spacer"
                                aria-hidden="true"
                                style={{ height: `${virtualRange.totalHeight - virtualRange.offsetY - (virtualRange.endIndex - virtualRange.startIndex + 1) * virtualize!.itemSize}px` }}
                            ><td colSpan={leafColumns.length + (rowSelection ? 1 : 0) + ((expandedRowRender || rowExpandable) && !hideExpandedColumn ? 1 : 0)} /></tr>
                        }
                        </>
                    }
                </tbody>
            </table>
        </div>

        @if (footer) {
            <div class="lotus-table-footer">{footer()}</div>
        }

        @if (showPaginationBottom) {
            <div class="lotus-table-pagination lotus-table-pagination-bottom">
                <Pagination
                    {...paginationOpts}
                    total={pageResult.total}
                    currentPage={state.currentPage}
                    pageSize={state.pageSize}
                    onPageChange={handlePageChange}
                    onPageSizeChange={handlePageSizeChange}
                />
            </div>
        }

        <style>
            .lotus-table-wrapper {
                display: flex;
                flex-direction: column;
                gap: 12px;
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-table-title {
                font-weight: 600;
            }

            .lotus-table-scroll {
                width: 100%;
            }

            .lotus-table {
                width: 100%;
                border-collapse: collapse;
                table-layout: auto;
            }

            .lotus-table-resizable {
                table-layout: fixed;
            }

            .lotus-table-cell {
                padding: 12px 16px;
                text-align: start;
                border-bottom: 1px solid var(--lotus-color-border);
                box-sizing: border-box;
            }

            .lotus-table-size-middle .lotus-table-cell {
                padding: 8px 16px;
            }

            .lotus-table-size-small .lotus-table-cell {
                padding: 4px 12px;
            }

            .lotus-table-bordered .lotus-table-cell {
                border-inline-end: 1px solid var(--lotus-color-border);
            }

            .lotus-table-bordered .lotus-table-cell:last-child {
                border-inline-end: none;
            }

            .lotus-table-header-cell {
                position: relative;
                background: var(--lotus-color-fill-0);
                font-weight: 600;
                color: var(--lotus-color-text-1);
                white-space: nowrap;
            }

            .lotus-table-resize-handle {
                position: absolute;
                top: 0;
                right: -4px;
                bottom: 0;
                width: 8px;
                cursor: col-resize;
                touch-action: none;
                z-index: 1;
            }

            .lotus-table-resize-handle:hover,
            .lotus-table-resize-handle:active {
                background: var(--lotus-color-primary);
                opacity: 0.4;
            }

            .lotus-table-thead-hidden {
                display: none;
            }

            .lotus-table-thead-sticky {
                z-index: 2;
            }

            .lotus-table-thead-sticky .lotus-table-header-cell {
                background: var(--lotus-color-bg-1);
            }

            .lotus-table-align-left { text-align: left; }
            .lotus-table-align-center { text-align: center; }
            .lotus-table-align-right { text-align: right; }

            .lotus-table-header-sortable {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                cursor: pointer;
                user-select: none;
            }

            .lotus-table-sort-icons {
                display: inline-flex;
                flex-direction: column;
                line-height: 0;
                margin-inline-start: 2px;
            }

            .lotus-table-sort-icon,
            .lotus-table-sort-icon-active {
                font-size: 10px;
                color: var(--lotus-color-text-3);
            }

            .lotus-table-sort-icon-active {
                color: var(--lotus-color-primary);
            }

            .lotus-table-filter-trigger {
                display: inline-flex;
                align-items: center;
                margin-inline-start: 6px;
                cursor: pointer;
                color: var(--lotus-color-text-3);
            }

            .lotus-table-filter-trigger:hover {
                color: var(--lotus-color-primary);
            }

            .lotus-table-virtual-spacer > td {
                padding: 0;
                border: none;
            }

            .lotus-table-selection-cell,
            .lotus-table-expand-cell {
                width: 1%;
                white-space: nowrap;
            }

            .lotus-table-loading-cell,
            .lotus-table-empty-cell {
                text-align: center;
                padding: 40px 16px;
            }

            .lotus-table-pagination {
                display: flex;
                justify-content: flex-end;
            }

            .lotus-table-footer {
                padding: 12px 16px;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-table-filter-menu {
                display: flex;
                flex-direction: column;
                min-width: 160px;
            }

            .lotus-table-filter-list {
                list-style: none;
                margin: 0;
                padding: 8px;
                max-height: 200px;
                overflow-y: auto;
            }

            .lotus-table-filter-item {
                padding: 4px 8px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
            }

            .lotus-table-filter-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-table-filter-footer {
                display: flex;
                justify-content: flex-end;
                gap: 8px;
                padding: 8px;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-table-filter-btn {
                padding: 4px 12px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-bg-1);
                cursor: pointer;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-table-filter-btn-primary {
                background: var(--lotus-color-primary);
                border-color: var(--lotus-color-primary);
                color: #ffffff;
            }

            .lotus-table-cell-fixed {
                background: var(--lotus-color-bg-1);
            }

            .lotus-table-header-cell.lotus-table-cell-fixed {
                background: var(--lotus-color-fill-0);
            }

            .lotus-table-cell-fixed-left-last {
                box-shadow: 4px 0 8px -4px rgba(0, 0, 0, 0.12);
            }

            .lotus-table-cell-fixed-right-first {
                box-shadow: -4px 0 8px -4px rgba(0, 0, 0, 0.12);
            }
        </style>
    </div>
}
