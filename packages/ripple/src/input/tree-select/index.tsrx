import { track, untrack, effect } from 'ripple';
import {
    TreeSelectFoundation,
    buildKeyEntities,
    flattenTreeData,
    calcExpandedKeys,
    calcAllExpandedKeys,
    calcCheckedKeys,
    computeSearchResult,
    normalizeCheckedKeysToValue,
    foldTags,
    type TreeSelectState,
    type TreeSelectCheckRelation,
    type TreeNodeData,
    type FilterTreeNode,
    type KeyEntities,
    type FlatTreeNode,
} from '@lotus/foundation/input/tree-select';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { IconChevronDown, IconChevronRight, IconClear, IconLoading, IconSearch } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';
import { Checkbox } from '../checkbox/index.tsrx';

export type TreeSelectSize = 'large' | 'default' | 'small';
export type TreeSelectValidateStatus = 'default' | 'warning' | 'error';
export type { TreeSelectCheckRelation };
export type { TreeNodeData };

export interface TreeSelectProps {
    treeData?: TreeNodeData[];
    value?: string | string[];
    defaultValue?: string | string[];
    multiple?: boolean;
    disabled?: boolean;
    placeholder?: any;
    size?: TreeSelectSize;
    validateStatus?: TreeSelectValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    position?: FloatingPosition;
    /** 多选三态级联开关，'unRelated' 时选中态互相独立，默认 'related'。 */
    checkRelation?: TreeSelectCheckRelation;
    /** 多选：父全选时 value 只保留父 key，不逐一列出子孙，默认 true。 */
    autoMergeValue?: boolean;
    /** 多选：value 只保留叶子节点 key，默认 false，优先级高于 autoMergeValue。 */
    leafOnly?: boolean;
    /** 多选标签超出该数量后折叠为 "+N"。 */
    maxTagCount?: number;
    expandedKeys?: string[];
    defaultExpandedKeys?: string[];
    defaultExpandAll?: boolean;
    autoExpandParent?: boolean;
    onExpand?: (expandedKeys: string[], info: { expanded: boolean; node: TreeNodeData }) => void;
    filterTreeNode?: FilterTreeNode;
    showFilteredOnly?: boolean;
    searchPlaceholder?: any;
    onSearch?: (input: string) => void;
    loadData?: (node: TreeNodeData) => Promise<TreeNodeData[]>;
    onLoad?: (loadedKeys: string[], node: TreeNodeData) => void;
    onLoadError?: (node: TreeNodeData, error: unknown) => void;
    renderLabel?: (label: any, node: TreeNodeData) => any;
    /** 大数据量场景下开启固定行高虚拟滚动（对齐 Select/Cascader 已验证的实现
     * 模式，复用同一份 `base/virtual-list.ts` 纯算法）——`flatNodes` 已经是
     * "展开路径上可见节点"的扁平数组，天然固定行高（不因层级/展开状态变化），
     * 直接对这个一维数组做虚拟化即可，不需要像 Cascader 那样按列拆分。 */
    virtualize?: { height?: number; itemSize: number };
    onChange?: (value: string | string[] | undefined) => void;
    onSelect?: (selectedKey: string | null, selected: boolean, node: TreeNodeData) => void;
    onClear?: () => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onDropdownVisibleChange?: (visible: boolean) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function toKeyArray(value: string | string[] | undefined): string[] {
    if (value === undefined) return [];
    return Array.isArray(value) ? value : [value];
}

interface TreeSelectNodeItemProps {
    node: FlatTreeNode;
    multiple: boolean;
    selected: boolean;
    checked: boolean;
    halfChecked: boolean;
    expanded: boolean;
    loading: boolean;
    loadData: boolean;
    disabled: boolean;
    renderLabel?: (label: any, node: TreeNodeData) => any;
    onToggleExpand: (key: string, data: TreeNodeData, hasChildren: boolean) => void;
    onSelectNode: (key: string, data: TreeNodeData) => void;
}

/** 单个树节点行的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用
 * （对齐 Select/Cascader 已验证的同一模式）。 */
function TreeSelectNodeItem(&{
    node,
    multiple,
    selected,
    checked,
    halfChecked,
    expanded,
    loading,
    loadData,
    disabled,
    renderLabel,
    onToggleExpand,
    onSelectNode,
}: TreeSelectNodeItemProps) @{
    <>
    <div
        role="treeitem"
        aria-selected={!multiple && selected}
        aria-disabled={node.disabled}
        aria-expanded={node.hasChildren ? expanded : undefined}
        class={['lotus-tree-select-node', !multiple && selected ? 'lotus-tree-select-node-selected' : '', node.disabled ? 'lotus-tree-select-node-disabled' : ''].filter(Boolean).join(' ')}
        style={{ paddingLeft: `${node.level * 20}px` }}
    >
        @if (!node.isLeaf || loadData) {
            <span
                class={['lotus-tree-select-switcher', expanded ? 'lotus-tree-select-switcher-expanded' : ''].filter(Boolean).join(' ')}
                onClick={() => onToggleExpand(node.key, node.data, node.hasChildren)}
            >
                @if (loading) {
                    <span class="lotus-tree-select-switcher-loading"><IconLoading /></span>
                } @if (!loading) {
                    <IconChevronRight />
                }
            </span>
        } @if (node.isLeaf && !loadData) {
            <span class="lotus-tree-select-switcher lotus-tree-select-switcher-placeholder" />
        }

        @if (multiple) {
            <span class="lotus-tree-select-node-checkbox" onClick={(event: MouseEvent) => event.stopPropagation()}>
                <Checkbox checked={checked} indeterminate={halfChecked} disabled={disabled || node.disabled} onChange={() => onSelectNode(node.key, node.data)} />
            </span>
        }

        <span class="lotus-tree-select-node-content" onClick={() => onSelectNode(node.key, node.data)}>
            @if (node.icon) {
                <span class="lotus-tree-select-node-icon">{node.icon}</span>
            }
            <span class="lotus-tree-select-node-label">{renderLabel ? renderLabel(node.label, node.data) : node.label}</span>
        </span>
    </div>

    <style>
        .lotus-tree-select-node {
            display: flex;
            align-items: center;
            gap: 4px;
            min-height: 32px;
            border-radius: var(--lotus-border-radius-small);
        }

        .lotus-tree-select-node:hover:not(.lotus-tree-select-node-disabled) {
            background: var(--lotus-color-fill-0);
        }

        .lotus-tree-select-node-selected {
            background: var(--lotus-color-fill-1);
            color: var(--lotus-color-primary);
        }

        .lotus-tree-select-node-disabled {
            color: var(--lotus-color-disabled-text);
            cursor: not-allowed;
        }

        .lotus-tree-select-switcher {
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

        .lotus-tree-select-switcher-placeholder { cursor: default; }

        .lotus-tree-select-switcher-expanded { transform: rotate(90deg); }

        .lotus-tree-select-switcher-loading {
            display: flex;
            animation: lotus-tree-select-spin 1s linear infinite;
        }

        @keyframes lotus-tree-select-spin {
            to { transform: rotate(360deg); }
        }

        .lotus-tree-select-node-checkbox {
            display: inline-flex;
            align-items: center;
            flex-shrink: 0;
        }

        .lotus-tree-select-node-content {
            display: flex;
            align-items: center;
            gap: 6px;
            flex: 1;
            min-width: 0;
            cursor: pointer;
            padding: 2px 4px;
        }

        .lotus-tree-select-node-icon {
            display: flex;
            align-items: center;
            flex-shrink: 0;
        }

        .lotus-tree-select-node-label {
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    </style>
    </>
}

/**
 * TreeSelect：树形选择器。本质是"Select 式触发器外壳 + Tree 渲染逻辑塞进
 * 浮层"——算法层（entity 索引、展开、三态级联、搜索）100% 复用 Tree 的
 * 四个纯函数模块（经 Foundation re-export），不重新实现；渲染层不直接嵌入
 * 整个 `<Tree>` 组件（会有双重搜索框/容器样式冲突，状态也难以和触发器
 * 联动），而是内联一份精简的节点渲染（去掉 Tree 自带的外层容器/搜索框/
 * 空状态定位，只保留展开开关+checkbox+label 三个核心视觉单元）。
 *
 * 触发器开关状态管理（document 级 mousedown 常驻监听 + 双 contains 判断）
 * 照搬 Cascader 已验证过的模式。响应式派生值（columns/searchResults 等）
 * 统一直接读 `state.xxx` 建立依赖，不经过 Foundation 方法（对齐 Cascader
 * 踩坑 #74 的教训——`foundation.method()` 内部用 `untrack()` 包裹的
 * `getState()` 会阻断 track() 的响应式依赖追踪）。
 */
export function TreeSelect(&{
    treeData = [],
    value,
    defaultValue,
    multiple = false,
    disabled = false,
    placeholder,
    size = 'default',
    validateStatus = 'default',
    borderless = false,
    showClear = false,
    position = 'bottomLeft',
    checkRelation = 'related',
    autoMergeValue = true,
    leafOnly = false,
    maxTagCount,
    expandedKeys: expandedKeysProp,
    defaultExpandedKeys,
    defaultExpandAll = false,
    autoExpandParent = true,
    onExpand,
    filterTreeNode = false,
    showFilteredOnly = false,
    searchPlaceholder,
    onSearch,
    loadData,
    onLoad,
    onLoadError,
    renderLabel,
    virtualize,
    onChange,
    onSelect,
    onClear,
    onFocus,
    onBlur,
    onDropdownVisibleChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: TreeSelectProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[entities] = track<KeyEntities>(() => buildKeyEntities(treeData));

    const isValueControlled = value !== undefined;
    const isExpandControlled = expandedKeysProp !== undefined;

    function computeInitialExpanded(ents: KeyEntities): Set<string> {
        if (isExpandControlled) return calcExpandedKeys(expandedKeysProp!, ents, autoExpandParent);
        if (defaultExpandAll) return calcAllExpandedKeys(ents);
        if (defaultExpandedKeys) return calcExpandedKeys(defaultExpandedKeys, ents, autoExpandParent);
        return new Set<string>();
    }

    const initialEntities = buildKeyEntities(treeData);
    const initialCheckedSource = multiple ? (isValueControlled ? value : defaultValue) : undefined;
    const initialCascade = initialCheckedSource !== undefined
        ? calcCheckedKeys(toKeyArray(initialCheckedSource), initialEntities)
        : { checkedKeys: new Set<string>(), halfCheckedKeys: new Set<string>() };
    const initialIndependent = multiple && checkRelation === 'unRelated' && initialCheckedSource !== undefined
        ? new Set(toKeyArray(initialCheckedSource).filter((k) => initialEntities[k]))
        : new Set<string>();
    const initialSingleSelected = !multiple
        ? ((isValueControlled ? value : defaultValue) as string | undefined) ?? null
        : null;

    let &[state] = track<TreeSelectState>({
        expandedKeys: computeInitialExpanded(initialEntities),
        checkedKeys: checkRelation === 'unRelated' ? new Set<string>() : initialCascade.checkedKeys,
        halfCheckedKeys: checkRelation === 'unRelated' ? new Set<string>() : initialCascade.halfCheckedKeys,
        independentCheckedKeys: initialIndependent,
        selectedKey: initialSingleSelected,
        searchInput: '',
        loadedKeys: new Set<string>(),
        loadingKeys: new Set<string>(),
    });
    let &[isOpen] = track<boolean>(false);
    let &[rootNode] = track<HTMLElement | null>(null);
    let &[listNode] = track<HTMLElement | null>(null);

    const foundation = new TreeSelectFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TreeSelectState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控 value 同步：外部传入新值时，重新算三态（multiple related）/独立
    // 集合（multiple unRelated）/直接替换（单选）。
    effect(() => {
        if (!isValueControlled) return;
        const current = untrack(() => state);
        const ents = untrack(() => entities);
        if (multiple) {
            const keys = toKeyArray(value);
            if (checkRelation === 'unRelated') {
                const next = new Set(keys.filter((k) => ents[k]));
                const same = current.independentCheckedKeys.size === next.size && [...next].every((k) => current.independentCheckedKeys.has(k));
                if (same) return;
                untrack(() => { state = { ...current, independentCheckedKeys: next }; });
                return;
            }
            const result = calcCheckedKeys(keys, ents);
            const same = current.checkedKeys.size === result.checkedKeys.size
                && [...result.checkedKeys].every((k) => current.checkedKeys.has(k));
            if (same) return;
            untrack(() => { state = { ...current, checkedKeys: result.checkedKeys, halfCheckedKeys: result.halfCheckedKeys }; });
        } else {
            const next = (value as string | undefined) ?? null;
            if (current.selectedKey === next) return;
            untrack(() => { state = { ...current, selectedKey: next }; });
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
        untrack(() => { state = { ...current, expandedKeys: next }; });
    });

    // 直接读 state.searchInput/state.expandedKeys 建立响应式依赖（不经过
    // foundation 方法，参照 Cascader 踩坑 #74）。
    let &[searchResult] = track(() =>
        filterTreeNode && state.searchInput ? computeSearchResult(state.searchInput, entities, filterTreeNode) : null,
    );

    let &[flatNodes] = track<FlatTreeNode[]>(() =>
        flattenTreeData(
            treeData,
            state.expandedKeys,
            showFilteredOnly && searchResult ? searchResult.filteredShownKeys : null,
        ),
    );

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

    let &[virtualVisibleNodes] = track<Array<{ node: FlatTreeNode; index: number }>>(() => {
        if (!virtualRange) return [];
        const result: Array<{ node: FlatTreeNode; index: number }> = [];
        for (let i = virtualRange.startIndex; i <= virtualRange.endIndex; i++) {
            const node = flatNodes[i];
            if (node) result.push({ node, index: i });
        }
        return result;
    });

    function checkedKeysFor(): Set<string> {
        return checkRelation === 'unRelated' ? untrack(() => state).independentCheckedKeys : untrack(() => state).checkedKeys;
    }

    function notifyChange() {
        if (multiple) {
            const value = foundation.resolveValue(untrack(() => entities), checkRelation, { autoMergeValue, leafOnly });
            onChange?.(value);
        } else {
            const key = untrack(() => state).selectedKey;
            onChange?.(key ?? undefined);
        }
    }

    function handleToggleExpand(key: string, node: TreeNodeData, hasChildren: boolean) {
        const currentState = untrack(() => state);
        const wasExpanded = currentState.expandedKeys.has(key);

        if (!wasExpanded && loadData && !hasChildren && !currentState.loadedKeys.has(key)) {
            foundation.handleLoadStart(key);
            loadData(node)
                .then((children) => {
                    node.children = children;
                    entities = buildKeyEntities(treeData);
                    foundation.handleLoadEnd(key, true);
                    const next = isExpandControlled ? new Set([...untrack(() => state).expandedKeys, key]) : foundation.handleExpand(key);
                    onLoad?.([...untrack(() => state).loadedKeys], node);
                    onExpand?.([...next], { expanded: true, node });
                })
                .catch((error: unknown) => {
                    foundation.handleLoadEnd(key, false);
                    onLoadError?.(node, error);
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
            foundation.handleCheck(key, untrack(() => entities), checkRelation);
            notifyChange();
            return;
        }
        const next = foundation.handleSelect(key);
        onSelect?.(next, next !== null, node);
        notifyChange();
        if (next !== null) {
            isOpen = false;
            onDropdownVisibleChange?.(false);
        }
    }

    function handleSearchInput(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        foundation.handleSearch(input, untrack(() => entities), filterTreeNode);
        onSearch?.(input);
    }

    function handleTriggerClick() {
        if (disabled) return;
        const next = !untrack(() => isOpen);
        isOpen = next;
        onDropdownVisibleChange?.(next);
    }

    function handleClear(event: MouseEvent) {
        event.stopPropagation();
        untrack(() => {
            state = { ...state, selectedKey: null, checkedKeys: new Set(), halfCheckedKeys: new Set(), independentCheckedKeys: new Set() };
        });
        onChange?.(multiple ? [] : undefined);
        onClear?.();
    }

    // 同 Cascader：document 级常驻 mousedown 监听，双 contains 判断处理 Portal 场景。
    effect(() => {
        const handleDocumentMouseDown = (event: MouseEvent) => {
            if (!untrack(() => isOpen)) return;
            if (!(event.target instanceof Node)) return;
            const root = untrack(() => rootNode);
            if (root?.contains(event.target)) return;
            const list = untrack(() => listNode);
            if (list?.contains(event.target)) return;
            isOpen = false;
            onDropdownVisibleChange?.(false);
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
        return () => document.removeEventListener('mousedown', handleDocumentMouseDown);
    });

    let &[singleSelectedLabel] = track<any>(() => {
        if (multiple || !state.selectedKey) return undefined;
        return entities[state.selectedKey]?.data.label;
    });

    let &[selectedNodesData] = track<TreeNodeData[]>(() => {
        if (!multiple) return [];
        const keys = checkRelation === 'unRelated' ? state.independentCheckedKeys : state.checkedKeys;
        const value = checkRelation === 'unRelated' ? [...keys] : normalizeCheckedKeysToValue(keys, entities, { autoMergeValue, leafOnly });
        return value.map((k) => entities[k]?.data).filter((d): d is TreeNodeData => !!d);
    });

    let &[tagFold] = track(() => foldTags(selectedNodesData, maxTagCount));

    function handleRemoveTag(node: TreeNodeData, event: MouseEvent) {
        event.stopPropagation();
        foundation.handleCheck(node.key, untrack(() => entities), checkRelation);
        notifyChange();
    }

    let &[allowClear] = track<boolean>(() => {
        if (disabled || !showClear) return false;
        return multiple ? selectedNodesData.length > 0 : !!state.selectedKey;
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-tree-select',
            `lotus-tree-select-size-${size}`,
            `lotus-tree-select-status-${validateStatus}`,
            borderless ? 'lotus-tree-select-borderless' : '',
            disabled ? 'lotus-tree-select-disabled' : '',
            isOpen ? 'lotus-tree-select-open' : '',
            multiple ? 'lotus-tree-select-multiple' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }}>
            <Popover
                trigger="custom"
                visible={isOpen}
                position={position}
                spacing={4}
                closeOnEsc={true}
                content={
                    <div class="lotus-tree-select-panel" ref={(node: HTMLElement) => { listNode = node; }}>
                        @if (filterTreeNode) {
                            <div class="lotus-tree-select-search-box">
                                <IconSearch />
                                <input
                                    class="lotus-tree-select-search-input"
                                    type="text"
                                    value={state.searchInput}
                                    placeholder={searchPlaceholder}
                                    onInput={handleSearchInput}
                                />
                            </div>
                        }
                        @if (flatNodes.length === 0) {
                            <div class="lotus-tree-select-empty">暂无数据</div>
                        }
                        @if (virtualize) {
                            <div
                                class="lotus-tree-select-tree lotus-tree-select-tree-virtual"
                                role="tree"
                                aria-multiselectable={multiple}
                                style={{ height: `${virtualize.height ?? 280}px` }}
                                onScroll={handleVirtualScroll}
                            >
                                <div style={{ height: `${virtualRange?.totalHeight ?? 0}px` }}>
                                    <div style={{ transform: `translateY(${virtualRange?.offsetY ?? 0}px)` }}>
                                        @for (const entry of virtualVisibleNodes; key entry.node.key) {
                                            <div style={{ height: `${virtualize.itemSize}px` }}>
                                                <TreeSelectNodeItem
                                                    node={entry.node}
                                                    multiple={multiple}
                                                    selected={entry.node.key === state.selectedKey}
                                                    checked={(checkRelation === 'unRelated' ? state.independentCheckedKeys : state.checkedKeys).has(entry.node.key)}
                                                    halfChecked={checkRelation === 'related' && state.halfCheckedKeys.has(entry.node.key)}
                                                    expanded={state.expandedKeys.has(entry.node.key)}
                                                    loading={state.loadingKeys.has(entry.node.key)}
                                                    loadData={!!loadData}
                                                    disabled={disabled}
                                                    renderLabel={renderLabel}
                                                    onToggleExpand={handleToggleExpand}
                                                    onSelectNode={handleSelectNode}
                                                />
                                            </div>
                                        }
                                    </div>
                                </div>
                            </div>
                        } @else {
                            <div class="lotus-tree-select-tree" role="tree" aria-multiselectable={multiple}>
                                @for (const node of flatNodes; index i; key node.key) {
                                    <TreeSelectNodeItem
                                        node={node}
                                        multiple={multiple}
                                        selected={node.key === state.selectedKey}
                                        checked={(checkRelation === 'unRelated' ? state.independentCheckedKeys : state.checkedKeys).has(node.key)}
                                        halfChecked={checkRelation === 'related' && state.halfCheckedKeys.has(node.key)}
                                        expanded={state.expandedKeys.has(node.key)}
                                        loading={state.loadingKeys.has(node.key)}
                                        loadData={!!loadData}
                                        disabled={disabled}
                                        renderLabel={renderLabel}
                                        onToggleExpand={handleToggleExpand}
                                        onSelectNode={handleSelectNode}
                                    />
                                }
                            </div>
                        }
                    </div>
                }
            >
                <div
                    role="combobox"
                    aria-expanded={isOpen}
                    aria-haspopup="tree"
                    aria-label={ariaLabel}
                    aria-disabled={disabled}
                    tabIndex={disabled ? -1 : 0}
                    class="lotus-tree-select-trigger"
                    onClick={handleTriggerClick}
                    onFocus={(event: FocusEvent) => onFocus?.(event)}
                    onBlur={(event: FocusEvent) => onBlur?.(event)}
                >
                    @if (multiple) {
                        <div class="lotus-tree-select-tags">
                            @if (selectedNodesData.length === 0) {
                                <span class="lotus-tree-select-placeholder">{placeholder}</span>
                            } @else {
                                <>
                                    @for (const node of tagFold.visible; key node.key) {
                                        <span class="lotus-tree-select-tag">
                                            <span class="lotus-tree-select-tag-label">{node.label}</span>
                                            <span class="lotus-tree-select-tag-remove" onClick={(event: MouseEvent) => handleRemoveTag(node, event)}>
                                                <IconClear />
                                            </span>
                                        </span>
                                    }
                                    @if (tagFold.restCount > 0) {
                                        <span class="lotus-tree-select-tag lotus-tree-select-tag-rest">{`+${tagFold.restCount}`}</span>
                                    }
                                </>
                            }
                        </div>
                    } @else {
                        @if (singleSelectedLabel !== undefined) {
                            <span class="lotus-tree-select-value">{singleSelectedLabel}</span>
                        } @else {
                            <span class="lotus-tree-select-placeholder">{placeholder}</span>
                        }
                    }
                    @if (allowClear) {
                        <span class="lotus-tree-select-clear" aria-label={locale.Select.clear} onClick={handleClear}>
                            <IconClear />
                        </span>
                    }
                    <span class="lotus-tree-select-arrow">
                        <IconChevronDown />
                    </span>
                </div>
            </Popover>
        </div>

        <style>
            .lotus-tree-select {
                display: inline-block;
                width: 100%;
            }

            .lotus-tree-select-trigger {
                display: flex;
                align-items: center;
                width: 100%;
                box-sizing: border-box;
                gap: 6px;
                padding: 0 var(--lotus-spacing-tight);
                background: var(--lotus-color-bg-1);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                transition: border-color 0.2s ease;
            }

            .lotus-tree-select-open .lotus-tree-select-trigger,
            .lotus-tree-select-trigger:hover {
                border-color: var(--lotus-color-primary);
            }

            .lotus-tree-select-borderless .lotus-tree-select-trigger {
                border-color: transparent;
                background: transparent;
            }

            .lotus-tree-select-disabled .lotus-tree-select-trigger {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
                border-color: var(--lotus-color-border);
            }

            .lotus-tree-select-status-warning .lotus-tree-select-trigger { border-color: var(--lotus-color-warning); }
            .lotus-tree-select-status-error .lotus-tree-select-trigger { border-color: var(--lotus-color-danger); }

            .lotus-tree-select-size-large .lotus-tree-select-trigger { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }
            .lotus-tree-select-size-default .lotus-tree-select-trigger { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-tree-select-size-small .lotus-tree-select-trigger { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }

            .lotus-tree-select-multiple .lotus-tree-select-trigger {
                height: auto;
                min-height: var(--lotus-height-control-default);
                padding: 4px var(--lotus-spacing-tight);
            }

            .lotus-tree-select-value,
            .lotus-tree-select-placeholder {
                flex: 1;
                min-width: 0;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                color: var(--lotus-color-text-0);
            }

            .lotus-tree-select-placeholder { color: var(--lotus-color-text-3); }

            .lotus-tree-select-disabled .lotus-tree-select-value,
            .lotus-tree-select-disabled .lotus-tree-select-placeholder {
                color: var(--lotus-color-disabled-text);
            }

            .lotus-tree-select-arrow {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
                font-size: 12px;
                transition: transform 0.2s ease;
            }

            .lotus-tree-select-open .lotus-tree-select-arrow { transform: rotate(180deg); }

            .lotus-tree-select-clear {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-tree-select-clear:hover { color: var(--lotus-color-text-0); }

            .lotus-tree-select-tags {
                display: flex;
                flex: 1;
                flex-wrap: wrap;
                gap: 4px;
                min-width: 0;
            }

            .lotus-tree-select-tag {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                padding: 2px 6px;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-tree-select-tag-rest {
                color: var(--lotus-color-text-2);
            }

            .lotus-tree-select-tag-remove {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                font-size: 10px;
            }

            .lotus-tree-select-tag-remove:hover { color: var(--lotus-color-text-0); }

            .lotus-tree-select-panel {
                display: flex;
                flex-direction: column;
                min-width: 240px;
                max-width: 360px;
            }

            .lotus-tree-select-search-box {
                display: flex;
                align-items: center;
                gap: 6px;
                padding: 6px 8px;
                border-bottom: 1px solid var(--lotus-color-border);
                color: var(--lotus-color-text-2);
            }

            .lotus-tree-select-search-input {
                flex: 1;
                border: none;
                outline: none;
                background: transparent;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-tree-select-tree {
                max-height: 300px;
                overflow-y: auto;
                padding: 4px;
            }

            .lotus-tree-select-tree-virtual {
                max-height: none;
            }

            .lotus-tree-select-empty {
                padding: var(--lotus-spacing-base);
                text-align: center;
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}
