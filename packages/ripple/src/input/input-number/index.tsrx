import { track, untrack } from 'ripple';
import { InputNumberFoundation, type InputNumberState, type InputNumberBounds } from '@lotus/foundation/input/input-number';
import { IconChevronUp, IconChevronDown, IconClear } from '@lotus/icons';

export type InputNumberSize = 'large' | 'default' | 'small';

export interface InputNumberProps {
    value?: number;
    defaultValue?: number;
    min?: number;
    max?: number;
    step?: number;
    disabled?: boolean;
    size?: InputNumberSize;
    hideButtons?: boolean;
    showClear?: boolean;
    prefix?: any;
    suffix?: any;
    placeholder?: string;
    'aria-label'?: string;
    onChange?: (value: number | undefined) => void;
    onNumberChange?: (value: number) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    style?: Record<string, any>;
    class?: string;
}

export function InputNumber(&{
    value,
    defaultValue,
    min = -Infinity,
    max = Infinity,
    step = 1,
    disabled = false,
    size = 'default',
    hideButtons = false,
    showClear = false,
    prefix,
    suffix,
    placeholder,
    'aria-label': ariaLabel,
    onChange,
    onNumberChange,
    onFocus,
    onBlur,
    style,
    class: className,
}: InputNumberProps) @{
    const isControlled = value !== undefined;
    let &[state] = track<InputNumberState>({
        inputValue: (isControlled ? value : defaultValue) !== undefined ? String(isControlled ? value : defaultValue) : '',
        value: isControlled ? value : defaultValue,
        isFocus: false,
    });

    const foundation = new InputNumberFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<InputNumberState>) => { state = { ...state, ...patch }; },
    });

    let &[bounds] = track<InputNumberBounds>(() => ({ min, max, step }));

    // 受控模式下，展示字符串直接跟随外部 value；非受控模式下用内部 state.inputValue
    // （允许 "1."/"-" 这类还没解析完成的中间输入态，见 Foundation 注释）。
    let &[displayInputValue] = track<string>(() => (isControlled ? (value !== undefined ? String(value) : '') : state.inputValue));
    let &[displayValue] = track<number | undefined>(() => (isControlled ? value : state.value));

    const handleChange = (v: number | undefined) => {
        if (v !== undefined) onNumberChange?.(v);
        onChange?.(v);
    };

    const handleInputEvent = (event: Event) => {
        const target = event.target as HTMLInputElement;
        foundation.handleInput(target.value, isControlled, handleChange);
    };

    const handleFocusEvent = (event: FocusEvent) => {
        foundation.handleFocus();
        onFocus?.(event);
    };

    const handleBlurEvent = (event: FocusEvent) => {
        foundation.handleBlur(untrack(() => bounds), isControlled, handleChange);
        onBlur?.(event);
    };

    const handleStepUp = () => foundation.handleStep(1, untrack(() => bounds), isControlled, disabled, handleChange);
    const handleStepDown = () => foundation.handleStep(-1, untrack(() => bounds), isControlled, disabled, handleChange);

    let &[stepUpDisabled] = track<boolean>(() => InputNumberFoundation.isStepDisabled(1, displayValue, bounds, disabled));
    let &[stepDownDisabled] = track<boolean>(() => InputNumberFoundation.isStepDisabled(-1, displayValue, bounds, disabled));

    let &[allowClear] = track<boolean>(() => showClear && !disabled && displayInputValue !== '');

    let &[classes] = track<string>(() =>
        [
            'lotus-input-number',
            `lotus-input-number-size-${size}`,
            disabled ? 'lotus-input-number-disabled' : '',
            state.isFocus ? 'lotus-input-number-focus' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class={classes} style={style}>
            @if (prefix) {
                <span class="lotus-input-number-prefix">{prefix}</span>
            }
            <input
                type="text"
                inputMode="decimal"
                class="lotus-input-number-native"
                value={displayInputValue}
                placeholder={placeholder}
                disabled={disabled}
                aria-label={ariaLabel}
                onInput={handleInputEvent}
                onFocus={handleFocusEvent}
                onBlur={handleBlurEvent}
            />
            @if (allowClear) {
                <button
                    type="button"
                    class="lotus-input-number-clear"
                    aria-label="清除"
                    onMouseDown={(event: MouseEvent) => event.preventDefault()}
                    onClick={() => { foundation.handleInput('', isControlled, handleChange); }}
                >
                    <IconClear />
                </button>
            }
            @if (suffix) {
                <span class="lotus-input-number-suffix">{suffix}</span>
            }
            @if (!hideButtons) {
                <div class="lotus-input-number-buttons">
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label="增加"
                        disabled={stepUpDisabled}
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={handleStepUp}
                    >
                        <IconChevronUp />
                    </button>
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label="减少"
                        disabled={stepDownDisabled}
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={handleStepDown}
                    >
                        <IconChevronDown />
                    </button>
                </div>
            }
        </div>

        <style>
            .lotus-input-number {
                display: inline-flex;
                align-items: stretch;
                width: 100%;
                box-sizing: border-box;
                background: var(--lotus-color-bg-1);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                transition: border-color 0.2s ease;
            }

            .lotus-input-number-focus {
                border-color: var(--lotus-color-primary);
            }

            .lotus-input-number-disabled {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
            }

            .lotus-input-number-size-large { height: var(--lotus-height-control-large); font-size: var(--lotus-font-body-size); }
            .lotus-input-number-size-default { height: var(--lotus-height-control-default); font-size: var(--lotus-font-body-size); }
            .lotus-input-number-size-small { height: var(--lotus-height-control-small); font-size: var(--lotus-font-label-size); }

            .lotus-input-number-native {
                flex: 1;
                min-width: 0;
                border: none;
                outline: none;
                background: transparent;
                color: var(--lotus-color-text-0);
                font-family: var(--lotus-font-family);
                font-size: inherit;
                padding: 0 var(--lotus-spacing-tight);
                text-align: left;
            }

            .lotus-input-number-native:disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-input-number-native::placeholder {
                color: var(--lotus-color-text-3);
            }

            .lotus-input-number-prefix,
            .lotus-input-number-suffix {
                display: inline-flex;
                align-items: center;
                padding: 0 var(--lotus-spacing-tight);
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
            }

            .lotus-input-number-clear {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                margin-right: var(--lotus-spacing-tight);
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-input-number-clear:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-input-number-buttons {
                display: flex;
                flex-direction: column;
                flex-shrink: 0;
                border-left: var(--lotus-border-width-control) solid var(--lotus-color-border);
            }

            .lotus-input-number-button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                flex: 1;
                width: 24px;
                border: none;
                background: transparent;
                padding: 0;
                color: var(--lotus-color-text-2);
                font-size: 12px;
                cursor: pointer;
                line-height: 1;
            }

            .lotus-input-number-button:first-child {
                border-bottom: var(--lotus-border-width-control) solid var(--lotus-color-border);
            }

            .lotus-input-number-button:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-input-number-button:disabled {
                cursor: not-allowed;
                color: var(--lotus-color-disabled-text);
            }
        </style>
    </>
}
