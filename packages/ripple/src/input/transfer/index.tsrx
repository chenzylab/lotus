import { track, untrack, effect } from 'ripple';
import {
    TransferFoundation,
    resolveValue,
    generateDataByType,
    calcSelectAllStatus,
    type TransferState,
    type ResolvedDataItem,
    type TransferDataSource,
    type TransferType,
    type TransferFilter,
} from '@lotus/foundation/input/transfer';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { calcTargetIndex, getDragOffset, type ItemRect, type SortableDragState } from '@lotus/foundation/base/sortable-drag';
import { Checkbox } from '../checkbox/index.tsrx';
import { Input } from '../input/index.tsrx';
import { Button } from '../../basic/button/index.tsrx';
import { Spin } from '../../feedback/spin/index.tsrx';
import { Empty } from '../../show/empty/index.tsrx';
import { Pagination } from '../../navigation/pagination/index.tsrx';
import { Tree, type TreeNodeData } from '../../navigation/tree/index.tsrx';
import { IconSearch, IconClose, IconHandle } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { TransferType, TransferDataSource, TransferFilter };

export interface TransferEmptyContent {
    left?: any;
    right?: any;
    search?: any;
}

export interface TransferVirtualizeConfig {
    height?: number;
    itemSize: number;
}

export interface TransferPaginationConfig {
    currentPage?: number;
    defaultCurrentPage?: number;
    pageSize?: number;
    onPageChange?: (page: number) => void;
}

export interface TransferProps {
    dataSource?: TransferDataSource;
    type?: TransferType;
    filter?: TransferFilter;
    value?: Array<string | number>;
    defaultValue?: Array<string | number>;
    disabled?: boolean;
    loading?: boolean;
    draggable?: boolean;
    virtualize?: TransferVirtualizeConfig;
    pagination?: TransferPaginationConfig;
    showPath?: boolean;
    emptyContent?: TransferEmptyContent;
    onChange?: (values: Array<string | number>, items: ResolvedDataItem[]) => void;
    onSelect?: (item: ResolvedDataItem) => void;
    onDeselect?: (item: ResolvedDataItem) => void;
    onSearch?: (input: string) => void;
    renderSourceItem?: (item: ResolvedDataItem & { checked: boolean }) => any;
    renderSelectedItem?: (item: ResolvedDataItem) => any;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

const DEFAULT_PAGE_SIZE = 10;

function itemLabel(item: ResolvedDataItem): string {
    return typeof item.label === 'string' ? item.label : String(item.key);
}

function pathLabel(item: ResolvedDataItem): string {
    if (!item.path) return itemLabel(item);
    return item.path.map((p) => (typeof p.label === 'string' ? p.label : String(p.key))).join(' > ');
}

function toTreeNodeData(items: ResolvedDataItem[]): TreeNodeData[] {
    // treeList 已在 Foundation 层打平，这里只需要按 key 建立父子关系还原树形结构，
    // 供内部 <Tree multiple> 组件渲染（Tree 组件本身接受嵌套 treeData，不接受打平数组）。
    const byKey = new Map<string | number, TreeNodeData & { _origKey: string | number }>();
    for (const item of items) {
        byKey.set(item.key, {
            key: String(item.key),
            label: item.label ?? String(item.key),
            disabled: item.disabled,
            children: [],
            _origKey: item.key,
        } as any);
    }
    const roots: TreeNodeData[] = [];
    for (const item of items) {
        const node = byKey.get(item.key)!;
        const parentPath = item.path;
        const parentKey = parentPath && parentPath.length > 1 ? parentPath[parentPath.length - 2]!.key : undefined;
        if (parentKey !== undefined && byKey.has(parentKey)) {
            const parent = byKey.get(parentKey)!;
            (parent.children as TreeNodeData[]).push(node);
        } else {
            roots.push(node);
        }
    }
    return roots;
}

interface SourceItemProps {
    item: ResolvedDataItem;
    checked: boolean;
    disabled: boolean;
    onToggle: (item: ResolvedDataItem) => void;
    renderSourceItem?: (item: ResolvedDataItem & { checked: boolean }) => any;
}

function SourceItem(&{ item, checked, disabled, onToggle, renderSourceItem }: SourceItemProps) @{
    <>
    <div class="lotus-transfer-source-item" role="listitem">
        @if (renderSourceItem) {
            <div onClick={() => onToggle(item)}>{renderSourceItem({ ...item, checked })}</div>
        } @else {
            <Checkbox
                checked={checked}
                disabled={disabled}
                onChange={() => onToggle(item)}
                aria-label={itemLabel(item)}
            >
                {itemLabel(item)}
            </Checkbox>
        }
    </div>

    <style>
        .lotus-transfer-source-item {
            padding: 6px 12px;
            display: flex;
            align-items: center;
        }

        .lotus-transfer-source-item:hover {
            background: var(--lotus-color-fill-0);
        }
    </style>
    </>
}

interface SelectedItemProps {
    item: ResolvedDataItem;
    showPath: boolean;
    draggable: boolean;
    dragging: boolean;
    dragOffset: number;
    onRemove: (item: ResolvedDataItem) => void;
    onDragStart: (event: MouseEvent) => void;
    renderSelectedItem?: (item: ResolvedDataItem) => any;
    itemRef?: (node: HTMLElement) => void;
}

function SelectedItem(&{
    item,
    showPath,
    draggable,
    dragging,
    dragOffset,
    onRemove,
    onDragStart,
    renderSelectedItem,
    itemRef,
}: SelectedItemProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    <>
    <div
        class={['lotus-transfer-selected-item', dragging ? 'lotus-transfer-selected-item-dragging' : ''].filter(Boolean).join(' ')}
        style={dragging ? { transform: `translateY(${dragOffset}px)` } : undefined}
        role="listitem"
        ref={(node: HTMLElement) => itemRef?.(node)}
    >
        @if (renderSelectedItem) {
            {renderSelectedItem(item)}
        } @else {
            <>
                @if (draggable) {
                    <span
                        class="lotus-transfer-drag-handle"
                        role="button"
                        aria-label={locale.Transfer.dragHandle}
                        onMouseDown={onDragStart}
                    >
                        <IconHandle />
                    </span>
                }
                <span class="lotus-transfer-selected-item-label">{showPath ? pathLabel(item) : itemLabel(item)}</span>
                <span
                    class="lotus-transfer-selected-item-remove"
                    role="button"
                    aria-label={locale.Transfer.remove(itemLabel(item))}
                    onClick={() => onRemove(item)}
                >
                    <IconClose />
                </span>
            </>
        }
    </div>

    <style>
        .lotus-transfer-selected-item {
            padding: 6px 12px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .lotus-transfer-selected-item:hover {
            background: var(--lotus-color-fill-0);
        }

        .lotus-transfer-selected-item-dragging {
            position: relative;
            z-index: 1;
            background: var(--lotus-color-bg-2);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }

        .lotus-transfer-drag-handle {
            display: flex;
            align-items: center;
            cursor: grab;
            color: var(--lotus-color-text-2);
            flex-shrink: 0;
        }

        .lotus-transfer-selected-item-label {
            flex: 1;
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .lotus-transfer-selected-item-remove {
            display: flex;
            align-items: center;
            cursor: pointer;
            color: var(--lotus-color-text-2);
            flex-shrink: 0;
        }

        .lotus-transfer-selected-item-remove:hover {
            color: var(--lotus-color-text-0);
        }
    </style>
    </>
}

/**
 * Transfer：穿梭框。单一数据源 + selectedItems Map 的"勾选即迁移"模型
 * （对齐 Semi 的真实设计——左侧渲染全量数据，右侧渲染选中子集，没有中间
 * 移动箭头按钮，左侧勾选/右侧点击移除是同一个"翻转选中态"动作）。
 * type='list'/'groupList' 走自绘列表，type='treeList' 左侧改用内部
 * `<Tree multiple>` 组件渲染（三态级联复用 Tree 已验证的算法）。draggable
 * 拖拽排序（仅右侧）和 virtualize 虚拟化（仅右侧）互斥，与 Semi/参考实现
 * chenzy.design 两方验证过的产品规则一致。拖拽用 document 级
 * mousemove/mouseup + pointer 位移换算（复用 lotus Slider 已验证的监听
 * 模式，注意 onMouseDown 不用 onPointerDown，对齐踩坑 #81）。
 */
export function Transfer(&{
    dataSource = [],
    type = 'list',
    filter,
    value,
    defaultValue = [],
    disabled = false,
    loading = false,
    draggable = false,
    virtualize,
    pagination,
    showPath = false,
    emptyContent = {},
    onChange,
    onSelect,
    onDeselect,
    onSearch,
    renderSourceItem,
    renderSelectedItem,
    'aria-label': ariaLabel,
    style,
    class: className,
}: TransferProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = value !== undefined;
    const effectiveDraggable = draggable && !virtualize;
    const effectiveVirtualize = virtualize && !draggable;

    function computeInitialState(): TransferState {
        const data = generateDataByType(dataSource, type);
        const initialValues = isControlled ? value! : defaultValue;
        const selectedItems = new Map<string | number, ResolvedDataItem>();
        for (const val of initialValues) {
            const item = data.find((d) => resolveValue(d) === val);
            if (item) selectedItems.set(item.key, item);
        }
        return {
            data,
            selectedItems,
            searchResult: new Set(data.map((d) => d.key)),
            inputValue: '',
            leftCurrentPage: 1,
        };
    }

    let &[state] = track<TransferState>(computeInitialState());

    const foundation = new TransferFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TransferState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (value === undefined) return;
        untrack(() => foundation.syncSelectedItems(value!));
    });

    effect(() => {
        const ds = dataSource;
        const t = type;
        untrack(() => foundation.syncData(ds, t));
    });

    function emitChange(result: { values: Array<string | number>; items: ResolvedDataItem[] }) {
        onChange?.(result.values, result.items);
    }

    function handleToggle(item: ResolvedDataItem) {
        const result = foundation.handleSelectOrRemove(item, isControlled);
        if (!result) return;
        if (result.direction === 'select') onSelect?.(item);
        else onDeselect?.(item);
        emitChange(result);
    }

    function handleAllClick() {
        const status = foundation.getSelectAllStatus();
        const result = foundation.handleAll(!status.allChecked, isControlled);
        emitChange(result);
    }

    function handleSearchInput(inputVal: string) {
        foundation.handleInputChange(inputVal, filter);
        onSearch?.(inputVal);
    }

    function handleTreeChange(keys: string[]) {
        const { data } = untrack(() => state);
        const selectedItems = untrack(() => state).selectedItems;
        const next = new Map<string | number, ResolvedDataItem>();
        const keySet = new Set(keys);
        for (const item of data) {
            if (keySet.has(String(item.key))) next.set(item.key, item);
        }
        if (!isControlled) untrack(() => { state = { ...state, selectedItems: next }; });
        const values = [...next.values()].map((item) => resolveValue(item));
        onChange?.(values, [...next.values()]);
    }

    // ===================== 拖拽排序（仅右侧） =====================

    let &[dragState] = track<SortableDragState>({ draggingIndex: null, startPos: 0, currentPos: 0 });
    let selectedItemNodes: Array<HTMLElement | null> = [];

    function handleDragStart(index: number, event: MouseEvent) {
        if (!effectiveDraggable) return;
        untrack(() => { dragState = { draggingIndex: index, startPos: event.clientY, currentPos: event.clientY }; });
    }

    effect(() => {
        const handleMove = (event: MouseEvent) => {
            const current = untrack(() => dragState);
            if (current.draggingIndex === null) return;
            untrack(() => { dragState = { ...current, currentPos: event.clientY }; });
        };
        const handleUp = () => {
            const current = untrack(() => dragState);
            if (current.draggingIndex === null) return;
            const rects: ItemRect[] = selectedItemNodes.map((node, index) => {
                if (!node) return { index, center: 0 };
                const rect = node.getBoundingClientRect();
                return { index, center: rect.top + rect.height / 2 };
            });
            const draggingRect = rects[current.draggingIndex];
            const draggingCenter = draggingRect ? draggingRect.center + getDragOffset(current) : current.currentPos;
            const targetIndex = calcTargetIndex(current.draggingIndex, draggingCenter, rects);
            untrack(() => { dragState = { draggingIndex: null, startPos: 0, currentPos: 0 }; });
            if (targetIndex !== current.draggingIndex) {
                const result = foundation.handleSortEnd(current.draggingIndex, targetIndex, isControlled);
                emitChange(result);
            }
        };
        document.addEventListener('mousemove', handleMove);
        document.addEventListener('mouseup', handleUp);
        return () => {
            document.removeEventListener('mousemove', handleMove);
            document.removeEventListener('mouseup', handleUp);
        };
    });

    // ===================== 虚拟化（仅右侧） =====================

    let &[scrollTop] = track<number>(0);
    let virtualContainerNode: HTMLElement | null = null;

    function handleVirtualScroll(event: Event) {
        untrack(() => { scrollTop = (event.target as HTMLElement).scrollTop; });
    }

    // ===================== 分页（左侧，仅 list/groupList） =====================

    let &[currentPage] = track<number>(pagination?.defaultCurrentPage ?? pagination?.currentPage ?? 1);
    let &[pageSizeState] = track<number>(pagination?.pageSize ?? DEFAULT_PAGE_SIZE);

    effect(() => {
        if (pagination?.currentPage === undefined) return;
        const p = pagination.currentPage;
        untrack(() => { currentPage = p; });
    });

    function handlePageChange(page: number) {
        untrack(() => { currentPage = page; });
        pagination?.onPageChange?.(page);
    }

    // ===================== 派生展示值 =====================

    let &[visibleData] = track<ResolvedDataItem[]>(() =>
        state.inputValue ? state.data.filter((item) => state.searchResult.has(item.key)) : state.data,
    );
    let &[selectAllStatus] = track(() => calcSelectAllStatus(visibleData, state.selectedItems));
    let &[selectedList] = track<ResolvedDataItem[]>(() => [...state.selectedItems.values()]);

    let &[pagedVisibleData] = track<ResolvedDataItem[]>(() => {
        if (!pagination || type === 'treeList') return visibleData;
        const start = (currentPage - 1) * pageSizeState;
        return visibleData.slice(start, start + pageSizeState);
    });

    let &[groupedRows] = track<Array<{ kind: 'group'; title: string } | { kind: 'item'; item: ResolvedDataItem }>>(() => {
        if (type !== 'groupList') return pagedVisibleData.map((item) => ({ kind: 'item' as const, item }));
        const rows: Array<{ kind: 'group'; title: string } | { kind: 'item'; item: ResolvedDataItem }> = [];
        const seenGroups = new Set<string>();
        for (const item of pagedVisibleData) {
            const title = item._parent?.title;
            if (title && !seenGroups.has(title)) {
                seenGroups.add(title);
                rows.push({ kind: 'group', title });
            }
            rows.push({ kind: 'item', item });
        }
        return rows;
    });

    let &[treeNodes] = track<TreeNodeData[]>(() => (type === 'treeList' ? toTreeNodeData(state.data) : []));
    let &[treeCheckedKeys] = track<string[]>(() => [...state.selectedItems.keys()].map(String));

    let &[virtualRange] = track(() => {
        if (!effectiveVirtualize) return null;
        return calcVirtualRange({
            itemCount: selectedList.length,
            itemHeight: virtualize!.itemSize,
            containerHeight: virtualize!.height ?? 280,
            scrollTop,
        });
    });

    let &[virtualVisibleItems] = track<Array<{ item: ResolvedDataItem; index: number }>>(() => {
        if (!virtualRange) return [];
        const result: Array<{ item: ResolvedDataItem; index: number }> = [];
        for (let i = virtualRange.startIndex; i <= virtualRange.endIndex; i++) {
            const item = selectedList[i];
            if (item) result.push({ item, index: i });
        }
        return result;
    });

    let &[classes] = track<string>(() =>
        ['lotus-transfer', disabled ? 'lotus-transfer-disabled' : '', className ?? ''].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <div class="lotus-transfer-panel lotus-transfer-panel-left">
                <div class="lotus-transfer-header">
                    <span class="lotus-transfer-header-title">{locale.Transfer.itemCount(visibleData.length)}</span>
                    @if (selectAllStatus.showButton && type !== 'treeList') {
                        <Button theme="borderless" type="tertiary" size="small" onClick={handleAllClick} disabled={disabled}>
                            {selectAllStatus.allChecked ? locale.Transfer.clearAll : locale.Transfer.selectAll}
                        </Button>
                    }
                </div>
                @if (filter !== false && type !== 'treeList') {
                    <div class="lotus-transfer-search" role="search" aria-label={locale.Transfer.filterLabel}>
                        <Input
                            prefix={<IconSearch />}
                            showClear
                            placeholder={locale.Transfer.searchPlaceholder}
                            value={state.inputValue}
                            disabled={disabled}
                            onChange={handleSearchInput}
                        />
                    </div>
                }
                <div class="lotus-transfer-body">
                    @if (loading) {
                        <div class="lotus-transfer-loading"><Spin /></div>
                    } @else if (type === 'treeList') {
                        @if (treeNodes.length === 0) {
                            <Empty description={emptyContent.left ?? locale.Transfer.emptyLeft} />
                        } @else {
                            <Tree
                                treeData={treeNodes}
                                multiple
                                value={treeCheckedKeys}
                                onChange={(v: any) => handleTreeChange(Array.isArray(v) ? v : v ? [v] : [])}
                                filterTreeNode={filter !== false ? ((input: string, label: string) => label.includes(input)) : false}
                                disabled={disabled}
                            />
                        }
                    } @else if (pagedVisibleData.length === 0) {
                        <Empty description={state.inputValue ? (emptyContent.search ?? locale.Transfer.emptySearch) : (emptyContent.left ?? locale.Transfer.emptyLeft)} />
                    } @else {
                        <div class="lotus-transfer-list" role="list" aria-label={locale.Transfer.optionListLabel}>
                            @for (const row of groupedRows; index ri) {
                                @if (row.kind === 'group') {
                                    <div class="lotus-transfer-group-title">{row.title}</div>
                                } @else {
                                    <SourceItem
                                        item={row.item}
                                        checked={state.selectedItems.has(row.item.key)}
                                        disabled={disabled || !!row.item.disabled}
                                        onToggle={handleToggle}
                                        renderSourceItem={renderSourceItem}
                                    />
                                }
                            }
                        </div>
                    }
                </div>
                @if (pagination && type !== 'treeList' && visibleData.length > pageSizeState) {
                    <div class="lotus-transfer-pagination">
                        <Pagination
                            total={visibleData.length}
                            currentPage={currentPage}
                            pageSize={pageSizeState}
                            onPageChange={handlePageChange}
                            size="small"
                        />
                    </div>
                }
            </div>

            <div class="lotus-transfer-panel lotus-transfer-panel-right">
                <div class="lotus-transfer-header">
                    <span class="lotus-transfer-header-title">{locale.Transfer.itemCountSelected(selectedList.length)}</span>
                    @if (selectedList.length > 0) {
                        <Button theme="borderless" type="tertiary" size="small" disabled={disabled} onClick={() => { const result = foundation.handleAll(false, isControlled); emitChange(result); }}>
                            {locale.Transfer.clear}
                        </Button>
                    }
                </div>
                <div class="lotus-transfer-body">
                    @if (selectedList.length === 0) {
                        <Empty description={emptyContent.right ?? locale.Transfer.emptyRight} />
                    } @else if (effectiveVirtualize) {
                        <div
                            class="lotus-transfer-list lotus-transfer-list-virtual"
                            role="list"
                            aria-label={locale.Transfer.selectedListLabel}
                            style={{ height: `${virtualize!.height ?? 280}px` }}
                            onScroll={handleVirtualScroll}
                            ref={(node: HTMLElement) => { virtualContainerNode = node; }}
                        >
                            <div class="lotus-transfer-virtual-spacer" style={{ height: `${virtualRange?.totalHeight ?? 0}px` }}>
                                <div style={{ transform: `translateY(${virtualRange?.offsetY ?? 0}px)` }}>
                                    @for (const entry of virtualVisibleItems; index vi; key entry.item.key) {
                                        <div style={{ height: `${virtualize!.itemSize}px` }}>
                                            <SelectedItem
                                                item={entry.item}
                                                showPath={showPath}
                                                draggable={false}
                                                dragging={false}
                                                dragOffset={0}
                                                onRemove={handleToggle}
                                                onDragStart={() => {}}
                                                renderSelectedItem={renderSelectedItem}
                                            />
                                        </div>
                                    }
                                </div>
                            </div>
                        </div>
                    } @else {
                        <div class="lotus-transfer-list" role="list" aria-label={locale.Transfer.selectedListLabel}>
                            @for (const item of selectedList; index si; key item.key) {
                                <SelectedItem
                                    item={item}
                                    showPath={showPath}
                                    draggable={effectiveDraggable}
                                    dragging={dragState.draggingIndex === si}
                                    dragOffset={getDragOffset(dragState)}
                                    onRemove={handleToggle}
                                    onDragStart={(e: MouseEvent) => handleDragStart(si, e)}
                                    renderSelectedItem={renderSelectedItem}
                                    itemRef={(node: HTMLElement) => { selectedItemNodes[si] = node; }}
                                />
                            }
                        </div>
                    }
                </div>
            </div>
        </div>

        <style>
            .lotus-transfer {
                display: flex;
                gap: 8px;
            }

            .lotus-transfer-panel {
                display: flex;
                flex-direction: column;
                width: 240px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-bg-1);
            }

            .lotus-transfer-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 8px 12px;
                border-bottom: 1px solid var(--lotus-color-border);
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-transfer-search {
                padding: 8px 12px;
            }

            .lotus-transfer-body {
                flex: 1;
                min-height: 200px;
                max-height: 320px;
                overflow-y: auto;
            }

            .lotus-transfer-loading {
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100%;
                padding: 24px 0;
            }

            .lotus-transfer-list {
                display: flex;
                flex-direction: column;
            }

            .lotus-transfer-list-virtual {
                overflow-y: auto;
                position: relative;
            }

            .lotus-transfer-virtual-spacer {
                position: relative;
                /* .lotus-transfer-list-virtual 同时带有 .lotus-transfer-list 的
                   display:flex/flex-direction:column，flex 子项默认 min-height:auto
                   会导致 height 内联样式被压缩到不超过父容器可用空间——即使 height
                   显式设成了内容总高度也不生效，必须 flex-shrink:0 关闭压缩。 */
                flex-shrink: 0;
            }

            .lotus-transfer-group-title {
                padding: 6px 12px;
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
                background: var(--lotus-color-fill-0);
            }

            .lotus-transfer-pagination {
                padding: 8px;
                border-top: 1px solid var(--lotus-color-border);
                display: flex;
                justify-content: center;
            }

            .lotus-transfer-disabled {
                opacity: 0.6;
                pointer-events: none;
            }
        </style>
    </>
}

