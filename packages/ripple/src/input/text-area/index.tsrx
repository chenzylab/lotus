import { track, effect, untrack } from 'ripple';
import { TextAreaFoundation, type TextAreaState } from '@lotus/foundation/input/text-area';
import { calculateAutosizeHeight, type AutosizeOption } from './measure';
import { IconClear } from '@lotus/icons';

export interface TextAreaProps {
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
    showClear?: boolean;
    borderless?: boolean;
    composition?: boolean;
    style?: Record<string, any>;
    textareaStyle?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
    onChange?: (value: string, event: Event) => void;
    onClear?: (event: MouseEvent) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    onKeyDown?: (event: KeyboardEvent) => void;
    onEnterPress?: (event: KeyboardEvent) => void;
    onCompositionStart?: (event: CompositionEvent) => void;
    onCompositionEnd?: (event: CompositionEvent) => void;
    onCompositionUpdate?: (event: CompositionEvent) => void;
    onResize?: (size: { height: number }) => void;
}

export function TextArea(&{
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
    showClear = false,
    borderless = false,
    composition = false,
    style,
    textareaStyle,
    class: className,
    'aria-label': ariaLabel,
    onChange,
    onClear,
    onFocus,
    onBlur,
    onKeyDown,
    onEnterPress,
    onCompositionStart,
    onCompositionEnd,
    onCompositionUpdate,
    onResize,
}: TextAreaProps) @{
    const isControlled = value !== undefined;
    let &[state] = track<TextAreaState>({
        value: isControlled ? (value ?? '') : defaultValue,
        isFocus: false,
        isHovering: false,
    });
    let &[textareaNode] = track<HTMLTextAreaElement | null>(null);
    let &[autoHeight] = track<number | null>(null);

    const foundation = new TextAreaFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TextAreaState>) => { state = { ...state, ...patch }; },
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

    const handleInputEvent = (event: Event) => {
        const target = event.target as HTMLTextAreaElement;
        let nextValue = target.value;
        if (maxLength !== undefined && nextValue.length > maxLength) {
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
            <textarea
                class="lotus-textarea-native"
                value={displayValue}
                placeholder={placeholder}
                disabled={disabled}
                readonly={readonly}
                rows={rows}
                cols={cols}
                style={mergedTextareaStyle}
                aria-label={ariaLabel}
                ref={(node: HTMLTextAreaElement) => { textareaNode = node; }}
                onInput={handleInputEvent}
                onFocus={(event: FocusEvent) => foundation.handleFocus(event, onFocus)}
                onBlur={(event: FocusEvent) => foundation.handleBlur(event, onBlur)}
                onKeyDown={handleKeyDownEvent}
                onCompositionStart={(event: CompositionEvent) => foundation.handleCompositionStart(event, onCompositionStart)}
                onCompositionUpdate={(event: CompositionEvent) => foundation.handleCompositionUpdate(event, onCompositionUpdate)}
                onCompositionEnd={(event: CompositionEvent) => {
                    const target = event.target as HTMLTextAreaElement;
                    foundation.handleCompositionEnd(target.value, event, isControlled, composition, onChange, onCompositionEnd);
                }}
            />
            <div class="lotus-textarea-footer">
                @if (allowClear) {
                    <button
                        type="button"
                        class="lotus-textarea-clear"
                        aria-label="清除"
                        onMouseDown={(event: MouseEvent) => event.preventDefault()}
                        onClick={(event: MouseEvent) => foundation.handleClear(event, isControlled, onChange, onClear)}
                    >
                        <IconClear />
                    </button>
                }
                @if (maxCount !== undefined) {
                    <span class="lotus-textarea-count">{displayValue.length}/{maxCount}</span>
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
