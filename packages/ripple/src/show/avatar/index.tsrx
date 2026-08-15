import { track, effect, untrack } from 'ripple';
import { AvatarFoundation, type AvatarState } from '@lotus/foundation/show/avatar';

export type AvatarShape = 'circle' | 'square';
export type AvatarSize = 'extra-extra-small' | 'extra-small' | 'small' | 'default' | 'medium' | 'large' | 'extra-large';
export type AvatarColor =
    | 'grey' | 'red' | 'pink' | 'purple' | 'violet' | 'indigo' | 'blue' | 'light-blue'
    | 'cyan' | 'teal' | 'green' | 'light-green' | 'lime' | 'yellow' | 'amber' | 'orange' | 'white';

const SIZE_KEYWORDS: AvatarSize[] = ['extra-extra-small', 'extra-small', 'small', 'default', 'medium', 'large', 'extra-large'];

export interface AvatarTopSlot {
    render?: () => any;
    gradientStart?: string;
    gradientEnd?: string;
    text?: any;
    textColor?: string;
    class?: string;
    style?: Record<string, any>;
}

export interface AvatarBottomSlot {
    render?: () => any;
    shape?: AvatarShape;
    text?: any;
    bgColor?: string;
    textColor?: string;
    class?: string;
    style?: Record<string, any>;
}

export interface AvatarBorder {
    color?: string;
    motion?: boolean;
}

export interface AvatarProps {
    children?: any;
    color?: AvatarColor;
    shape?: AvatarShape;
    /** 内置尺寸关键字，或任意合法的 CSS width 值（如 "10px"）。 */
    size?: AvatarSize | string;
    /**
     * `children` 是否为纯文字内容（触发自适应字符缩放，超出容器宽度时按比例缩小）。
     * 默认 `true`——大多数场景下 Avatar 内容就是文字缩写。传入图标/自定义 JSX 内容时
     * 显式传 `false`，跳过缩放测量逻辑。
     *
     * Semi 原版通过 `typeof children === 'string'` 自动判断，lotus 版本必须显式声明：
     * Ripple 编译器对所有带 JSX children 的组件调用都会把 children 包装成渲染函数
     * （而不是保留原始字符串/元素值），`typeof children === 'string'` 在 Ripple 下永远
     * 为 false，无法照搬 Semi 的自动判断方式，这是 Ripple 架构约束下的诚实设计取舍。
     */
    isText?: boolean;
    hoverMask?: any;
    gap?: number;
    src?: string;
    srcSet?: string;
    alt?: string;
    onError?: () => boolean | void;
    onClick?: (event: MouseEvent) => void;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    topSlot?: AvatarTopSlot;
    bottomSlot?: AvatarBottomSlot;
    /** 额外边框：传 true 显示静态边框，传对象可自定义颜色/开启呼吸动效。 */
    border?: boolean | AvatarBorder;
    /** 内容区域呼吸动效（配合直播/在线等场景使用）。 */
    contentMotion?: boolean;
    style?: Record<string, any>;
    class?: string;
}

function kebabToCamel(color: string): string {
    return color.replace(/-([a-z])/g, (_, c) => c.toUpperCase());
}

/** 顶部 Slot 徽章背景形状：纯几何 SVG 视觉资产，与具体品牌文字无关。 */
function TopSlotBadgeSvg({ gradientStart, gradientEnd, gradientId }: { gradientStart: string; gradientEnd: string; gradientId: string }) {
    return <svg xmlns="http://www.w3.org/2000/svg" width="51" height="52" viewBox="0 0 51 52" fill="none">
        <path
            d="M40.4918 46.5592C44.6795 43.176 46.261 34.1333 47.5301 25.6141C49.5854 11.8168 39.6662 1 25.8097 1C11.2857 1 3 11.4279 3 25.3518C3 33.7866 6.29361 43.8947 10.4602 46.5592C12.5868 47.9192 12.5868 47.9051 25.8097 47.9192C38.3651 47.9282 38.5352 48.14 40.4918 46.5592Z"
            fill={`url(#${gradientId})`}
        />
        <defs>
            <linearGradient id={gradientId} x1="17.671" y1="31.7392" x2="17.671" y2="47.9333" gradientUnits="userSpaceOnUse">
                <stop stop-color={gradientStart} />
                <stop offset="1" stop-color={gradientEnd} />
            </linearGradient>
        </defs>
    </svg>;
}

let topSlotGradientCounter = 0;

export function Avatar({
    children,
    color = 'grey',
    shape = 'circle',
    size = 'medium',
    isText = true,
    hoverMask,
    gap = 3,
    src,
    srcSet,
    alt,
    onError,
    onClick,
    onMouseEnter,
    onMouseLeave,
    topSlot,
    bottomSlot,
    border,
    contentMotion = false,
    style,
    class: className,
}: AvatarProps) @{
    let &[state] = track<AvatarState>({ imgLoaded: true });
    let &[scale] = track<number>(1);
    let &[hovering] = track<boolean>(false);
    let &[avatarNode] = track<HTMLElement | null>(null);

    const foundation = new AvatarFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<AvatarState>) => { state = { ...state, ...patch }; },
    });

    const isTextContent = isText && children != null;
    const isSizeKeyword = SIZE_KEYWORDS.includes(size as AvatarSize);
    const gradientId = `lotus-avatar-top-slot-${++topSlotGradientCounter}`;

    // 自适应字符缩放：挂载后测量真实 DOM 宽度（文字内容才需要，图片/图标内容不参与）。
    // 只在挂载时执行一次测量，不建立对 state 的响应式依赖（同 Grid Row 的 untrack 范式）。
    effect(() => {
        if (!isTextContent) return;
        const node = untrack(() => avatarNode);
        const textNode = node?.firstElementChild?.firstElementChild as HTMLElement | undefined;
        if (!node || !textNode) return;
        const nextScale = AvatarFoundation.computeTextScale(node.offsetWidth, textNode.offsetWidth, gap);
        scale = nextScale;
    });

    const isImg = !!src && state.imgLoaded;
    const shouldWrap = !!(bottomSlot || topSlot || border);

    let &[avatarClasses] = track<string>(() =>
        [
            'lotus-avatar',
            `lotus-avatar-${shape}`,
            isSizeKeyword ? `lotus-avatar-${size}` : '',
            !isImg ? `lotus-avatar-color-${kebabToCamel(color)}` : '',
            isImg ? 'lotus-avatar-img' : '',
            contentMotion ? 'lotus-avatar-animated' : '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const customSize: Record<string, string> = isSizeKeyword ? {} : { width: String(size), height: String(size) };
    const wrapperStyle = { ...customSize, ...style };

    const handleImgError = () => {
        foundation.handleImgError(onError);
    };

    const handleEnter = (event: MouseEvent) => {
        hovering = true;
        onMouseEnter?.(event);
    };
    const handleLeave = (event: MouseEvent) => {
        hovering = false;
        onMouseLeave?.(event);
    };

    <>
        @if (shouldWrap) {
            <div
                class={['lotus-avatar-wrapper', className ?? ''].filter(Boolean).join(' ')}
                style={wrapperStyle}
                onClick={onClick}
                onMouseEnter={handleEnter}
                onMouseLeave={handleLeave}
            >
                @if (border) {
                    <div style={{ position: 'relative' }}>
                        <span
                            class={avatarClasses}
                            ref={(node: HTMLElement) => { avatarNode = node; }}
                        >
                            @if (isImg) {
                                <img alt={alt} src={src} srcSet={srcSet} onError={handleImgError} />
                            } @else {
                                @if (isTextContent) {
                                    <span class="lotus-avatar-content" style={{ transform: `scale(${scale})` }}>
                                        <span role="img" aria-label={alt ?? ''}>{children}</span>
                                    </span>
                                } @else {
                                    <>{children}</>
                                }
                            }
                            @if (hovering && hoverMask) {
                                <span class="lotus-avatar-hover">{hoverMask}</span>
                            }
                        </span>
                        <span
                            class={[
                                'lotus-avatar-additional-border',
                                `lotus-avatar-additional-border-${isSizeKeyword ? size : 'default'}`,
                                `lotus-avatar-${shape}`,
                            ].join(' ')}
                            style={{ borderColor: (typeof border === 'object' ? border.color : '') ?? '' }}
                        />
                        @if (typeof border === 'object' && border.motion) {
                            <span
                                class={[
                                    'lotus-avatar-additional-border',
                                    `lotus-avatar-additional-border-${isSizeKeyword ? size : 'default'}`,
                                    `lotus-avatar-${shape}`,
                                    'lotus-avatar-additional-border-animated',
                                ].join(' ')}
                                style={{ borderColor: (typeof border === 'object' ? border.color : '') ?? '' }}
                            />
                        }
                    </div>
                } @else {
                    <span class={avatarClasses} ref={(node: HTMLElement) => { avatarNode = node; }}>
                        @if (isImg) {
                            <img alt={alt} src={src} srcSet={srcSet} onError={handleImgError} />
                        } @else {
                            @if (isTextContent) {
                                <span class="lotus-avatar-content" style={{ transform: `scale(${scale})` }}>
                                    <span role="img" aria-label={alt ?? ''}>{children}</span>
                                </span>
                            } @else {
                                <>{children}</>
                            }
                        }
                        @if (hovering && hoverMask) {
                            <span class="lotus-avatar-hover">{hoverMask}</span>
                        }
                    </span>
                }

                @if (topSlot && isSizeKeyword && shape === 'circle') {
                    @if (topSlot.render) {
                        <>{topSlot.render()}</>
                    } @else {
                        <div
                            class={['lotus-avatar-top-slot-wrapper', topSlot.class ?? '', contentMotion ? 'lotus-avatar-animated' : ''].filter(Boolean).join(' ')}
                            style={topSlot.style}
                        >
                            <div class={`lotus-avatar-top-slot-bg lotus-avatar-top-slot-bg-${size}`}>
                                <TopSlotBadgeSvg
                                    gradientStart={topSlot.gradientStart ?? 'var(--lotus-color-primary)'}
                                    gradientEnd={topSlot.gradientEnd ?? 'var(--lotus-color-primary)'}
                                    gradientId={gradientId}
                                />
                            </div>
                            <div class="lotus-avatar-top-slot">
                                <div
                                    class={`lotus-avatar-top-slot-content lotus-avatar-top-slot-content-${size}`}
                                    style={{ color: topSlot.textColor ?? '' }}
                                >
                                    {topSlot.text}
                                </div>
                            </div>
                        </div>
                    }
                }

                @if (bottomSlot && isSizeKeyword) {
                    @if (bottomSlot.render) {
                        <>{bottomSlot.render()}</>
                    } @else {
                        <div class="lotus-avatar-bottom-slot" style={bottomSlot.style}>
                            <span
                                class={[
                                    `lotus-avatar-bottom-slot-shape-${bottomSlot.shape ?? 'circle'}`,
                                    `lotus-avatar-bottom-slot-shape-${bottomSlot.shape ?? 'circle'}-${size}`,
                                    bottomSlot.class ?? '',
                                ].filter(Boolean).join(' ')}
                                style={{ backgroundColor: bottomSlot.bgColor ?? '', color: bottomSlot.textColor ?? '' }}
                            >
                                {bottomSlot.text}
                            </span>
                        </div>
                    }
                }
            </div>
        } @else {
            <span
                class={[avatarClasses, className ?? ''].filter(Boolean).join(' ')}
                style={wrapperStyle}
                role="listitem"
                onClick={onClick}
                onMouseEnter={handleEnter}
                onMouseLeave={handleLeave}
                ref={(node: HTMLElement) => { avatarNode = node; }}
            >
                @if (isImg) {
                    <img alt={alt} src={src} srcSet={srcSet} onError={handleImgError} />
                } @else {
                    @if (isTextContent) {
                        <span class="lotus-avatar-content" style={{ transform: `scale(${scale})` }}>
                            <span role="img" aria-label={alt ?? ''}>{children}</span>
                        </span>
                    } @else {
                        <>{children}</>
                    }
                }
                @if (hovering && hoverMask) {
                    <span class="lotus-avatar-hover">{hoverMask}</span>
                }
            </span>
        }

        <style>
            .lotus-avatar,
            .lotus-avatar-wrapper {
                display: inline-flex;
                position: relative;
                box-sizing: border-box;
            }

            .lotus-avatar {
                align-items: center;
                justify-content: center;
                overflow: hidden;
                cursor: default;
                user-select: none;
                color: #ffffff;
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-avatar img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .lotus-avatar-circle {
                border-radius: var(--lotus-border-radius-circle);
            }

            .lotus-avatar-square {
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-avatar-extra-extra-small {
                width: 20px;
                height: 20px;
                font-size: 10px;
            }

            .lotus-avatar-extra-small {
                width: 24px;
                height: 24px;
                font-size: 10px;
            }

            .lotus-avatar-small {
                width: 32px;
                height: 32px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-avatar-default {
                width: 40px;
                height: 40px;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-avatar-medium {
                width: 48px;
                height: 48px;
                font-size: var(--lotus-font-body-size);
            }

            .lotus-avatar-large {
                width: 72px;
                height: 72px;
                font-size: 28px;
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-avatar-large.lotus-avatar-circle {
                border-radius: var(--lotus-border-radius-circle);
            }

            .lotus-avatar-extra-large {
                width: 128px;
                height: 128px;
                font-size: 64px;
                border-radius: var(--lotus-border-radius-large);
            }

            .lotus-avatar-extra-large.lotus-avatar-circle {
                border-radius: var(--lotus-border-radius-circle);
            }

            .lotus-avatar-content {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 100%;
                height: 100%;
                white-space: nowrap;
            }

            .lotus-avatar-color-grey {
                background: var(--lotus-color-tag-grey);
            }

            .lotus-avatar-color-red {
                background: var(--lotus-color-tag-red);
            }

            .lotus-avatar-color-pink {
                background: var(--lotus-color-tag-pink);
            }

            .lotus-avatar-color-purple {
                background: var(--lotus-color-tag-purple);
            }

            .lotus-avatar-color-violet {
                background: var(--lotus-color-tag-violet);
            }

            .lotus-avatar-color-indigo {
                background: var(--lotus-color-tag-indigo);
            }

            .lotus-avatar-color-blue {
                background: var(--lotus-color-tag-blue);
            }

            .lotus-avatar-color-lightBlue {
                background: var(--lotus-color-tag-light-blue);
            }

            .lotus-avatar-color-cyan {
                background: var(--lotus-color-tag-cyan);
            }

            .lotus-avatar-color-teal {
                background: var(--lotus-color-tag-teal);
            }

            .lotus-avatar-color-green {
                background: var(--lotus-color-tag-green);
            }

            .lotus-avatar-color-lightGreen {
                background: var(--lotus-color-tag-light-green);
            }

            .lotus-avatar-color-lime {
                background: var(--lotus-color-tag-lime);
            }

            .lotus-avatar-color-yellow {
                background: var(--lotus-color-tag-yellow);
            }

            .lotus-avatar-color-amber {
                background: var(--lotus-color-tag-amber);
            }

            .lotus-avatar-color-orange {
                background: var(--lotus-color-tag-orange);
            }

            .lotus-avatar-color-white {
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-0);
                border: 1px solid var(--lotus-color-border);
            }

            .lotus-avatar-hover {
                position: absolute;
                inset: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                background: var(--lotus-color-overlay-bg);
                border-radius: inherit;
            }

            .lotus-avatar-additional-border {
                position: absolute;
                inset: -3.5px;
                box-sizing: border-box;
                border: 1.5px solid var(--lotus-color-primary);
                border-radius: inherit;
                pointer-events: none;
            }

            .lotus-avatar-additional-border-animated {
                animation: lotus-avatar-border-pulse 800ms linear infinite;
            }

            .lotus-avatar-animated {
                animation: lotus-avatar-content-pulse 1000ms linear infinite;
            }

            @keyframes lotus-avatar-border-pulse {
                0% {
                    opacity: 1;
                    transform: scale(1);
                }

                to {
                    border-width: 0;
                    opacity: 0;
                    transform: scale(1.15);
                }
            }

            @keyframes lotus-avatar-content-pulse {
                0% {
                    transform: scale(1);
                }

                50% {
                    transform: scale(0.9);
                }

                to {
                    transform: scale(1);
                }
            }

            .lotus-avatar-top-slot-wrapper {
                position: absolute;
                top: -30px;
                left: 50%;
                transform: translateX(-50%);
                display: flex;
                flex-direction: column;
                align-items: center;
                pointer-events: none;
            }

            .lotus-avatar-top-slot-bg {
                width: 24px;
            }

            .lotus-avatar-top-slot-bg-large,
            .lotus-avatar-top-slot-bg-extra-large {
                width: 32px;
            }

            .lotus-avatar-top-slot-bg svg {
                width: 100%;
                height: auto;
                display: block;
            }

            .lotus-avatar-top-slot-content {
                margin-top: -14px;
                font-size: 6px;
                font-weight: var(--lotus-font-weight-semibold);
                color: #ffffff;
                white-space: nowrap;
            }

            .lotus-avatar-top-slot-content-large,
            .lotus-avatar-top-slot-content-extra-large {
                font-size: 10px;
            }

            .lotus-avatar-bottom-slot {
                position: absolute;
                bottom: -2px;
                left: 50%;
                transform: translateX(-50%);
            }

            .lotus-avatar-bottom-slot-shape-circle {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: var(--lotus-border-radius-circle);
                background: var(--lotus-color-primary);
                color: #ffffff;
                border: 2px solid var(--lotus-color-bg-0);
                font-size: 5px;
            }

            .lotus-avatar-bottom-slot-shape-circle-default,
            .lotus-avatar-bottom-slot-shape-circle-medium {
                width: 16px;
                height: 16px;
                font-size: 12px;
            }

            .lotus-avatar-bottom-slot-shape-circle-large,
            .lotus-avatar-bottom-slot-shape-circle-extra-large {
                width: 28px;
                height: 28px;
                font-size: 12px;
            }

            .lotus-avatar-bottom-slot-shape-square {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border-radius: 4px;
                background: var(--lotus-color-primary);
                color: #ffffff;
                border: 2px solid var(--lotus-color-bg-0);
                padding: 1px 4px;
                font-size: 5px;
                white-space: nowrap;
            }

            .lotus-avatar-bottom-slot-shape-square-default,
            .lotus-avatar-bottom-slot-shape-square-medium {
                font-size: 12px;
            }

            .lotus-avatar-bottom-slot-shape-square-large,
            .lotus-avatar-bottom-slot-shape-square-extra-large {
                font-size: 14px;
            }
        </style>
    </>
}
