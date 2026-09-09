import { track, effect, untrack } from 'ripple';
import {
    CollapsibleFoundation,
    shouldRenderCollapsibleChildren,
    calcTargetHeight,
    shouldFadeOut,
    type CollapsibleState,
} from '@lotus/foundation/show/collapsible';

export interface CollapsibleProps {
    isOpen?: boolean;
    children?: any;
    duration?: number;
    motion?: boolean;
    keepDOM?: boolean;
    lazyRender?: boolean;
    collapseHeight?: number;
    collapseHeightAdaptive?: boolean;
    reCalcKey?: number | string;
    fade?: boolean;
    onMotionEnd?: () => void;
    style?: Record<string, any>;
    class?: string;
    id?: string;
    'aria-label'?: string;
}

/**
 * 无头（headless）展开/收起动画容器，对齐 Semi Design 的 Collapsible：
 * isOpen 完全受控，没有 header/itemKey/多面板状态机，触发器由使用方
 * 自己写（如一个普通 Button + 外部 track() 状态）。与 Collapse 的区别是
 * Collapse = "多个带 header 的 Panel + 手风琴/多选状态机"，Collapsible =
 * "单个裸的展开收起动画壳子，可包任意内容"。
 *
 * 用 ResizeObserver 实测 scrollHeight 驱动 CSS `height` 过渡，取代旧版
 * `max-height: 2000px` 的近似方案——max-height 动画按声明的常量差值算
 * 过渡进度而非内容真实高度，短内容展开时视觉上大半时间在过渡"看不见的
 * 空白"、后段才突然出现；内容超过 2000px 还会被直接截断，是真实功能性
 * 缺陷，不是可接受的近似。真实高度测量 + 状态机判断收纳进
 * CollapsibleFoundation 的纯函数，DOM 测量/事件绑定留在这里。
 */
export function Collapsible(&{
    isOpen = false,
    children,
    duration = 250,
    motion = true,
    keepDOM = false,
    lazyRender = false,
    collapseHeight = 0,
    collapseHeightAdaptive = false,
    reCalcKey,
    fade = false,
    onMotionEnd,
    style,
    class: className,
    id,
    'aria-label': ariaLabel,
}: CollapsibleProps) @{
    let &[state] = track<CollapsibleState>({
        domHeight: 0,
        visible: isOpen,
        isTransitioning: false,
        hasBeenRendered: false,
    });

    const foundation = new CollapsibleFoundation({
        getState: () => untrack(() => state),
        setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
    });

    let innerNode: HTMLElement | null = null;

    function remeasure() {
        if (innerNode) foundation.updateDOMHeight(innerNode.scrollHeight);
    }

    function handleInnerRef(node: HTMLElement | null) {
        innerNode = node;
        if (!node || typeof ResizeObserver === 'undefined') {
            if (node) remeasure();
            return;
        }
        remeasure();
        const observer = new ResizeObserver(() => remeasure());
        observer.observe(node);
        return () => observer.disconnect();
    }

    // isOpen 翻转时驱动 visible/isTransitioning 状态机（对齐 Semi
    // getDerivedStateFromProps）；reCalcKey 变化时强制重新测量（内容动态
    // 变化后外部主动通知）。两者都要跳过首次挂载（初始 state 已经在
    // track() 初值里对齐过 isOpen，不需要重复触发一次“翻转”）。
    let prevIsOpen = isOpen;
    let prevReCalcKey = reCalcKey;
    let hasMounted = false;
    effect(() => {
        void isOpen;
        void reCalcKey;
        untrack(() => {
            if (!hasMounted) {
                hasMounted = true;
                return;
            }
            if (isOpen !== prevIsOpen) {
                prevIsOpen = isOpen;
                foundation.handleOpenChange(isOpen, motion);
            }
            if (reCalcKey !== prevReCalcKey) {
                prevReCalcKey = reCalcKey;
                remeasure();
            }
        });
    });

    let &[shouldRenderChildren] = track<boolean>(() =>
        shouldRenderCollapsibleChildren({
            isOpen,
            visible: state.visible,
            keepDOM,
            lazyRender,
            hasBeenRendered: state.hasBeenRendered,
            collapseHeight,
        }),
    );

    effect(() => {
        if (shouldRenderChildren) untrack(() => foundation.markRendered());
    });

    let &[targetHeight] = track<number>(() =>
        calcTargetHeight({ isOpen, domHeight: state.domHeight, collapseHeight, collapseHeightAdaptive }),
    );

    let &[fadeOut] = track<boolean>(() => shouldFadeOut({ isOpen, fade, collapseHeight }));

    function handleTransitionEnd() {
        untrack(() => foundation.handleTransitionEnd(isOpen));
        onMotionEnd?.();
    }

    <>
        <div
            id={id}
            class={['lotus-collapsible', motion && state.isTransitioning ? 'lotus-collapsible-transitioning' : ''].filter(Boolean).join(' ')}
            style={{
                ...style,
                height: `${targetHeight}px`,
                opacity: fadeOut ? 0 : 1,
                transitionDuration: `${motion && state.isTransitioning ? duration : 0}ms`,
            }}
            aria-hidden={!isOpen}
            aria-label={ariaLabel}
            onTransitionEnd={handleTransitionEnd}
        >
            <div class={['lotus-collapsible-inner', className ?? ''].filter(Boolean).join(' ')} ref={handleInnerRef}>
                @if (shouldRenderChildren) {
                    <>{children}</>
                }
            </div>
        </div>

        <style>
            .lotus-collapsible {
                overflow: hidden;
                transition-property: height, opacity;
                transition-timing-function: ease;
            }

            .lotus-collapsible-inner {
                overflow: hidden;
            }
        </style>
    </>
}
