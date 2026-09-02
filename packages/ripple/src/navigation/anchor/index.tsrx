import { track, effect, untrack } from 'ripple';
import { flattenLinks, resolveActiveLink, shouldShowInCollapse, sortRegisteredLinks, type AnchorLinkInput, type FlatAnchorLink } from '@lotus/foundation/navigation/anchor';
import { throttle } from '@lotus/foundation/base/animate-value';
import { scrollIntoView } from '@lotus/foundation/base/scroll-into-view';
import { Tooltip } from '../../show/tooltip/index.tsrx';
import { AnchorContext, type AnchorRegisteredLink } from './anchor-context.js';

export type { AnchorLinkInput };
export { AnchorLink } from './link.tsrx';
export type { AnchorLinkProps } from './link.tsrx';

export type AnchorPosition = 'left' | 'right';
export type AnchorRailTheme = 'primary' | 'muted';
export type AnchorSize = 'default' | 'small';
export type AnchorShowTooltip = boolean | { position?: string };

export interface AnchorProps {
    /** 链接数据数组写法；也可以省略此项，改用嵌套的 `<AnchorLink>` 子组件声明式写法
     * （二选一，对齐 Radio 既支持 `options` 也支持 `children` 的先例）。 */
    links?: AnchorLinkInput[];
    children?: any;
    getContainer?: () => HTMLElement | Window;
    offsetTop?: number;
    /** 点击后滚动目标位置的独立偏移量，默认与 offsetTop 相同（对齐 Semi：
     * offsetTop 控制高亮判定阈值，targetOffset 控制滚动落点，两者语义不同）。 */
    targetOffset?: number;
    activeLink?: string;
    defaultActiveLink?: string;
    position?: AnchorPosition;
    railTheme?: AnchorRailTheme;
    size?: AnchorSize;
    /** 非激活链接的子链接自动折叠隐藏。 */
    autoCollapse?: boolean;
    /** 标题过长被省略时 hover 展示完整标题。 */
    showTooltip?: AnchorShowTooltip;
    maxHeight?: string | number;
    maxWidth?: string | number;
    /** 点击后滚动是否带平滑动画。 */
    scrollMotion?: boolean;
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

function toCssSize(value: string | number | undefined): string | undefined {
    if (value === undefined) return undefined;
    return typeof value === 'number' ? `${value}px` : value;
}

/**
 * Anchor：滚动监听 + 高亮联动，本仓库首个需要"多目标元素位置计算"的
 * 滚动类组件（BackTop 只关心单一滚动位置阈值）。points/resolveActiveLink
 * 算法自研（Foundation 纯函数），滚动到目标用自研的 scrollIntoView
 * （不依赖 scroll-into-view-if-needed）。
 *
 * 支持两种写法：`links` 数组（同 Breadcrumb 先例，摊平渲染）；或嵌套的
 * `<AnchorLink>` 子组件声明式写法（对齐 Semi `<Anchor><Link>...</Link>
 * </Anchor>` 视觉，Ripple 无 children 遍历/克隆能力，靠 AnchorLink 自己
 * 在 mount 时把 href/title/disabled/level 注册进 AnchorContext 实现，
 * 同 Form.Field 的 registerField 模式）。两种写法二选一，`links` 存在
 * 时优先生效。
 */
export function Anchor(&{
    links,
    children,
    getContainer,
    offsetTop = 0,
    targetOffset,
    activeLink: activeLinkProp,
    defaultActiveLink,
    position = 'left',
    railTheme = 'primary',
    size = 'default',
    autoCollapse = false,
    showTooltip = false,
    maxHeight,
    maxWidth,
    scrollMotion = false,
    onChange,
    onClick,
    style,
    class: className,
    'aria-label': ariaLabel,
}: AnchorProps) @{
    const isControlled = activeLinkProp !== undefined;
    let &[state] = track<string | null>(isControlled ? activeLinkProp ?? null : defaultActiveLink ?? null);
    let &[clickLink] = track<boolean>(false);

    // 声明式写法下 AnchorLink 注册进这个 Map；links 数组写法直接摊平，
    // 不经过这个 Map（两条数据源互斥，links 存在时优先）。
    let &[registeredLinks] = track<Map<string, AnchorRegisteredLink>>(new Map());

    function registerLink(link: AnchorRegisteredLink) {
        const next = new Map(untrack(() => registeredLinks));
        next.set(link.href, link);
        registeredLinks = next;
    }

    function unregisterLink(href: string) {
        const next = new Map(untrack(() => registeredLinks));
        next.delete(href);
        registeredLinks = next;
    }

    let &[, anchorContextValue] = track(() => ({
        activeLink: isControlled ? activeLinkProp ?? null : state,
        showTooltip,
        size,
        registerLink,
        unregisterLink,
    }));
    AnchorContext.set(anchorContextValue);

    let &[flatLinks] = track<FlatAnchorLink[]>(() => {
        if (links) return flattenLinks(links);
        // 声明式写法：Map 的注册顺序取决于 Ripple 子组件先于父组件 mount
        // 的实际时序，不是 JSX 书写顺序——用 sortRegisteredLinks 按
        // parentHref 重建父子关系再深度优先遍历，还原"父节点后紧跟其
        // 全部子节点"的视觉顺序（与 links 数组写法共用同一套 ancestorHrefs
        // 计算，autoCollapse 判断逻辑对两种写法完全一致）。注意：多个
        // 顶层 AnchorLink 兄弟之间的相对顺序仍取决于各自 effect 的注册
        // 时序，无法从 Context 数据本身还原真实的 JSX 书写顺序。
        return sortRegisteredLinks([...registeredLinks.values()]);
    });

    let &[displayActive] = track<string | null>(() => (isControlled ? activeLinkProp ?? null : state));

    function resolveContainer(): HTMLElement | Window {
        return getContainer ? getContainer() : window;
    }

    function setActive(next: string | null) {
        const prev = untrack(() => displayActive);
        if (prev === next) return;
        if (!isControlled) state = next;
        onChange?.(next ?? '', prev ?? '');
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

    function handleLinkClick(event: MouseEvent, href: string, disabled: boolean | undefined) {
        event.preventDefault();
        if (disabled) return;
        clickLink = true;
        setActive(href);
        onClick?.(event, href);
        const el = document.querySelector(href);
        if (el instanceof HTMLElement) {
            scrollIntoView(el, { offset: targetOffset ?? offsetTop, duration: scrollMotion ? 300 : 0 });
        }
        // 点击触发的滚动期间不响应 scroll 事件计算高亮，避免和目标锚点打架
        // （同 Select 点击外部关闭的踩坑思路：mousedown 早于其他事件触发，
        // 这里对称地用一个宽松的定时器窗口覆盖 scrollIntoView 的整个动画时长）。
        if (clickLinkTimer) clearTimeout(clickLinkTimer);
        clickLinkTimer = setTimeout(() => { clickLink = false; }, 400);
    }

    // autoCollapse：两种写法（links 数组/AnchorLink 声明式）都携带完整
    // ancestorHrefs，共用 Foundation 的 shouldShowInCollapse 判断逻辑。
    // 这里必须直接读 displayActive/flatLinks（不能包 untrack），否则
    // active 变化时 visibleLinks 的 track() 不会重新求值——同一根因
    // 已在下方 flatLinks 计算处的 registeredLinks 读取踩过一次。
    let &[visibleLinks] = track<FlatAnchorLink[]>(() => {
        if (!autoCollapse) return flatLinks;
        const active = displayActive;
        const activeAncestors = active ? (flatLinks.find((l) => l.href === active)?.ancestorHrefs ?? []) : [];
        return flatLinks.filter((link) => shouldShowInCollapse(link, active, activeAncestors));
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-anchor',
            `lotus-anchor-${position}`,
            `lotus-anchor-rail-${railTheme}`,
            `lotus-anchor-size-${size}`,
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[containerStyle] = track<Record<string, any>>(() => ({
        ...(maxHeight !== undefined ? { maxHeight: toCssSize(maxHeight), overflowY: 'auto' } : {}),
        ...(maxWidth !== undefined ? { maxWidth: toCssSize(maxWidth) } : {}),
        ...style,
    }));

    <>
        <div class={classes} style={containerStyle} aria-label={ariaLabel}>
            @if (children) {
                <span style="display:contents">{children}</span>
            }
            @for (const link of visibleLinks; key link.href) {
                <Tooltip
                    content={link.title ?? link.href}
                    condition={showTooltip !== false}
                    position={(typeof showTooltip === 'object' ? showTooltip?.position : undefined) as any ?? 'right'}
                >
                    <a
                        href={link.href}
                        class={[
                            'lotus-anchor-link',
                            `lotus-anchor-link-level-${link.level}`,
                            link.href === displayActive ? 'lotus-anchor-link-active' : '',
                            link.disabled ? 'lotus-anchor-link-disabled' : '',
                        ].filter(Boolean).join(' ')}
                        aria-disabled={link.disabled}
                        onClick={(event: MouseEvent) => handleLinkClick(event, link.href, link.disabled)}
                    >
                        {link.title ?? link.href}
                    </a>
                </Tooltip>
            }
        </div>

        <style>
            .lotus-anchor {
                display: flex;
                flex-direction: column;
                border-inline-start: 2px solid var(--lotus-color-border);
            }

            .lotus-anchor-right {
                border-inline-start: none;
                border-inline-end: 2px solid var(--lotus-color-border);
                align-items: flex-end;
            }

            .lotus-anchor-link {
                display: block;
                padding: 6px 0 6px 16px;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                text-decoration: none;
                transition: color 0.2s ease;
            }

            .lotus-anchor-right .lotus-anchor-link {
                padding: 6px 16px 6px 0;
                text-align: right;
            }

            .lotus-anchor-size-small .lotus-anchor-link {
                padding-top: 4px;
                padding-bottom: 4px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-anchor-link-level-1 {
                padding-inline-start: 32px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-anchor-link-level-2 {
                padding-inline-start: 48px;
                font-size: var(--lotus-font-label-size);
            }

            .lotus-anchor-right .lotus-anchor-link-level-1 {
                padding-inline-end: 32px;
                padding-inline-start: 0;
            }

            .lotus-anchor-right .lotus-anchor-link-level-2 {
                padding-inline-end: 48px;
                padding-inline-start: 0;
            }

            .lotus-anchor-link:hover {
                color: var(--lotus-color-primary);
            }

            .lotus-anchor-link-active {
                color: var(--lotus-color-primary);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-anchor-rail-muted .lotus-anchor-link-active {
                color: var(--lotus-color-text-0);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-anchor-link-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
                pointer-events: none;
            }
        </style>
    </>
}
