import { track, untrack, effect } from 'ripple';
import {
    AutoCompleteFoundation,
    normalizeOptions,
    type AutoCompleteState,
    type AutoCompleteValue,
    type AutoCompleteDataItem,
    type AutoCompleteOptionItem,
} from '@lotus/foundation/input/auto-complete';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { Popover } from '../../show/popover/index.tsrx';
import { Input, type InputSize, type InputValidateStatus } from '../input/index.tsrx';
import { Spin } from '../../feedback/spin/index.tsrx';

export type AutoCompleteSize = InputSize;
export type AutoCompleteValidateStatus = InputValidateStatus;
export type { AutoCompleteValue, AutoCompleteDataItem };

export interface AutoCompleteProps {
    data?: AutoCompleteDataItem[];
    value?: AutoCompleteValue;
    defaultValue?: AutoCompleteValue;
    disabled?: boolean;
    placeholder?: string;
    size?: AutoCompleteSize;
    validateStatus?: AutoCompleteValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    position?: FloatingPosition;
    /** 打开面板时默认高亮第一个候选项，回车可直接选中，默认 false（对齐 Semi）。 */
    defaultActiveFirstOption?: boolean;
    loading?: boolean;
    emptyContent?: any;
    /** 自定义候选项渲染。 */
    renderItem?: (option: AutoCompleteOptionItem) => any;
    onChange?: (value: AutoCompleteValue) => void;
    onSearch?: (inputValue: AutoCompleteValue) => void;
    onSelect?: (option: AutoCompleteOptionItem) => void;
    onClear?: () => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onDropdownVisibleChange?: (visible: boolean) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

/**
 * AutoComplete：自由文本输入 + 候选建议。与 Select 的本质区别（对齐 Semi
 * 源码注释）：Select 是选择器，点击展开会清空/不依赖输入；AutoComplete 是
 * 增强型 Input，允许用户输入任意文本，候选项只是"建议"，不强制从中选择。
 *
 * 不做候选项过滤——`data` 展示什么完全由外部决定，消费方在 `onSearch`
 * 回调里算好新的候选数组传回 `data` prop（对齐 Semi 源码：AutoComplete
 * 本身没有过滤/匹配算法，这是刻意的设计留白）。
 *
 * 架构：直接组合现有 `Input` 组件作为触发器（不重新实现输入框），浮层开关
 * 复用 Cascader 已验证的 Popover(trigger="custom") + document mousedown
 * 双 contains 判断模式。键盘导航（上下键移动焦点、循环回绕、跳过 disabled
 * 项、Enter 选中、Esc 关闭）完整对齐 Semi——这是本次调研发现 Semi 少数
 * 键盘支持较完整的组件，值得对齐而非简化。
 */
export function AutoComplete(&{
    data = [],
    value,
    defaultValue,
    disabled = false,
    placeholder,
    size = 'default',
    validateStatus = 'default',
    borderless = false,
    showClear = false,
    position = 'bottomLeft',
    defaultActiveFirstOption = false,
    loading = false,
    emptyContent,
    renderItem,
    onChange,
    onSearch,
    onSelect,
    onClear,
    onFocus,
    onBlur,
    onDropdownVisibleChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: AutoCompleteProps) @{
    let &[options] = track<AutoCompleteOptionItem[]>(() => normalizeOptions(data));

    const isControlled = value !== undefined;
    let &[state] = track<AutoCompleteState>({
        inputValue: isControlled ? (value ?? '') : (defaultValue ?? ''),
        visible: false,
        focusIndex: -1,
    });
    let &[rootNode] = track<HTMLElement | null>(null);
    let &[listNode] = track<HTMLElement | null>(null);

    const foundation = new AutoCompleteFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<AutoCompleteState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控 value 同步：外部传入新值时直接替换展示值（对齐 Semi handleValueChange
    // 的效果——受控下 inputValue 完全由外部决定）。同 Select/Cascader 已验证的
    // hasBeenControlled 处理，避免非受控写入后又变回 undefined 时残留陈旧值。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, inputValue: value }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, inputValue: '' }; });
        }
    });

    function handleInputChange(nextValue: string) {
        foundation.handleSearch(nextValue, untrack(() => options), defaultActiveFirstOption, isControlled);
        onSearch?.(nextValue);
        onChange?.(nextValue);
    }

    function handleOptionSelect(option: AutoCompleteOptionItem, index: number) {
        if (option.disabled) return;
        const value = foundation.handleSelect(option, index, isControlled);
        onSelect?.(option);
        onChange?.(value);
    }

    function handleInputFocus(event: FocusEvent) {
        onFocus?.(event);
    }

    function handleInputBlur(event: FocusEvent) {
        onBlur?.(event);
    }

    function handleInputClear() {
        onClear?.();
    }

    function handleTriggerClick() {
        if (disabled) return;
        const wasVisible = untrack(() => state).visible;
        if (wasVisible) return;
        foundation.openOnTriggerClick(untrack(() => options), defaultActiveFirstOption);
        onDropdownVisibleChange?.(true);
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (event.key === 'ArrowDown') {
            event.preventDefault();
            const wasVisible = untrack(() => state).visible;
            foundation.handleArrowKey(untrack(() => options), 1, defaultActiveFirstOption);
            if (!wasVisible) onDropdownVisibleChange?.(true);
            return;
        }
        if (event.key === 'ArrowUp') {
            event.preventDefault();
            const wasVisible = untrack(() => state).visible;
            foundation.handleArrowKey(untrack(() => options), -1, defaultActiveFirstOption);
            if (!wasVisible) onDropdownVisibleChange?.(true);
            return;
        }
        if (event.key === 'Enter') {
            event.preventDefault();
            const current = untrack(() => state);
            if (!current.visible) {
                foundation.open(untrack(() => options), defaultActiveFirstOption);
                onDropdownVisibleChange?.(true);
                return;
            }
            if (current.focusIndex >= 0) {
                const option = untrack(() => options)[current.focusIndex];
                if (option) handleOptionSelect(option, current.focusIndex);
            } else {
                foundation.close();
                onDropdownVisibleChange?.(false);
            }
            return;
        }
        if (event.key === 'Escape') {
            if (untrack(() => state).visible) {
                foundation.close();
                onDropdownVisibleChange?.(false);
            }
            return;
        }
        if (event.key === 'Tab') {
            if (untrack(() => state).visible) {
                foundation.close();
                onDropdownVisibleChange?.(false);
            }
        }
    }

    // 同 Cascader：document 级常驻 mousedown 监听，双 contains 判断处理 Portal 场景。
    effect(() => {
        const handleDocumentMouseDown = (event: MouseEvent) => {
            if (!untrack(() => state).visible) return;
            if (!(event.target instanceof Node)) return;
            const root = untrack(() => rootNode);
            if (root?.contains(event.target)) return;
            const list = untrack(() => listNode);
            if (list?.contains(event.target)) return;
            foundation.close();
            onDropdownVisibleChange?.(false);
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
    });

    let &[displayValue] = track<string>(() => String(state.inputValue ?? ''));

    let &[classes] = track<string>(() =>
        ['lotus-auto-complete', disabled ? 'lotus-auto-complete-disabled' : '', className ?? ''].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }} onKeyDown={handleKeyDown}>
            <Popover
                trigger="custom"
                visible={state.visible && (loading || options.length > 0 || emptyContent !== undefined)}
                position={position}
                spacing={4}
                closeOnEsc={false}
                content={
                    <div class="lotus-auto-complete-panel" ref={(node: HTMLElement) => { listNode = node; }}>
                        @if (loading) {
                            <div class="lotus-auto-complete-loading"><Spin size="small" /></div>
                        } @else {
                            @if (options.length === 0) {
                                @if (emptyContent !== undefined) {
                                    <div class="lotus-auto-complete-empty">{emptyContent}</div>
                                }
                            } @else {
                                <ul class="lotus-auto-complete-list" role="listbox">
                                    @for (const option of options; index i; key option.value) {
                                        <li
                                            role="option"
                                            aria-selected={i === state.focusIndex}
                                            aria-disabled={option.disabled}
                                            class={[
                                                'lotus-auto-complete-option',
                                                i === state.focusIndex ? 'lotus-auto-complete-option-focused' : '',
                                                option.disabled ? 'lotus-auto-complete-option-disabled' : '',
                                            ].filter(Boolean).join(' ')}
                                            onClick={() => handleOptionSelect(option, i)}
                                            onMouseEnter={() => { if (!option.disabled) untrack(() => { state = { ...state, focusIndex: i }; }); }}
                                        >
                                            {renderItem ? renderItem(option) : option.label}
                                        </li>
                                    }
                                </ul>
                            }
                        }
                    </div>
                }
            >
                <div onClick={handleTriggerClick}>
                    <Input
                        value={displayValue}
                        disabled={disabled}
                        size={size}
                        validateStatus={validateStatus}
                        borderless={borderless}
                        showClear={showClear}
                        placeholder={placeholder}
                        aria-label={ariaLabel}
                        onChange={handleInputChange}
                        onFocus={handleInputFocus}
                        onBlur={handleInputBlur}
                        onClear={handleInputClear}
                    />
                </div>
            </Popover>
        </div>

        <style>
            .lotus-auto-complete {
                display: inline-block;
                width: 100%;
            }

            .lotus-auto-complete-panel {
                min-width: 160px;
            }

            .lotus-auto-complete-list {
                list-style: none;
                margin: 0;
                padding: 4px;
                max-height: 300px;
                overflow-y: auto;
            }

            .lotus-auto-complete-option {
                padding: 6px 8px;
                border-radius: var(--lotus-border-radius-small);
                cursor: pointer;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

            .lotus-auto-complete-option:hover,
            .lotus-auto-complete-option-focused {
                background: var(--lotus-color-fill-0);
            }

            .lotus-auto-complete-option-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-auto-complete-option-disabled:hover {
                background: transparent;
            }

            .lotus-auto-complete-empty {
                padding: var(--lotus-spacing-base);
                text-align: center;
                color: var(--lotus-color-text-2);
            }

            .lotus-auto-complete-loading {
                display: flex;
                align-items: center;
                justify-content: center;
                padding: var(--lotus-spacing-base);
            }
        </style>
    </>
}
