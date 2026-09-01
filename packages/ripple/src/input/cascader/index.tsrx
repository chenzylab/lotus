import { track, untrack, effect } from 'ripple';
import {
    CascaderFoundation,
    buildCascaderEntities,
    computeColumns,
    computeCascaderSearchResult,
    collapseCheckedKeysToValuePaths,
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
export type { CascaderNodeData, CascaderEntity };

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
    /** 多选：已勾选节点是否禁止被再次点击取消勾选（对齐 Semi/TreeSelect
     * 同名 prop），默认 false。 */
    disableStrictly?: boolean;
    /** 多选：叶子节点点击行本身（非 checkbox）即可勾选，默认 false（对齐 Semi）。 */
    enableLeafClick?: boolean;
    /** 多选：任意节点点击行本身即可勾选（优先级高于 enableLeafClick），默认
     * false（对齐 Semi）。 */
    clickToSelect?: boolean;
    /** 多选最多可选项数（按折叠后的外部 value 路径数计算），达上限后新增
     * 勾选被拦截并触发 onExceed（对齐 Semi）。 */
    max?: number;
    /** 多选已选 tag 数量超出后折叠为 "+N"，0/不传表示不折叠（对齐 Semi）。 */
    maxTagCount?: number;
    /** 是否开启搜索，true 用内置路径文本匹配，函数则完全交给调用方判断。 */
    filterTreeNode?: CascaderFilterTreeNode;
    /** 搜索结果是否只保留叶子节点路径，默认 true。 */
    filterLeafOnly?: boolean;
    searchPlaceholder?: any;
    /** 路径展示分隔符，默认 ' / '。 */
    separator?: string;
    /** 自定义空状态内容（搜索无匹配结果时），替代默认纯文本 locale（对齐 Semi
     * emptyContent）。 */
    emptyContent?: any;
    /** 单选已选路径的展示字段名：默认展示每级 label 用 separator 拼接，指定
     * 后改为读取每级节点 data 上对应字段（对齐 Semi displayProp）。 */
    displayProp?: string;
    /** 单选已选路径完全自定义渲染，优先级高于 displayProp（对齐 Semi
     * displayRender）。 */
    displayRender?: (selectedPathLabel: string, entities: CascaderEntity[]) => any;
    /** 完全自定义触发器渲染，替换默认 combobox 触发框（对齐 Semi
     * triggerRender）；需自行处理点击展开等交互。 */
    triggerRender?: (props: { value: ValuePath | ValuePath[] | undefined; placeholder: any; open: boolean; disabled: boolean }) => any;
    /** 下拉面板最外层顶部固定区域（对齐 Semi topSlot）。 */
    topSlot?: any;
    /** 下拉面板最外层底部固定区域（对齐 Semi bottomSlot）。 */
    bottomSlot?: any;
    /** 浮层挂载的目标容器，不传则挂载在 Popover 默认位置（对齐 Semi
     * getPopupContainer）。 */
    getPopupContainer?: () => HTMLElement;
    /** 浮层层级（对齐 Semi zIndex），不传由 CSS 层级 token 控制。 */
    zIndex?: number;
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
    /** 异步加载成功后触发，携带本次新增的 loaded key 集合与刚加载完的节点
     * 数据（对齐 Semi onLoad(newLoadedKeys, data)）。 */
    onLoad?: (newLoadedKeys: Set<string>, data: { value: string | number; label: any; valuePath: ValuePath }) => void;
    /** 多选达到 max 上限、新增勾选被拦截时触发（对齐 Semi onExceed）。 */
    onExceed?: () => void;
    'aria-label'?: string;
    'aria-labelledby'?: string;
    'aria-describedby'?: string;
    'aria-errormessage'?: string;
    'aria-invalid'?: boolean;
    'aria-required'?: boolean;
    id?: string;
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
    /** 键盘导航虚拟焦点（与 `active` 语义不同——`active` 表示这个 entity 在
     * 当前展开路径上，`keyboardActive` 表示键盘当前聚焦在这一行）。 */
    keyboardActive?: boolean;
    id?: string;
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
    keyboardActive = false,
    id,
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
        id={id}
        role="menuitem"
        aria-expanded={!isLeaf ? active : undefined}
        aria-disabled={disabled}
        class={['lotus-cascader-item', active ? 'lotus-cascader-item-active' : '', keyboardActive ? 'lotus-cascader-item-keyboard-active' : '', disabled ? 'lotus-cascader-item-disabled' : ''].filter(Boolean).join(' ')}
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

        .lotus-cascader-item-keyboard-active {
            background: var(--lotus-color-fill-0);
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
    disableStrictly = false,
    enableLeafClick = false,
    clickToSelect = false,
    max,
    maxTagCount,
    filterTreeNode = false,
    filterLeafOnly = true,
    searchPlaceholder,
    separator = ' / ',
    emptyContent,
    displayProp,
    displayRender,
    triggerRender,
    topSlot,
    bottomSlot,
    getPopupContainer,
    zIndex,
    virtualize,
    loadData,
    onChange,
    onClear,
    onSearch,
    onFocus,
    onBlur,
    onDropdownVisibleChange,
    onLoadError,
    onLoad,
    onExceed,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledby,
    'aria-describedby': ariaDescribedby,
    'aria-errormessage': ariaErrormessage,
    'aria-invalid': ariaInvalid,
    'aria-required': ariaRequired,
    id,
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
    // 键盘导航虚拟焦点：{col, row} 指向 columns[col][row]，与 state.activeKeys
    // （鼠标 hover/点击展开出的"当前路径"，用来决定渲染几列）是完全不同的两个
    // 概念——activeCoord 只是"键盘当前聚焦在哪一列哪一行"，不驱动列的展开。
    let &[activeCoord] = track<{ col: number; row: number } | null>(null);
    const componentId = Math.random().toString(36).slice(2);

    function itemDomId(col: number, row: number): string {
        return `lotus-cascader-item-${componentId}-${col}-${row}`;
    }

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

    function firstEnabledRow(col: number): number {
        const column = columns[col];
        if (!column) return -1;
        return column.findIndex((e) => !e.data.disabled);
    }

    function nextEnabledRow(col: number, from: number, step: 1 | -1): number {
        const column = columns[col];
        if (!column || column.length === 0) return -1;
        let i = from;
        for (let count = 0; count < column.length; count++) {
            i = (i + step + column.length) % column.length;
            if (!column[i]?.data.disabled) return i;
        }
        return -1;
    }

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
        const loadedEntityInfo = { value: entity.data.value, label: entity.data.label, valuePath: entity.valuePath };
        loadData(loadedEntityInfo)
            .then(() => {
                const result = foundation.handleLoadEnd(entity.key, true);
                onLoad?.(result.newLoadedKeys, loadedEntityInfo);
            })
            .catch((error: unknown) => {
                foundation.handleLoadEnd(entity.key, false);
                onLoadError?.(loadedEntityInfo, error);
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
            const currentEntities = untrack(() => entities);
            const wasChecked = untrack(() => state).checkedKeys.has(entity.key);
            if (!wasChecked && max !== undefined) {
                const preview = foundation.handleMultipleCheck(entity.key, currentEntities, checkRelation, true, { disableStrictly });
                const previewPaths = collapseCheckedKeysToValuePaths(preview.checkedKeys, currentEntities, { autoMergeValue, leafOnly });
                if (previewPaths.length > max) {
                    onExceed?.();
                    return;
                }
            }
            foundation.handleMultipleCheck(entity.key, currentEntities, checkRelation, isControlled, { disableStrictly });
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

    // 多选模式下点击行本身（非 checkbox）默认只展开路径，不勾选——勾选由
    // Checkbox 自己的 onChange 独立触发。对齐 Semi handleSingleSelect：
    // clickToSelect 时任意节点点击行都同时触发勾选（优先级最高）；
    // enableLeafClick 时仅叶子节点点击行触发勾选；两者都为 false（默认）时
    // 点文字=展开、点 checkbox=勾选，两个交互互不干扰。
    function handleColumnItemClick(entity: CascaderEntity) {
        if (multiple) {
            const leaf = isLeafEntity(entity);
            if (clickToSelect || (enableLeafClick && leaf)) {
                handleItemSelect(entity);
            }
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

    function scrollActiveItemIntoView() {
        const list = untrack(() => listNode);
        const coord = untrack(() => activeCoord);
        if (!list || !coord) return;
        const el = list.querySelector(`#${itemDomId(coord.col, coord.row)}`);
        el?.scrollIntoView({ block: 'nearest' });
    }

    /** 键盘无障碍：DOM 焦点留在 trigger 上，activeCoord={col,row} 指向多列
     * 面板里"当前聚焦在第几列第几行"。ArrowDown/ArrowUp 在同一列内移动
     * （自动跳过 disabled 行），ArrowRight 展开当前行进入下一列，ArrowLeft
     * 回到上一列，Enter 等价于点击当前行（分派逻辑对齐 handleColumnItemClick：
     * 叶子节点或 changeOnSelect 时选中，否则展开下一列），Escape 关闭面板——
     * Cascader 用 Popover trigger="custom" 完全接管开关状态，Popover 内建的
     * closeOnEsc 只在非受控模式下生效（`!isControlled` 短路判断），这里必须
     * 自己实现 Esc 处理（同 Select/TreeSelect）。 */
    function handleTriggerKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        const open = untrack(() => isOpen);
        switch (event.key) {
            case 'ArrowDown':
            case 'ArrowUp': {
                event.preventDefault();
                if (!open) {
                    isOpen = true;
                    onDropdownVisibleChange?.(true);
                    const row = firstEnabledRow(0);
                    activeCoord = row >= 0 ? { col: 0, row } : null;
                    scrollActiveItemIntoView();
                    return;
                }
                const coord = untrack(() => activeCoord);
                const col = coord?.col ?? 0;
                const fromRow = coord?.row ?? -1;
                const nextRow = nextEnabledRow(col, fromRow, event.key === 'ArrowDown' ? 1 : -1);
                activeCoord = nextRow >= 0 ? { col, row: nextRow } : null;
                scrollActiveItemIntoView();
                return;
            }
            case 'ArrowRight': {
                if (!open) return;
                const coord = untrack(() => activeCoord);
                if (!coord) return;
                const entity = columns[coord.col]?.[coord.row];
                if (!entity || isLeafEntity(entity)) return;
                event.preventDefault();
                handleItemActivate(entity);
                const nextCol = coord.col + 1;
                const row = firstEnabledRow(nextCol);
                if (row >= 0) {
                    activeCoord = { col: nextCol, row };
                    scrollActiveItemIntoView();
                }
                return;
            }
            case 'ArrowLeft': {
                if (!open) return;
                const coord = untrack(() => activeCoord);
                if (!coord || coord.col === 0) return;
                event.preventDefault();
                activeCoord = { col: coord.col - 1, row: 0 };
                scrollActiveItemIntoView();
                return;
            }
            case 'Enter': {
                if (!open) return;
                const coord = untrack(() => activeCoord);
                if (!coord) return;
                const entity = columns[coord.col]?.[coord.row];
                if (!entity) return;
                event.preventDefault();
                handleColumnItemClick(entity);
                return;
            }
            case 'Escape': {
                if (!open) return;
                event.preventDefault();
                isOpen = false;
                onDropdownVisibleChange?.(false);
                return;
            }
            default:
                return;
        }
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

    let &[selectedPathEntities] = track<CascaderEntity[]>(() => {
        if (multiple) return [];
        const key = state.selectedKey;
        if (!key) return [];
        let node: CascaderEntity | null = entities[key] ?? null;
        const chain: CascaderEntity[] = [];
        while (node) {
            chain.unshift(node);
            node = node.parent;
        }
        return chain;
    });

    let &[displayPathLabel] = track<string>(() => {
        if (!displayProp) return selectedPathEntities.map((e) => e.data.label).join(separator);
        return selectedPathEntities.map((e) => (e.data as any)[displayProp] ?? e.data.label).join(separator);
    });

    // 已选路径展示内容优先级：displayRender（完全自定义）> displayProp（自定义
    // 字段）> 默认按 label 用 separator 拼接（对齐 Semi）。
    let &[resolvedDisplayContent] = track<any>(() => {
        if (displayRender) return displayRender(displayPathLabel, selectedPathEntities);
        return displayPathLabel;
    });

    let &[selectedTags] = track<CascaderEntity[]>(() => {
        if (!multiple) return [];
        return [...state.checkedKeys]
            .map((key) => entities[key])
            .filter((e): e is CascaderEntity => !!e);
    });

    // 多选 tag 折叠：对齐 Select 已验证的 maxTagCount 折叠展示模式。
    let &[visibleTagsResult] = track<{ visible: CascaderEntity[]; restCount: number }>(() =>
        CascaderFoundation.resolveVisibleTags(selectedTags, maxTagCount),
    );

    let &[allowClear] = track<boolean>(() => {
        if (disabled || !showClear) return false;
        return multiple ? selectedTags.length > 0 : !!state.selectedKey;
    });

    function handleRemoveTag(entity: CascaderEntity, event: MouseEvent) {
        event.stopPropagation();
        if (disableStrictly) return;
        foundation.handleMultipleCheck(entity.key, untrack(() => entities), checkRelation, isControlled, { disableStrictly });
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
                getPopupContainer={getPopupContainer}
                zIndex={zIndex}
                content={
                    <div class="lotus-cascader-panel" ref={(node: HTMLElement) => { listNode = node; }}>
                        @if (topSlot) {
                            <div class="lotus-cascader-top-slot">{topSlot}</div>
                        }
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
                                    <li class="lotus-cascader-empty">{emptyContent ?? locale.Select.emptyText}</li>
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
                                                                keyboardActive={activeCoord?.col === colIndex && activeCoord?.row === entry.index}
                                                                id={itemDomId(colIndex, entry.index)}
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
                                            @for (const entity of column; index rowIndex; key entity.key) {
                                                <CascaderColumnItem
                                                    entity={entity}
                                                    multiple={multiple}
                                                    active={state.activeKeys.has(entity.key)}
                                                    keyboardActive={activeCoord?.col === colIndex && activeCoord?.row === rowIndex}
                                                    id={itemDomId(colIndex, rowIndex)}
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
                        @if (bottomSlot) {
                            <div class="lotus-cascader-bottom-slot">{bottomSlot}</div>
                        }
                    </div>
                }
            >
                @if (triggerRender) {
                    <div onClick={handleTriggerClick} onKeyDown={handleTriggerKeyDown}>
                        {triggerRender({ value, placeholder, open: isOpen, disabled })}
                    </div>
                } @else {
                    <div
                        id={id}
                        role="combobox"
                        aria-expanded={isOpen}
                        aria-haspopup="listbox"
                        aria-label={ariaLabel}
                        aria-labelledby={ariaLabelledby}
                        aria-describedby={ariaDescribedby}
                        aria-errormessage={ariaErrormessage}
                        aria-invalid={ariaInvalid}
                        aria-required={ariaRequired}
                        aria-disabled={disabled}
                        aria-activedescendant={isOpen && activeCoord ? itemDomId(activeCoord.col, activeCoord.row) : undefined}
                        tabIndex={disabled ? -1 : 0}
                        class="lotus-cascader-trigger"
                        onClick={handleTriggerClick}
                        onKeyDown={handleTriggerKeyDown}
                        onFocus={(event: FocusEvent) => onFocus?.(event)}
                        onBlur={(event: FocusEvent) => onBlur?.(event)}
                    >
                        @if (multiple) {
                            <div class="lotus-cascader-tags">
                                @if (selectedTags.length === 0) {
                                    <span class="lotus-cascader-placeholder">{placeholder}</span>
                                } @else {
                                    <>
                                        @for (const entity of visibleTagsResult.visible; key entity.key) {
                                            <span class="lotus-cascader-tag">
                                                <span class="lotus-cascader-tag-label">{entity.data.label}</span>
                                                <span class="lotus-cascader-tag-remove" onClick={(event: MouseEvent) => handleRemoveTag(entity, event)}>
                                                    <IconClear />
                                                </span>
                                            </span>
                                        }
                                        @if (visibleTagsResult.restCount > 0) {
                                            <span class="lotus-cascader-tag lotus-cascader-tag-rest">+{visibleTagsResult.restCount}</span>
                                        }
                                    </>
                                }
                            </div>
                        } @else {
                            @if (displayText) {
                                <span class="lotus-cascader-value" title={displayPathLabel}>{resolvedDisplayContent}</span>
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
                }
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

            .lotus-cascader-tag-rest {
                color: var(--lotus-color-text-2);
                cursor: default;
            }

            .lotus-cascader-top-slot,
            .lotus-cascader-bottom-slot {
                padding: 6px 8px;
            }

            .lotus-cascader-top-slot {
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-cascader-bottom-slot {
                border-top: 1px solid var(--lotus-color-border);
            }
        </style>
    </>
}
