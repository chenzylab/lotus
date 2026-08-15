import { track, effect, untrack, Portal } from 'ripple';
import { TooltipFoundation, type TooltipState, type TooltipTrigger } from '@lotus/foundation/show/tooltip';
import { calcFloatingStyle, type FloatingPosition } from '@lotus/foundation/base/floating-position';

export interface PopoverProps {
    children?: any;
    /** 浮层内容，支持任意 JSX（不限于文本），这是 Popover 与 Tooltip 的核心差异。 */
    content?: any;
    position?: FloatingPosition;
    trigger?: TooltipTrigger;
    visible?: boolean;
    condition?: boolean;
    mouseEnterDelay?: number;
    mouseLeaveDelay?: number;
    autoAdjustOverflow?: boolean;
    spacing?: number;
    showArrow?: boolean;
    /** 按 Esc 键（触发元素或浮层内）是否关闭面板；受控模式下不生效。 */
    closeOnEsc?: boolean;
    getPopupContainer?: () => HTMLElement | null;
    zIndex?: number;
    style?: Record<string, any>;
    class?: string;
    onVisibleChange?: (visible: boolean) => void;
}

let popoverIdCounter = 0;

export function Popover({
    children,
    content,
    position = 'bottom',
    trigger = 'hover',
    visible: visibleProp,
    condition = true,
    mouseEnterDelay = 50,
    mouseLeaveDelay = 50,
    autoAdjustOverflow = true,
    spacing,
    showArrow = false,
    closeOnEsc = true,
    getPopupContainer,
    zIndex = 1030,
    style,
    class: className,
    onVisibleChange,
}: PopoverProps) @{
    const isControlled = trigger === 'custom';
    let &[state] = track<TooltipState>({ visible: isControlled ? !!visibleProp : false });
    let &[triggerNode] = track<HTMLElement | null>(null);
    let &[floatingNode] = track<HTMLElement | null>(null);
    let &[floatingStyle] = track<{ position: FloatingPosition; left: number; top: number; transform: string } | null>(null);
    const contentId = `lotus-popover-${++popoverIdCounter}`;
    // showArrow=true 时浮层需要给箭头留出更多间距，对齐 Semi 的 4px/10px 默认值差异。
    const resolvedSpacing = spacing ?? (showArrow ? 10 : 4);
    // trigger 为 click/custom 时 content 是独立可交互面板（dialog 语义），
    // hover/focus 时只是辅助说明（tooltip 语义），对齐 Semi 的无障碍设计。
    const contentRole = trigger === 'click' || trigger === 'custom' ? 'dialog' : 'tooltip';

    const foundation = new TooltipFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TooltipState>) => { state = { ...state, ...patch }; },
    });

    let &[displayVisible] = track<boolean>(() => (isControlled ? !!visibleProp : state.visible));

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
            spacing: resolvedSpacing,
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
    const handleKeyDown = (event: KeyboardEvent) => {
        if (closeOnEsc && !isControlled && event.key === 'Escape' && untrack(() => state.visible)) {
            foundation.hide(isControlled, onVisibleChange);
            untrack(() => triggerNode)?.focus();
        }
    };

    function resolvePortalTarget(): HTMLElement | null {
        if (getPopupContainer) return getPopupContainer();
        return typeof document !== 'undefined' ? document.body : null;
    }

    let &[floatingClasses] = track<string>(() =>
        ['lotus-popover', showArrow ? `lotus-popover-arrow-${floatingStyle?.position ?? position}` : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        <span
            class="lotus-popover-trigger"
            aria-expanded={displayVisible}
            aria-haspopup="dialog"
            aria-controls={displayVisible ? contentId : undefined}
            tabIndex={trigger === 'focus' ? 0 : undefined}
            ref={(node: HTMLElement) => { triggerNode = node; }}
            onMouseEnter={handleMouseEnter}
            onMouseLeave={handleMouseLeave}
            onClick={handleClick}
            onFocusIn={handleFocus}
            onFocusOut={handleBlur}
            onContextMenu={handleContextMenu}
            onKeyDown={handleKeyDown}
        >
            {children}
        </span>

        @if (displayVisible && content != null) {
            <Portal target={resolvePortalTarget()}>
                <div
                    id={contentId}
                    role={contentRole}
                    class={floatingClasses}
                    style={{
                        ...style,
                        position: 'fixed',
                        left: `${floatingStyle?.left ?? 0}px`,
                        top: `${floatingStyle?.top ?? 0}px`,
                        transform: floatingStyle?.transform ?? '',
                        zIndex,
                    }}
                    onKeyDown={handleKeyDown}
                    ref={(node: HTMLElement) => { floatingNode = node; }}
                >
                    @if (showArrow) {
                        <div class="lotus-popover-arrow" />
                    }
                    <div class="lotus-popover-content">{content}</div>
                </div>
            </Portal>
        }

        <style>
            .lotus-popover-trigger {
                display: inline-block;
            }

            .lotus-popover {
                box-sizing: border-box;
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-popover-content {
                position: relative;
                box-sizing: border-box;
                padding: var(--lotus-spacing-base-tight);
            }

            .lotus-popover-arrow {
                position: absolute;
                width: 10px;
                height: 10px;
                background: var(--lotus-color-bg-1);
                transform: rotate(45deg);
                box-shadow: var(--lotus-shadow-elevated);
            }

            .lotus-popover-arrow-top .lotus-popover-arrow,
            .lotus-popover-arrow-topLeft .lotus-popover-arrow,
            .lotus-popover-arrow-topRight .lotus-popover-arrow {
                bottom: -5px;
                left: calc(50% - 5px);
            }

            .lotus-popover-arrow-bottom .lotus-popover-arrow,
            .lotus-popover-arrow-bottomLeft .lotus-popover-arrow,
            .lotus-popover-arrow-bottomRight .lotus-popover-arrow {
                top: -5px;
                left: calc(50% - 5px);
            }

            .lotus-popover-arrow-left .lotus-popover-arrow,
            .lotus-popover-arrow-leftTop .lotus-popover-arrow,
            .lotus-popover-arrow-leftBottom .lotus-popover-arrow {
                right: -5px;
                top: calc(50% - 5px);
            }

            .lotus-popover-arrow-right .lotus-popover-arrow,
            .lotus-popover-arrow-rightTop .lotus-popover-arrow,
            .lotus-popover-arrow-rightBottom .lotus-popover-arrow {
                left: -5px;
                top: calc(50% - 5px);
            }
        </style>
    </>
}
