import { track, effect, untrack } from 'ripple';
import { SpinFoundation, type SpinState } from '@lotus/foundation/feedback/spin';

export type SpinSize = 'small' | 'middle' | 'large';

export interface SpinProps {
    children?: any;
    size?: SpinSize;
    spinning?: boolean;
    indicator?: any;
    delay?: number;
    tip?: any;
    wrapperClassName?: string;
    style?: Record<string, any>;
    childStyle?: Record<string, any>;
    'aria-label'?: string;
}

let spinIdCounter = 0;

/** 默认转圈指示器：渐变弧线 + 旋转动画，对齐 Semi 的视觉设计但改写成 lotus 前缀与 token。 */
function SpinIcon(&{ gradientId }: { gradientId: string }) {
    return <svg class="lotus-spin-icon" width="48" height="48" viewBox="0 0 36 36" aria-hidden={true}>
        <defs>
            <linearGradient x1="0%" y1="100%" x2="100%" y2="100%" id={gradientId}>
                <stop stop-color="currentColor" stop-opacity="0" offset="0%" />
                <stop stop-color="currentColor" stop-opacity="0.5" offset="39.9430698%" />
                <stop stop-color="currentColor" offset="100%" />
            </linearGradient>
        </defs>
        <path
            d="M34,18 C34,9.163444 26.836556,2 18,2 C11.6597233,2 6.18078805,5.68784135 3.59122325,11.0354951"
            stroke={`url(#${gradientId})`}
            stroke-width="4"
            stroke-linecap="round"
            fill="none"
        />
    </svg>;
}

/**
 * Spin：加载中蒙层，包裹 children 渲染。`delay` 延迟显示状态机在 Foundation
 * 自研（SpinFoundation.syncFromProps），避免快速完成的请求也闪烁一下 loading。
 */
export function Spin(&{
    children,
    size = 'middle',
    spinning = true,
    indicator,
    delay = 0,
    tip,
    wrapperClassName,
    style,
    childStyle,
    'aria-label': ariaLabel,
}: SpinProps) @{
    let &[state] = track<SpinState>({ loading: !delay ? spinning : false });
    const gradientId = `lotus-spin-gradient-${++spinIdCounter}`;

    const foundation = new SpinFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<SpinState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        foundation.syncFromProps(spinning, delay);
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-spin',
            `lotus-spin-size-${size}`,
            children != null ? 'lotus-spin-block' : '',
            state.loading ? '' : 'lotus-spin-hidden',
            wrapperClassName ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel} aria-busy={state.loading}>
            @if (state.loading) {
                <div class="lotus-spin-wrapper">
                    @if (indicator) {
                        <div class="lotus-spin-animate">{indicator}</div>
                    } @if (!indicator) {
                        <SpinIcon gradientId={gradientId} />
                    }
                    @if (tip) {
                        <div class="lotus-spin-tip">{tip}</div>
                    }
                </div>
            }
            @if (children != null) {
                <div class="lotus-spin-children" style={childStyle}>{children}</div>
            }
        </div>

        <style>
            .lotus-spin {
                position: relative;
                display: inline-block;
            }

            .lotus-spin-block {
                display: block;
                width: 100%;
            }

            .lotus-spin-wrapper {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: var(--lotus-spacing-tight);
                color: var(--lotus-color-primary);
            }

            .lotus-spin:not(.lotus-spin-block) .lotus-spin-wrapper {
                position: static;
            }

            .lotus-spin-block .lotus-spin-wrapper {
                position: absolute;
                inset: 0;
                z-index: 1;
                background: var(--lotus-color-bg-1);
            }

            .lotus-spin-hidden .lotus-spin-wrapper {
                display: none;
            }

            .lotus-spin-icon {
                animation: lotus-spin-rotate 1s linear infinite;
            }

            .lotus-spin-size-small .lotus-spin-icon {
                width: 20px;
                height: 20px;
            }

            .lotus-spin-size-middle .lotus-spin-icon {
                width: 32px;
                height: 32px;
            }

            .lotus-spin-size-large .lotus-spin-icon {
                width: 48px;
                height: 48px;
            }

            @keyframes lotus-spin-rotate {
                to {
                    transform: rotate(360deg);
                }
            }

            .lotus-spin-tip {
                font-size: var(--lotus-font-label-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-spin-children {
                transition: opacity 0.2s ease;
            }

            .lotus-spin-block:not(.lotus-spin-hidden) .lotus-spin-children {
                opacity: 0.4;
                pointer-events: none;
            }
        </style>
    </>
}
