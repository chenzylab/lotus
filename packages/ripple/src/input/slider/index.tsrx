import { track, untrack, effect } from 'ripple';
import {
    SliderFoundation,
    type SliderState,
    type SliderFoundationOptions,
    type SliderValue,
    type SliderHandle,
    type RailRect,
} from '@lotus/foundation/input/slider';
import { Tooltip } from '../../show/tooltip/index.tsrx';

export interface SliderProps {
    min?: number;
    max?: number;
    step?: number;
    value?: SliderValue;
    defaultValue?: SliderValue;
    range?: boolean;
    marks?: Record<number, string>;
    included?: boolean;
    vertical?: boolean;
    verticalReverse?: boolean;
    disabled?: boolean;
    tipFormatter?: ((value: number) => any) | null;
    onChange?: (value: SliderValue) => void;
    onAfterChange?: (value: SliderValue) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function isPair(value: SliderValue): value is [number, number] {
    return Array.isArray(value);
}

function defaultValueFor(range: boolean, min: number): SliderValue {
    return range ? [min, min] : min;
}

/**
 * Slider：滑动输入条，单值/range 双滑块共用同一组件（对齐 Semi 用 `range` prop
 * 切换而非拆两个组件）。拖拽状态机移植自 Semi semi-foundation/slider/foundation.ts
 * 的算法思路：Foundation 只做像素↔数值换算和纯状态计算，轨道尺寸
 * （getBoundingClientRect）和 document 级 mousemove/mouseup 监听留给本组件，
 * 复用 Resizable 已验证的"effect() 里无条件注册 document 监听、handler 内部
 * 按 state.dragging 判断是否是当前活跃拖拽"模式，不在 mousedown/mouseup 时
 * 反复增删监听器。
 */
export function Slider(&{
    min = 0,
    max = 100,
    step = 1,
    value,
    defaultValue,
    range = false,
    marks,
    included = true,
    vertical = false,
    verticalReverse = false,
    disabled = false,
    tipFormatter,
    onChange,
    onAfterChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: SliderProps) @{
    const isControlled = value !== undefined;

    let &[state] = track<SliderState>({
        value: isControlled ? value! : (defaultValue ?? defaultValueFor(range, min)),
        dragging: false,
        focusPos: false,
    });

    const foundationOpts: SliderFoundationOptions = { min, max, step, range, vertical, verticalReverse };

    const foundation = new SliderFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<SliderState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        foundationOpts,
    );

    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value === undefined) return;
        untrack(() => { hasBeenControlled = true; });
        untrack(() => { state = { ...state, value: value! }; });
    });

    let railNode: HTMLElement | null = null;
    let &[railRect] = track<RailRect>({ left: 0, top: 0, width: 0, height: 0 });

    function measureRail(): RailRect {
        if (!railNode) return untrack(() => railRect);
        const r = railNode.getBoundingClientRect();
        const measured: RailRect = { left: r.left, top: r.top, width: r.width, height: r.height };
        untrack(() => { railRect = measured; });
        return measured;
    }

    function emitChange(next: SliderValue) {
        onChange?.(next);
    }

    function emitAfterChange() {
        onAfterChange?.(untrack(() => state).value);
    }

    function handlePointerDownOnHandle(handler: SliderHandle) {
        if (disabled) return;
        measureRail();
        foundation.onHandleDown(handler);
    }

    function handleRailPointerDown(event: MouseEvent) {
        if (disabled) return;
        if (event.target instanceof HTMLElement && event.target.closest('.lotus-slider-handle')) return;
        const rect = measureRail();
        const result = foundation.onRailClick(event.clientX, event.clientY, rect);
        if (result?.changed) emitChange(result.value);
        foundation.onHandleDown(result?.handler ?? 'min');
    }

    effect(() => {
        const handleMove = (event: MouseEvent) => {
            const current = untrack(() => state);
            if (!current.dragging) return;
            const rect = untrack(() => railRect);
            const result = foundation.onHandleMove(event.clientX, event.clientY, rect);
            if (result?.changed) emitChange(result.value);
        };
        const handleUp = () => {
            const current = untrack(() => state);
            if (!current.dragging) return;
            foundation.onHandleUp();
            emitAfterChange();
        };
        document.addEventListener('mousemove', handleMove);
        document.addEventListener('mouseup', handleUp);
    });

    function handleKeyDown(event: KeyboardEvent, handler: SliderHandle) {
        if (disabled) return;
        const navigationKeys = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End'];
        if (!navigationKeys.includes(event.key)) return;
        event.preventDefault();
        const result = foundation.handleKeyDown(event.key, handler);
        if (result?.changed) {
            emitChange(result.value);
            emitAfterChange();
        }
    }

    function handleBlur() {
        foundation.onBlur();
    }

    let &[minValue] = track<number>(() => (isPair(state.value) ? state.value[0] : (state.value as number)));
    let &[maxValue] = track<number>(() => (isPair(state.value) ? state.value[1] : (state.value as number)));

    let &[trackStyle] = track<Record<string, any>>(() => {
        const startPercent = range ? foundation.valueToPercent(minValue) : 0;
        const endPercent = foundation.valueToPercent(maxValue);
        if (!included) return { display: 'none' };
        if (vertical) {
            return verticalReverse
                ? { top: `${startPercent}%`, height: `${endPercent - startPercent}%` }
                : { bottom: `${startPercent}%`, height: `${endPercent - startPercent}%` };
        }
        return { left: `${startPercent}%`, width: `${endPercent - startPercent}%` };
    });

    function handlePositionStyle(percent: number): Record<string, any> {
        if (vertical) {
            return verticalReverse ? { top: `${percent}%` } : { bottom: `${percent}%` };
        }
        return { left: `${percent}%` };
    }

    function formatTip(v: number): any {
        if (tipFormatter === null) return undefined;
        return tipFormatter ? tipFormatter(v) : v;
    }

    let &[markList] = track<Array<{ value: number; percent: number; label: string; active: boolean }>>(() => {
        if (!marks) return [];
        return Object.keys(marks).map((key) => {
            const v = Number(key);
            return { value: v, percent: foundation.valueToPercent(v), label: marks[v]!, active: foundation.isMarkActive(v) };
        });
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-slider',
            vertical ? 'lotus-slider-vertical' : 'lotus-slider-horizontal',
            disabled ? 'lotus-slider-disabled' : '',
            range ? 'lotus-slider-range' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style}>
            <div
                class="lotus-slider-rail-wrapper"
                ref={(node: HTMLElement) => { railNode = node; }}
                onMouseDown={handleRailPointerDown}
            >
                <div class="lotus-slider-rail">
                    <div class="lotus-slider-track" style={trackStyle} />
                    @if (marks) {
                        <div class="lotus-slider-dots">
                            @for (const mark of markList; index mi; key mark.value) {
                                <div
                                    class={['lotus-slider-dot', mark.active ? 'lotus-slider-dot-active' : ''].filter(Boolean).join(' ')}
                                    style={handlePositionStyle(mark.percent)}
                                />
                            }
                        </div>
                    }
                </div>
                @if (marks) {
                    <div class="lotus-slider-marks">
                        @for (const mark of markList; index mi2; key mark.value) {
                            <div class="lotus-slider-mark" style={handlePositionStyle(mark.percent)}>{mark.label}</div>
                        }
                    </div>
                }

                <Tooltip
                    trigger="custom"
                    visible={state.dragging === 'min' || state.focusPos === 'min'}
                    content={formatTip(minValue)}
                    position={vertical ? 'right' : 'top'}
                >
                    <div
                        class="lotus-slider-handle"
                        style={handlePositionStyle(foundation.valueToPercent(minValue))}
                        role="slider"
                        tabIndex={disabled ? -1 : 0}
                        aria-label={ariaLabel}
                        aria-valuemin={min}
                        aria-valuemax={range ? maxValue : max}
                        aria-valuenow={minValue}
                        aria-disabled={disabled}
                        onMouseDown={() => handlePointerDownOnHandle('min')}
                        onKeyDown={(e: KeyboardEvent) => handleKeyDown(e, 'min')}
                        onBlur={handleBlur}
                    />
                </Tooltip>

                @if (range) {
                    <Tooltip
                        trigger="custom"
                        visible={state.dragging === 'max' || state.focusPos === 'max'}
                        content={formatTip(maxValue)}
                        position={vertical ? 'right' : 'top'}
                    >
                        <div
                            class="lotus-slider-handle"
                            style={handlePositionStyle(foundation.valueToPercent(maxValue))}
                            role="slider"
                            tabIndex={disabled ? -1 : 0}
                            aria-valuemin={minValue}
                            aria-valuemax={max}
                            aria-valuenow={maxValue}
                            aria-disabled={disabled}
                            onMouseDown={() => handlePointerDownOnHandle('max')}
                            onKeyDown={(e: KeyboardEvent) => handleKeyDown(e, 'max')}
                            onBlur={handleBlur}
                        />
                    </Tooltip>
                }
            </div>
        </div>

        <style>
            .lotus-slider {
                display: inline-block;
                width: 100%;
                padding: 8px 0;
            }

            .lotus-slider-vertical {
                width: auto;
                height: 100%;
                padding: 0 8px;
            }

            .lotus-slider-rail-wrapper {
                position: relative;
            }

            .lotus-slider-rail {
                position: relative;
                height: 4px;
                border-radius: 2px;
                background: var(--lotus-color-fill-1);
                cursor: pointer;
            }

            .lotus-slider-vertical .lotus-slider-rail-wrapper {
                height: 100%;
            }

            .lotus-slider-vertical .lotus-slider-rail {
                width: 4px;
                height: 100%;
            }

            .lotus-slider-disabled .lotus-slider-rail {
                cursor: not-allowed;
                opacity: 0.5;
            }

            .lotus-slider-track {
                position: absolute;
                top: 0;
                bottom: 0;
                height: 4px;
                border-radius: 2px;
                background: var(--lotus-color-primary);
            }

            .lotus-slider-vertical .lotus-slider-track {
                top: auto;
                left: 0;
                right: 0;
                width: 4px;
                height: auto;
            }

            .lotus-slider-handle {
                position: absolute;
                top: 50%;
                width: 14px;
                height: 14px;
                margin-left: -7px;
                margin-top: -7px;
                border-radius: 50%;
                background: var(--lotus-color-bg-1);
                border: 2px solid var(--lotus-color-primary);
                cursor: pointer;
                box-sizing: border-box;
                touch-action: none;
            }

            .lotus-slider-vertical .lotus-slider-handle {
                top: auto;
                left: 50%;
                margin-left: -7px;
                margin-top: -7px;
            }

            .lotus-slider-handle:focus-visible {
                box-shadow: 0 0 0 3px var(--lotus-color-primary-light, rgba(0, 100, 250, 0.2));
                outline: none;
            }

            .lotus-slider-disabled .lotus-slider-handle {
                cursor: not-allowed;
                border-color: var(--lotus-color-text-3);
            }

            .lotus-slider-dots {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
            }

            .lotus-slider-dot {
                position: absolute;
                top: 50%;
                width: 6px;
                height: 6px;
                margin-left: -3px;
                margin-top: -3px;
                border-radius: 50%;
                background: var(--lotus-color-bg-1);
                border: 1px solid var(--lotus-color-border);
            }

            .lotus-slider-dot-active {
                border-color: var(--lotus-color-primary);
            }

            .lotus-slider-marks {
                position: relative;
                margin-top: 8px;
                height: 18px;
            }

            .lotus-slider-mark {
                position: absolute;
                transform: translateX(-50%);
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
                white-space: nowrap;
            }

            .lotus-slider-vertical .lotus-slider-marks {
                position: absolute;
                left: 16px;
                top: 0;
                bottom: 0;
                width: auto;
                margin-top: 0;
            }

            .lotus-slider-vertical .lotus-slider-mark {
                transform: translateY(50%);
            }
        </style>
    </>
}
