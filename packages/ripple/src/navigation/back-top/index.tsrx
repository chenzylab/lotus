import { track, effect, untrack } from 'ripple';
import { BackTopFoundation, type BackTopState } from '@lotus/foundation/navigation/back-top';
import { animateValue, throttle } from '@lotus/foundation/base/animate-value';
import { IconChevronUp } from '@lotus/icons';

export interface BackTopProps {
    children?: any;
    target?: () => HTMLElement | Window;
    visibilityHeight?: number;
    duration?: number;
    onClick?: (event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function getScrollTop(node: HTMLElement | Window): number {
    if (node === window) return window.pageYOffset ?? document.documentElement.scrollTop;
    return (node as HTMLElement).scrollTop;
}

function scrollNodeTo(node: HTMLElement | Window, top: number): void {
    if (node === window) {
        window.scrollTo(0, top);
    } else {
        (node as HTMLElement).scrollTop = top;
    }
}

/**
 * BackTop：滚动监听（节流）+ 数值动画回顶（animateValue 自研，不依赖
 * 第三方动画库）。target 默认 window，滚动监听是常驻挂载（effect 无
 * 清理函数场景下的标准做法，同 Select 的 document mousedown 监听），
 * 回调内部实时读取最新 target，不需要随 target 变化反复装卸监听器
 * （target 通常挂载后不会变化）。
 */
export function BackTop(&{
    children,
    target,
    visibilityHeight = 400,
    duration = 450,
    onClick,
    style,
    class: className,
    'aria-label': ariaLabel = '回到顶部',
}: BackTopProps) @{
    let &[state] = track<BackTopState>({ visible: false });

    const foundation = new BackTopFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<BackTopState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    function resolveTarget(): HTMLElement | Window {
        return target ? target() : window;
    }

    effect(() => {
        const node = resolveTarget();
        const syncVisible = () => foundation.handleScroll(getScrollTop(node), visibilityHeight);
        // 节流只用于真实的 scroll 事件监听，不能包含初始化调用——否则初始化
        // 调用会占用节流窗口的"首次立即执行"名额，紧随其后的真实滚动事件
        // （尤其是页面加载后立刻发生的滚动，间隔可能小于节流阈值）会被静默
        // 吞掉，导致状态不同步（真机测试偶发失败，见 specs 踩坑记录）。
        const throttledHandleScroll = throttle(syncVisible, 100);
        node.addEventListener('scroll', throttledHandleScroll);
        syncVisible();
    });

    function handleClick(event: MouseEvent) {
        foundation.handleClick(() => {
            const node = resolveTarget();
            const from = getScrollTop(node);
            animateValue({
                from,
                to: 0,
                duration,
                easing: 'easeInOutCubic',
                onFrame: (value) => scrollNodeTo(node, value),
            });
            onClick?.(event);
        });
    }

    let &[classes] = track<string>(() =>
        ['lotus-back-top', state.visible ? 'lotus-back-top-visible' : '', className ?? ''].filter(Boolean).join(' '),
    );

    <>
        @if (state.visible) {
            <button type="button" class={classes} style={style} aria-label={ariaLabel} onClick={handleClick}>
                @if (children != null) {
                    {children}
                } @if (children == null) {
                    <IconChevronUp />
                }
            </button>
        }

        <style>
            .lotus-back-top {
                position: fixed;
                right: 24px;
                bottom: 24px;
                z-index: var(--lotus-z-back-top);
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 40px;
                height: 40px;
                padding: 0;
                border: none;
                border-radius: var(--lotus-border-radius-full);
                background: var(--lotus-color-bg-1);
                color: var(--lotus-color-text-1);
                box-shadow: var(--lotus-shadow-elevated);
                cursor: pointer;
                transition: background-color 0.2s ease;
            }

            .lotus-back-top:hover {
                background: var(--lotus-color-fill-1);
            }
        </style>
    </>
}
