import { track, effect, untrack } from 'ripple';
import {
    TreeFoundation,
    createInitialTreeState,
    buildKeyEntities,
    flattenTreeData,
    calcExpandedKeys,
    calcAllExpandedKeys,
    calcCheckedKeys,
    computeSearchResult,
    calcDropRelativePosition,
    type TreeState,
    type TreeNodeData,
    type FilterTreeNode,
    type KeyEntities,
    type FlatTreeNode,
    type TreeCheckRelation,
} from '@lotus/foundation/navigation/tree';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { Checkbox } from '../../input/checkbox/index.tsrx';
import { IconChevronRight, IconLoading, IconSearch, IconClose, IconFile, IconFolder, IconFolderOpen } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { TreeNodeData, FilterTreeNode, TreeCheckRelation };

export type TreeExpandAction = 'click' | 'doubleClick' | false;

export interface TreeVirtualize {
    height?: number;
    itemSize: number;
}

export interface TreeRenderFullLabelProps {
    level: number;
    className: string;
    style?: Record<string, any>;
    onExpand: (e: MouseEvent) => void;
    onClick: (e: MouseEvent) => void;
    onDoubleClick: (e: MouseEvent) => void;
    onContextMenu: (e: MouseEvent) => void;
    onCheck?: (e: MouseEvent) => void;
    expandIcon: any;
    checkStatus: { checked: boolean; halfChecked: boolean };
    expandStatus: { expanded: boolean; loading: boolean };
    data: TreeNodeData;
}

export interface TreeSearchRenderProps {
    class: string;
    placeholder: string;
    showClear: boolean;
    value: string;
    onChange: (value: string) => void;
}

export interface TreeDragEventInfo {
    event: DragEvent;
    node: TreeNodeData;
    dragNode?: TreeNodeData | null;
    dragNodesKeys?: string[];
    dropPosition?: number;
    dropToGap?: boolean;
}

export interface TreeProps {
    treeData: TreeNodeData[];
    multiple?: boolean;
    checkRelation?: TreeCheckRelation;
    leafOnly?: boolean;
    autoMergeValue?: boolean;
    value?: string | string[];
    defaultValue?: string | string[];
    /** `onChangeWithObject` 为 true 时，回调传节点数据（对象/对象数组）而非 key。 */
    onChange?: (value: string | string[] | TreeNodeData | TreeNodeData[] | undefined) => void;
    onChangeWithObject?: boolean;
    onSelect?: (selectedKey: string | null, selected: boolean, node: TreeNodeData) => void;
    expandedKeys?: string[];
    defaultExpandedKeys?: string[];
    defaultExpandAll?: boolean;
    autoExpandParent?: boolean;
    onExpand?: (expandedKeys: string[], info: { expanded: boolean; node: TreeNodeData }) => void;
    disabled?: boolean;
    disableStrictly?: boolean;
    filterTreeNode?: FilterTreeNode;
    treeNodeFilterProp?: string;
    showFilteredOnly?: boolean;
    searchPlaceholder?: string;
    searchRender?: ((props: TreeSearchRenderProps) => any) | false;
    onSearch?: (input: string, filteredExpandedKeys: string[]) => void;
    loadData?: (node: TreeNodeData) => Promise<TreeNodeData[]>;
    loadedKeys?: string[];
    onLoad?: (loadedKeys: string[], node: TreeNodeData) => void;
    renderLabel?: (label: any, node: TreeNodeData) => any;
    renderFullLabel?: (props: TreeRenderFullLabelProps) => any;
    icon?: any | ((node: TreeNodeData) => any);
    expandIcon?: any;
    expandAction?: TreeExpandAction;
    directory?: boolean;
    showLine?: boolean;
    blockNode?: boolean;
    virtualize?: TreeVirtualize;
    emptyContent?: any;
    onDoubleClick?: (event: MouseEvent, node: TreeNodeData) => void;
    onContextMenu?: (event: MouseEvent, node: TreeNodeData) => void;
    draggable?: boolean;
    autoExpandWhenDragEnter?: boolean;
    hideDraggingNode?: boolean;
    onDragStart?: (info: TreeDragEventInfo) => void;
    onDragEnter?: (info: TreeDragEventInfo) => void;
    onDragOver?: (info: TreeDragEventInfo) => void;
    onDragLeave?: (info: TreeDragEventInfo) => void;
    onDrop?: (info: TreeDragEventInfo) => void;
    onDragEnd?: (info: TreeDragEventInfo) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function toKeyArray(value: string | string[] | undefined): string[] {
    if (value === undefined) return [];
    return Array.isArray(value) ? value : [value];
}

interface TreeNodeItemProps {
    node: FlatTreeNode;
    multiple: boolean;
    selected: boolean;
    checked: boolean;
    halfChecked: boolean;
    expanded: boolean;
    loading: boolean;
    loadData: boolean;
    disabled: boolean;
    disableStrictly: boolean;
    renderLabel?: (label: any, node: TreeNodeData) => any;
    renderFullLabel?: (props: TreeRenderFullLabelProps) => any;
    icon?: any | ((node: TreeNodeData) => any);
    expandIcon?: any;
    expandAction: TreeExpandAction;
    directory: boolean;
    draggable: boolean;
    isDragging: boolean;
    dragOver: boolean;
    dropPosition: -1 | 0 | 1 | null;
    ariaLabel: string;
    onToggleExpand: (key: string, data: TreeNodeData, hasChildren: boolean) => void;
    onSelectNode: (key: string, data: TreeNodeData) => void;
    onDoubleClickNode?: (event: MouseEvent, node: TreeNodeData) => void;
    onContextMenuNode?: (event: MouseEvent, node: TreeNodeData) => void;
    onDragStartNode?: (event: DragEvent, node: TreeNodeData) => void;
    onDragEnterNode?: (event: DragEvent, node: TreeNodeData, rect: DOMRect) => void;
    onDragOverNode?: (event: DragEvent, node: TreeNodeData, rect: DOMRect) => void;
    onDragLeaveNode?: (event: DragEvent, node: TreeNodeData) => void;
    onDropNode?: (event: DragEvent, node: TreeNodeData) => void;
    onDragEndNode?: (event: DragEvent, node: TreeNodeData) => void;
}

/** 单个树节点行渲染，供虚拟化/非虚拟化两条渲染路径共用（对齐 TreeSelect
 * 已验证的 NodeItem 拆分模式）。directory 模式下无自定义 icon 时自动展示
 * 文件夹/文件图标（对齐 Semi TreeNode.renderIcon 语义）。 */
function TreeNodeItem(&{
    node,
    multiple,
    selected,
    checked,
    halfChecked,
    expanded,
    loading,
    loadData,
    disabled,
    disableStrictly,
    renderLabel,
    renderFullLabel,
    icon,
    expandIcon,
    expandAction,
    directory,
    draggable,
    isDragging,
    dragOver,
    dropPosition,
    ariaLabel,
    onToggleExpand,
    onSelectNode,
    onDoubleClickNode,
    onContextMenuNode,
    onDragStartNode,
    onDragEnterNode,
    onDragOverNode,
    onDragLeaveNode,
    onDropNode,
    onDragEndNode,
}: TreeNodeItemProps) @{
    let &[isDisabled] = track<boolean>(() => disabled || !!node.disabled);
    let &[nodeClassName] = track<string>(() => [
        'lotus-tree-node',
        !multiple && selected ? 'lotus-tree-node-selected' : '',
        node.disabled ? 'lotus-tree-node-disabled' : '',
        isDragging ? 'lotus-tree-node-dragging' : '',
        dragOver && dropPosition === 0 ? 'lotus-tree-node-drag-over' : '',
        dragOver && dropPosition === -1 ? 'lotus-tree-node-drag-over-top' : '',
        dragOver && dropPosition === 1 ? 'lotus-tree-node-drag-over-bottom' : '',
    ].filter(Boolean).join(' '));

    function handleExpandClick(event: MouseEvent) {
        event.stopPropagation();
        onToggleExpand(node.key, node.data, node.hasChildren);
    }

    function handleRowClick() {
        onSelectNode(node.key, node.data);
    }

    /** expandAction='click' 对齐 Semi 真实语义：整行点击同时触发选中和展开。 */
    function handleRowClickWithExpand() {
        onSelectNode(node.key, node.data);
        if (node.hasChildren || loadData) onToggleExpand(node.key, node.data, node.hasChildren);
    }

    function handleRowDoubleClickExpand() {
        if (!node.hasChildren && !loadData) return;
        onToggleExpand(node.key, node.data, node.hasChildren);
    }

    function handleDoubleClick(event: MouseEvent) {
        onDoubleClickNode?.(event, node.data);
        if (expandAction === 'doubleClick') handleRowDoubleClickExpand();
    }

    function handleContextMenu(event: MouseEvent) {
        onContextMenuNode?.(event, node.data);
    }

    function resolveIcon(): any {
        if (typeof icon === 'function') return icon(node.data);
        if (icon) return icon;
        if (node.icon) return node.icon;
        if (directory) {
            if (!node.hasChildren && node.isLeaf) return <IconFile />;
            return expanded ? <IconFolderOpen /> : <IconFolder />;
        }
        return null;
    }

    const resolvedIcon = resolveIcon();

    <>
    @if (renderFullLabel) {
        <span style="display:contents">{renderFullLabel({
            level: node.level,
            className: nodeClassName,
            style: { paddingLeft: `${node.level * 20}px` },
            onExpand: handleExpandClick,
            onClick: handleRowClick,
            onDoubleClick: handleDoubleClick,
            onContextMenu: handleContextMenu,
            onCheck: multiple ? () => onSelectNode(node.key, node.data) : undefined,
            expandIcon: expandIcon ?? <IconChevronRight />,
            checkStatus: { checked, halfChecked },
            expandStatus: { expanded, loading },
            data: node.data,
        })}</span>
    } @else {
        <div
            role="treeitem"
            aria-label={ariaLabel}
            aria-selected={!multiple && selected}
            aria-disabled={isDisabled}
            aria-expanded={node.hasChildren || loadData ? expanded : undefined}
            aria-level={node.level + 1}
            class={nodeClassName}
            style={{ paddingLeft: `${node.level * 20}px` }}
            draggable={draggable && !isDisabled}
            onDblClick={handleDoubleClick}
            onContextMenu={handleContextMenu}
            onDragStart={draggable ? (e: DragEvent) => onDragStartNode?.(e, node.data) : undefined}
            onDragEnter={draggable ? (e: DragEvent) => { e.preventDefault(); onDragEnterNode?.(e, node.data, (e.currentTarget as HTMLElement).getBoundingClientRect()); } : undefined}
            onDragOver={draggable ? (e: DragEvent) => { e.preventDefault(); onDragOverNode?.(e, node.data, (e.currentTarget as HTMLElement).getBoundingClientRect()); } : undefined}
            onDragLeave={draggable ? (e: DragEvent) => onDragLeaveNode?.(e, node.data) : undefined}
            onDrop={draggable ? (e: DragEvent) => { e.preventDefault(); onDropNode?.(e, node.data); } : undefined}
            onDragEnd={draggable ? (e: DragEvent) => onDragEndNode?.(e, node.data) : undefined}
        >
            @if (!node.isLeaf || loadData) {
                <span
                    class={['lotus-tree-switcher', expanded ? 'lotus-tree-switcher-expanded' : ''].filter(Boolean).join(' ')}
                    onClick={handleExpandClick}
                >
                    @if (loading) {
                        <span class="lotus-tree-switcher-loading"><IconLoading /></span>
                    } @if (!loading) {
                        <IconChevronRight />
                    }
                </span>
            } @if (node.isLeaf && !loadData) {
                <span class="lotus-tree-switcher lotus-tree-switcher-placeholder" />
            }

            @if (multiple) {
                <span class="lotus-tree-node-checkbox" onClick={(event: MouseEvent) => event.stopPropagation()}>
                    <Checkbox
                        checked={checked}
                        indeterminate={halfChecked}
                        disabled={isDisabled}
                        onChange={() => onSelectNode(node.key, node.data)}
                        aria-label={typeof node.label === 'string' ? node.label : node.key}
                    />
                </span>
            }

            <span
                class="lotus-tree-node-content"
                onClick={expandAction === 'click' ? handleRowClickWithExpand : handleRowClick}
            >
                @if (resolvedIcon) {
                    <span class="lotus-tree-node-icon">{resolvedIcon}</span>
                }
                <span class="lotus-tree-node-label">{renderLabel ? renderLabel(node.label, node.data) : node.label}</span>
            </span>
        </div>
    }
    </>
}

/**
 * Tree：完整版（展开/收起、单选/多选三态级联含 checkRelation='unRelated'/
 * disableStrictly、搜索过滤、loadData 异步懒加载、拖拽排序、虚拟滚动、
 * directory 文件夹风格）。渲染层用 Foundation 的 flattenTreeData 摊平结果
 * 做单层 @for，不在循环体内做可见性判断（对齐 Breadcrumb 的踩坑 #13
 * 修复范式——可见性过滤在数据生成阶段完成，不是渲染阶段）。
 *
 * 拖拽不直接改 treeData——Foundation 只管拖拽过程的视觉状态（dragging/
 * dragOverNodeKey/dropPosition），真正的数据重排交给消费方在 onDrop
 * 回调里自行操作 treeData（对齐 Semi 本身的设计：onDrop 只给
 * dropPosition/dropToGap 信息，不直接修改 treeData）。
 */
export function Tree(&{
    treeData,
    multiple = false,
    checkRelation = 'related',
    leafOnly = false,
    autoMergeValue = true,
    value: valueProp,
    defaultValue,
    onChange,
    onChangeWithObject = false,
    onSelect,
    expandedKeys: expandedKeysProp,
    defaultExpandedKeys,
    defaultExpandAll = false,
    autoExpandParent = true,
    onExpand,
    disabled = false,
    disableStrictly = false,
    filterTreeNode = false,
    treeNodeFilterProp = 'label',
    showFilteredOnly = false,
    searchPlaceholder,
    searchRender,
    onSearch,
    loadData,
    loadedKeys: loadedKeysProp,
    onLoad,
    renderLabel,
    renderFullLabel,
    icon,
    expandIcon,
    expandAction = false,
    directory = false,
    showLine = false,
    blockNode = true,
    virtualize,
    emptyContent,
    onDoubleClick,
    onContextMenu,
    draggable = false,
    autoExpandWhenDragEnter = false,
    hideDraggingNode = false,
    onDragStart,
    onDragEnter,
    onDragOver,
    onDragLeave,
    onDrop,
    onDragEnd,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TreeProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isValueControlled = valueProp !== undefined;
    const isExpandControlled = expandedKeysProp !== undefined;
    const isLoadedControlled = loadedKeysProp !== undefined;

    let &[entities] = track<KeyEntities>(() => buildKeyEntities(treeData));

    function disabledKeysFor(ents: KeyEntities): Set<string> | undefined {
        if (!disableStrictly) return undefined;
        const result = new Set<string>();
        for (const key of Object.keys(ents)) {
            if (ents[key]!.data.disabled) result.add(key);
        }
        return result;
    }

    function computeInitialExpanded(ents: KeyEntities): Set<string> {
        if (isExpandControlled) return calcExpandedKeys(expandedKeysProp!, ents, autoExpandParent);
        if (defaultExpandAll) return calcAllExpandedKeys(ents);
        if (defaultExpandedKeys) return calcExpandedKeys(defaultExpandedKeys, ents, autoExpandParent);
        return new Set<string>();
    }

    const initialEntities = buildKeyEntities(treeData);
    const initialCheckedSource = multiple ? (isValueControlled ? valueProp : defaultValue) : undefined;
    const initialCascade = initialCheckedSource !== undefined && checkRelation === 'related'
        ? calcCheckedKeys(toKeyArray(initialCheckedSource), initialEntities)
        : { checkedKeys: new Set<string>(), halfCheckedKeys: new Set<string>() };
    const initialIndependent = multiple && checkRelation === 'unRelated' && initialCheckedSource !== undefined
        ? new Set(toKeyArray(initialCheckedSource).filter((k) => initialEntities[k]))
        : new Set<string>();
    const initialSingleSelected = !multiple
        ? ((isValueControlled ? valueProp : defaultValue) as string | undefined) ?? null
        : null;

    let &[state] = track<TreeState>({
        ...createInitialTreeState(),
        expandedKeys: computeInitialExpanded(initialEntities),
        checkedKeys: initialCascade.checkedKeys,
        halfCheckedKeys: initialCascade.halfCheckedKeys,
        independentCheckedKeys: initialIndependent,
        selectedKey: initialSingleSelected,
        loadedKeys: isLoadedControlled ? new Set(loadedKeysProp!) : new Set<string>(),
    });

    const foundation = new TreeFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TreeState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控 value 同步：外部传入新值时，重新算三态（多选 related）/直接替换
    // 独立集合（多选 unRelated）/直接替换（单选）。
    effect(() => {
        if (!isValueControlled) return;
        const current = untrack(() => state);
        const ents = untrack(() => entities);
        if (multiple) {
            if (checkRelation === 'unRelated') {
                const keys = new Set(toKeyArray(valueProp).filter((k) => ents[k]));
                const same = current.independentCheckedKeys.size === keys.size && [...keys].every((k) => current.independentCheckedKeys.has(k));
                if (same) return;
                state = { ...current, independentCheckedKeys: keys };
                return;
            }
            const keys = toKeyArray(valueProp);
            const result = calcCheckedKeys(keys, ents);
            const same = current.checkedKeys.size === result.checkedKeys.size
                && [...result.checkedKeys].every((k) => current.checkedKeys.has(k));
            if (same) return;
            state = { ...current, checkedKeys: result.checkedKeys, halfCheckedKeys: result.halfCheckedKeys };
        } else {
            const next = (valueProp as string | undefined) ?? null;
            if (current.selectedKey === next) return;
            state = { ...current, selectedKey: next };
        }
    });

    // 受控 expandedKeys 同步。
    effect(() => {
        if (!isExpandControlled) return;
        const ents = untrack(() => entities);
        const next = calcExpandedKeys(expandedKeysProp!, ents, autoExpandParent);
        const current = untrack(() => state);
        const same = current.expandedKeys.size === next.size && [...next].every((k) => current.expandedKeys.has(k));
        if (same) return;
        state = { ...current, expandedKeys: next };
    });

    // 受控 loadedKeys 同步。
    effect(() => {
        if (!isLoadedControlled) return;
        const next = new Set(loadedKeysProp!);
        const current = untrack(() => state);
        const same = current.loadedKeys.size === next.size && [...next].every((k) => current.loadedKeys.has(k));
        if (same) return;
        state = { ...current, loadedKeys: next };
    });

    function labelOf(data: TreeNodeData): string {
        return String((data as any)[treeNodeFilterProp] ?? data.label ?? '');
    }

    // foundation.handleSearch() 已经把展开祖先链的副作用写进 state；这里
    // 用同一个纯函数 computeSearchResult 幂等地重新计算一次搜索结果，
    // 只是为了拿到 filteredShownKeys 供 showFilteredOnly 过滤渲染列表。
    let &[searchResult] = track(() =>
        filterTreeNode && state.searchInput ? computeSearchResult(state.searchInput, entities, filterTreeNode, labelOf) : null,
    );

    let &[flatNodes] = track(() =>
        flattenTreeData(
            treeData,
            state.expandedKeys,
            showFilteredOnly && searchResult ? searchResult.filteredShownKeys : null,
        ),
    );

    function checkedKeysFor(): Set<string> {
        return checkRelation === 'unRelated' ? untrack(() => state).independentCheckedKeys : untrack(() => state).checkedKeys;
    }

    function nodeDataOf(key: string): TreeNodeData | undefined {
        return untrack(() => entities)[key]?.data;
    }

    function notifyChange() {
        if (multiple) {
            const keys = foundation.resolveValue(untrack(() => entities), checkRelation, { autoMergeValue, leafOnly });
            onChange?.(onChangeWithObject ? keys.map((k) => nodeDataOf(k)).filter(Boolean) as TreeNodeData[] : keys);
        } else {
            const key = untrack(() => state).selectedKey;
            if (onChangeWithObject) {
                onChange?.(key ? nodeDataOf(key) : undefined);
            } else {
                onChange?.(key ?? undefined);
            }
        }
    }

    function handleToggleExpand(key: string, node: TreeNodeData, hasChildren: boolean) {
        const currentState = untrack(() => state);
        const wasExpanded = currentState.expandedKeys.has(key);

        if (!wasExpanded && loadData && !hasChildren && !currentState.loadedKeys.has(key)) {
            foundation.handleLoadStart(key);
            loadData(node).then((children) => {
                node.children = children;
                entities = buildKeyEntities(treeData);
                foundation.handleLoadEnd(key);
                const next = isExpandControlled ? new Set([...untrack(() => state).expandedKeys, key]) : foundation.handleExpand(key);
                onLoad?.([...untrack(() => state).loadedKeys], node);
                onExpand?.([...next], { expanded: true, node });
            });
            return;
        }

        if (!hasChildren && !loadData) return;

        if (isExpandControlled) {
            const next = wasExpanded
                ? new Set([...currentState.expandedKeys].filter((k) => k !== key))
                : new Set([...currentState.expandedKeys, key]);
            onExpand?.([...next], { expanded: !wasExpanded, node });
            return;
        }
        const next = foundation.handleExpand(key);
        onExpand?.([...next], { expanded: !wasExpanded, node });
    }

    function handleSelectNode(key: string, node: TreeNodeData) {
        if (disabled || node.disabled) return;
        if (multiple) {
            foundation.handleCheck(key, untrack(() => entities), checkRelation, disabledKeysFor(untrack(() => entities)));
            notifyChange();
            return;
        }
        const next = foundation.handleSelect(key);
        onSelect?.(next, next !== null, node);
        if (onChangeWithObject) {
            onChange?.(next ? nodeDataOf(next) : undefined);
        } else {
            onChange?.(next ?? undefined);
        }
    }

    function handleSearchInput(input: string) {
        const result = foundation.handleSearch(input, untrack(() => entities), filterTreeNode);
        onSearch?.(input, [...result.expandedAncestorKeys]);
    }

    function handleClearSearch() {
        handleSearchInput('');
    }

    // ===================== 拖拽 =====================

    function handleDragStartNode(event: DragEvent, node: TreeNodeData) {
        foundation.handleDragStart(node.key, untrack(() => entities));
        if (hideDraggingNode) {
            const target = event.currentTarget as HTMLElement;
            const dragImg = target.cloneNode(true) as HTMLElement;
            dragImg.style.opacity = '0';
            document.body.appendChild(dragImg);
            event.dataTransfer?.setDragImage(dragImg, 0, 0);
            setTimeout(() => document.body.removeChild(dragImg), 0);
        }
        onDragStart?.({ event, node });
    }

    function handleDragEnterNode(event: DragEvent, node: TreeNodeData, rect: DOMRect) {
        const dropPosition = calcDropRelativePosition(event.clientY, rect);
        const accepted = foundation.handleDragEnter(node.key, dropPosition);
        if (!accepted) return;
        const dragState = untrack(() => state).drag;
        if (autoExpandWhenDragEnter && node.children?.length && !untrack(() => state).expandedKeys.has(node.key)) {
            handleToggleExpand(node.key, node, true);
        }
        onDragEnter?.({ event, node, dragNodesKeys: [...dragState.dragNodesKeys] });
    }

    function handleDragOverNode(event: DragEvent, node: TreeNodeData, rect: DOMRect) {
        const dropPosition = calcDropRelativePosition(event.clientY, rect);
        const accepted = foundation.handleDragOver(node.key, dropPosition);
        if (!accepted) return;
        onDragOver?.({ event, node });
    }

    function handleDragLeaveNode(event: DragEvent, node: TreeNodeData) {
        foundation.handleDragLeave();
        onDragLeave?.({ event, node });
    }

    function handleDropNode(event: DragEvent, node: TreeNodeData) {
        const dragState = foundation.clearDragState();
        if (dragState.dragNodesKeys.has(node.key)) return;
        const dragNodeEntity = dragState.dragNodeKey ? untrack(() => entities)[dragState.dragNodeKey] : undefined;
        onDrop?.({
            event,
            node,
            dragNode: dragNodeEntity?.data,
            dragNodesKeys: [...dragState.dragNodesKeys],
            dropPosition: dragState.dropPosition ?? 0,
            dropToGap: dragState.dropPosition !== 0,
        });
    }

    function handleDragEndNode(event: DragEvent, node: TreeNodeData) {
        foundation.clearDragState();
        onDragEnd?.({ event, node });
    }

    // ===================== 虚拟滚动 =====================

    let &[virtualScrollTop] = track<number>(0);

    function handleVirtualScroll(event: Event) {
        const scrollTop = (event.target as HTMLElement).scrollTop;
        untrack(() => { virtualScrollTop = scrollTop; });
    }

    let &[virtualRange] = track(() => {
        if (!virtualize) return null;
        return calcVirtualRange({
            itemCount: flatNodes.length,
            itemHeight: virtualize.itemSize,
            containerHeight: virtualize.height ?? 280,
            scrollTop: virtualScrollTop,
        });
    });

    let &[virtualVisibleNodes] = track<FlatTreeNode[]>(() => {
        if (!virtualRange) return [];
        const result: FlatTreeNode[] = [];
        for (let i = virtualRange.startIndex; i <= virtualRange.endIndex; i++) {
            const node = flatNodes[i];
            if (node) result.push(node);
        }
        return result;
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-tree',
            blockNode ? 'lotus-tree-block' : '',
            disabled ? 'lotus-tree-disabled' : '',
            showLine ? 'lotus-tree-show-line' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    function nodeAriaLabel(node: FlatTreeNode): string {
        return typeof node.label === 'string' ? node.label : node.key;
    }

    <>
        <div class={classes} style={style} role="tree" aria-label={ariaLabel} aria-multiselectable={multiple ? true : undefined}>
            @if (searchRender !== false) {
                @if (filterTreeNode) {
                    @if (searchRender) {
                        <span style="display:contents">{searchRender({
                            class: 'lotus-tree-search-input',
                            placeholder: searchPlaceholder ?? locale.Tree.searchPlaceholder,
                            showClear: !!state.searchInput,
                            value: state.searchInput,
                            onChange: handleSearchInput,
                        })}</span>
                    } @else {
                        <div class="lotus-tree-search">
                            <span class="lotus-tree-search-icon"><IconSearch /></span>
                            <input
                                type="text"
                                class="lotus-tree-search-input"
                                placeholder={searchPlaceholder ?? locale.Tree.searchPlaceholder}
                                value={state.searchInput}
                                onInput={(e: Event) => handleSearchInput((e.target as HTMLInputElement).value)}
                            />
                            @if (state.searchInput) {
                                <button
                                    type="button"
                                    class="lotus-tree-search-clear"
                                    aria-label={locale.Tree.clearSearch}
                                    onClick={handleClearSearch}
                                >
                                    <IconClose />
                                </button>
                            }
                        </div>
                    }
                }
            }

            @if (flatNodes.length === 0) {
                <div class="lotus-tree-empty">{emptyContent ?? locale.Tree.emptyContent}</div>
            }

            @if (virtualize) {
                <div
                    class="lotus-tree-virtual-viewport"
                    style={{ height: `${virtualize.height ?? 280}px` }}
                    onScroll={handleVirtualScroll}
                >
                    <div style={{ height: `${virtualRange?.totalHeight ?? 0}px` }}>
                        <div style={{ transform: `translateY(${virtualRange?.offsetY ?? 0}px)` }}>
                            @for (const node of virtualVisibleNodes; key node.key) {
                                <div style={{ height: `${virtualize.itemSize}px` }}>
                                    <TreeNodeItem
                                        node={node}
                                        multiple={multiple}
                                        selected={node.key === state.selectedKey}
                                        checked={checkedKeysFor().has(node.key)}
                                        halfChecked={checkRelation === 'related' && state.halfCheckedKeys.has(node.key)}
                                        expanded={state.expandedKeys.has(node.key)}
                                        loading={state.loadingKeys.has(node.key)}
                                        loadData={!!loadData}
                                        disabled={disabled}
                                        disableStrictly={disableStrictly}
                                        renderLabel={renderLabel}
                                        renderFullLabel={renderFullLabel}
                                        icon={icon}
                                        expandIcon={expandIcon}
                                        expandAction={expandAction}
                                        directory={directory}
                                        draggable={draggable}
                                        isDragging={state.drag.dragNodeKey === node.key}
                                        dragOver={state.drag.dragOverNodeKey === node.key}
                                        dropPosition={state.drag.dragOverNodeKey === node.key ? state.drag.dropPosition : null}
                                        ariaLabel={nodeAriaLabel(node)}
                                        onToggleExpand={handleToggleExpand}
                                        onSelectNode={handleSelectNode}
                                        onDoubleClickNode={onDoubleClick}
                                        onContextMenuNode={onContextMenu}
                                        onDragStartNode={handleDragStartNode}
                                        onDragEnterNode={handleDragEnterNode}
                                        onDragOverNode={handleDragOverNode}
                                        onDragLeaveNode={handleDragLeaveNode}
                                        onDropNode={handleDropNode}
                                        onDragEndNode={handleDragEndNode}
                                    />
                                </div>
                            }
                        </div>
                    </div>
                </div>
            } @else {
                @for (const node of flatNodes; key node.key) {
                    <TreeNodeItem
                        node={node}
                        multiple={multiple}
                        selected={node.key === state.selectedKey}
                        checked={checkedKeysFor().has(node.key)}
                        halfChecked={checkRelation === 'related' && state.halfCheckedKeys.has(node.key)}
                        expanded={state.expandedKeys.has(node.key)}
                        loading={state.loadingKeys.has(node.key)}
                        loadData={!!loadData}
                        disabled={disabled}
                        disableStrictly={disableStrictly}
                        renderLabel={renderLabel}
                        renderFullLabel={renderFullLabel}
                        icon={icon}
                        expandIcon={expandIcon}
                        expandAction={expandAction}
                        directory={directory}
                        draggable={draggable}
                        isDragging={state.drag.dragNodeKey === node.key}
                        dragOver={state.drag.dragOverNodeKey === node.key}
                        dropPosition={state.drag.dragOverNodeKey === node.key ? state.drag.dropPosition : null}
                        ariaLabel={nodeAriaLabel(node)}
                        onToggleExpand={handleToggleExpand}
                        onSelectNode={handleSelectNode}
                        onDoubleClickNode={onDoubleClick}
                        onContextMenuNode={onContextMenu}
                        onDragStartNode={handleDragStartNode}
                        onDragEnterNode={handleDragEnterNode}
                        onDragOverNode={handleDragOverNode}
                        onDragLeaveNode={handleDragLeaveNode}
                        onDropNode={handleDropNode}
                        onDragEndNode={handleDragEndNode}
                    />
                }
            }
        </div>

        <style>
            .lotus-tree {
                display: flex;
                flex-direction: column;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-tree-search {
                display: flex;
                align-items: center;
                gap: 6px;
                height: var(--lotus-height-control-default);
                padding: 0 var(--lotus-spacing-tight);
                margin-bottom: var(--lotus-spacing-tight);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-bg-1);
            }

            .lotus-tree-search-icon {
                display: flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
            }

            .lotus-tree-search-input {
                flex: 1;
                min-width: 0;
                border: none;
                outline: none;
                background: transparent;
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-tree-search-clear {
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 18px;
                height: 18px;
                padding: 0;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
            }

            .lotus-tree-empty {
                padding: var(--lotus-spacing-base);
                text-align: center;
                color: var(--lotus-color-text-2);
            }

            .lotus-tree-virtual-viewport {
                overflow-y: auto;
            }

            .lotus-tree-node {
                display: flex;
                align-items: center;
                gap: 4px;
                min-height: 32px;
                border-radius: var(--lotus-border-radius-small);
                position: relative;
            }

            .lotus-tree-block .lotus-tree-node:hover:not(.lotus-tree-node-disabled) {
                background: var(--lotus-color-fill-0);
            }

            .lotus-tree-node-selected {
                background: var(--lotus-color-fill-1);
            }

            .lotus-tree-node-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-tree-node-dragging {
                opacity: 0.4;
            }

            .lotus-tree-node-drag-over {
                background: var(--lotus-color-fill-1);
                outline: 1px dashed var(--lotus-color-primary);
            }

            .lotus-tree-node-drag-over-top::before,
            .lotus-tree-node-drag-over-bottom::after {
                content: '';
                position: absolute;
                left: 0;
                right: 0;
                height: 2px;
                background: var(--lotus-color-primary);
            }

            .lotus-tree-node-drag-over-top::before {
                top: 0;
            }

            .lotus-tree-node-drag-over-bottom::after {
                bottom: 0;
            }

            .lotus-tree-switcher {
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 20px;
                height: 20px;
                cursor: pointer;
                color: var(--lotus-color-text-2);
                transition: transform 0.2s ease;
            }

            .lotus-tree-switcher-placeholder {
                cursor: default;
            }

            .lotus-tree-switcher-expanded {
                transform: rotate(90deg);
            }

            .lotus-tree-switcher-loading {
                display: flex;
                animation: lotus-tree-spin 1s linear infinite;
            }

            @keyframes lotus-tree-spin {
                to { transform: rotate(360deg); }
            }

            .lotus-tree-node-checkbox {
                display: inline-flex;
                align-items: center;
                flex-shrink: 0;
            }

            .lotus-tree-node-content {
                display: flex;
                align-items: center;
                gap: 6px;
                flex: 1;
                min-width: 0;
                cursor: pointer;
                padding: 2px 4px;
            }

            .lotus-tree-node-icon {
                display: flex;
                align-items: center;
                flex-shrink: 0;
            }

            .lotus-tree-node-label {
                min-width: 0;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .lotus-tree-show-line .lotus-tree-node {
                position: relative;
            }

            .lotus-tree-show-line .lotus-tree-node::before {
                content: '';
                position: absolute;
                left: 10px;
                top: -2px;
                bottom: 50%;
                width: 1px;
                background: var(--lotus-color-border);
            }

            .lotus-tree-show-line .lotus-tree-node::after {
                content: '';
                position: absolute;
                left: 10px;
                top: 50%;
                width: 10px;
                height: 1px;
                background: var(--lotus-color-border);
            }
        </style>
    </>
}
