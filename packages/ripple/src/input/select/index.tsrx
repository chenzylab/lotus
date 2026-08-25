import { track, untrack, effect } from 'ripple';
import { SelectFoundation, type SelectState, type SelectValue } from '@lotus/foundation/input/select';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { calcVirtualRange } from '@lotus/foundation/base/virtual-list';
import { IconChevronDown, IconClear, IconTick } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';

export type SelectSize = 'large' | 'default' | 'small';
export type SelectValidateStatus = 'default' | 'warning' | 'error';

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
    'aria-label'?: string;
    onChange?: (value: SelectValue | SelectValue[] | undefined) => void;
    onClear?: () => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onDropdownVisibleChange?: (visible: boolean) => void;
    style?: Record<string, any>;
    class?: string;
}

interface SelectOptionItemProps {
    option: SelectOption;
    selected: boolean;
    onSelect: (option: SelectOption) => void;
}

/** 单个选项 `<li>` 的渲染抽成子组件，供虚拟化/非虚拟化两条渲染路径共用，
 * 避免重复维护同一份 class/aria 拼装逻辑。 */
function SelectOptionItem(&{ option, selected, onSelect }: SelectOptionItemProps) @{
    <>
    <li
        role="option"
        aria-selected={selected}
        aria-disabled={option.disabled}
        class={['lotus-select-option', selected ? 'lotus-select-option-selected' : '', option.disabled ? 'lotus-select-option-disabled' : ''].filter(Boolean).join(' ')}
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
    position = 'bottomLeft',
    'aria-label': ariaLabel,
    onChange,
    onClear,
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
    });
    let &[isOpen] = track<boolean>(false);
    let &[rootNode] = track<HTMLElement | null>(null);
    let &[listNode] = track<HTMLElement | null>(null);
    let &[scrollTop] = track<number>(0);

    function handleVirtualScroll(event: Event) {
        untrack(() => { scrollTop = (event.target as HTMLElement).scrollTop; });
    }

    let &[virtualRange] = track(() => {
        if (!virtualize) return null;
        return calcVirtualRange({
            itemCount: optionList.length,
            itemHeight: virtualize.itemSize,
            containerHeight: virtualize.height ?? 280,
            scrollTop,
        });
    });

    let &[virtualVisibleOptions] = track<Array<{ option: SelectOption; index: number }>>(() => {
        if (!virtualRange) return [];
        const result: Array<{ option: SelectOption; index: number }> = [];
        for (let i = virtualRange.startIndex; i <= virtualRange.endIndex; i++) {
            const option = optionList[i];
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

    const handleOptionClick = (option: SelectOption) => {
        if (option.disabled) return;
        if (multiple) {
            foundation.selectMultiple(option.value, isControlled, handleMultipleChange);
            return;
        }
        foundation.selectSingle(option.value, isControlled, handleSingleChange);
        isOpen = false;
        onDropdownVisibleChange?.(false);
    };

    const handleRemoveTag = (itemValue: SelectValue, event: MouseEvent) => {
        event.stopPropagation();
        foundation.removeMultipleValue(itemValue, isControlled, handleMultipleChange);
    };

    const handleTriggerClick = () => {
        if (disabled) return;
        const next = !untrack(() => isOpen);
        isOpen = next;
        onDropdownVisibleChange?.(next);
    };

    const handleClear = (event: MouseEvent) => {
        event.stopPropagation();
        foundation.clear(multiple, isControlled, handleSingleChange as (v: SelectValue | SelectValue[] | undefined) => void);
        onClear?.();
    };

    // 点击 Select 触发器/浮层以外的区域时收起下拉——Popover 本身只支持"再点一次触发器
    // 关闭"（trigger='click' 的 toggle 语义），选择器类组件还需要"点击选项后关闭"和
    // "点击页面任意其他地方关闭"，所以这里改用 Popover 的 trigger='custom' 完全自己
    // 接管开关状态。Ripple 的 effect() 没有返回清理函数的机制（不同于 React
    // useEffect 的 cleanup），故不在 effect 里装卸监听器，而是组件挂载时装一次
    // 常驻的 document 级监听，回调内部实时读取 isOpen/rootNode 判断是否需要处理，
    // 这与 Popover 内部处理 Portal 目标的"常驻而非按需装卸"思路一致。
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
            isOpen = false;
            onDropdownVisibleChange?.(false);
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
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

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }}>
            <Popover
                trigger="custom"
                visible={isOpen}
                position={position}
                spacing={4}
                closeOnEsc={true}
                content={
                    <ul
                        class={['lotus-select-list', virtualize ? 'lotus-select-list-virtual' : ''].filter(Boolean).join(' ')}
                        role="listbox"
                        aria-multiselectable={multiple}
                        style={virtualize ? { height: `${virtualize.height ?? 280}px` } : undefined}
                        onScroll={virtualize ? handleVirtualScroll : undefined}
                        ref={(node: HTMLElement) => { listNode = node; }}
                    >
                        @if (virtualize) {
                            <div style={{ height: `${virtualRange?.totalHeight ?? 0}px` }}>
                                <div style={{ transform: `translateY(${virtualRange?.offsetY ?? 0}px)` }}>
                                    @for (const entry of virtualVisibleOptions; index vi; key entry.option.value) {
                                        <div style={{ height: `${virtualize.itemSize}px` }}>
                                            <SelectOptionItem
                                                option={entry.option}
                                                selected={multiple ? SelectFoundation.isMultipleChecked(displayValue, entry.option.value) : SelectFoundation.isSingleChecked(displayValue, entry.option.value)}
                                                onSelect={handleOptionClick}
                                            />
                                        </div>
                                    }
                                </div>
                            </div>
                        } @else {
                            @for (const option of optionList; key option.value) {
                                <SelectOptionItem
                                    option={option}
                                    selected={multiple ? SelectFoundation.isMultipleChecked(displayValue, option.value) : SelectFoundation.isSingleChecked(displayValue, option.value)}
                                    onSelect={handleOptionClick}
                                />
                            }
                        }
                    </ul>
                }
            >
                <div
                    role="combobox"
                    aria-expanded={isOpen}
                    aria-haspopup="listbox"
                    aria-label={ariaLabel}
                    aria-disabled={disabled}
                    tabIndex={disabled ? -1 : 0}
                    class="lotus-select-trigger"
                    onClick={handleTriggerClick}
                    onFocus={(event: FocusEvent) => onFocus?.(event)}
                    onBlur={(event: FocusEvent) => onBlur?.(event)}
                >
                    @if (prefix) {
                        <span class="lotus-select-prefix">{prefix}</span>
                    }
                    @if (multiple) {
                        <div class="lotus-select-tags">
                            @if (selectedLabels.length === 0) {
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
                        </div>
                    } @else {
                        @if (selectedLabels.length > 0) {
                            <span class="lotus-select-value">{selectedLabels[0]!.label}</span>
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

        </style>
    </>
}
