import { track, effect, untrack } from 'ripple';
import { TextAreaFoundation, type TextAreaState } from '@lotus/foundation/input/text-area';
import { calculateAutosizeHeight, measureTextWidth, getLineHeightPx, type AutosizeOption } from './measure';
import { IconClear } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface TextAreaApi {
    /** 命令式聚焦原生 textarea（对齐 Semi 的 ref.current.focus()；与 Input 的
     * getInputApi 同一模式）。`preventScroll` 透传给原生 focus() 的同名选项。 */
    focus: (options?: { preventScroll?: boolean }) => void;
    /** 命令式移出焦点，同上。 */
    blur: () => void;
}

export interface TextAreaProps {
    /** 原生 textarea 元素的 id，配合 Form.Field 渲染的 `<label for={field}>` 建立真正的语义关联。 */
    id?: string;
    value?: string;
    defaultValue?: string;
    disabled?: boolean;
    readonly?: boolean;
    placeholder?: string;
    rows?: number;
    cols?: number;
    autosize?: boolean | AutosizeOption;
    resize?: 'none' | 'both' | 'horizontal' | 'vertical';
    maxCount?: number;
    maxLength?: number;
    /** 自定义计算字符串长度，用于 maxLength 截断判断与 maxCount 计数展示。 */
    getValueLength?: (value: string) => number;
    getTextAreaApi?: (api: TextAreaApi) => void;
    showClear?: boolean;
    borderless?: boolean;
    /** 校验状态，仅影响展示样式（对齐 Semi）。 */
    validateStatus?: 'default' | 'warning' | 'error';
    /** 挂载时是否自动聚焦，透传给原生 autofocus 属性（对齐 Semi）。 */
    autoFocus?: boolean;
    /** 独立开关，不传 maxCount 也单独显示当前字符计数（不带 "/总数"）；
     * 传 maxCount 时无论是否传这个 prop 都会显示计数器（对齐 Semi
     * `showCounter || maxCount` 的判定条件）。 */
    showCounter?: boolean;
    /** 左侧行号栏（代码编辑器式），对齐 Semi。 */
    showLineNumber?: boolean;
    /** 起始行号（对齐 Semi，默认 1）。 */
    lineNumberStart?: number;
    lineNumberClassName?: string;
    lineNumberStyle?: Record<string, any>;
    composition?: boolean;
    style?: Record<string, any>;
    textareaStyle?: Record<string, any>;
    class?: string;
    'aria-describedby'?: string;
    'aria-errormessage'?: string;
    'aria-invalid'?: string;
    'aria-label'?: string;
    'aria-labelledby'?: string;
    'aria-required'?: boolean;
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
    onResize?: (size: { height: number }) => void;
}

export function TextArea(&{
    id,
    value,
    defaultValue = '',
    disabled = false,
    readonly = false,
    placeholder,
    rows = 4,
    cols,
    autosize = false,
    resize,
    maxCount,
    maxLength,
    getValueLength,
    getTextAreaApi,
    showClear = false,
    borderless = false,
    validateStatus = 'default',
    autoFocus = false,
    showCounter = false,
    showLineNumber = false,
    lineNumberStart = 1,
    lineNumberClassName,
    lineNumberStyle,
    composition = false,
    style,
    textareaStyle,
    class: className,
    'aria-describedby': ariaDescribedBy,
    'aria-errormessage': ariaErrorMessage,
    'aria-invalid': ariaInvalidProp,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledBy,
    'aria-required': ariaRequired,
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
    onResize,
}: TextAreaProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    // track() 而非普通 const——见 input/index.tsrx 同名注释，受控身份要能随
    // value 的 undefined↔有值 变化重新判定，否则外部表单 reset 无法清空展示值。
    let &[isControlled] = track<boolean>(() => value !== undefined);
    let &[state] = track<TextAreaState>({
        value: isControlled ? (value ?? '') : defaultValue,
        isFocus: false,
        isHovering: false,
    });
    let &[textareaNode] = track<HTMLTextAreaElement | null>(null);
    let &[autoHeight] = track<number | null>(null);

    getTextAreaApi?.({
        focus: (options) => untrack(() => textareaNode)?.focus(options),
        blur: () => untrack(() => textareaNode)?.blur(),
    });

    // readonly={readonly} 这个 JSX 属性名真机验证发现完全不生效（与 Input
    // 组件同一根因——tsrx 编译器对 readonly 这个具体属性名有异常处理路径，
    // 详见 Input 组件同名注释），改用 ref+effect 直接赋值 property 绕过。
    effect(() => {
        const node = untrack(() => textareaNode);
        if (node) node.readOnly = readonly;
    });

    const foundation = new TextAreaFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TextAreaState>) => { state = { ...state, ...patch }; },
    });

    // 一旦组件经历过"非受控写入 state → 被外部 value 变为受控 → 又变回
    // undefined"，如果不同步，切回非受控展示时 state.value 会残留陈旧值。
    // 详见 input-number/index.tsrx 同名注释与
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
    let &[allowClear] = track<boolean>(() => TextAreaFoundation.isAllowClear(displayValue, showClear, disabled, readonly, state.isFocus, state.isHovering));
    const autosizeOption: AutosizeOption | null = autosize === true ? {} : autosize === false ? null : autosize;

    effect(() => {
        if (!autosizeOption) return;
        const node = untrack(() => textareaNode);
        if (!node) return;
        const height = calculateAutosizeHeight(node, displayValue, autosizeOption);
        if (untrack(() => autoHeight) !== height) {
            autoHeight = height;
            onResize?.({ height });
        }
    });

    // 行号栏：每个逻辑行（按 \n 拆分）在自动换行下可能占据多个视觉行，
    // 需要按实际测量宽度算出每行的换行数，让行号栏的每一项 minHeight
    // 跟 textarea 里对应文本块的视觉高度对齐（对齐 Semi renderLineNumbers +
    // calculateWrappedLines）。lineNumberVersion 只是一个纯粹的“重算触发器”
    // ——textarea 宽度变化（ResizeObserver）时递增，配合 displayValue 一起
    // 作为下面 track 的依赖，触发 lineNumberHeights 重新计算。
    let &[lineNumberVersion] = track<number>(0);
    let &[lineNumberNode] = track<HTMLElement | null>(null);
    // 行号栏高度钳制在 textarea 实测 clientHeight 内，避免行号栏自身内容
    // 撑高外层容器（对齐 Semi textareaHeight state，来自 ResizeObserver 实测）。
    let &[textareaClientHeight] = track<number>(0);

    effect(() => {
        if (!showLineNumber) return;
        const node = untrack(() => textareaNode);
        if (!node || typeof ResizeObserver === 'undefined') return;
        textareaClientHeight = node.clientHeight;
        const observer = new ResizeObserver(() => {
            lineNumberVersion++;
            textareaClientHeight = node.clientHeight;
        });
        observer.observe(node);
        return () => observer.disconnect();
    });

    let &[lineNumberHeights] = track<number[]>(() => {
        void lineNumberVersion;
        if (!showLineNumber) return [];
        const node = untrack(() => textareaNode);
        const lines = TextAreaFoundation.splitLinesForNumbering(displayValue);
        if (!node) return lines.map(() => 21);
        const style = window.getComputedStyle(node);
        const lineHeightPx = getLineHeightPx(node);
        const paddingLeft = parseFloat(style.paddingLeft) || 0;
        const paddingRight = parseFloat(style.paddingRight) || 0;
        const textareaWidth = node.clientWidth - paddingLeft - paddingRight;
        return lines.map((line) => {
            if (!line) return lineHeightPx;
            const width = measureTextWidth(line, style.fontSize, style.fontFamily);
            const wrapped = TextAreaFoundation.calculateWrappedLineCount(width, textareaWidth);
            return wrapped * lineHeightPx;
        });
    });

    function handleTextAreaScroll(event: Event) {
        if (!showLineNumber) return;
        const panel = untrack(() => lineNumberNode);
        if (!panel) return;
        const scrollTop = (event.target as HTMLTextAreaElement).scrollTop;
        requestAnimationFrame(() => { panel.scrollTop = scrollTop; });
    }

    const resolveValueLength = (text: string) => (getValueLength ? getValueLength(text) : text.length);

    const handleInputEvent = (event: Event) => {
        const target = event.target as HTMLTextAreaElement;
        let nextValue = target.value;
        if (maxLength !== undefined && resolveValueLength(nextValue) > maxLength) {
            nextValue = nextValue.slice(0, maxLength);
            target.value = nextValue;
        }
        foundation.handleInput(nextValue, event, isControlled, composition, onChange);
    };

    const handleKeyDownEvent = (event: KeyboardEvent) => {
        onKeyDown?.(event);
        if (event.key === 'Enter' && !event.shiftKey) onEnterPress?.(event);
    };

    let &[classes] = track<string>(() =>
        [
            'lotus-textarea-wrapper',
            borderless ? 'lotus-textarea-borderless' : '',
            disabled ? 'lotus-textarea-disabled' : '',
            state.isFocus ? 'lotus-textarea-focus' : '',
            validateStatus !== 'default' ? `lotus-textarea-status-${validateStatus}` : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[mergedTextareaStyle] = track<Record<string, any>>(() => ({
        ...(autosizeOption && autoHeight ? { height: `${autoHeight}px`, overflow: 'hidden' } : {}),
        ...(resize ? { resize } : {}),
        ...textareaStyle,
    }));

    <>
        <div
            class={classes}
            style={style}
            onMouseEnter={() => foundation.handleMouseEnter()}
            onMouseLeave={() => foundation.handleMouseLeave()}
        >
            <div class={showLineNumber ? 'lotus-textarea-content-row' : ''}>
            @if (showLineNumber) {
                <div
                    class={['lotus-textarea-line-number', lineNumberClassName ?? ''].filter(Boolean).join(' ')}
                    style={{ ...(textareaClientHeight ? { height: `${textareaClientHeight}px`, maxHeight: `${textareaClientHeight}px` } : {}), ...lineNumberStyle }}
                    ref={(node: HTMLElement) => { lineNumberNode = node; }}
                >
                    @for (const h of lineNumberHeights; index li) {
                        <div class="lotus-textarea-line-number-item" style={{ minHeight: `${h}px`, lineHeight: `${h}px` }}>
                            {lineNumberStart + li}
                        </div>
                    }
                </div>
            }
            <textarea
                id={id}
                class="lotus-textarea-native"
                value={displayValue}
                placeholder={placeholder}
                disabled={disabled}
                readonly={readonly}
                autofocus={autoFocus}
                rows={rows}
                cols={cols}
                style={mergedTextareaStyle}
                aria-describedby={ariaDescribedBy}
                aria-errormessage={ariaErrorMessage}
                aria-invalid={ariaInvalidProp}
                aria-label={ariaLabel}
                aria-labelledby={ariaLabelledBy}
                aria-required={ariaRequired}
                ref={(node: HTMLTextAreaElement) => { textareaNode = node; }}
                onInput={handleInputEvent}
                onFocus={(event: FocusEvent) => foundation.handleFocus(event, onFocus)}
                onBlur={(event: FocusEvent) => foundation.handleBlur(event, onBlur)}
                onKeyDown={handleKeyDownEvent}
                onKeyUp={(event: KeyboardEvent) => onKeyUp?.(event)}
                onKeyPress={(event: KeyboardEvent) => onKeyPress?.(event)}
                onScroll={handleTextAreaScroll}
                onCompositionStart={(event: CompositionEvent) => foundation.handleCompositionStart(event, onCompositionStart)}
                onCompositionUpdate={(event: CompositionEvent) => foundation.handleCompositionUpdate(event, onCompositionUpdate)}
                onCompositionEnd={(event: CompositionEvent) => {
                    const target = event.target as HTMLTextAreaElement;
                    foundation.handleCompositionEnd(target.value, event, isControlled, composition, onChange, onCompositionEnd);
                }}
            />
            </div>
            <div class="lotus-textarea-footer">
                @if (allowClear) {
                    <button
                        type="button"
                        class="lotus-textarea-clear"
                        aria-label={locale.TextArea.clear}
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={(event: MouseEvent) => foundation.handleClear(event, isControlled, onChange, onClear)}
                    >
                        <IconClear />
                    </button>
                }
                @if (showCounter || maxCount !== undefined) {
                    <span class="lotus-textarea-count">{resolveValueLength(displayValue)}{maxCount !== undefined ? `/${maxCount}` : ''}</span>
                }
            </div>
        </div>

        <style>
            .lotus-textarea-wrapper {
                display: inline-flex;
                flex-direction: column;
                width: 100%;
                box-sizing: border-box;
                background: var(--lotus-color-bg-1);
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                padding: var(--lotus-spacing-tight);
                transition: border-color 0.2s ease;
            }

            .lotus-textarea-wrapper.lotus-textarea-focus {
                border-color: var(--lotus-color-primary);
            }

            .lotus-textarea-wrapper.lotus-textarea-borderless {
                border-color: transparent;
                background: transparent;
            }

            .lotus-textarea-wrapper.lotus-textarea-disabled {
                background: var(--lotus-color-disabled-bg);
                cursor: not-allowed;
            }

            .lotus-textarea-wrapper.lotus-textarea-status-warning {
                border-color: var(--lotus-color-warning);
            }

            .lotus-textarea-wrapper.lotus-textarea-status-error {
                border-color: var(--lotus-color-danger);
            }

            .lotus-textarea-content-row {
                display: flex;
                align-items: flex-start;
                width: 100%;
                min-width: 0;
            }

            .lotus-textarea-line-number {
                flex-shrink: 0;
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base);
                background: var(--lotus-color-fill-1);
                border-right: 1px solid var(--lotus-color-border);
                color: var(--lotus-color-text-2);
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;
                font-size: inherit;
                line-height: 1.5;
                text-align: right;
                user-select: none;
                min-width: 36px;
                overflow-y: auto;
                overflow-x: hidden;
                scrollbar-width: none;
            }

            .lotus-textarea-line-number::-webkit-scrollbar {
                display: none;
            }

            .lotus-textarea-line-number-item {
                display: flex;
                align-items: flex-start;
                justify-content: flex-end;
                box-sizing: border-box;
            }

            .lotus-textarea-content-row .lotus-textarea-native {
                flex: 1;
                min-width: 0;
            }

            .lotus-textarea-native {
                width: 100%;
                border: none;
                outline: none;
                background: transparent;
                color: var(--lotus-color-text-0);
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                line-height: var(--lotus-font-body-line-height);
                box-sizing: border-box;
                resize: vertical;
            }

            .lotus-textarea-native:disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-textarea-native::placeholder {
                color: var(--lotus-color-text-3);
            }

            .lotus-textarea-footer {
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 8px;
                margin-top: 4px;
            }

            .lotus-textarea-clear {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: none;
                background: transparent;
                padding: 0;
                color: var(--lotus-color-text-2);
                cursor: pointer;
            }

            .lotus-textarea-clear:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-textarea-count {
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-2);
            }
        </style>
    </>
}
