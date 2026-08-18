import { track, effect, untrack } from 'ripple';
import { flattenLinks, resolveActiveLink, type AnchorLinkInput, type FlatAnchorLink } from '@lotus/foundation/navigation/anchor';
import { throttle } from '@lotus/foundation/base/animate-value';
import { scrollIntoView } from '@lotus/foundation/base/scroll-into-view';

export type { AnchorLinkInput };

export interface AnchorProps {
    links: AnchorLinkInput[];
    getContainer?: () => HTMLElement | Window;
    offsetTop?: number;
    activeLink?: string;
    defaultActiveLink?: string;
    onChange?: (currentLink: string | null, previousLink: string | null) => void;
    onClick?: (event: MouseEvent, link: string) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function getScrollTop(node: HTMLElement | Window): number {
    if (node === window) return window.pageYOffset ?? document.documentElement.scrollTop;
    return (node as HTMLElement).scrollTop;
}

/**
 * Anchor：滚动监听 + 高亮联动，本仓库首个需要"多目标元素位置计算"的
 * 滚动类组件（BackTop 只关心单一滚动位置阈值）。points/resolveActiveLink
 * 算法自研（Foundation 纯函数），滚动到目标用自研的 scrollIntoView
 * （不依赖 scroll-into-view-if-needed）。links 数组 + 摊平渲染取代
 * children 组合（同 Breadcrumb 先例）。
 */
export function Anchor(&{
    links,
    getContainer,
    offsetTop = 0,
    activeLink: activeLinkProp,
    defaultActiveLink,
    onChange,
    onClick,
    style,
    class: className,
    'aria-label': ariaLabel,
}: AnchorProps) @{
    const isControlled = activeLinkProp !== undefined;
    let &[state] = track<string | null>(isControlled ? activeLinkProp ?? null : defaultActiveLink ?? null);
    let &[clickLink] = track<boolean>(false);
    let &[flatLinks] = track<FlatAnchorLink[]>(() => flattenLinks(links));

    let &[displayActive] = track<string | null>(() => (isControlled ? activeLinkProp ?? null : state));

    function resolveContainer(): HTMLElement | Window {
        return getContainer ? getContainer() : window;
    }

    function setActive(next: string | null) {
        const prev = untrack(() => displayActive);
        if (prev === next) return;
        if (!isControlled) state = next;
        onChange?.(next, prev);
    }

    // 常驻挂载一次（effect 无清理函数机制场景下的标准做法，同 Select 的
    // document mousedown 监听、BackTop 的 scroll 监听），回调内部实时读取
    // 最新的 flatLinks/clickLink，不需要随 links prop 变化反复装卸监听器
    // （导航目录通常挂载后不会动态变化）。
    effect(() => {
        const container = untrack(() => resolveContainer());

        const computeActive = () => {
            if (untrack(() => clickLink)) return;
            const currentFlatLinks = untrack(() => flatLinks);
            const tops = currentFlatLinks.map((link) => {
                const el = document.querySelector(link.href);
                if (!el) return Infinity;
                const containerTop = container === window ? 0 : (container as HTMLElement).getBoundingClientRect().top;
                return el.getBoundingClientRect().top - containerTop - offsetTop;
            });
            const next = resolveActiveLink(currentFlatLinks.map((l) => l.href), tops);
            setActive(next);
        };

        const throttledCompute = throttle(computeActive, 100);
        container.addEventListener('scroll', throttledCompute);
        computeActive();
    });

    let clickLinkTimer: ReturnType<typeof setTimeout> | null = null;

    function handleLinkClick(event: MouseEvent, href: string) {
        event.preventDefault();
        clickLink = true;
        setActive(href);
        onClick?.(event, href);
        const el = document.querySelector(href);
        if (el instanceof HTMLElement) {
            scrollIntoView(el, { offset: offsetTop });
        }
        // 点击触发的滚动期间不响应 scroll 事件计算高亮，避免和目标锚点打架
        // （同 Select 点击外部关闭的踩坑思路：mousedown 早于其他事件触发，
        // 这里对称地用一个宽松的定时器窗口覆盖 scrollIntoView 的整个动画时长）。
        if (clickLinkTimer) clearTimeout(clickLinkTimer);
        clickLinkTimer = setTimeout(() => { clickLink = false; }, 400);
    }

    let &[classes] = track<string>(() => ['lotus-anchor', className ?? ''].filter(Boolean).join(' '));

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            @for (const link of flatLinks; key link.href) {
                <a
                    href={link.href}
                    class={[
                        'lotus-anchor-link',
                        `lotus-anchor-link-level-${link.level}`,
                        link.href === displayActive ? 'lotus-anchor-link-active' : '',
                    ].filter(Boolean).join(' ')}
                    onClick={(event: MouseEvent) => handleLinkClick(event, link.href)}
                >
                    {link.title ?? link.href}
                </a>
            }
        </div>

        <style>
            .lotus-anchor {
                display: flex;
                flex-direction: column;
                border-left: 2px solid var(--lotus-color-border);
            }

            .lotus-anchor-link {
                display: block;
                padding: 6px 0 6px 16px;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                text-decoration: none;
                transition: color 0.2s ease;
            }

            .lotus-anchor-link-level-1 {
                padding-left: 32px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-anchor-link-level-2 {
                padding-left: 48px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-anchor-link:hover {
                color: var(--lotus-color-primary);
            }

            .lotus-anchor-link-active {
                color: var(--lotus-color-primary);
                font-weight: var(--lotus-font-weight-semibold);
            }
        </style>
    </>
}
