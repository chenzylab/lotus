import { track, untrack, effect } from 'ripple';
import {
    CascaderFoundation,
    buildCascaderEntities,
    computeColumns,
    computeCascaderSearchResult,
    isLeafEntity,
    joinValuePath,
    type CascaderState,
    type CascaderNodeData,
    type CascaderEntities,
    type CascaderEntity,
    type CascaderFilterTreeNode,
} from '@lotus/foundation/input/cascader';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { IconChevronDown, IconChevronRight, IconClear, IconSearch } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';
import { Checkbox } from '../checkbox/index.tsrx';
import { Spin } from '../../feedback/spin/index.tsrx';

export type CascaderSize = 'large' | 'default' | 'small';
export type CascaderValidateStatus = 'default' | 'warning' | 'error';
export type CascaderCheckRelation = 'related' | 'unRelated';
export type { CascaderNodeData };

type ValuePath = Array<string | number>;

export interface CascaderProps {
    treeData?: CascaderNodeData[];
    value?: ValuePath | ValuePath[];
    defaultValue?: ValuePath | ValuePath[];
    multiple?: boolean;
    disabled?: boolean;
    placeholder?: any;
    size?: CascaderSize;
    validateStatus?: CascaderValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    position?: FloatingPosition;
    /** 非叶子节点是否可直接选中（单选），默认 false（对齐 Semi）。 */
    changeOnSelect?: boolean;
    /** 触发下一级展开的方式，默认 click（对齐 Semi）。 */
    showNext?: 'click' | 'hover';
    /** 多选：父全选时 value 只保留父路径，不逐一列出子孙，默认 true。 */
    autoMergeValue?: boolean;
    /** 多选：value 只保留叶子节点路径，默认 false，优先级高于 autoMergeValue。 */
    leafOnly?: boolean;
    /** 多选三态级联开关，'unRelated' 时选中态互相独立，默认 'related'。 */
    checkRelation?: CascaderCheckRelation;
    /** 是否开启搜索，true 用内置路径文本匹配，函数则完全交给调用方判断。 */
    filterTreeNode?: CascaderFilterTreeNode;
    /** 搜索结果是否只保留叶子节点路径，默认 true。 */
    filterLeafOnly?: boolean;
    searchPlaceholder?: any;
    /** 路径展示分隔符，默认 ' / '。 */
    separator?: string;
    /** 大数据量场景下开启单列固定行高虚拟滚动（对齐 Select 已验证的实现模式，
     * 复用同一份 `base/virtual-list.ts` 纯算法）——每一级列各自独立虚拟化，
     * 因为 Cascader 是多列联动、每列的选项数量可能都很大。 */
    virtualize?: { height?: number; itemSize: number };
    /** 异步加载子节点：约定回调里外部自行更新 treeData 对应节点的 children，
     * Cascader 监听 treeData 引用变化重新渲染（对齐 Semi loadData 的 Promise<void> 约定）。 */
    loadData?: (entity: { value: string | number; label: any; valuePath: ValuePath }) => Promise<void>;
    onChange?: (value: ValuePath | ValuePath[] | undefined) => void;
    onClear?: () => void;
    onSearch?: (input: string) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onDropdownVisibleChange?: (visible: boolean) => void;
    onLoadError?: (entity: { value: string | number; label: any; valuePath: ValuePath }, error: unknown) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function isMultiValue(v: ValuePath | ValuePath[] | undefined): v is ValuePath[] {
    return Array.isArray(v) && (v.length === 0 || Array.isArray(v[0]));
}

interface CascaderColumnItemProps {
    entity: CascaderEntity;
    multiple: boolean;
    active: boolean;
    checked: boolean;
    halfChecked: boolean;
    disabled: boolean;
    loading: boolean;
    isLeaf: boolean;
    onItemClick: (entity: CascaderEntity) => void;
    onItemHover: (entity: CascaderEntity) => void;
    onItemCheck: (entity: CascaderEntity) => void;
}

/** 单个级联项 `<li>` 的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用
 * （对齐 Select 组件 `SelectOptionItem` 已验证的同一模式）。 */
function CascaderColumnItem(&{
    entity,
    multiple,
    active,
    checked,
    halfChecked,
    disabled,
    loading,
    isLeaf,
    onItemClick,
    onItemHover,
    onItemCheck,
}: CascaderColumnItemProps) @{
    <>
    <li
        role="menuitem"
        aria-expanded={!isLeaf ? active : undefined}
        aria-disabled={disabled}
        class={['lotus-cascader-item', active ? 'lotus-cascader-item-active' : '', disabled ? 'lotus-cascader-item-disabled' : ''].filter(Boolean).join(' ')}
        onClick={() => onItemClick(entity)}
        onMouseEnter={() => onItemHover(entity)}
    >
        @if (multiple) {
            <span class="lotus-cascader-item-checkbox" onClick={(event: MouseEvent) => event.stopPropagation()}>
                <Checkbox checked={checked} indeterminate={halfChecked} disabled={disabled} onChange={() => onItemCheck(entity)} />
            </span>
        }
        <span class="lotus-cascader-item-label">{entity.data.label}</span>
        @if (loading) {
            <Spin size="small" />
        }
        @if (!isLeaf && !loading) {
            <span class="lotus-cascader-item-arrow"><IconChevronRight /></span>
        }
    </li>

    <style>
        .lotus-cascader-item {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 8px;
            border-radius: var(--lotus-border-radius-small);
            cursor: pointer;
            font-size: var(--lotus-font-body-size);
            color: var(--lotus-color-text-0);
            white-space: nowrap;
        }

        .lotus-cascader-item:hover { background: var(--lotus-color-fill-0); }

        .lotus-cascader-item-active {
            color: var(--lotus-color-primary);
            background: var(--lotus-color-fill-0);
        }

        .lotus-cascader-item-disabled {
            color: var(--lotus-color-disabled-text);
            cursor: not-allowed;
        }

        .lotus-cascader-item-disabled:hover { background: transparent; }

        .lotus-cascader-item-checkbox {
            display: inline-flex;
            align-items: center;
            flex-shrink: 0;
        }

        .lotus-cascader-item-label {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .lotus-cascader-item-arrow {
            display: inline-flex;
            align-items: center;
            color: var(--lotus-color-text-3);
            font-size: 12px;
            flex-shrink: 0;
        }
    </style>
    </>
}

/**
 * Cascader：多级联动选择器。单个 Popover(trigger="custom") + 内部横向 flex
 * 多列面板（对齐 Semi 架构——多列渲染在同一浮层里，不是多个独立定位的浮层
 * 依次展开），浮层定位完全交给 Popover 复用的共享定位引擎，不重新实现坐标
 * 数学。多选三态级联复用 Tree 的 check-cascade 算法（Semi 源码本身也是这么
 * 做的）。搜索模式下浮层内容整体切换成打平的单列匹配结果列表。
 */
export function Cascader(&{
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
    changeOnSelect = false,
    showNext = 'click',
    autoMergeValue = true,
    leafOnly = false,
    checkRelation = 'related',
    filterTreeNode = false,
    filterLeafOnly = true,
    searchPlaceholder,
    separator = ' / ',
    virtualize,
    loadData,
    onChange,
    onClear,
    onSearch,
    onFocus,
    onBlur,
    onDropdownVisibleChange,
    onLoadError,
    'aria-label': ariaLabel,
    style,
    class: className,
}: CascaderProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[entities] = track<CascaderEntities>(() => buildCascaderEntities(treeData));

    const isControlled = value !== undefined;
    const initialState: CascaderState = {
        activeKeys: new Set(),
        selectedKey: null,
        checkedKeys: new Set(),
        halfCheckedKeys: new Set(),
        searchInput: '',
        loadingKeys: new Set(),
        loadedKeys: new Set(),
    };
    let &[state] = track<CascaderState>(initialState);
    let &[isOpen] = track<boolean>(false);
    let &[rootNode] = track<HTMLElement | null>(null);
    let &[listNode] = track<HTMLElement | null>(null);

    const foundation = new CascaderFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<CascaderState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控值同步：多选是二维路径数组，需要重算三态选中集；单选是一维路径，
    // 直接定位 selectedKey。同 Select 的 hasBeenControlled 处理，避免非受控
    // 写入后又变回 undefined 时残留陈旧值。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        const currentEntities = entities;
        if (value === undefined) {
            if (untrack(() => hasBeenControlled)) {
                untrack(() => {
                    if (multiple) foundation.syncCheckedKeysFromValue([], currentEntities);
                    else state = { ...state, selectedKey: null };
                });
            }
            return;
        }
        untrack(() => { hasBeenControlled = true; });
        if (multiple) {
            const paths = isMultiValue(value) ? value : [];
            untrack(() => foundation.syncCheckedKeysFromValue(paths, currentEntities));
        } else {
            const path = isMultiValue(value) ? undefined : (value as ValuePath | undefined);
            if (path) {
                const key = joinValuePath(path);
                untrack(() => { state = { ...state, selectedKey: currentEntities[key] ? key : null }; });
            }
        }
    });

    // defaultValue 只在挂载时消费一次（非受控初值）。
    effect(() => {
        if (isControlled) return;
        const currentEntities = untrack(() => entities);
        untrack(() => {
            if (defaultValue === undefined) return;
            if (multiple) {
                const paths = isMultiValue(defaultValue) ? defaultValue : [];
                foundation.syncCheckedKeysFromValue(paths, currentEntities);
            } else {
                const path = isMultiValue(defaultValue) ? undefined : (defaultValue as ValuePath | undefined);
                if (path) {
                    const key = joinValuePath(path);
                    if (currentEntities[key]) state = { ...state, selectedKey: key };
                }
            }
        });
    });

    // 直接读 state.activeKeys（而非 foundation.computeColumns()，其内部经
    // adapter.getState() 的 untrack() 包裹会阻断响应式依赖追踪，导致这个
    // track() 派生值只在挂载时计算一次、之后 activeKeys 变化不会重新求值——
    // 对齐 Tree 组件 flatNodes 直接读 state.expandedKeys 传给纯函数的模式）。
    let &[columns] = track<CascaderEntity[][]>(() => computeColumns(treeData, state.activeKeys, entities));

    // 每一列各自独立的虚拟滚动位置（colIndex -> scrollTop），因为 Cascader
    // 是多列联动、每列的选项数量可能都很大，不能只对某一列做虚拟化。
    let &[columnScrollTops] = track<Record<number, number>>({});

    function handleColumnScroll(colIndex: number, event: Event) {
        const scrollTop = (event.target as HTMLElement).scrollTop;
        untrack(() => { columnScrollTops = { ...columnScrollTops, [colIndex]: scrollTop }; });
    }

    let &[virtualColumns] = track(() => {
        if (!virtualize) return null;
        return columns.map((column, colIndex) => {
            const scrollTop = columnScrollTops[colIndex] ?? 0;
            const range = calcVirtualRange({
                itemCount: column.length,
                itemHeight: virtualize.itemSize,
                containerHeight: virtualize.height ?? 280,
                scrollTop,
            });
            const visible: Array<{ entity: CascaderEntity; index: number }> = [];
            for (let i = range.startIndex; i <= range.endIndex; i++) {
                const entity = column[i];
                if (entity) visible.push({ entity, index: i });
            }
            return { range, visible };
        });
    });

    // 同理：直接读 state.searchInput 建立响应式依赖，不经过 foundation 方法。
    let &[searchResults] = track(() => computeCascaderSearchResult(state.searchInput, entities, filterTreeNode, { separator, filterLeafOnly }));

    let &[isSearching] = track<boolean>(() => !!filterTreeNode && state.searchInput.length > 0);

    function notifyChange() {
        if (multiple) {
            const paths = foundation.resolveValue(untrack(() => entities), { autoMergeValue, leafOnly });
            onChange?.(paths);
        } else {
            const key = untrack(() => state).selectedKey;
            const path = key ? untrack(() => entities)[key]?.valuePath : undefined;
            onChange?.(path);
        }
    }

    function triggerLoad(entity: CascaderEntity) {
        if (!loadData) return;
        if (isLeafEntity(entity)) return;
        const s = untrack(() => state);
        if (s.loadingKeys.has(entity.key) || s.loadedKeys.has(entity.key)) return;
        foundation.handleLoadStart(entity.key);
        loadData({ value: entity.data.value, label: entity.data.label, valuePath: entity.valuePath })
            .then(() => { foundation.handleLoadEnd(entity.key, true); })
            .catch((error: unknown) => {
                foundation.handleLoadEnd(entity.key, false);
                onLoadError?.({ value: entity.data.value, label: entity.data.label, valuePath: entity.valuePath }, error);
            });
    }

    function handleItemActivate(entity: CascaderEntity) {
        if (entity.data.disabled) return;
        foundation.handleActivate(entity.key, untrack(() => entities));
        triggerLoad(entity);
    }

    function handleItemSelect(entity: CascaderEntity) {
        if (entity.data.disabled) return;
        if (multiple) {
            foundation.handleMultipleCheck(entity.key, untrack(() => entities), checkRelation, isControlled);
            notifyChange();
            triggerLoad(entity);
            return;
        }
        const result = foundation.handleSingleSelect(entity.key, untrack(() => entities), changeOnSelect, isControlled);
        if (result.selectedKey !== null) notifyChange();
        if (result.canClose) {
            isOpen = false;
            onDropdownVisibleChange?.(false);
        }
        if (!result.canClose) triggerLoad(entity);
    }

    // 多选模式下点击行本身（非 checkbox）永远只展开路径，不勾选——勾选由
    // Checkbox 自己的 onChange 独立触发。对齐 Semi handleSingleSelect：多选时
    // 先 activeKeys=path，只有 clickToSelect（lotus 未实现该增强）或
    // isLeaf&&enableLeafClick 才会让点击行同时触发勾选，默认两者都是 false，
    // 即默认配置下点文字=展开、点 checkbox=勾选，两个交互互不干扰。
    function handleColumnItemClick(entity: CascaderEntity) {
        if (multiple) {
            handleItemActivate(entity);
            return;
        }
        const leaf = isLeafEntity(entity);
        if (showNext === 'hover' && !leaf) {
            handleItemActivate(entity);
            return;
        }
        if (leaf || changeOnSelect) {
            handleItemSelect(entity);
            return;
        }
        handleItemActivate(entity);
    }

    function handleColumnItemHover(entity: CascaderEntity) {
        if (showNext !== 'hover') return;
        if (entity.data.disabled) return;
        handleItemActivate(entity);
    }

    function handleSearchResultClick(key: string) {
        const entity = untrack(() => entities)[key];
        if (!entity || entity.data.disabled) return;
        handleItemSelect(entity);
    }

    function handleTriggerClick() {
        if (disabled) return;
        const next = !untrack(() => isOpen);
        isOpen = next;
        onDropdownVisibleChange?.(next);
    }

    function handleClear(event: MouseEvent) {
        event.stopPropagation();
        if (!isControlled) {
            untrack(() => {
                state = { ...state, selectedKey: null, checkedKeys: new Set(), halfCheckedKeys: new Set(), activeKeys: new Set() };
            });
        }
        onChange?.(multiple ? [] : undefined);
        onClear?.();
    }

    function handleSearchInput(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        foundation.handleSearch(input, untrack(() => entities), filterTreeNode, { separator, filterLeafOnly });
        onSearch?.(input);
    }

    // 同 Select：document 级常驻 mousedown 监听，双 contains 判断处理 Portal 场景。
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

    let &[displayText] = track<string>(() => {
        if (multiple) return '';
        const key = state.selectedKey;
        if (!key) return '';
        const entity = entities[key];
        if (!entity) return '';
        return entity.valuePath.length ? untrack(() => entities)[key]!.data.label : '';
    });

    let &[displayPathLabel] = track<string>(() => {
        if (multiple) return '';
        const key = state.selectedKey;
        if (!key) return '';
        let node: CascaderEntity | null = entities[key] ?? null;
        const labels: any[] = [];
        while (node) {
            labels.unshift(node.data.label);
            node = node.parent;
        }
        return labels.join(separator);
    });

    let &[selectedTags] = track<CascaderEntity[]>(() => {
        if (!multiple) return [];
        return [...state.checkedKeys]
            .map((key) => entities[key])
            .filter((e): e is CascaderEntity => !!e);
    });

    let &[allowClear] = track<boolean>(() => {
        if (disabled || !showClear) return false;
        return multiple ? selectedTags.length > 0 : !!state.selectedKey;
    });

    function handleRemoveTag(entity: CascaderEntity, event: MouseEvent) {
        event.stopPropagation();
        foundation.handleMultipleCheck(entity.key, untrack(() => entities), checkRelation, isControlled);
        notifyChange();
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-cascader',
            `lotus-cascader-size-${size}`,
            `lotus-cascader-status-${validateStatus}`,
            borderless ? 'lotus-cascader-borderless' : '',
            disabled ? 'lotus-cascader-disabled' : '',
            isOpen ? 'lotus-cascader-open' : '',
            multiple ? 'lotus-cascader-multiple' : '',
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
                    <div class="lotus-cascader-panel" ref={(node: HTMLElement) => { listNode = node; }}>
                        @if (filterTreeNode) {
                            <div class="lotus-cascader-search-box">
                                <IconSearch />
                                <input
                                    class="lotus-cascader-search-input"
                                    type="text"
                                    value={state.searchInput}
                                    placeholder={searchPlaceholder}
                                    onInput={handleSearchInput}
                                />
                            </div>
                        }
                        @if (isSearching) {
                            <ul class="lotus-cascader-search-list" role="listbox">
                                @if (searchResults.length === 0) {
                                    <li class="lotus-cascader-empty">{locale.Select.clear}</li>
                                }
                                @for (const item of searchResults; key item.key) {
                                    <li
                                        role="option"
                                        class="lotus-cascader-search-item"
                                        onClick={() => handleSearchResultClick(item.key)}
                                    >
                                        {item.pathLabel}
                                    </li>
                                }
                            </ul>
                        } @else {
                            <div class="lotus-cascader-columns">
                                @if (virtualize) {
                                    @for (const column of columns; index colIndex) {
                                        <ul
                                            class="lotus-cascader-column lotus-cascader-column-virtual"
                                            role="menu"
                                            style={{ height: `${virtualize.height ?? 280}px` }}
                                            onScroll={(event: Event) => handleColumnScroll(colIndex, event)}
                                        >
                                            <div style={{ height: `${virtualColumns?.[colIndex]?.range.totalHeight ?? 0}px` }}>
                                                <div style={{ transform: `translateY(${virtualColumns?.[colIndex]?.range.offsetY ?? 0}px)` }}>
                                                    @for (const entry of (virtualColumns?.[colIndex]?.visible ?? []); key entry.entity.key) {
                                                        <div style={{ height: `${virtualize.itemSize}px` }}>
                                                            <CascaderColumnItem
                                                                entity={entry.entity}
                                                                multiple={multiple}
                                                                active={state.activeKeys.has(entry.entity.key)}
                                                                checked={state.checkedKeys.has(entry.entity.key)}
                                                                halfChecked={state.halfCheckedKeys.has(entry.entity.key)}
                                                                disabled={!!entry.entity.data.disabled}
                                                                loading={state.loadingKeys.has(entry.entity.key)}
                                                                isLeaf={isLeafEntity(entry.entity)}
                                                                onItemClick={handleColumnItemClick}
                                                                onItemHover={handleColumnItemHover}
                                                                onItemCheck={handleItemSelect}
                                                            />
                                                        </div>
                                                    }
                                                </div>
                                            </div>
                                        </ul>
                                    }
                                } @else {
                                    @for (const column of columns; index colIndex) {
                                        <ul class="lotus-cascader-column" role="menu">
                                            @for (const entity of column; key entity.key) {
                                                <CascaderColumnItem
                                                    entity={entity}
                                                    multiple={multiple}
                                                    active={state.activeKeys.has(entity.key)}
                                                    checked={state.checkedKeys.has(entity.key)}
                                                    halfChecked={state.halfCheckedKeys.has(entity.key)}
                                                    disabled={!!entity.data.disabled}
                                                    loading={state.loadingKeys.has(entity.key)}
                                                    isLeaf={isLeafEntity(entity)}
                                                    onItemClick={handleColumnItemClick}
                                                    onItemHover={handleColumnItemHover}
                                                    onItemCheck={handleItemSelect}
                                                />
                                            }
                                        </ul>
                                    }
                                }
                            </div>
                        }
                    </div>
                }
            >
                <div
                    role="combobox"
                    aria-expanded={isOpen}
                    aria-haspopup="listbox"
                    aria-label={ariaLabel}
                    aria-disabled={disabled}
                    tabIndex={disabled ? -1 : 0}
                    class="lotus-cascader-trigger"
                    onClick={handleTriggerClick}
                    onFocus={(event: FocusEvent) => onFocus?.(event)}
                    onBlur={(event: FocusEvent) => onBlur?.(event)}
                >
                    @if (multiple) {
                        <div class="lotus-cascader-tags">
                            @if (selectedTags.length === 0) {
                                <span class="lotus-cascader-placeholder">{placeholder}</span>
                            } @else {
                                @for (const entity of selectedTags; key entity.key) {
                                    <span class="lotus-cascader-tag">
                                        <span class="lotus-cascader-tag-label">{entity.data.label}</span>
                                        <span class="lotus-cascader-tag-remove" onClick={(event: MouseEvent) => handleRemoveTag(entity, event)}>
                                            <IconClear />
                                        </span>
                                    </span>
                                }
                            }
                        </div>
                    } @else {
                        @if (displayText) {
                            <span class="lotus-cascader-value" title={displayPathLabel}>{displayPathLabel}</span>
                        } @else {
                            <span class="lotus-cascader-placeholder">{placeholder}</span>
                        }
                    }
                    @if (allowClear) {
                        <span class="lotus-cascader-clear" aria-label={locale.Select.clear} onClick={handleClear}>
                            <IconClear />
                        </span>
                    }
                    <span class="lotus-cascader-arrow">
                        <IconChevronDown />
                    </span>
                </div>
            </Popover>
        </div>

        <style>
            .lotus-cascader {
                display: inline-block;
                width: 100%;
            }

            .lotus-cascader-trigger {
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

            .lotus-cascader-open .lotus-cascader-trigger,
            .lotus-cascader-trigger:hover {
                border-color: var(--lotus-color-primary);
            }

            .lotus-cascader-borderless .lotus-cascader-trigger {
                border-color: transparent;
                background: transparent;
            }

            .lotus-cascader-disabled .lotus-cascader-trigger {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
                border-color: var(--lotus-color-border);
            }

            .lotus-cascader-status-warning .lotus-cascader-trigger { border-color: var(--lotus-color-warning); }
            .lotus-cascader-status-error .lotus-cascader-trigger { border-color: var(--lotus-color-danger); }

            .lotus-cascader-size-large .lotus-cascader-trigger { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }
            .lotus-cascader-size-default .lotus-cascader-trigger { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-cascader-size-small .lotus-cascader-trigger { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }

            .lotus-cascader-multiple .lotus-cascader-trigger {
                height: auto;
                min-height: var(--lotus-height-control-default);
                padding: 4px var(--lotus-spacing-tight);
            }

            .lotus-cascader-value,
            .lotus-cascader-placeholder {
                flex: 1;
                min-width: 0;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                color: var(--lotus-color-text-0);
            }

            .lotus-cascader-placeholder { color: var(--lotus-color-text-3); }

            .lotus-cascader-disabled .lotus-cascader-value,
            .lotus-cascader-disabled .lotus-cascader-placeholder {
                color: var(--lotus-color-disabled-text);
            }

            .lotus-cascader-arrow {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
                font-size: 12px;
                transition: transform 0.2s ease;
            }

            .lotus-cascader-open .lotus-cascader-arrow { transform: rotate(180deg); }

            .lotus-cascader-clear {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-cascader-clear:hover { color: var(--lotus-color-text-0); }

            .lotus-cascader-tags {
                display: flex;
                flex: 1;
                flex-wrap: wrap;
                gap: 4px;
                min-width: 0;
            }

            .lotus-cascader-tag {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                padding: 2px 6px;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-cascader-tag-remove {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                font-size: 10px;
            }

            .lotus-cascader-tag-remove:hover { color: var(--lotus-color-text-0); }

            .lotus-cascader-panel {
                display: flex;
                flex-direction: column;
                min-width: 120px;
            }

            .lotus-cascader-search-box {
                display: flex;
                align-items: center;
                gap: 6px;
                padding: 6px 8px;
                border-bottom: 1px solid var(--lotus-color-border);
                color: var(--lotus-color-text-2);
            }

            .lotus-cascader-search-input {
                flex: 1;
                border: none;
                outline: none;
                background: transparent;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-cascader-columns {
                display: flex;
                align-items: flex-start;
            }

            .lotus-cascader-column {
                list-style: none;
                margin: 0;
                padding: 4px;
                max-height: 270px;
                overflow-y: auto;
                min-width: 140px;
            }

            .lotus-cascader-column + .lotus-cascader-column {
                border-inline-start: 1px solid var(--lotus-color-border);
            }

            .lotus-cascader-column-virtual {
                max-height: none;
            }

            .lotus-cascader-search-list {
                list-style: none;
                margin: 0;
                padding: 4px;
                max-height: 270px;
                overflow-y: auto;
                min-width: 240px;
            }

            .lotus-cascader-search-item {
                padding: 6px 8px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-cascader-search-item:hover { background: var(--lotus-color-fill-0); }

            .lotus-cascader-empty {
                padding: 6px 8px;
                color: var(--lotus-color-text-3);
                font-size: var(--lotus-font-body-size);
            }
        </style>
    </>
}
