import { track, effect, untrack } from 'ripple';
import {
    TableFoundation,
    flattenLeafColumns,
    getColumnKey,
    getCellValue,
    getHeaderRowCount,
    sortData,
    filterData,
    flattenRows,
    calcAllSelectedStatus,
    type TableState,
    type ColumnDef,
    type SortOrder,
    type FlatRow,
    type ChangeInfo,
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
    empty?: any;
    title?: () => any;
    footer?: () => any;
    virtualize?: { itemSize: number };
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
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
}

/** 单行 `<tr>` 的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用，避免
 * 重复维护 selection/expand/普通列三段拼装逻辑。 */
function TableRow<T = any>(&{
    flat,
    leafColumns,
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
}: TableRowProps<T>) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    @if (flat.isExpandedContent) {
        <tr class="lotus-table-expanded-row" role="row">
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
                <td class="lotus-table-cell lotus-table-expand-cell" style={flat.level > 0 ? { paddingLeft: `${flat.level * 20}px` } : undefined}>
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
            @for (const col of leafColumns) {
                <td
                    class={['lotus-table-cell', col.align ? `lotus-table-align-${col.align}` : '', col.className ?? ''].filter(Boolean).join(' ')}
                    role="gridcell"
                    onClick={() => { if (expandRowByClick && (flat.hasChildren || hasExpandedRowRender)) onExpandToggle(flat.key, flat.record); }}
                >
                    {col.render ? col.render(getCellValue(flat.record, col.dataIndex), flat.record, 0) : getCellValue(flat.record, col.dataIndex)}
                </td>
            }
        </tr>
    }

    <style>
        .lotus-table-cell {
            padding: 12px 16px;
            text-align: left;
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
            border-right: 1px solid var(--lotus-color-border);
        }

        .lotus-table-bordered .lotus-table-cell:last-child {
            border-right: none;
        }

        .lotus-table-align-left { text-align: left; }
        .lotus-table-align-center { text-align: center; }
        .lotus-table-align-right { text-align: right; }

        .lotus-table-row:hover .lotus-table-cell {
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
    empty,
    title,
    footer,
    virtualize,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TableProps<T>) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isSelectionControlled = rowSelection?.selectedRowKeys !== undefined;
    const isExpandControlled = expandedRowKeysProp !== undefined;
    const hasExpandedRowRender = expandedRowRender !== undefined;

    const paginationOpts = pagination === true ? {} : pagination === false ? null : pagination;
    const initialPageSize = paginationOpts?.pageSize ?? 10;
    const initialPage = paginationOpts?.currentPage ?? paginationOpts?.defaultCurrentPage ?? 1;

    let &[state] = track<TableState<T>>({
        sortState: {},
        filterState: {},
        selectedRowKeys: toKeySet(rowSelection?.selectedRowKeys),
        halfSelectedRowKeys: new Set<string>(),
        expandedRowKeys: toKeySet(expandedRowKeysProp ?? defaultExpandedRowKeys),
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

    let &[openFilterKey] = track<string | null>(null);
    let &[draftFilterValues] = track<Array<string | number | boolean>>([]);

    let &[leafColumns] = track<ColumnDef<T>[]>(() => flattenLeafColumns(columns));
    let &[headerRowCount] = track<number>(() => getHeaderRowCount(columns));
    let &[headerRows] = track<HeaderCell<T>[][]>(() => buildHeaderRows(columns, headerRowCount));

    let &[processed] = track<T[]>(() => {
        const filtered = filterData(dataSource, leafColumns, state.filterState);
        return sortData(filtered, leafColumns, state.sortState);
    });
    let &[pageResult] = track<{ pageData: T[]; total: number }>(() => {
        if (!paginationOpts) return { pageData: processed, total: processed.length };
        const start = (state.currentPage - 1) * state.pageSize;
        return { pageData: processed.slice(start, start + state.pageSize), total: processed.length };
    });
    let &[flatRows] = track<FlatRow<T>[]>(() =>
        flattenRows(pageResult.pageData, {
            rowKey: (r, i) => foundation.resolveKey(r, i),
            childrenKey: childrenRecordName,
            expandedRowKeys: state.expandedRowKeys,
            hasExpandedRowRender,
        }),
    );

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
            <table class="lotus-table" role="grid" style={scroll?.x ? { minWidth: typeof scroll.x === 'number' ? `${scroll.x}px` : scroll.x } : undefined}>
                <thead class="lotus-table-thead" style={scroll?.y !== undefined ? { position: 'sticky', top: 0, zIndex: 1 } : undefined}>
                    @for (const row of headerRows) {
                        <tr role="row">
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
                                    class={['lotus-table-cell', 'lotus-table-header-cell', cell.column.align ? `lotus-table-align-${cell.column.align}` : '', cell.column.className ?? ''].filter(Boolean).join(' ')}
                                    role="columnheader"
                                    colSpan={cell.colSpan > 1 ? cell.colSpan : undefined}
                                    rowSpan={cell.rowSpan > 1 ? cell.rowSpan : undefined}
                                    style={cell.column.width ? { width: `${cell.column.width}px` } : undefined}
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
                                </th>
                            }
                        </tr>
                    }
                </thead>
                <tbody class="lotus-table-tbody">
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
                        @for (const flat of visibleFlatRows; key flat.key) {
                            <TableRow
                                flat={flat}
                                leafColumns={leafColumns}
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

            .lotus-table-cell {
                padding: 12px 16px;
                text-align: left;
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
                border-right: 1px solid var(--lotus-color-border);
            }

            .lotus-table-bordered .lotus-table-cell:last-child {
                border-right: none;
            }

            .lotus-table-header-cell {
                background: var(--lotus-color-fill-0);
                font-weight: 600;
                color: var(--lotus-color-text-1);
                white-space: nowrap;
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
                margin-left: 2px;
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
                margin-left: 6px;
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
        </style>
    </div>
}
