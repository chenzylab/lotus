import { track, effect, untrack } from 'ripple';
import {
    TreeFoundation,
    buildKeyEntities,
    flattenTreeData,
    calcExpandedKeys,
    calcAllExpandedKeys,
    calcCheckedKeys,
    computeSearchResult,
    type TreeState,
    type TreeNodeData,
    type FilterTreeNode,
    type KeyEntities,
} from '@lotus/foundation/navigation/tree';
import { Checkbox } from '../../input/checkbox/index.tsrx';
import { IconChevronRight, IconLoading, IconSearch, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { TreeNodeData, FilterTreeNode };

export interface TreeProps {
    treeData: TreeNodeData[];
    multiple?: boolean;
    value?: string | string[];
    defaultValue?: string | string[];
    onChange?: (value: string | string[] | undefined) => void;
    onSelect?: (selectedKey: string | null, selected: boolean, node: TreeNodeData) => void;
    expandedKeys?: string[];
    defaultExpandedKeys?: string[];
    defaultExpandAll?: boolean;
    autoExpandParent?: boolean;
    onExpand?: (expandedKeys: string[], info: { expanded: boolean; node: TreeNodeData }) => void;
    disabled?: boolean;
    filterTreeNode?: FilterTreeNode;
    showFilteredOnly?: boolean;
    searchPlaceholder?: string;
    onSearch?: (input: string) => void;
    loadData?: (node: TreeNodeData) => Promise<TreeNodeData[]>;
    onLoad?: (loadedKeys: string[], node: TreeNodeData) => void;
    renderLabel?: (label: any, node: TreeNodeData) => any;
    blockNode?: boolean;
    emptyContent?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function toKeyArray(value: string | string[] | undefined): string[] {
    if (value === undefined) return [];
    return Array.isArray(value) ? value : [value];
}

/**
 * Tree：完整版（展开/收起、单选/多选三态级联、搜索过滤、loadData 异步
 * 懒加载）。渲染层用 Foundation 的 flattenTreeData 摊平结果做单层 @for，
 * 不在循环体内做可见性判断（对齐 Breadcrumb 的踩坑 #13 修复范式——
 * 可见性过滤在数据生成阶段完成，不是渲染阶段）。多选三态视觉直接复用
 * 已有 Checkbox 组件的 indeterminate prop。
 */
export function Tree(&{
    treeData,
    multiple = false,
    value: valueProp,
    defaultValue,
    onChange,
    onSelect,
    expandedKeys: expandedKeysProp,
    defaultExpandedKeys,
    defaultExpandAll = false,
    autoExpandParent = true,
    onExpand,
    disabled = false,
    filterTreeNode = false,
    showFilteredOnly = false,
    searchPlaceholder,
    onSearch,
    loadData,
    onLoad,
    renderLabel,
    blockNode = true,
    emptyContent,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TreeProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isValueControlled = valueProp !== undefined;
    const isExpandControlled = expandedKeysProp !== undefined;

    let &[entities] = track<KeyEntities>(() => buildKeyEntities(treeData));

    function computeInitialExpanded(ents: KeyEntities): Set<string> {
        if (isExpandControlled) return calcExpandedKeys(expandedKeysProp!, ents, autoExpandParent);
        if (defaultExpandAll) return calcAllExpandedKeys(ents);
        if (defaultExpandedKeys) return calcExpandedKeys(defaultExpandedKeys, ents, autoExpandParent);
        return new Set<string>();
    }

    const initialEntities = buildKeyEntities(treeData);
    const initialCheckedSource = multiple ? (isValueControlled ? valueProp : defaultValue) : undefined;
    const initialCascade = initialCheckedSource !== undefined
        ? calcCheckedKeys(toKeyArray(initialCheckedSource), initialEntities)
        : { checkedKeys: new Set<string>(), halfCheckedKeys: new Set<string>() };
    const initialSingleSelected = !multiple
        ? ((isValueControlled ? valueProp : defaultValue) as string | undefined) ?? null
        : null;

    let &[state] = track<TreeState>({
        expandedKeys: computeInitialExpanded(initialEntities),
        checkedKeys: initialCascade.checkedKeys,
        halfCheckedKeys: initialCascade.halfCheckedKeys,
        selectedKey: initialSingleSelected,
        searchInput: '',
        loadedKeys: new Set<string>(),
        loadingKeys: new Set<string>(),
    });

    const foundation = new TreeFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TreeState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控 value 同步：外部传入新值时，重新算三态（多选）或直接替换（单选）。
    effect(() => {
        if (!isValueControlled) return;
        const current = untrack(() => state);
        const ents = untrack(() => entities);
        if (multiple) {
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

    // foundation.handleSearch() 已经把展开祖先链的副作用写进 state；这里
    // 用同一个纯函数 computeSearchResult 幂等地重新计算一次搜索结果，
    // 只是为了拿到 filteredShownKeys 供 showFilteredOnly 过滤渲染列表。
    let &[searchResult] = track(() =>
        filterTreeNode && state.searchInput ? computeSearchResult(state.searchInput, entities, filterTreeNode) : null,
    );

    let &[flatNodes] = track(() =>
        flattenTreeData(
            treeData,
            state.expandedKeys,
            showFilteredOnly && searchResult ? searchResult.filteredShownKeys : null,
        ),
    );

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
            const result = foundation.handleCheck(key, untrack(() => entities));
            onChange?.([...result.checkedKeys]);
            return;
        }
        const next = foundation.handleSelect(key);
        onSelect?.(next, next !== null, node);
        onChange?.(next ?? undefined);
    }

    function handleSearchInput(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        foundation.handleSearch(input, untrack(() => entities), filterTreeNode);
        onSearch?.(input);
    }

    let &[classes] = track<string>(() =>
        ['lotus-tree', blockNode ? 'lotus-tree-block' : '', disabled ? 'lotus-tree-disabled' : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @if (filterTreeNode) {
                <div class="lotus-tree-search">
                    <span class="lotus-tree-search-icon"><IconSearch /></span>
                    <input
                        type="text"
                        class="lotus-tree-search-input"
                        placeholder={searchPlaceholder ?? locale.Tree.searchPlaceholder}
                        value={state.searchInput}
                        onInput={handleSearchInput}
                    />
                    @if (state.searchInput) {
                        <button
                            type="button"
                            class="lotus-tree-search-clear"
                            aria-label={locale.Tree.clearSearch}
                            onClick={() => foundation.handleSearch('', entities, filterTreeNode)}
                        >
                            <IconClose />
                        </button>
                    }
                </div>
            }

            @if (flatNodes.length === 0) {
                <div class="lotus-tree-empty">{emptyContent ?? locale.Tree.emptyContent}</div>
            }

            @for (const node of flatNodes; index i; key node.key) {
                <div
                    class={[
                        'lotus-tree-node',
                        node.key === state.selectedKey ? 'lotus-tree-node-selected' : '',
                        node.disabled ? 'lotus-tree-node-disabled' : '',
                    ].filter(Boolean).join(' ')}
                    style={{ paddingLeft: `${node.level * 20}px` }}
                >
                    @if (!node.isLeaf || loadData) {
                        <span
                            class={[
                                'lotus-tree-switcher',
                                state.expandedKeys.has(node.key) ? 'lotus-tree-switcher-expanded' : '',
                            ].filter(Boolean).join(' ')}
                            onClick={() => handleToggleExpand(node.key, node.data, node.hasChildren)}
                        >
                            @if (state.loadingKeys.has(node.key)) {
                                <span class="lotus-tree-switcher-loading"><IconLoading /></span>
                            } @if (!state.loadingKeys.has(node.key)) {
                                <IconChevronRight />
                            }
                        </span>
                    } @if (node.isLeaf && !loadData) {
                        <span class="lotus-tree-switcher lotus-tree-switcher-placeholder" />
                    }

                    @if (multiple) {
                        <Checkbox
                            checked={state.checkedKeys.has(node.key)}
                            indeterminate={state.halfCheckedKeys.has(node.key)}
                            disabled={disabled || node.disabled}
                            onChange={() => handleSelectNode(node.key, node.data)}
                            aria-label={typeof node.label === 'string' ? node.label : node.key}
                        />
                    }

                    <span
                        class="lotus-tree-node-content"
                        onClick={() => { if (!multiple) handleSelectNode(node.key, node.data); }}
                    >
                        @if (node.icon) {
                            <span class="lotus-tree-node-icon">{node.icon}</span>
                        }
                        <span class="lotus-tree-node-label">{renderLabel ? renderLabel(node.label, node.data) : node.label}</span>
                    </span>
                </div>
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

            .lotus-tree-node {
                display: flex;
                align-items: center;
                gap: 4px;
                min-height: 32px;
                border-radius: var(--lotus-border-radius-small);
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
        </style>
    </>
}
