import { track, effect, untrack, Portal } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import {
    resolveStepTarget,
    resolveSpotlightPadding,
    computeSpotlightRect,
    isRectInViewport,
    computeUserGuideFloatingStyle,
    UserGuideFoundation,
    type UserGuideState,
    type UserGuideMode,
    type UserGuideStepData,
} from '@lotus/foundation/show/user-guide';
import type { FloatingPosition, FloatingRect } from '@lotus/foundation/base/floating-position';
import { Button, type ButtonProps } from '../../basic/button/index.tsrx';
import { Modal } from '../modal/index.tsrx';

export type { UserGuideMode };
export type UserGuideStep = UserGuideStepData;

export interface UserGuideProps {
    steps?: UserGuideStep[];
    visible?: boolean;
    current?: number;
    mode?: UserGuideMode;
    mask?: boolean;
    theme?: 'default' | 'primary';
    position?: FloatingPosition;
    spotlightPadding?: number;
    showPrevButton?: boolean;
    showSkipButton?: boolean;
    finishText?: string;
    nextButtonProps?: ButtonProps;
    prevButtonProps?: ButtonProps;
    onChange?: (current: number) => void;
    onNext?: (current: number) => void;
    onPrev?: (current: number) => void;
    onSkip?: () => void;
    onFinish?: () => void;
    zIndex?: number;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const EMPTY_RECT: FloatingRect = { top: 0, left: 0, right: 0, bottom: 0, width: 0, height: 0 };

function rectFromElement(el: Element): FloatingRect {
    const r = el.getBoundingClientRect();
    return { top: r.top, left: r.left, right: r.right, bottom: r.bottom, width: r.width, height: r.height };
}

/**
 * UserGuide：分步引导组件。popup 模式用 SVG `<mask>` 做镂空遮罩（对齐 Semi 思路——
 * 比 box-shadow 技巧更干净，支持任意圆角，且能用透明矩形精确分区拦截点击、镂空区域
 * 内部完全穿透），浮层不锚定目标元素本身，而是以"高亮框矩形"作为虚拟锚点传给
 * `calcFloatingStyle`（与 Tooltip/Popover 共享同一定位引擎，不重新实现坐标数学）。
 *
 * 主动偏离 Semi 之处（详见 specs 踩坑记录）：
 * - padding 优先级判断用 `??` 而非 `||`，修正 Semi `spotlightPadding: 0` 被吞掉的 bug。
 * - 状态机边界钳制在 Foundation 层完成（`current` 不会产生 -1），不依赖 UI 层隐式保护。
 * - 新增键盘支持：ESC 触发 Skip，方向键 ←/→ 触发上一步/下一步（Semi 完全空白）。
 * - 新增 resize 监听：窗口尺寸变化时高亮框和浮层自动重新定位（Semi 完全空白）。
 * - 不做 `getPopupContainer`（Semi 源码里这个 prop 名不副实，只影响 body 滚动锁定，
 *   不影响实际挂载位置，属于半成品，不照搬）。
 */
export function UserGuide(&{
    steps = [],
    visible = false,
    current: currentProp,
    mode = 'popup',
    mask = true,
    theme = 'default',
    position = 'bottom',
    spotlightPadding,
    showPrevButton = true,
    showSkipButton = true,
    finishText,
    nextButtonProps = {},
    prevButtonProps = {},
    onChange,
    onNext,
    onPrev,
    onSkip,
    onFinish,
    zIndex = 1030,
    style,
    class: className,
    'aria-label': ariaLabel,
}: UserGuideProps) @{
    const isControlled = currentProp !== undefined;
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<UserGuideState>({ current: isControlled ? (currentProp ?? 0) : 0 });
    let &[spotlightRect] = track<FloatingRect | null>(null);
    let &[floatingNode] = track<HTMLElement | null>(null);
    let &[floatingSize] = track<{ width: number; height: number }>({ width: 0, height: 0 });
    let &[recalcTick] = track<number>(0);

    const foundation = new UserGuideFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<UserGuideState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // 受控模式下展示的 current 直接跟随外部 prop；非受控走内部 state。
    let &[displayCurrent] = track<number>(() => (isControlled ? (currentProp ?? 0) : state.current));

    // 受控模式下 Foundation 读写的 state.current 必须跟随外部 prop 同步——否则
    // foundation.next()/prev() 每次都基于挂载时的陈旧初值计算，第二次及以后的
    // 推进会算出错误结果（如 stepCount=3 时 current=1 再次 next() 会得到 1 而非 2，
    // 因为 state.current 从未更新过，一直停在初始快照）。同 Resizable/Tooltip 等
    // 既有组件的受控值同步模式，effect 内读写同一 state 需要 untrack 避免死循环。
    effect(() => {
        if (!isControlled) return;
        const next = currentProp ?? 0;
        const current = untrack(() => state).current;
        if (current === next) return;
        untrack(() => { state = { ...state, current: next }; });
    });

    // visible 从 false -> true 时强制回到第一步（对齐 Semi：每次重新打开引导都从头开始）。
    let &[prevVisible] = track<boolean>(visible);
    effect(() => {
        if (visible && !untrack(() => prevVisible)) {
            untrack(() => foundation.reset());
        }
        untrack(() => { prevVisible = visible; });
    });

    let &[currentStep] = track<UserGuideStep | undefined>(() => steps[displayCurrent]);
    let &[isFirst] = track<boolean>(() => displayCurrent <= 0);
    let &[isLast] = track<boolean>(() => displayCurrent >= steps.length - 1);

    // 目标元素测量：仅 popup 模式需要。visible/current/step 变化，或 resize 触发的
    // recalcTick 变化时重新求值。滚动到可视区域后用 requestAnimationFrame 等一帧布局
    // 稳定再测量（对齐 Semi scrollIntoView 的异步时序处理）。
    effect(() => {
        const step = currentStep;
        const tick = recalcTick;
        if (mode !== 'popup' || !visible || !step) {
            untrack(() => { spotlightRect = null; });
            return;
        }
        const target = resolveStepTarget(step);
        if (!target) {
            untrack(() => { spotlightRect = null; });
            return;
        }
        const targetRect = rectFromElement(target);
        if (!isRectInViewport(targetRect, window.innerWidth, window.innerHeight)) {
            target.scrollIntoView({ behavior: 'auto', block: 'center' });
        }
        requestAnimationFrame(() => {
            const freshRect = rectFromElement(target);
            const padding = resolveSpotlightPadding(step, spotlightPadding);
            untrack(() => { spotlightRect = computeSpotlightRect(freshRect, padding); });
        });
    });

    // resize 监听：popup 模式展示期间，窗口尺寸变化触发重新测量（Semi 完全没做这个，主动增强）。
    effect(() => {
        if (mode !== 'popup' || !visible) return;
        const handleResize = () => { untrack(() => { recalcTick = recalcTick + 1; }); };
        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    });

    // 键盘支持：ESC 触发 Skip，方向键左右触发上一步/下一步（Semi 完全空白，主动增强）。
    effect(() => {
        if (!visible) return;
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key === 'Escape') { onSkip?.(); return; }
            if (event.key === 'ArrowRight') { untrack(() => handleNext()); return; }
            if (event.key === 'ArrowLeft') { untrack(() => handlePrev()); return; }
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    function handlePrev() {
        const next = foundation.prev(isControlled);
        if (next !== untrack(() => displayCurrent)) onChange?.(next);
        onPrev?.(next);
    }

    function handleNext() {
        const result = foundation.next(steps.length, isControlled);
        if (result.finished) {
            onFinish?.();
            return;
        }
        onChange?.(result.current);
        onNext?.(result.current);
    }

    function handleSkip() {
        onSkip?.();
    }

    let &[floatingStyle] = track(() => {
        const rect = spotlightRect;
        const step = currentStep;
        if (!rect || !step) return null;
        return computeUserGuideFloatingStyle({
            spotlightRect: rect,
            position: step.position ?? position,
            floatingSize,
        });
    });

    function handleFloatingRef(node: HTMLElement | null) {
        if (!node) return;
        floatingNode = node;
        if (typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver((entries) => {
            const entry = entries[0];
            if (!entry) return;
            const next = { width: entry.contentRect.width, height: entry.contentRect.height };
            const current = untrack(() => floatingSize);
            if (current.width === next.width && current.height === next.height) return;
            floatingSize = next;
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    let &[maskPathId] = track<string>(`lotus-user-guide-mask-${Math.random().toString(36).slice(2)}`);

    let &[showPrev] = track<boolean>(() => showPrevButton && !isFirst);
    let &[showSkip] = track<boolean>(() => showSkipButton && !isLast);
    let &[nextLabel] = track<string>(() => {
        if (nextButtonProps.children !== undefined) return '';
        return isLast ? (finishText ?? locale.UserGuide.finish) : locale.UserGuide.next;
    });

    let &[popupCardClasses] = track<string>(() =>
        ['lotus-user-guide-card', `lotus-user-guide-card-theme-${currentStep?.theme ?? theme}`, className ?? ''].filter(Boolean).join(' '),
    );

    let &[modalDotClasses] = track<(index: number) => string>(() => (index: number) =>
        ['lotus-user-guide-modal-dot', index === displayCurrent ? 'lotus-user-guide-modal-dot-active' : ''].filter(Boolean).join(' '),
    );

    <>
        @if (visible && mode === 'popup' && currentStep) {
            <Portal target={typeof document !== 'undefined' ? document.body : null}>
                <svg class="lotus-user-guide-spotlight" style={{ zIndex }} aria-hidden="true">
                    <defs>
                        <mask id={maskPathId}>
                            <rect width="100%" height="100%" fill="white" />
                            @if (spotlightRect) {
                                <rect
                                    x={spotlightRect.left}
                                    y={spotlightRect.top}
                                    width={spotlightRect.width}
                                    height={spotlightRect.height}
                                    rx={4}
                                    fill="black"
                                />
                            }
                        </mask>
                    </defs>
                    @if (mask) {
                        <rect width="100%" height="100%" fill="var(--lotus-color-overlay-bg)" mask={`url(#${maskPathId})`} class="lotus-user-guide-spotlight-fill" />
                    }
                </svg>

                @if (spotlightRect) {
                    <div
                        class={popupCardClasses}
                        style={{
                            ...style,
                            position: 'fixed',
                            left: `${floatingStyle?.left ?? 0}px`,
                            top: `${floatingStyle?.top ?? 0}px`,
                            transform: floatingStyle?.transform ?? '',
                            zIndex: zIndex + 1,
                        }}
                        role="dialog"
                        aria-label={ariaLabel}
                        aria-live="polite"
                        ref={handleFloatingRef}
                    >
                        @if (currentStep.showArrow !== false) {
                            <div class={`lotus-user-guide-arrow lotus-user-guide-arrow-${floatingStyle?.position ?? position}`} />
                        }
                        @if (currentStep.cover !== undefined) {
                            <div class="lotus-user-guide-cover">{currentStep.cover}</div>
                        }
                        <div class="lotus-user-guide-body">
                            @if (currentStep.title !== undefined) {
                                <div class="lotus-user-guide-title">{currentStep.title}</div>
                            }
                            @if (currentStep.description !== undefined) {
                                <div class="lotus-user-guide-description">{currentStep.description}</div>
                            }
                        </div>
                        <div class="lotus-user-guide-footer">
                            <div class="lotus-user-guide-footer-left">
                                @if (showSkip) {
                                    <Button theme="borderless" size="small" onClick={handleSkip}>{locale.UserGuide.skip}</Button>
                                }
                            </div>
                            <div class="lotus-user-guide-footer-right">
                                @if (showPrev) {
                                    <Button theme="light" size="small" {...prevButtonProps} onClick={(e: MouseEvent) => { prevButtonProps.onClick?.(e); handlePrev(); }}>
                                        {prevButtonProps.children ?? locale.UserGuide.prev}
                                    </Button>
                                }
                                <Button theme="solid" type="primary" size="small" {...nextButtonProps} onClick={(e: MouseEvent) => { nextButtonProps.onClick?.(e); handleNext(); }}>
                                    {nextButtonProps.children ?? nextLabel}
                                </Button>
                            </div>
                        </div>
                    </div>
                }
            </Portal>
        }

        @if (mode === 'modal' && steps.length > 0) {
            <Modal
                visible={visible}
                mask={mask}
                maskClosable={false}
                closable={false}
                closeOnEsc={false}
                header={null}
                footer={null}
                centered
                zIndex={zIndex}
                class={['lotus-user-guide-modal', className ?? ''].filter(Boolean).join(' ')}
                style={style}
                aria-label={ariaLabel}
            >
                @if (currentStep) {
                    <>
                        @if (currentStep.cover !== undefined) {
                            <div class="lotus-user-guide-modal-cover">{currentStep.cover}</div>
                        }
                        <div class="lotus-user-guide-modal-body">
                            @if (currentStep.title !== undefined) {
                                <div class="lotus-user-guide-title">{currentStep.title}</div>
                            }
                            @if (currentStep.description !== undefined) {
                                <div class="lotus-user-guide-description">{currentStep.description}</div>
                            }
                        </div>
                        @if (steps.length > 1) {
                            <div class="lotus-user-guide-modal-dots" role="tablist" aria-label="步骤指示器">
                                @for (const _step of steps; index i) {
                                    <span class={modalDotClasses(i)} />
                                }
                            </div>
                        }
                        <div class="lotus-user-guide-footer">
                            <div class="lotus-user-guide-footer-left">
                                @if (showSkip) {
                                    <Button theme="borderless" size="small" onClick={handleSkip}>{locale.UserGuide.skip}</Button>
                                }
                            </div>
                            <div class="lotus-user-guide-footer-right">
                                @if (showPrev) {
                                    <Button theme="light" size="small" {...prevButtonProps} onClick={(e: MouseEvent) => { prevButtonProps.onClick?.(e); handlePrev(); }}>
                                        {prevButtonProps.children ?? locale.UserGuide.prev}
                                    </Button>
                                }
                                <Button theme="solid" type="primary" size="small" {...nextButtonProps} onClick={(e: MouseEvent) => { nextButtonProps.onClick?.(e); handleNext(); }}>
                                    {nextButtonProps.children ?? nextLabel}
                                </Button>
                            </div>
                        </div>
                    </>
                }
            </Modal>
        }

        <style>
            .lotus-user-guide-spotlight {
                position: fixed;
                top: 0;
                left: 0;
                width: 100vw;
                height: 100vh;
                pointer-events: none;
            }

            .lotus-user-guide-spotlight-fill {
                pointer-events: auto;
            }

            .lotus-user-guide-card {
                box-sizing: border-box;
                width: 320px;
                max-width: calc(100vw - 32px);
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
                overflow: hidden;
            }

            .lotus-user-guide-card-theme-primary {
                background: var(--lotus-color-primary);
                color: var(--lotus-color-bg-0);
            }

            .lotus-user-guide-arrow {
                position: absolute;
                width: 10px;
                height: 10px;
                background: inherit;
                transform: rotate(45deg);
            }

            .lotus-user-guide-arrow-top,
            .lotus-user-guide-arrow-topLeft,
            .lotus-user-guide-arrow-topRight {
                bottom: -5px;
                left: calc(50% - 5px);
            }

            .lotus-user-guide-arrow-bottom,
            .lotus-user-guide-arrow-bottomLeft,
            .lotus-user-guide-arrow-bottomRight {
                top: -5px;
                left: calc(50% - 5px);
            }

            .lotus-user-guide-arrow-left,
            .lotus-user-guide-arrow-leftTop,
            .lotus-user-guide-arrow-leftBottom {
                right: -5px;
                top: calc(50% - 5px);
            }

            .lotus-user-guide-arrow-right,
            .lotus-user-guide-arrow-rightTop,
            .lotus-user-guide-arrow-rightBottom {
                left: -5px;
                top: calc(50% - 5px);
            }

            .lotus-user-guide-cover {
                width: 100%;
            }

            .lotus-user-guide-body {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base) 0;
            }

            .lotus-user-guide-title {
                font-size: var(--lotus-font-heading-size-small);
                font-weight: 600;
                margin-bottom: var(--lotus-spacing-tight);
            }

            .lotus-user-guide-description {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                line-height: 1.6;
            }

            .lotus-user-guide-card-theme-primary .lotus-user-guide-description {
                color: var(--lotus-color-bg-0);
                opacity: 0.85;
            }

            .lotus-user-guide-footer {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: var(--lotus-spacing-base);
                gap: var(--lotus-spacing-tight);
            }

            .lotus-user-guide-footer-right {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-tight);
            }

            .lotus-user-guide-modal-cover {
                width: 100%;
            }

            .lotus-user-guide-modal-body {
                padding: var(--lotus-spacing-base) 0;
                text-align: center;
            }

            .lotus-user-guide-modal-dots {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: var(--lotus-spacing-tight);
                padding-bottom: var(--lotus-spacing-base);
            }

            .lotus-user-guide-modal-dot {
                width: 6px;
                height: 6px;
                border-radius: 50%;
                background: var(--lotus-color-fill-2);
            }

            .lotus-user-guide-modal-dot-active {
                background: var(--lotus-color-primary);
            }
        </style>
    </>
}
