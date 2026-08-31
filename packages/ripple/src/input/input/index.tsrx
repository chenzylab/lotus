import { track, untrack, effect } from 'ripple';
import { InputFoundation, type InputState } from '@lotus/foundation/input/input';
import { IconClear, IconEyeOpened, IconEyeClosedSolid } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type InputSize = 'large' | 'default' | 'small';
export type InputValidateStatus = 'default' | 'warning' | 'error';
export type InputMode = 'text' | 'password';

export interface InputApi {
    /** 命令式聚焦原生 input（对齐 Semi 的 ref.current.focus()；Ripple 没有 ref
     * 转发到自定义实例的机制，改用 getInputApi 回调获取，与 Cropper 的
     * getCropperApi 同一模式）。`preventScroll` 透传给原生 focus() 的同名选项。 */
    focus: (options?: { preventScroll?: boolean }) => void;
    /** 命令式移出焦点，同上。 */
    blur: () => void;
}

export interface InputProps {
    /** 原生 input 元素的 id，配合 Form.Field 渲染的 `<label for={field}>` 建立真正的语义关联。 */
    id?: string;
    value?: string;
    defaultValue?: string;
    disabled?: boolean;
    size?: InputSize;
    mode?: InputMode;
    validateStatus?: InputValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    hideSuffix?: boolean;
    clearIcon?: any;
    prefix?: any;
    suffix?: any;
    addonBefore?: any;
    addonAfter?: any;
    placeholder?: string;
    type?: string;
    composition?: boolean;
    maxLength?: number;
    /** 自定义计算字符串长度（如按字节而非字符数统计），用于 maxLength 截断判断。 */
    getValueLength?: (value: string) => number;
    getInputApi?: (api: InputApi) => void;
    'aria-describedby'?: string;
    'aria-errormessage'?: string;
    /** 显式覆盖 aria-invalid；不传时 validateStatus="error" 会自动推导为 "true"。 */
    'aria-invalid'?: string;
    'aria-label'?: string;
    'aria-labelledby'?: string;
    'aria-required'?: boolean;
    style?: Record<string, any>;
    class?: string;
    onChange?: (value: string, event: Event) => void;
    onClear?: (event: MouseEvent) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onKeyDown?: (event: KeyboardEvent) => void;
    onKeyUp?: (event: KeyboardEvent) => void;
    onKeyPress?: (event: KeyboardEvent) => void;
    onEnterPress?: (event: KeyboardEvent) => void;
    onCompositionStart?: (event: CompositionEvent) => void;
    onCompositionEnd?: (event: CompositionEvent) => void;
    onCompositionUpdate?: (event: CompositionEvent) => void;
}

export function Input(&{
    id,
    value,
    defaultValue = '',
    disabled = false,
    size = 'default',
    mode = 'text',
    validateStatus = 'default',
    borderless = false,
    showClear = false,
    hideSuffix = false,
    clearIcon,
    prefix,
    suffix,
    addonBefore,
    addonAfter,
    placeholder,
    type = 'text',
    composition = false,
    maxLength,
    getValueLength,
    getInputApi,
    'aria-describedby': ariaDescribedBy,
    'aria-errormessage': ariaErrorMessage,
    'aria-invalid': ariaInvalidProp,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledBy,
    'aria-required': ariaRequired,
    style,
    class: className,
    onChange,
    onClear,
    onFocus,
    onBlur,
    onKeyDown,
    onKeyUp,
    onKeyPress,
    onEnterPress,
    onCompositionStart,
    onCompositionEnd,
    onCompositionUpdate,
}: InputProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    let inputEl: HTMLInputElement | null = null;

    getInputApi?.({
        focus: (options) => inputEl?.focus(options),
        blur: () => inputEl?.blur(),
    });

    // 用 track() 而非普通 const，让受控身份能随 value 从 undefined 变为有值
    // （或反向变化，例如外部表单 reset 把值清回 undefined）而重新判定——
    // 普通 const 只在组件挂载时求值一次，此后 value 无论怎么变化，组件都会
    // 永久锁死在挂载时判定的受控/非受控模式，导致 reset 场景下受控组件的
    // 展示值无法被清空。见 specs/cross-cutting/foundation-adapter-pattern.md
    // 关于 isControlled 响应式修复的记录。
    let &[isControlled] = track<boolean>(() => value !== undefined);
    let &[state] = track<InputState>({
        value: isControlled ? (value ?? '') : defaultValue,
        isFocus: false,
        isHovering: false,
        eyeOpen: false,
    });

    const foundation = new InputFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<InputState>) => { state = { ...state, ...patch }; },
    });

    // 一旦组件经历过"非受控写入 state → 被外部 value 变为受控 → 又变回
    // undefined"（如 Form 字段初始 undefined、用户输入后受控、reset 又变回
    // undefined），如果不同步，切回非受控展示时 state.value 会残留 reset 前
    // 的陈旧值。详见 input-number/index.tsrx 同名注释与
    // specs/cross-cutting/foundation-adapter-pattern.md。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, value }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, value: '' }; });
        }
    });

    let &[displayValue] = track<string>(() => (isControlled ? (value ?? '') : state.value));
    const isPasswordMode = mode === 'password';
    let &[resolvedType] = track<string>(() => (isPasswordMode ? (state.eyeOpen ? 'text' : 'password') : type));
    let &[allowClear] = track<boolean>(() => InputFoundation.isAllowClear(displayValue, showClear, disabled, state.isFocus, state.isHovering));

    const resolveValueLength = (text: string) => (getValueLength ? getValueLength(text) : text.length);

    const handleInputEvent = (event: Event) => {
        const target = event.target as HTMLInputElement;
        let nextValue = target.value;
        if (maxLength !== undefined && resolveValueLength(nextValue) > maxLength) {
            nextValue = nextValue.slice(0, maxLength);
            target.value = nextValue;
        }
        foundation.handleInput(nextValue, event, isControlled, composition, onChange);
    };

    const handleKeyDownEvent = (event: KeyboardEvent) => {
        onKeyDown?.(event);
        if (event.key === 'Enter') onEnterPress?.(event);
    };

    let &[resolvedAriaInvalid] = track<string | undefined>(() =>
        ariaInvalidProp ?? (validateStatus === 'error' ? 'true' : undefined),
    );

    let &[classes] = track<string>(() =>
        [
            'lotus-input-wrapper',
            `lotus-input-size-${size}`,
            `lotus-input-status-${validateStatus}`,
            borderless ? 'lotus-input-borderless' : '',
            disabled ? 'lotus-input-disabled' : '',
            state.isFocus ? 'lotus-input-focus' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class="lotus-input-group">
            @if (addonBefore) {
                <div class="lotus-input-addon lotus-input-addon-before">{addonBefore}</div>
            }
            <div
                class={classes}
                style={style}
                onMouseEnter={() => foundation.handleMouseEnter()}
                onMouseLeave={() => foundation.handleMouseLeave()}
            >
                @if (prefix) {
                    <span class="lotus-input-prefix">{prefix}</span>
                }
                <input
                    ref={(node: HTMLInputElement) => { inputEl = node; }}
                    id={id}
                    type={resolvedType}
                    class="lotus-input-native"
                    value={displayValue}
                    placeholder={placeholder}
                    disabled={disabled}
                    aria-describedby={ariaDescribedBy}
                    aria-errormessage={ariaErrorMessage}
                    aria-invalid={resolvedAriaInvalid}
                    aria-label={ariaLabel}
                    aria-labelledby={ariaLabelledBy}
                    aria-required={ariaRequired}
                    onInput={handleInputEvent}
                    onFocus={(event: FocusEvent) => foundation.handleFocus(event, onFocus)}
                    onBlur={(event: FocusEvent) => foundation.handleBlur(event, onBlur)}
                    onKeyDown={handleKeyDownEvent}
                    onKeyUp={(event: KeyboardEvent) => onKeyUp?.(event)}
                    onKeyPress={(event: KeyboardEvent) => onKeyPress?.(event)}
                    onCompositionStart={(event: CompositionEvent) => foundation.handleCompositionStart(event, onCompositionStart)}
                    onCompositionUpdate={(event: CompositionEvent) => foundation.handleCompositionUpdate(event, onCompositionUpdate)}
                    onCompositionEnd={(event: CompositionEvent) => {
                        const target = event.target as HTMLInputElement;
                        foundation.handleCompositionEnd(target.value, event, isControlled, composition, onChange, onCompositionEnd);
                    }}
                />
                @if (allowClear) {
                    <button
                        type="button"
                        class="lotus-input-clear"
                        aria-label={locale.Input.clear}
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={(event: MouseEvent) => foundation.handleClear(event, isControlled, onChange, onClear)}
                    >
                        {clearIcon ?? <IconClear />}
                    </button>
                }
                @if (isPasswordMode) {
                    <button
                        type="button"
                        class="lotus-input-eye"
                        aria-label={state.eyeOpen ? locale.Input.hidePassword : locale.Input.showPassword}
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={() => foundation.toggleEye()}
                    >
                        @if (state.eyeOpen) {
                            <IconEyeOpened />
                        } @else {
                            <IconEyeClosedSolid />
                        }
                    </button>
                }
                @if (suffix && !(allowClear && hideSuffix)) {
                    <span class="lotus-input-suffix">{suffix}</span>
                }
            </div>
            @if (addonAfter) {
                <div class="lotus-input-addon lotus-input-addon-after">{addonAfter}</div>
            }
        </div>

        <style>
            .lotus-input-group {
                display: inline-flex;
                align-items: stretch;
                width: 100%;
            }

            .lotus-input-addon {
                display: inline-flex;
                align-items: center;
                padding: 0 var(--lotus-spacing-tight);
                background: var(--lotus-color-fill-0);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                color: var(--lotus-color-text-2);
                white-space: nowrap;
            }

            .lotus-input-addon-before {
                border-inline-end: none;
                border-start-start-radius: var(--lotus-border-radius-small);
                border-end-start-radius: var(--lotus-border-radius-small);
            }

            .lotus-input-addon-after {
                border-inline-start: none;
                border-start-end-radius: var(--lotus-border-radius-small);
                border-end-end-radius: var(--lotus-border-radius-small);
            }

            .lotus-input-group .lotus-input-addon-before + .lotus-input-wrapper {
                border-start-end-radius: var(--lotus-border-radius-small);
                border-end-end-radius: var(--lotus-border-radius-small);
            }

            .lotus-input-wrapper {
                display: inline-flex;
                align-items: center;
                flex: 1;
                min-width: 0;
                box-sizing: border-box;
                gap: 6px;
                padding: 0 var(--lotus-spacing-tight);
                background: var(--lotus-color-bg-1);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                transition: border-color 0.2s ease;
            }

            .lotus-input-group > .lotus-input-addon-before ~ .lotus-input-wrapper,
            .lotus-input-group > .lotus-input-wrapper:has(+ .lotus-input-addon-after) {
                border-radius: 0;
            }

            .lotus-input-group > .lotus-input-addon-before ~ .lotus-input-wrapper:has(+ .lotus-input-addon-after) {
                border-radius: 0;
            }

            .lotus-input-wrapper:first-child {
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-input-wrapper:first-child:has(~ .lotus-input-addon-after) {
                border-radius: var(--lotus-border-radius-small) 0 0 var(--lotus-border-radius-small);
            }

            .lotus-input-wrapper.lotus-input-focus {
                border-color: var(--lotus-color-primary);
            }

            .lotus-input-wrapper.lotus-input-borderless {
                border-color: transparent;
                background: transparent;
            }

            .lotus-input-wrapper.lotus-input-disabled {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
            }

            .lotus-input-wrapper.lotus-input-status-warning {
                border-color: var(--lotus-color-warning);
            }

            .lotus-input-wrapper.lotus-input-status-error {
                border-color: var(--lotus-color-danger);
            }

            .lotus-input-size-large { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }
            .lotus-input-size-default { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-input-size-small { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }

            .lotus-input-native {
                flex: 1;
                min-width: 0;
                border: none;
                outline: none;
                background: transparent;
                color: var(--lotus-color-text-0);
                font-family: var(--lotus-font-family);
                font-size: inherit;
            }

            .lotus-input-native:disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-input-native::placeholder {
                color: var(--lotus-color-text-3);
            }

            .lotus-input-prefix,
            .lotus-input-suffix {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
            }

            .lotus-input-clear,
            .lotus-input-eye {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-input-clear:hover,
            .lotus-input-eye:hover {
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}
