import { track, untrack, effect } from 'ripple';
import { InputNumberFoundation, type InputNumberState, type InputNumberBounds, type ScientificNotationConfig } from '@lotus/foundation/input/input-number';
import { IconChevronUp, IconChevronDown, IconClear } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type InputNumberSize = 'large' | 'default' | 'small';
export type { ScientificNotationConfig };

export interface InputNumberApi {
    /** 命令式聚焦原生 input（对齐 Semi 的 ref.current.focus()；与 Input 的
     * getInputApi 同一模式）。`preventScroll` 透传给原生 focus() 的同名选项。 */
    focus: (options?: { preventScroll?: boolean }) => void;
    /** 命令式移出焦点，同上。 */
    blur: () => void;
}

export interface InputNumberProps {
    /** 原生 input 元素的 id，配合 Form.Field 渲染的 `<label for={field}>` 建立真正的语义关联。 */
    id?: string;
    value?: number;
    defaultValue?: number;
    min?: number;
    max?: number;
    step?: number;
    /** 按住 Shift 键时的步进值，覆盖 step（对齐 Semi，默认 10）。 */
    shiftStep?: number;
    disabled?: boolean;
    size?: InputNumberSize;
    hideButtons?: boolean;
    /** 步进按钮显示在输入框内部而非右侧独立区域。 */
    innerButtons?: boolean;
    /** 点击步进按钮时保持输入框聚焦（不触发 blur）；innerButtons=true 时天然保持聚焦，对齐 Semi。 */
    keepFocus?: boolean;
    autofocus?: boolean;
    showClear?: boolean;
    clearIcon?: any;
    /** 数值精度：blur/步进后四舍五入到指定小数位数。 */
    precision?: number;
    /** 自定义输入框展示值的格式（如千分位）；聚焦与失焦态都会应用。 */
    formatter?: (value: number | string) => string;
    /** 配合 formatter 使用，把展示字符串转换回可解析的原始数字字符串。 */
    parser?: (str: string) => string;
    /** 科学计数法：失焦时若有效数字位数达到阈值（默认 15）则用科学计数法展示；不支持货币模式。 */
    scientificNotation?: ScientificNotationConfig;
    /** 货币种类：true 时按 localeCode 自动推导，也可直接传货币代码（如 'USD'）。 */
    currency?: boolean | string;
    currencyDisplay?: 'symbol' | 'code' | 'name';
    /** 货币模式下的国家/地区代码；不传时跟随 ConfigProvider 的当前语言环境。 */
    localeCode?: string;
    showCurrencySymbol?: boolean;
    pressInterval?: number;
    pressTimeout?: number;
    getInputNumberApi?: (api: InputNumberApi) => void;
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
    id,
    value,
    defaultValue,
    min = -Infinity,
    max = Infinity,
    step = 1,
    shiftStep = 10,
    disabled = false,
    size = 'default',
    hideButtons = false,
    innerButtons = false,
    keepFocus = false,
    autofocus = false,
    showClear = false,
    clearIcon,
    precision,
    formatter,
    parser,
    scientificNotation = false,
    currency = false,
    currencyDisplay = 'symbol',
    localeCode,
    showCurrencySymbol = true,
    pressInterval = 250,
    pressTimeout = 250,
    getInputNumberApi,
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
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    let inputEl: HTMLInputElement | null = null;
    const resolvedLocaleCode = localeCode ?? locale.code;
    const isCurrencyMode = currency === true || (typeof currency === 'string' && currency.trim() !== '');
    // 货币模式与科学计数法互斥（对齐 Semi 文档："该功能不支持货币模式"），货币模式优先。
    const isScientificMode = !isCurrencyMode && InputNumberFoundation.isScientificNotationEnabled(scientificNotation);

    getInputNumberApi?.({
        focus: (options) => inputEl?.focus(options),
        blur: () => inputEl?.blur(),
    });

    // track() 而非普通 const——见 input/index.tsrx 同名注释，受控身份要能随
    // value 的 undefined↔有值 变化重新判定，否则外部表单 reset 无法清空展示值。
    let &[isControlled] = track<boolean>(() => value !== undefined);
    let &[state] = track<InputNumberState>({
        inputValue: (isControlled ? value : defaultValue) !== undefined ? String(isControlled ? value : defaultValue) : '',
        value: isControlled ? value : defaultValue,
        isFocus: false,
    });

    const foundation = new InputNumberFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<InputNumberState>) => { state = { ...state, ...patch }; },
    });

    // 受控身份会随 value 的 undefined↔有值 重新判定（见上面 isControlled 的
    // 注释）。但如果只是"一开始就非受控、用户在自由输入"（value 从未被外部
    // 传过），不应该被这个 effect 打扰；只有"曾经是受控组件（收到过非
    // undefined 的 value），之后被外部改回 undefined"（典型场景：Form 字段
    // 初始 undefined，用户输入后 Form 侧变为受控值，Form.reset() 又改回
    // undefined）才需要主动清空 state——否则 isControlled 变回 false 后，
    // state 会残留最后一次非受控写入的陈旧值，导致 reset 后展示值不会清空。
    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, inputValue: String(value), value }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, inputValue: '', value: undefined }; });
        }
    });

    let &[bounds] = track<InputNumberBounds>(() => ({ min, max, step }));

    // 受控模式下，展示字符串的"原始数字"部分直接跟随外部 value；非受控模式下
    // 用内部 state.inputValue（允许 "1."/"-" 这类还没解析完成的中间输入态，
    // 见 Foundation 注释）。
    let &[rawInputValue] = track<string>(() => (isControlled ? (value !== undefined ? String(value) : '') : state.inputValue));
    let &[displayValue] = track<number | undefined>(() => (isControlled ? value : state.value));

    // 聚焦态展示原始数字（方便编辑），失焦态才应用货币格式化/科学计数法/
    // 自定义 formatter（对齐 Semi `doFormat` 的 needAdjustCurrency 时机——
    // 那个标志只在 blur 路径为 true，输入过程中恒为 false）。
    let &[displayInputValue] = track<string>(() => {
        if (state.isFocus || rawInputValue === '') return formatter ? formatter(rawInputValue) : rawInputValue;
        const num = displayValue;
        if (num === undefined) return rawInputValue;
        let formatted: string;
        if (isCurrencyMode) {
            formatted = InputNumberFoundation.formatCurrency(num, currency, resolvedLocaleCode, currencyDisplay, showCurrencySymbol, precision);
        } else if (isScientificMode) {
            formatted = InputNumberFoundation.toScientificNotationIfNeeded(num, scientificNotation);
        } else {
            formatted = rawInputValue;
        }
        return formatter ? formatter(formatted) : formatted;
    });

    const handleChange = (v: number | undefined) => {
        if (v !== undefined) onNumberChange?.(v);
        onChange?.(v);
    };

    // parser 把 formatter/货币格式化后的展示字符串转换回可以直接解析的原始
    // 数字字符串（对齐 Semi："和 formatter 搭配使用"）；未传 parser 时，货币
    // 模式下也顺手剥离常见的千分位分隔符与货币符号残留数字之外的字符，
    // 让用户能在货币展示态下继续编辑而不必每次都被打回空值。
    function resolveRawInput(raw: string): string {
        if (parser) return parser(raw);
        if (isCurrencyMode) return raw.replace(/[^\d.-]/g, '');
        return raw;
    }

    const handleInputEvent = (event: Event) => {
        const target = event.target as HTMLInputElement;
        foundation.handleInput(resolveRawInput(target.value), isControlled, handleChange);
    };

    const handleFocusEvent = (event: FocusEvent) => {
        foundation.handleFocus();
        onFocus?.(event);
    };

    const handleBlurEvent = (event: FocusEvent) => {
        foundation.handleBlur(untrack(() => bounds), isControlled, handleChange, precision);
        onBlur?.(event);
    };

    function handleStepUp(useShiftStep: boolean) {
        foundation.handleStep(1, untrack(() => bounds), isControlled, disabled, handleChange, precision, useShiftStep ? shiftStep : undefined);
    }
    function handleStepDown(useShiftStep: boolean) {
        foundation.handleStep(-1, untrack(() => bounds), isControlled, disabled, handleChange, precision, useShiftStep ? shiftStep : undefined);
    }

    // 无障碍键盘步进：ArrowUp/ArrowDown 等价于点击加减按钮，对齐原生
    // <input type="number"> 的方向键行为（自定义控件必须自己实现，浏览器
    // 不会对 type="text" 的 input 提供这个默认交互）。按住 Shift 时用 shiftStep。
    function handleInputKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (event.key === 'ArrowUp') {
            event.preventDefault();
            handleStepUp(event.shiftKey);
        } else if (event.key === 'ArrowDown') {
            event.preventDefault();
            handleStepDown(event.shiftKey);
        }
    }

    let &[stepUpDisabled] = track<boolean>(() => InputNumberFoundation.isStepDisabled(1, displayValue, bounds, disabled));
    let &[stepDownDisabled] = track<boolean>(() => InputNumberFoundation.isStepDisabled(-1, displayValue, bounds, disabled));

    let &[allowClear] = track<boolean>(() => showClear && !disabled && rawInputValue !== '');

    // 长按步进按钮连续触发：pressTimeout 后开始，此后每 pressInterval 触发一次，
    // 松开/移出按钮时清理定时器，避免卸载后残留悬挂定时器持续触发。
    let pressTimeoutHandle: ReturnType<typeof setTimeout> | null = null;
    let pressIntervalHandle: ReturnType<typeof setInterval> | null = null;
    function clearPressTimers() {
        if (pressTimeoutHandle !== null) { clearTimeout(pressTimeoutHandle); pressTimeoutHandle = null; }
        if (pressIntervalHandle !== null) { clearInterval(pressIntervalHandle); pressIntervalHandle = null; }
    }
    function startPress(direction: 1 | -1, event: MouseEvent) {
        const useShiftStep = event.shiftKey;
        clearPressTimers();
        pressTimeoutHandle = setTimeout(() => {
            pressIntervalHandle = setInterval(() => {
                if (direction === 1) handleStepUp(useShiftStep); else handleStepDown(useShiftStep);
            }, pressInterval);
        }, pressTimeout);
    }
    effect(() => {
        return () => clearPressTimers();
    });

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
                ref={(node: HTMLInputElement) => { inputEl = node; }}
                id={id}
                type="text"
                inputMode="decimal"
                class="lotus-input-number-native"
                value={displayInputValue}
                placeholder={placeholder}
                disabled={disabled}
                autofocus={autofocus}
                aria-label={ariaLabel}
                onInput={handleInputEvent}
                onFocus={handleFocusEvent}
                onBlur={handleBlurEvent}
                onKeyDown={handleInputKeyDown}
            />
            @if (allowClear) {
                <button
                    type="button"
                    class="lotus-input-number-clear"
                    aria-label={locale.InputNumber.clear}
                    onMouseDown={(event: MouseEvent) => event.preventDefault()}
                    onClick={() => { foundation.handleClear(isControlled, handleChange); }}
                >
                    {clearIcon ?? <IconClear />}
                </button>
            }
            @if (suffix) {
                <span class="lotus-input-number-suffix">{suffix}</span>
            }
            @if (!hideButtons && !innerButtons) {
                <div class="lotus-input-number-buttons">
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label={locale.InputNumber.increase}
                        disabled={stepUpDisabled}
                        onMouseDown={(event: MouseEvent) => { if (keepFocus) event.preventDefault(); startPress(1, event); }}
                        onMouseUp={clearPressTimers}
                        onMouseLeave={clearPressTimers}
                        onClick={(event: MouseEvent) => handleStepUp(event.shiftKey)}
                    >
                        <IconChevronUp />
                    </button>
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label={locale.InputNumber.decrease}
                        disabled={stepDownDisabled}
                        onMouseDown={(event: MouseEvent) => { if (keepFocus) event.preventDefault(); startPress(-1, event); }}
                        onMouseUp={clearPressTimers}
                        onMouseLeave={clearPressTimers}
                        onClick={(event: MouseEvent) => handleStepDown(event.shiftKey)}
                    >
                        <IconChevronDown />
                    </button>
                </div>
            }
            @if (!hideButtons && innerButtons) {
                <div class="lotus-input-number-buttons lotus-input-number-buttons-inner">
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label={locale.InputNumber.decrease}
                        disabled={stepDownDisabled}
                        onMouseDown={(event: MouseEvent) => { event.preventDefault(); startPress(-1, event); }}
                        onMouseUp={clearPressTimers}
                        onMouseLeave={clearPressTimers}
                        onClick={(event: MouseEvent) => handleStepDown(event.shiftKey)}
                    >
                        <IconChevronDown />
                    </button>
                    <button
                        type="button"
                        class="lotus-input-number-button"
                        aria-label={locale.InputNumber.increase}
                        disabled={stepUpDisabled}
                        onMouseDown={(event: MouseEvent) => { event.preventDefault(); startPress(1, event); }}
                        onMouseUp={clearPressTimers}
                        onMouseLeave={clearPressTimers}
                        onClick={(event: MouseEvent) => handleStepUp(event.shiftKey)}
                    >
                        <IconChevronUp />
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
                text-align: start;
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
                margin-inline-end: var(--lotus-spacing-tight);
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
                border-inline-start: var(--lotus-border-width-control) solid var(--lotus-color-border);
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

            /* innerButtons：左右并排显示在输入框内部（对齐 Semi），不再上下堆叠、
               不再需要独立的左边框分隔——两个按钮各自用间距分开即可。 */
            .lotus-input-number-buttons-inner {
                flex-direction: row;
                align-items: center;
                gap: 2px;
                border-inline-start: none;
                padding-inline-end: var(--lotus-spacing-tight);
            }

            .lotus-input-number-buttons-inner .lotus-input-number-button {
                width: 18px;
                height: 18px;
                flex: none;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-input-number-buttons-inner .lotus-input-number-button:first-child {
                border-bottom: none;
            }

            .lotus-input-number-buttons-inner .lotus-input-number-button:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
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
