import { track, effect, untrack, Portal } from 'ripple';
import { TooltipFoundation, type TooltipState, type TooltipTrigger } from '@lotus/foundation/show/tooltip';
import { calcFloatingStyle, type FloatingPosition } from '@lotus/foundation/base/floating-position';

export type { FloatingPosition } from '@lotus/foundation/base/floating-position';

export interface TooltipProps {
    children?: any;
    content?: any;
    position?: FloatingPosition;
    trigger?: TooltipTrigger;
    /** `trigger="custom"` 时完全受控，由此 prop 决定显隐；其余 trigger 模式下作为非受控初始值不适用，仅 custom 生效。 */
    visible?: boolean;
    /** Tooltip 是否允许响应 hover/click/focus 等触发行为，为 false 时不响应（`trigger="custom"` 不受影响）。 */
    condition?: boolean;
    mouseEnterDelay?: number;
    mouseLeaveDelay?: number;
    autoAdjustOverflow?: boolean;
    spacing?: number;
    showArrow?: boolean;
    /** 返回浮层挂载的目标 DOM，默认 `document.body`。 */
    getPopupContainer?: () => HTMLElement | null;
    zIndex?: number;
    style?: Record<string, any>;
    class?: string;
    /**
     * children 本身是块级元素（撑满宽度）时需要显式声明——对齐 Semi `wrapSpan` 的
     * `block || blockDisplays.includes(display)` 检测，但 Ripple 的 `children` 在组件
     * 逻辑代码里是编译期特殊包装的渲染句柄，无法像 React 那样反射读取子元素的
     * `props.style.display`/`props.block`，只能由调用方显式声明（同 Avatar 的 `isText`
     * 处理方式）。为 true 时 trigger 容器改用 `width:100%`，否则维持 `inline-block`
     * 的 shrink-to-fit（默认，兼容多数场景）。
     */
    block?: boolean;
    onVisibleChange?: (visible: boolean) => void;
}

let tooltipIdCounter = 0;

export function Tooltip({
    children,
    content,
    position = 'top',
    trigger = 'hover',
    visible: visibleProp,
    condition = true,
    mouseEnterDelay = 50,
    mouseLeaveDelay = 50,
    autoAdjustOverflow = true,
    spacing = 8,
    showArrow = true,
    getPopupContainer,
    zIndex = 1060,
    style,
    class: className,
    block = false,
    onVisibleChange,
}: TooltipProps) @{
    const isControlled = trigger === 'custom';
    let &[state] = track<TooltipState>({ visible: isControlled ? !!visibleProp : false });
    let &[triggerNode] = track<HTMLElement | null>(null);
    let &[floatingNode] = track<HTMLElement | null>(null);
    let &[floatingStyle] = track<{ position: FloatingPosition; left: number; top: number; transform: string } | null>(null);
    const contentId = `lotus-tooltip-${++tooltipIdCounter}`;

    const foundation = new TooltipFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TooltipState>) => { state = { ...state, ...patch }; },
    });

    // 受控模式（trigger="custom"）下，展示状态直接跟随外部传入的 visible，
    // 不依赖内部 state.visible（同 Switch/Tag 已验证的受控范式）。
    let &[displayVisible] = track<boolean>(() => (isControlled ? !!visibleProp : state.visible));

    // 浮层可见时，测量触发元素与浮层自身尺寸，计算定位样式；随 displayVisible/position 变化重新计算。
    effect(() => {
        if (!displayVisible) {
            floatingStyle = null;
            return;
        }
        const trigger = triggerNode;
        if (!trigger) return;
        const rect = trigger.getBoundingClientRect();
        const floating = untrack(() => floatingNode);
        const floatingSize = floating
            ? { width: floating.offsetWidth, height: floating.offsetHeight }
            : { width: 0, height: 0 };
        floatingStyle = calcFloatingStyle({
            position,
            triggerRect: { top: rect.top, left: rect.left, right: rect.right, bottom: rect.bottom, width: rect.width, height: rect.height },
            floatingSize,
            spacing,
            autoAdjustOverflow,
        });
    });

    const handleMouseEnter = () => {
        if (!condition || trigger !== 'hover') return;
        foundation.scheduleShow(mouseEnterDelay, isControlled, onVisibleChange);
    };
    const handleMouseLeave = () => {
        if (!condition || trigger !== 'hover') return;
        foundation.scheduleHide(mouseLeaveDelay, isControlled, onVisibleChange);
    };
    const handleClick = () => {
        if (!condition || trigger !== 'click') return;
        foundation.toggle(isControlled, onVisibleChange);
    };
    const handleFocus = () => {
        if (!condition || trigger !== 'focus') return;
        foundation.scheduleShow(mouseEnterDelay, isControlled, onVisibleChange);
    };
    const handleBlur = () => {
        if (!condition || trigger !== 'focus') return;
        foundation.scheduleHide(mouseLeaveDelay, isControlled, onVisibleChange);
    };
    const handleContextMenu = (event: MouseEvent) => {
        if (!condition || trigger !== 'contextMenu') return;
        event.preventDefault();
        foundation.show(isControlled, onVisibleChange);
    };

    function resolvePortalTarget(): HTMLElement | null {
        if (getPopupContainer) return getPopupContainer();
        return typeof document !== 'undefined' ? document.body : null;
    }

    let &[floatingClasses] = track<string>(() =>
        ['lotus-tooltip', showArrow ? `lotus-tooltip-arrow-${floatingStyle?.position ?? position}` : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        <span
            class="lotus-tooltip-trigger"
            style={block ? { width: '100%' } : undefined}
            aria-describedby={displayVisible ? contentId : undefined}
            ref={(node: HTMLElement) => { triggerNode = node; }}
            onMouseEnter={handleMouseEnter}
            onMouseLeave={handleMouseLeave}
            onClick={handleClick}
            onFocusIn={handleFocus}
            onFocusOut={handleBlur}
            onContextMenu={handleContextMenu}
        >
            {children}
        </span>

        @if (displayVisible && content != null) {
            <Portal target={resolvePortalTarget()}>
                <div
                    id={contentId}
                    role="tooltip"
                    class={floatingClasses}
                    style={{
                        ...style,
                        position: 'fixed',
                        left: `${floatingStyle?.left ?? 0}px`,
                        top: `${floatingStyle?.top ?? 0}px`,
                        transform: floatingStyle?.transform ?? '',
                        zIndex,
                    }}
                    ref={(node: HTMLElement) => { floatingNode = node; }}
                >
                    @if (showArrow) {
                        <div class="lotus-tooltip-arrow" />
                    }
                    <div class="lotus-tooltip-content">{content}</div>
                </div>
            </Portal>
        }

        <style>
            .lotus-tooltip-trigger {
                display: inline-block;
            }

            .lotus-tooltip {
                box-sizing: border-box;
                max-width: 240px;
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base-tight);
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-text-0);
                color: var(--lotus-color-bg-1);
                font-size: var(--lotus-font-label-size);
                line-height: var(--lotus-font-label-line-height);
                word-wrap: break-word;
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-tooltip-content {
                position: relative;
            }

            .lotus-tooltip-arrow {
                position: absolute;
                width: 8px;
                height: 8px;
                background: var(--lotus-color-text-0);
                transform: rotate(45deg);
            }

            .lotus-tooltip-arrow-top .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-topLeft .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-topRight .lotus-tooltip-arrow {
                bottom: -4px;
                left: calc(50% - 4px);
            }

            .lotus-tooltip-arrow-bottom .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-bottomLeft .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-bottomRight .lotus-tooltip-arrow {
                top: -4px;
                left: calc(50% - 4px);
            }

            .lotus-tooltip-arrow-left .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-leftTop .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-leftBottom .lotus-tooltip-arrow {
                right: -4px;
                top: calc(50% - 4px);
            }

            .lotus-tooltip-arrow-right .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-rightTop .lotus-tooltip-arrow,
            .lotus-tooltip-arrow-rightBottom .lotus-tooltip-arrow {
                left: -4px;
                top: calc(50% - 4px);
            }
        </style>
    </>
}
