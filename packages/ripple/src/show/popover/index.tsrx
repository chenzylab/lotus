import { track, effect, untrack, Portal } from 'ripple';
import { TooltipFoundation, type TooltipState, type TooltipTrigger } from '@lotus/foundation/show/tooltip';
import { calcFloatingStyle, type FloatingPosition } from '@lotus/foundation/base/floating-position';
import { getFocusableElements, resolveTabWrapTarget } from '@lotus/foundation/base/focus-trap';

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
    /** "小三角"是否指向触发元素中心；仅 `showArrow=true` 且 position 为 top/bottom/left/right 时有意义。 */
    arrowPointAtCenter?: boolean;
    /** 按 Esc 键（触发元素或浮层内）是否关闭面板；受控模式下不生效。 */
    closeOnEsc?: boolean;
    /** 焦点处于浮层内时，Tab/Shift+Tab 是否在浮层内首尾元素间循环。 */
    guardFocus?: boolean;
    /** 关闭后焦点是否回到触发元素（仅 trigger 为 hover/focus/click 时生效）。 */
    returnFocusOnClose?: boolean;
    /** trigger 为 hover 时，是否不响应键盘聚焦触发浮层显示。 */
    disableFocusListener?: boolean;
    /** 点击弹出层及内部任一元素时是否自动关闭浮层。 */
    clickToHide?: boolean;
    /** 是否阻止浮层上的点击事件冒泡。 */
    stopPropagation?: boolean;
    /** 关闭时是否保留内部 DOM 不销毁（对齐 Semi，用于避免内部组件重新挂载）。 */
    keepDOM?: boolean;
    /** 更新该值可手动触发浮层重新定位。 */
    rePosKey?: string | number;
    getPopupContainer?: () => HTMLElement | null;
    zIndex?: number;
    style?: Record<string, any>;
    class?: string;
    onVisibleChange?: (visible: boolean) => void;
    /** 浮层展示时，点击非 children、非浮层内部区域的回调（仅 trigger 为 custom/click 时有效）。 */
    onClickOutSide?: (event: MouseEvent) => void;
    /** 触发元素或浮层内按 Esc 键时调用（不受 closeOnEsc 影响，即使不关闭也会触发）。 */
    onEscKeyDown?: (event: KeyboardEvent) => void;
}

let popoverIdCounter = 0;

export function Popover(&{
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
    arrowPointAtCenter = true,
    closeOnEsc = true,
    guardFocus = true,
    returnFocusOnClose = true,
    disableFocusListener = false,
    clickToHide = false,
    stopPropagation = false,
    keepDOM = false,
    rePosKey,
    getPopupContainer,
    zIndex = 1030,
    style,
    class: className,
    onVisibleChange,
    onClickOutSide,
    onEscKeyDown,
}: PopoverProps) @{
    const isControlled = trigger === 'custom';
    let &[state] = track<TooltipState>({ visible: isControlled ? !!visibleProp : false });
    let &[triggerNode] = track<HTMLElement | null>(null);
    let &[floatingNode] = track<HTMLElement | null>(null);
    let &[floatingStyle] = track<{ position: FloatingPosition; left: number; top: number; transform: string; arrowOffsetX?: string; arrowOffsetY?: string } | null>(null);
    let &[hasRenderedOnce] = track<boolean>(false);
    const contentId = `lotus-popover-${++popoverIdCounter}`;
    // showArrow=true 时浮层需要给箭头留出更多间距，对齐 Semi 的 4px/10px 默认值差异。
    const resolvedSpacing = spacing ?? (showArrow ? 10 : 4);
    // trigger 为 click/custom 时 content 是独立可交互面板（dialog 语义），
    // hover/focus 时只是辅助说明（tooltip 语义），对齐 Semi 的无障碍设计。
    const contentRole = trigger === 'click' || trigger === 'custom' ? 'dialog' : 'tooltip';
    let prevFocusElement: HTMLElement | null = null;

    const foundation = new TooltipFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TooltipState>) => { state = { ...state, ...patch }; },
    });

    let &[displayVisible] = track<boolean>(() => (isControlled ? !!visibleProp : state.visible));

    effect(() => {
        if (displayVisible) {
            hasRenderedOnce = true;
            prevFocusElement = untrack(() => document.activeElement instanceof HTMLElement ? document.activeElement : null);
        } else if (returnFocusOnClose && trigger !== 'custom') {
            untrack(() => prevFocusElement)?.focus({ preventScroll: true });
        }
    });

    effect(() => {
        if (!displayVisible) {
            floatingStyle = null;
            return;
        }
        const trigger = triggerNode;
        if (!trigger) return;
        // rePosKey 变化本身不携带任何数据，只需要让这个 effect 重新执行——读一下
        // 让 Ripple 的依赖追踪捕获它即可（对齐 Semi「更新该值可手动触发重新定位」语义）。
        void rePosKey;
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
            showArrow,
            arrowPointAtCenter,
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
        if (!condition || disableFocusListener || trigger !== 'focus') return;
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
        if (event.key === 'Escape' && untrack(() => state.visible)) {
            onEscKeyDown?.(event);
            if (closeOnEsc && !isControlled) {
                foundation.hide(isControlled, onVisibleChange);
                untrack(() => triggerNode)?.focus();
            }
            return;
        }
        if (guardFocus && event.key === 'Tab' && displayVisible) {
            const floating = untrack(() => floatingNode);
            if (!floating) return;
            const focusable = getFocusableElements(floating);
            const target = resolveTabWrapTarget(focusable, document.activeElement, event.shiftKey);
            if (target) {
                event.preventDefault();
                target.focus();
            }
        }
    };
    const handleContentClick = (event: MouseEvent) => {
        if (stopPropagation) event.stopPropagation();
        if (clickToHide) foundation.hide(isControlled, onVisibleChange);
    };

    // 对齐 Semi：trigger 为 click/contextMenu 时，点击触发器与浮层以外的区域
    // 默认关闭面板（不需要额外 prop 开关，Semi foundation.ts 的 `_bindEvent`
    // 在这两种 trigger 下无条件调用 `registerClickOutsideHandler`）。用
    // `mousedown` 而非 `click` 对齐 Semi 的事件时机——`click` 会在 mouseup
    // 后才触发，此时若外部点击目标本身也会引发页面跳转/其他副作用，会有一
    // 帧的时序竞争。custom trigger 下也要通知 onClickOutSide（Semi 语义：
    // custom/click 两种 trigger 都有效），但不能擅自 hide（真源在外部）。
    effect(() => {
        if (trigger !== 'click' && trigger !== 'contextMenu' && trigger !== 'custom') return;
        if (!displayVisible) return;
        function handleDocumentMouseDown(event: MouseEvent) {
            const target = event.target as Node;
            const trig = untrack(() => triggerNode);
            const floating = untrack(() => floatingNode);
            if (trig?.contains(target)) return;
            if (floating?.contains(target)) return;
            onClickOutSide?.(event);
            if (!isControlled) foundation.hide(isControlled, onVisibleChange);
        }
        document.addEventListener('mousedown', handleDocumentMouseDown);
        return () => document.removeEventListener('mousedown', handleDocumentMouseDown);
    });

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

        @if ((displayVisible || (keepDOM && hasRenderedOnce)) && content != null) {
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
                        ...(displayVisible ? {} : { display: 'none' }),
                        ...(floatingStyle?.arrowOffsetX ? { '--lotus-popover-arrow-offset-x': floatingStyle.arrowOffsetX } : {}),
                        ...(floatingStyle?.arrowOffsetY ? { '--lotus-popover-arrow-offset-y': floatingStyle.arrowOffsetY } : {}),
                    }}
                    onKeyDown={handleKeyDown}
                    onClick={handleContentClick}
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
                left: calc(var(--lotus-popover-arrow-offset-x, 50%) - 5px);
            }

            .lotus-popover-arrow-bottom .lotus-popover-arrow,
            .lotus-popover-arrow-bottomLeft .lotus-popover-arrow,
            .lotus-popover-arrow-bottomRight .lotus-popover-arrow {
                top: -5px;
                left: calc(var(--lotus-popover-arrow-offset-x, 50%) - 5px);
            }

            .lotus-popover-arrow-left .lotus-popover-arrow,
            .lotus-popover-arrow-leftTop .lotus-popover-arrow,
            .lotus-popover-arrow-leftBottom .lotus-popover-arrow {
                right: -5px;
                top: calc(var(--lotus-popover-arrow-offset-y, 50%) - 5px);
            }

            .lotus-popover-arrow-right .lotus-popover-arrow,
            .lotus-popover-arrow-rightTop .lotus-popover-arrow,
            .lotus-popover-arrow-rightBottom .lotus-popover-arrow {
                left: -5px;
                top: calc(var(--lotus-popover-arrow-offset-y, 50%) - 5px);
            }
        </style>
    </>
}
