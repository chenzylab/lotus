import { track, effect, untrack } from 'ripple';
import {
    clampPercent,
    calcCircleGeometry,
    resolveGradientStroke,
    type ProgressType,
    type ProgressDirection,
    type ProgressSize,
    type ProgressStrokeLinecap,
    type ProgressStrokeStop,
} from '@lotus/foundation/feedback/progress';
import { animateValue } from '@lotus/foundation/base/animate-value';

export type { ProgressType, ProgressDirection, ProgressSize, ProgressStrokeLinecap, ProgressStrokeStop };

export interface ProgressProps {
    percent?: number;
    type?: ProgressType;
    direction?: ProgressDirection;
    size?: ProgressSize;
    width?: number;
    strokeWidth?: number;
    strokeLinecap?: ProgressStrokeLinecap;
    stroke?: string | ProgressStrokeStop[];
    strokeGradient?: boolean;
    orbitStroke?: string;
    showInfo?: boolean;
    format?: (percent: number) => any;
    motion?: boolean;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const DEFAULT_FORMAT = (percent: number) => `${percent}%`;

/**
 * Progress：line/circle 两种类型。数值动画在自研的 `animateValue` 工具上实现
 * （不依赖第三方动画库），多段渐变描边色的插值算法在 Foundation 层自研（对齐
 * Semi `generates.ts` 的算法结构，但移除了其专属调色板 token 语法糖，只保留
 * 标准 hex/rgb/hsl 格式支持）。
 */
export function Progress(&{
    percent = 0,
    type = 'line',
    direction = 'horizontal',
    size = 'default',
    width,
    strokeWidth = 4,
    strokeLinecap = 'round',
    stroke,
    strokeGradient = false,
    orbitStroke,
    showInfo = false,
    format = DEFAULT_FORMAT,
    motion = true,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ProgressProps) @{
    let &[displayPercent] = track<number>(clampPercent(percent));
    let previousPercent = clampPercent(percent);

    effect(() => {
        const target = clampPercent(percent);
        const from = untrack(() => previousPercent);
        if (from === target) return;
        previousPercent = target;

        if (!motion) {
            displayPercent = target;
            return;
        }
        const handle = animateValue({
            from,
            to: target,
            duration: 300,
            easing: 'linear',
            onFrame: (value) => { displayPercent = Math.round(value); },
            onRest: () => { displayPercent = target; },
        });
        return () => handle.destroy();
    });

    let &[resolvedStroke] = track<string | undefined>(() => {
        if (stroke === undefined) return undefined;
        if (typeof stroke === 'string') return stroke;
        return resolveGradientStroke(stroke, displayPercent, strokeGradient);
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-progress',
            `lotus-progress-${type}`,
            `lotus-progress-size-${size}`,
            type === 'line' ? `lotus-progress-direction-${direction}` : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const resolvedWidth = width ?? (size === 'small' ? 24 : 72);
    let &[geometry] = track(() => calcCircleGeometry(resolvedWidth, strokeWidth, displayPercent));
    let &[text] = track(() => format(displayPercent));
    // aria-valuetext 只接受纯文本，format 可以返回任意 JSX（Progress 展示层不限制
    // 自定义内容的复杂度）——只在 format 的返回值恰好是字符串/数字这类可以安全转
    // 成文本的场景才设置，复杂 JSX 场景保持不设置，退化为屏幕阅读器读原始百分比
    // 数值而非报错或读出 "[object Object]" 这类无意义内容。不设置时不能传空字符串
    // 占位——空字符串会被部分屏幕阅读器当成"显式覆盖为空白"而不是"未设置"，效果
    // 反而比不设置更差，所以用 undefined 让浏览器彻底忽略这个属性。
    let &[ariaValueText] = track<string | undefined>(() =>
        typeof text === 'string' || typeof text === 'number' ? String(text) : undefined,
    );

    <>
        @if (type === 'line') {
            <div
                class={classes}
                style={style}
                role="progressbar"
                aria-valuemin={0}
                aria-valuemax={100}
                aria-valuenow={displayPercent}
                aria-valuetext={ariaValueText}
                aria-label={ariaLabel}
            >
                <div class="lotus-progress-track" style={orbitStroke ? { backgroundColor: orbitStroke } : {}} aria-hidden={true}>
                    <div
                        class="lotus-progress-track-inner"
                        style={{
                            background: resolvedStroke ?? '',
                            [direction === 'horizontal' ? 'width' : 'height']: `${displayPercent}%`,
                        }}
                        aria-hidden={true}
                    />
                </div>
                @if (showInfo) {
                    <div class="lotus-progress-line-text">{text}</div>
                }
            </div>
        } @if (type === 'circle') {
            <div
                class={classes}
                style={style}
                role="progressbar"
                aria-valuemin={0}
                aria-valuemax={100}
                aria-valuenow={displayPercent}
                aria-valuetext={ariaValueText}
                aria-label={ariaLabel}
            >
                <svg class="lotus-progress-circle-ring" height={resolvedWidth} width={resolvedWidth} aria-hidden={true}>
                    <circle
                        class="lotus-progress-circle-ring-track"
                        stroke-dashoffset={0}
                        stroke-width={strokeWidth}
                        stroke-dasharray={geometry.strokeDasharray}
                        stroke-linecap={strokeLinecap}
                        fill="transparent"
                        style={orbitStroke ? { stroke: orbitStroke } : {}}
                        r={geometry.radius}
                        cx={resolvedWidth / 2}
                        cy={resolvedWidth / 2}
                    />
                    <circle
                        class="lotus-progress-circle-ring-inner"
                        stroke-dashoffset={geometry.strokeDashoffset}
                        stroke-width={strokeWidth}
                        stroke-dasharray={geometry.strokeDasharray}
                        stroke-linecap={strokeLinecap}
                        fill="transparent"
                        style={resolvedStroke ? { stroke: resolvedStroke } : {}}
                        r={geometry.radius}
                        cx={resolvedWidth / 2}
                        cy={resolvedWidth / 2}
                    />
                </svg>
                @if (showInfo && size !== 'small') {
                    <span class="lotus-progress-circle-text">{text}</span>
                }
            </div>
        }

        <style>
            .lotus-progress-line {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-tight);
            }

            .lotus-progress-direction-vertical {
                flex-direction: column;
                height: 100%;
            }

            .lotus-progress-track {
                flex: 1;
                position: relative;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-full);
                background: var(--lotus-color-fill-0);
            }

            .lotus-progress-direction-horizontal .lotus-progress-track {
                height: var(--lotus-progress-track-thickness, 8px);
            }

            .lotus-progress-direction-vertical .lotus-progress-track {
                width: var(--lotus-progress-track-thickness, 8px);
                height: 100%;
            }

            .lotus-progress-size-small .lotus-progress-track {
                --lotus-progress-track-thickness: 6px;
            }

            .lotus-progress-size-large .lotus-progress-track {
                --lotus-progress-track-thickness: 10px;
            }

            .lotus-progress-track-inner {
                position: absolute;
                inset-inline-start: 0;
                bottom: 0;
                background: var(--lotus-color-success);
                border-radius: var(--lotus-border-radius-full);
                transition: background-color 0.2s ease;
            }

            .lotus-progress-direction-horizontal .lotus-progress-track-inner {
                top: 0;
                height: 100%;
            }

            .lotus-progress-direction-vertical .lotus-progress-track-inner {
                right: 0;
                width: 100%;
            }

            .lotus-progress-line-text {
                flex-shrink: 0;
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-1);
                min-width: 2.5em;
                text-align: end;
            }

            .lotus-progress-circle {
                position: relative;
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .lotus-progress-circle-ring-track {
                stroke: var(--lotus-color-fill-1);
            }

            .lotus-progress-circle-ring-inner {
                stroke: var(--lotus-color-success);
                transform: rotate(-90deg);
                transform-origin: center;
                transition: stroke 0.2s ease;
            }

            .lotus-progress-circle-text {
                position: absolute;
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}
