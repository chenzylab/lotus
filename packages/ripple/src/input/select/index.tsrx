import { track, untrack, effect } from 'ripple';
import { SelectFoundation, filterSelectOptions, type SelectFilter, type SelectState, type SelectValue } from '@lotus/foundation/input/select';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { IconChevronDown, IconClear, IconSearch, IconTick } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';

export type SelectSize = 'large' | 'default' | 'small';
export type SelectValidateStatus = 'default' | 'warning' | 'error';
export type SelectSearchPosition = 'trigger' | 'dropdown';
export type { SelectFilter };

export interface SelectOption {
    value: SelectValue;
    label?: any;
    disabled?: boolean;
}

/** 大数据量场景下开启固定行高虚拟滚动（对齐 Transfer 组件已验证的实现模式，
 * 复用同一份 `base/virtual-list.ts` 纯算法），仅在 `optionList.length` 较大
 * 时才需要传入；不传则按普通 `@for` 全量渲染。 */
export interface SelectVirtualizeConfig {
    /** 下拉面板的固定高度（px），默认 280。 */
    height?: number;
    /** 每个选项行的固定高度（px），必填——虚拟滚动要求固定行高。 */
    itemSize: number;
}

export interface SelectProps {
    optionList?: SelectOption[];
    value?: SelectValue | SelectValue[];
    defaultValue?: SelectValue | SelectValue[];
    multiple?: boolean;
    disabled?: boolean;
    placeholder?: any;
    size?: SelectSize;
    validateStatus?: SelectValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    prefix?: any;
    suffix?: any;
    position?: FloatingPosition;
    virtualize?: SelectVirtualizeConfig;
    /** 对齐 Semi `filter`：`true` 走内置 label 包含匹配（大小写不敏感），
     * 函数则完全交给调用方判断，`false`/不传不过滤（一手来源核对见 specs
     * 踩坑记录）。 */
    filter?: SelectFilter;
    /** 搜索框位置，仅在 `filter` 开启时生效：`'trigger'`（默认，叠加在
     * 触发器本身，与已选值/tags 共存）或 `'dropdown'`（固定在下拉面板
     * 顶部，对齐 Cascader/TreeSelect 已有实现）。 */
    searchPosition?: SelectSearchPosition;
    searchPlaceholder?: string;
    'aria-label'?: string;
    onChange?: (value: SelectValue | SelectValue[] | undefined) => void;
    onClear?: () => void;
    onSearch?: (input: string) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onDropdownVisibleChange?: (visible: boolean) => void;
    style?: Record<string, any>;
    class?: string;
}

interface SelectOptionItemProps {
    option: SelectOption;
    selected: boolean;
    active?: boolean;
    id?: string;
    onSelect: (option: SelectOption) => void;
}

/** 单个选项 `<li>` 的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用，
 * 避免重复维护同一份 class/aria 拼装逻辑。`active` 是键盘导航的虚拟焦点
 * （aria-activedescendant 模式——DOM 焦点始终留在 trigger 上，只用样式和
 * aria 属性标记"当前高亮到哪一项"，不是浏览器原生的 :focus）。 */
function SelectOptionItem(&{ option, selected, active = false, id, onSelect }: SelectOptionItemProps) @{
    <>
    <li
        id={id}
        role="option"
        aria-selected={selected}
        aria-disabled={option.disabled}
        class={['lotus-select-option', selected ? 'lotus-select-option-selected' : '', active ? 'lotus-select-option-active' : '', option.disabled ? 'lotus-select-option-disabled' : ''].filter(Boolean).join(' ')}
        onClick={() => onSelect(option)}
    >
        <span class="lotus-select-option-label">{option.label ?? String(option.value)}</span>
        @if (selected) {
            <span class="lotus-select-option-tick"><IconTick /></span>
        }
    </li>

    <style>
        .lotus-select-option {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            padding: 6px 8px;
            border-radius: var(--lotus-border-radius-small);
            cursor: pointer;
            font-size: var(--lotus-font-body-size);
            color: var(--lotus-color-text-0);
        }

        .lotus-select-option:hover {
            background: var(--lotus-color-fill-0);
        }

        .lotus-select-option-selected {
            color: var(--lotus-color-primary);
            font-weight: var(--lotus-font-weight-semibold);
        }

        .lotus-select-option-disabled {
            color: var(--lotus-color-disabled-text);
            cursor: not-allowed;
        }

        .lotus-select-option-active {
            background: var(--lotus-color-fill-0);
        }

        .lotus-select-option-disabled:hover {
            background: transparent;
        }

        .lotus-select-option-tick {
            display: inline-flex;
            align-items: center;
            color: var(--lotus-color-primary);
            font-size: 12px;
        }

        .lotus-select-option-label {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    </style>
    </>
}

export function Select(&{
    optionList = [],
    value,
    defaultValue,
    multiple = false,
    disabled = false,
    placeholder,
    size = 'default',
    validateStatus = 'default',
    borderless = false,
    showClear = false,
    prefix,
    suffix,
    virtualize,
    filter,
    searchPosition = 'trigger',
    searchPlaceholder,
    position = 'bottomLeft',
    'aria-label': ariaLabel,
    onChange,
    onClear,
    onSearch,
    onFocus,
    onBlur,
    onDropdownVisibleChange,
    style,
    class: className,
}: SelectProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    // track() 而非普通 const——见 input/index.tsrx 同名注释，受控身份要能随
    // value 的 undefined↔有值 变化重新判定，否则外部表单 reset 无法清空展示值。
    let &[isControlled] = track<boolean>(() => value !== undefined);
    let &[state] = track<SelectState>({
        value: isControlled ? value : defaultValue,
        searchInput: '',
    });
    let &[isOpen] = track<boolean>(false);
    let &[rootNode] = track<HTMLElement | null>(null);
    let &[listNode] = track<HTMLElement | null>(null);
    let triggerInputNode: HTMLInputElement | null = null;
    let &[scrollTop] = track<number>(0);
    // 键盘导航的虚拟焦点（aria-activedescendant 模式）：DOM 焦点始终留在
    // trigger 上，activeIndex 只是"当前高亮到 optionList 里第几项"，通过
    // aria-activedescendant 让屏幕阅读器感知，通过 CSS class 给出视觉反馈。
    let &[activeIndex] = track<number>(-1);
    const componentId = Math.random().toString(36).slice(2);

    function optionDomId(index: number): string {
        return `lotus-select-option-${componentId}-${index}`;
    }

    // 过滤后的候选列表：未开启 filter 或搜索框为空时等价于原始 optionList
    // （引用不变，避免无谓的虚拟化区间重算）。键盘导航/虚拟滚动/点击选中
    // 全部基于这份列表——搜索时方向键只应在可见候选间移动。
    let &[filteredOptions] = track<SelectOption[]>(() => {
        if (!filter || !state.searchInput) return optionList;
        return filterSelectOptions(optionList, state.searchInput, filter);
    });

    function firstEnabledIndex(): number {
        return filteredOptions.findIndex((o) => !o.disabled);
    }

    function nextEnabledIndex(from: number, step: 1 | -1): number {
        if (filteredOptions.length === 0) return -1;
        let i = from;
        for (let count = 0; count < filteredOptions.length; count++) {
            i = (i + step + filteredOptions.length) % filteredOptions.length;
            if (!filteredOptions[i]?.disabled) return i;
        }
        return -1;
    }

    function handleVirtualScroll(event: Event) {
        untrack(() => { scrollTop = (event.target as HTMLElement).scrollTop; });
    }

    let &[virtualRange] = track(() => {
        if (!virtualize) return null;
        return calcVirtualRange({
            itemCount: filteredOptions.length,
            itemHeight: virtualize.itemSize,
            containerHeight: virtualize.height ?? 280,
            scrollTop,
        });
    });

    let &[virtualVisibleOptions] = track<Array<{ option: SelectOption; index: number }>>(() => {
        if (!virtualRange) return [];
        const result: Array<{ option: SelectOption; index: number }> = [];
        for (let i = virtualRange.startIndex; i <= virtualRange.endIndex; i++) {
            const option = filteredOptions[i];
            if (option) result.push({ option, index: i });
        }
        return result;
    });

    const foundation = new SelectFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<SelectState>) => { state = { ...state, ...patch }; },
    });

    // 受控身份会随 value 的 undefined↔有值 重新判定，但内部 state 只在非受控
    // 分支被写入——一旦组件经历过"非受控写入 state → 变为受控 → 又变回
    // undefined"（如 Form 字段初始 undefined、用户选择后受控、reset 又变回
    // undefined），如果不同步，state 会残留陈旧值。详见 input-number/index.tsrx
    // 同名注释与 specs/cross-cutting/foundation-adapter-pattern.md。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, value }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, value: undefined }; });
        }
    });

    let &[displayValue] = track<SelectValue | SelectValue[] | undefined>(() => (isControlled ? value : state.value));

    const handleSingleChange = (v: SelectValue | SelectValue[] | undefined) => {
        onChange?.(v);
    };
    const handleMultipleChange = (v: SelectValue[]) => {
        onChange?.(v);
    };

    /** 统一的面板关闭出口：选中/Esc/点击外部均要清空搜索框（filter 开启时），
     * 避免散落多处 `isOpen = false` 各自决定是否重置、遗漏其中一处。 */
    function closePanel() {
        isOpen = false;
        if (filter) foundation.resetSearch();
        onDropdownVisibleChange?.(false);
    }

    const handleOptionClick = (option: SelectOption) => {
        if (option.disabled) return;
        if (multiple) {
            foundation.selectMultiple(option.value, isControlled, handleMultipleChange);
            if (filter) foundation.resetSearch();
            return;
        }
        foundation.selectSingle(option.value, isControlled, handleSingleChange);
        closePanel();
    };

    function handleSearchInput(event: Event) {
        const input = (event.target as HTMLInputElement).value;
        foundation.handleSearch(input, onSearch);
        activeIndex = -1;
    }

    const handleRemoveTag = (itemValue: SelectValue, event: MouseEvent) => {
        event.stopPropagation();
        foundation.removeMultipleValue(itemValue, isControlled, handleMultipleChange);
    };

    const handleTriggerClick = () => {
        if (disabled) return;
        const next = !untrack(() => isOpen);
        isOpen = next;
        onDropdownVisibleChange?.(next);
        if (next && filter && searchPosition === 'trigger') {
            untrack(() => { triggerInputNode?.focus(); });
        }
    };

    const handleClear = (event: MouseEvent) => {
        event.stopPropagation();
        foundation.clear(multiple, isControlled, handleSingleChange as (v: SelectValue | SelectValue[] | undefined) => void);
        onClear?.();
    };

    function scrollActiveIntoView() {
        const list = untrack(() => listNode);
        if (!list) return;
        const el = list.querySelector(`#${optionDomId(untrack(() => activeIndex))}`);
        el?.scrollIntoView({ block: 'nearest' });
    }

    /** 键盘无障碍：DOM 焦点始终留在 trigger 上（aria-activedescendant 模式），
     * ArrowDown/ArrowUp 打开面板并在可见选项间移动虚拟高亮，Enter 选中当前
     * 高亮项，Escape 关闭面板——Select 用 Popover trigger="custom" 完全
     * 接管开关状态，Popover 内建的 closeOnEsc 只在非受控模式下生效
     * （`!isControlled` 短路判断），这里必须自己实现 Esc 处理。 */
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
                    activeIndex = firstEnabledIndex();
                    scrollActiveIntoView();
                    return;
                }
                const current = untrack(() => activeIndex);
                activeIndex = nextEnabledIndex(current, event.key === 'ArrowDown' ? 1 : -1);
                scrollActiveIntoView();
                return;
            }
            case 'Enter': {
                if (!open) return;
                event.preventDefault();
                const current = untrack(() => activeIndex);
                const option = filteredOptions[current];
                if (option) handleOptionClick(option);
                return;
            }
            case 'Escape': {
                if (!open) return;
                event.preventDefault();
                closePanel();
                return;
            }
            default:
                return;
        }
    }

    // 点击 Select 触发器/浮层以外的区域时收起下拉——Popover 本身只支持"再点一次触发器
    // 关闭"（trigger='click' 的 toggle 语义），选择器类组件还需要"点击选项后关闭"和
    // "点击页面任意其他地方关闭"，所以这里改用 Popover 的 trigger='custom' 完全自己
    // 接管开关状态。effect 返回清理函数在组件卸载时移除监听器（Ripple 的 effect()
    // 完整支持这个机制，对齐 DragMove/Modal/HotKeys 等组件的既有用法——早期版本
    // 这里遗漏过 cleanup，全面质量复查发现同一遗漏在 Cascader/TreeSelect/
    // AutoComplete/DatePicker/TimePicker/ColorPicker/Slider/TagInput/Transfer
    // 等 10 个组件里被复制传播，详见 specs 踩坑记录）。
    //
    // 必须同时检查 rootNode 和 listNode 两个节点——Popover 的浮层内容通过 Portal
    // 渲染到 document.body，脱离了 rootNode 所在的 DOM 子树。只判断 rootNode.
    // contains() 会把"点击浮层内的选项"误判为"点击外部"：mousedown 先于 click 触发，
    // 全局监听器抢先把 isOpen 设为 false（连带把 @if (displayVisible) 条件渲染的
    // 选项从 DOM 移除），导致选项自己的 onClick 从未真正执行，看起来像"点击选项没反应"
    // （真机复现：点击"西瓜视频"后浮层关闭但触发器文本没有更新为选中值）。
    effect(() => {
        const handleDocumentMouseDown = (event: MouseEvent) => {
            if (!untrack(() => isOpen)) return;
            if (!(event.target instanceof Node)) return;
            const root = untrack(() => rootNode);
            if (root?.contains(event.target)) return;
            const list = untrack(() => listNode);
            if (list?.contains(event.target)) return;
            closePanel();
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
        return () => document.removeEventListener('mousedown', handleDocumentMouseDown);
    });

    let &[allowClear] = track<boolean>(() => {
        if (disabled || !showClear) return false;
        return multiple ? Array.isArray(displayValue) && displayValue.length > 0 : displayValue !== undefined;
    });

    let &[selectedLabels] = track<Array<{ value: SelectValue; label: any }>>(() => {
        const values = multiple ? (Array.isArray(displayValue) ? displayValue : []) : (displayValue !== undefined ? [displayValue as SelectValue] : []);
        return values.map((v) => {
            const option = optionList.find((o) => o.value === v);
            return { value: v, label: option?.label ?? String(v) };
        });
    });

    // 单选场景专用：不在模板里对 selectedLabels 求两次值（一次在 @if 条件、一次在
    // 分支体的 selectedLabels[0]）——derived 值的重新计算发生在每次访问时机，若
    // 两次访问之间 optionList/displayValue 恰好变化，会读到两个不同时刻的快照，
    // 曾经在并发跑多个 e2e 文件时命中过一次 Cannot read properties of undefined
    // (reading 'label')。这里改成单个派生值，`@if` 判断和渲染内容引用同一个变量，
    // 保证同一次求值结果只被计算一次、两处读到的是同一份数据。
    let &[singleSelectedLabel] = track<any>(() => (selectedLabels.length > 0 ? selectedLabels[0]!.label : undefined));

    let &[classes] = track<string>(() =>
        [
            'lotus-select',
            `lotus-select-size-${size}`,
            `lotus-select-status-${validateStatus}`,
            borderless ? 'lotus-select-borderless' : '',
            disabled ? 'lotus-select-disabled' : '',
            isOpen ? 'lotus-select-open' : '',
            multiple ? 'lotus-select-multiple' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    // trigger 模式的搜索框只在面板打开时渲染并接管焦点——参照 Semi
    // `showInput`/`toggle2SearchInput`：本质等价于 `isOpen && filter`，
    // 不需要单独维护一个显式的 showInput 状态字段。
    let &[showTriggerInput] = track<boolean>(() => !!filter && searchPosition === 'trigger' && isOpen);

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }}>
            <Popover
                trigger="custom"
                visible={isOpen}
                position={position}
                spacing={4}
                closeOnEsc={true}
                content={
                    <div class="lotus-select-panel" ref={(node: HTMLElement) => { listNode = node; }}>
                        @if (filter && searchPosition === 'dropdown') {
                            <div class="lotus-select-search-box">
                                <IconSearch />
                                <input
                                    class="lotus-select-search-input"
                                    type="text"
                                    value={state.searchInput}
                                    placeholder={searchPlaceholder}
                                    onInput={handleSearchInput}
                                />
                            </div>
                        }
                        <ul
                            class={['lotus-select-list', virtualize ? 'lotus-select-list-virtual' : ''].filter(Boolean).join(' ')}
                            role="listbox"
                            aria-multiselectable={multiple}
                            style={virtualize ? { height: `${virtualize.height ?? 280}px` } : undefined}
                            onScroll={virtualize ? handleVirtualScroll : undefined}
                        >
                            @if (filteredOptions.length === 0) {
                                <li class="lotus-select-empty">{locale.Select.emptyText}</li>
                            } @else if (virtualize) {
                                <div style={{ height: `${virtualRange?.totalHeight ?? 0}px` }}>
                                    <div style={{ transform: `translateY(${virtualRange?.offsetY ?? 0}px)` }}>
                                        @for (const entry of virtualVisibleOptions; index vi; key entry.option.value) {
                                            <div style={{ height: `${virtualize.itemSize}px` }}>
                                                <SelectOptionItem
                                                    option={entry.option}
                                                    selected={multiple ? SelectFoundation.isMultipleChecked(displayValue, entry.option.value) : SelectFoundation.isSingleChecked(displayValue, entry.option.value)}
                                                    active={entry.index === activeIndex}
                                                    id={optionDomId(entry.index)}
                                                    onSelect={handleOptionClick}
                                                />
                                            </div>
                                        }
                                    </div>
                                </div>
                            } @else {
                                @for (const option of filteredOptions; index oi; key option.value) {
                                    <SelectOptionItem
                                        option={option}
                                        selected={multiple ? SelectFoundation.isMultipleChecked(displayValue, option.value) : SelectFoundation.isSingleChecked(displayValue, option.value)}
                                        active={oi === activeIndex}
                                        id={optionDomId(oi)}
                                        onSelect={handleOptionClick}
                                    />
                                }
                            }
                        </ul>
                    </div>
                }
            >
                <div
                    role="combobox"
                    aria-expanded={isOpen}
                    aria-haspopup="listbox"
                    aria-label={ariaLabel}
                    aria-disabled={disabled}
                    aria-activedescendant={isOpen && activeIndex >= 0 ? optionDomId(activeIndex) : undefined}
                    tabIndex={disabled ? -1 : 0}
                    class="lotus-select-trigger"
                    onClick={handleTriggerClick}
                    onKeyDown={handleTriggerKeyDown}
                    onFocus={(event: FocusEvent) => onFocus?.(event)}
                    onBlur={(event: FocusEvent) => onBlur?.(event)}
                >
                    @if (prefix) {
                        <span class="lotus-select-prefix">{prefix}</span>
                    }
                    @if (multiple) {
                        <div class="lotus-select-tags">
                            @if (selectedLabels.length === 0 && !showTriggerInput) {
                                <span class="lotus-select-placeholder">{placeholder}</span>
                            } @else {
                                @for (const item of selectedLabels; key item.value) {
                                    <span class="lotus-select-tag">
                                        <span class="lotus-select-tag-label">{item.label}</span>
                                        <span
                                            class="lotus-select-tag-remove"
                                            onClick={(event: MouseEvent) => handleRemoveTag(item.value, event)}
                                        >
                                            <IconClear />
                                        </span>
                                    </span>
                                }
                            }
                            @if (showTriggerInput) {
                                <input
                                    class="lotus-select-trigger-input"
                                    type="text"
                                    value={state.searchInput}
                                    placeholder={selectedLabels.length === 0 ? placeholder : ''}
                                    onInput={handleSearchInput}
                                    onClick={(event: MouseEvent) => event.stopPropagation()}
                                    ref={(node: HTMLInputElement) => { triggerInputNode = node; }}
                                />
                            }
                        </div>
                    } @else if (showTriggerInput) {
                        <input
                            class="lotus-select-trigger-input"
                            type="text"
                            value={state.searchInput}
                            placeholder={singleSelectedLabel !== undefined ? String(singleSelectedLabel) : placeholder}
                            onInput={handleSearchInput}
                            onClick={(event: MouseEvent) => event.stopPropagation()}
                            ref={(node: HTMLInputElement) => { triggerInputNode = node; }}
                        />
                    } @else {
                        @if (singleSelectedLabel !== undefined) {
                            <span class="lotus-select-value">{singleSelectedLabel}</span>
                        } @else {
                            <span class="lotus-select-placeholder">{placeholder}</span>
                        }
                    }
                    @if (allowClear) {
                        <span
                            class="lotus-select-clear"
                            aria-label={locale.Select.clear}
                            onClick={handleClear}
                        >
                            <IconClear />
                        </span>
                    }
                    @if (suffix) {
                        <span class="lotus-select-suffix">{suffix}</span>
                    }
                    <span class="lotus-select-arrow">
                        <IconChevronDown />
                    </span>
                </div>
            </Popover>
        </div>

        <style>
            .lotus-select {
                display: inline-block;
                width: 100%;
            }

            .lotus-select-trigger {
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

            .lotus-select-open .lotus-select-trigger,
            .lotus-select-trigger:hover {
                border-color: var(--lotus-color-primary);
            }

            .lotus-select-borderless .lotus-select-trigger {
                border-color: transparent;
                background: transparent;
            }

            .lotus-select-disabled .lotus-select-trigger {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
                border-color: var(--lotus-color-border);
            }

            .lotus-select-status-warning .lotus-select-trigger {
                border-color: var(--lotus-color-warning);
            }

            .lotus-select-status-error .lotus-select-trigger {
                border-color: var(--lotus-color-danger);
            }

            .lotus-select-size-large .lotus-select-trigger { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }
            .lotus-select-size-default .lotus-select-trigger { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-select-size-small .lotus-select-trigger { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }

            .lotus-select-multiple .lotus-select-trigger {
                height: auto;
                min-height: var(--lotus-height-control-default);
                padding: 4px var(--lotus-spacing-tight);
            }

            .lotus-select-value,
            .lotus-select-placeholder {
                flex: 1;
                min-width: 0;
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                color: var(--lotus-color-text-0);
            }

            .lotus-select-placeholder {
                color: var(--lotus-color-text-3);
            }

            .lotus-select-disabled .lotus-select-value,
            .lotus-select-disabled .lotus-select-placeholder {
                color: var(--lotus-color-disabled-text);
            }

            .lotus-select-prefix,
            .lotus-select-suffix {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
            }

            .lotus-select-arrow {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
                font-size: 12px;
                transition: transform 0.2s ease;
            }

            .lotus-select-open .lotus-select-arrow {
                transform: rotate(180deg);
            }

            .lotus-select-clear {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-select-clear:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-select-tags {
                display: flex;
                flex: 1;
                flex-wrap: wrap;
                gap: 4px;
                min-width: 0;
            }

            .lotus-select-tag {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                padding: 2px 6px;
                background: var(--lotus-color-fill-0);
                border-radius: var(--lotus-border-radius-small);
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-select-tag-remove {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                font-size: 10px;
            }

            .lotus-select-tag-remove:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-select-panel {
                display: flex;
                flex-direction: column;
                min-width: 120px;
            }

            .lotus-select-search-box {
                display: flex;
                align-items: center;
                gap: 6px;
                padding: 6px 8px;
                border-bottom: 1px solid var(--lotus-color-border);
                color: var(--lotus-color-text-2);
            }

            .lotus-select-search-input {
                flex: 1;
                border: none;
                outline: none;
                background: transparent;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-select-trigger-input {
                flex: 1;
                min-width: 40px;
                border: none;
                outline: none;
                background: transparent;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                padding: 0;
            }

            .lotus-select-list {
                list-style: none;
                margin: 0;
                padding: 4px;
                max-height: 270px;
                overflow-y: auto;
                min-width: 120px;
            }

            .lotus-select-list-virtual {
                max-height: none;
            }

            .lotus-select-empty {
                padding: 6px 8px;
                color: var(--lotus-color-text-3);
                font-size: var(--lotus-font-body-size);
            }

        </style>
    </>
}
