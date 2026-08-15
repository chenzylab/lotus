import { track, untrack } from 'ripple';
import { BreadcrumbFoundation, type BreadcrumbState, type BreadcrumbRoute, type NormalizedRoute } from '@lotus/foundation/navigation/breadcrumb';
import { Popover } from '../../show/popover/index.tsrx';
import { Tooltip } from '../../show/tooltip/index.tsrx';

export type { BreadcrumbRoute, NormalizedRoute } from '@lotus/foundation/navigation/breadcrumb';
export type BreadcrumbMoreType = 'default' | 'popover';

export interface BreadcrumbShowTooltipOptions {
    /** 触发截断的宽度，单位 px；传 `'auto'` 表示不截断。默认 150。 */
    width?: number | 'auto';
    /** 省略号位置，默认从末尾省略。 */
    ellipsisPos?: 'end' | 'middle';
}

export interface BreadcrumbProps {
    /** 路由信息，由路由对象或字符串组成的数组。lotus 版本只支持 `routes` 声明式模式——
     * Ripple 没有 children 反射能力，做不到 Semi 的 `<Breadcrumb.Item>` children 模式，
     * 这是在 Ripple 约束下的诚实设计取舍（routes 模式本身也是 Semi 官方推荐且完整支持的用法）。 */
    routes?: Array<BreadcrumbRoute | string>;
    /** 是否紧凑显示（更小字号/间距），默认 true。 */
    compact?: boolean;
    /** 自定义分隔符，默认 `/`。 */
    separator?: any;
    /** 超出多少级自动折叠，默认 4。 */
    maxItemCount?: number;
    /** 是否超出 maxItemCount 后自动折叠，默认 true。 */
    autoCollapse?: boolean;
    /** 省略号区域渲染类型，`default` 显示省略号图标点击展开，`popover` 悬浮展示折叠项列表。 */
    moreType?: BreadcrumbMoreType;
    /** 自定义省略号区域渲染，优先级高于 moreType。 */
    renderMore?: (restRoutes: NormalizedRoute[]) => any;
    /** 自定义单个路由节点渲染，配合 routes 使用。 */
    renderItem?: (route: NormalizedRoute) => any;
    /** 级别名字溢出设定宽度后是否省略截断并显示 Tooltip，默认 true（宽度 150px，末尾省略）。 */
    showTooltip?: boolean | BreadcrumbShowTooltipOptions;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
    onClick?: (route: NormalizedRoute, event: MouseEvent) => void;
}

/** 从字符串中间截断，两端各保留一半可见字符，中间替换为省略号（CSS 原生 text-overflow
 * 只支持末尾省略，中间省略没有纯 CSS 方案，用字符串截断模拟——非精确像素级测量，
 * 但满足"从标题中间开始省略"这一视觉诉求）。 */
function truncateMiddle(name: string, visibleChars: number): string {
    if (name.length <= visibleChars) return name;
    const half = Math.floor(visibleChars / 2);
    return `${name.slice(0, half)}...${name.slice(name.length - half)}`;
}

function BreadcrumbLabel({ name, showTooltip }: { name: string; showTooltip: boolean | BreadcrumbShowTooltipOptions }) {
    if (!showTooltip) {
        return <span>{name}</span>;
    }
    const options = typeof showTooltip === 'object' ? showTooltip : {};
    const width = options.width ?? 150;
    const ellipsisPos = options.ellipsisPos ?? 'end';
    if (width === 'auto') {
        return <span>{name}</span>;
    }
    if (ellipsisPos === 'middle') {
        const displayText = truncateMiddle(name, 12);
        return <Tooltip content={name}>
            <span class="lotus-breadcrumb-label" style={{ maxWidth: `${width}px` }}>{displayText}</span>
        </Tooltip>;
    }
    return <Tooltip content={name}>
        <span class="lotus-breadcrumb-label lotus-breadcrumb-label-truncate-end" style={{ maxWidth: `${width}px` }}>{name}</span>
    </Tooltip>;
}

export function Breadcrumb({
    routes = [],
    compact = true,
    separator = '/',
    maxItemCount = 4,
    autoCollapse = true,
    moreType = 'default',
    renderMore,
    renderItem,
    showTooltip = true,
    'aria-label': ariaLabel,
    style,
    class: className,
    onClick,
}: BreadcrumbProps) @{
    let &[state] = track<BreadcrumbState>({ collapseExpanded: false });

    const foundation = new BreadcrumbFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<BreadcrumbState>) => { state = { ...state, ...patch }; },
    });

    let &[normalizedRoutes] = track<NormalizedRoute[]>(() => BreadcrumbFoundation.normalizeRoutes(routes));
    let &[collapsedRange] = track<[number, number] | null>(() =>
        BreadcrumbFoundation.computeCollapse(normalizedRoutes, maxItemCount, autoCollapse, state.collapseExpanded).collapsedRange,
    );
    // 预先摊平成单层展示列表（不含 @for 内部条件跳过），避免 keyed-diff 在折叠态
    // 切换时顺序错乱——完整踩坑记录见 foundation 侧 buildDisplayItems 的注释。
    let &[displayItems] = track(() => {
        const range = collapsedRange;
        const restRoutes = range ? normalizedRoutes.slice(range[0], range[1] + 1) : [];
        return BreadcrumbFoundation.buildDisplayItems(normalizedRoutes, range, restRoutes);
    });

    const classes = ['lotus-breadcrumb', compact ? 'lotus-breadcrumb-compact' : 'lotus-breadcrumb-loose', className ?? '']
        .filter(Boolean)
        .join(' ');

    function handleItemClick(route: NormalizedRoute, event: MouseEvent) {
        onClick?.(route, event);
    }

    <>
        <nav class={classes} style={style} aria-label={ariaLabel ?? '面包屑导航'}>
            <ol class="lotus-breadcrumb-list">
                @for (const item of displayItems; key item.type === 'more' ? 'collapse-more' : `item-${item.index}`) {
                    @if (item.type === 'more') {
                        <li class="lotus-breadcrumb-item-wrap">
                            @if (renderMore) {
                                <span class="lotus-breadcrumb-more">{renderMore(item.restRoutes)}</span>
                            } @else {
                                @if (moreType === 'popover') {
                                    <Popover
                                        trigger="hover"
                                        showArrow
                                        content={
                                            <div class="lotus-breadcrumb-popover-list">
                                                @for (const restRoute of item.restRoutes; key restRoute.name) {
                                                    <div class="lotus-breadcrumb-popover-item">{restRoute.name}</div>
                                                }
                                            </div>
                                        }
                                    >
                                        <span
                                            role="button"
                                            tabIndex={0}
                                            aria-label="展开面包屑省略项"
                                            class="lotus-breadcrumb-item lotus-breadcrumb-item-more"
                                        >
                                            •••
                                        </span>
                                    </Popover>
                                } @else {
                                    <span
                                        role="button"
                                        tabIndex={0}
                                        aria-label="展开面包屑省略项"
                                        class="lotus-breadcrumb-item lotus-breadcrumb-item-more"
                                        onClick={() => foundation.toggleExpand()}
                                        onKeyDown={(event: KeyboardEvent) => { if (event.key === 'Enter') foundation.toggleExpand(); }}
                                    >
                                        •••
                                    </span>
                                }
                            }
                            <span class="lotus-breadcrumb-separator">{separator}</span>
                        </li>
                    } @else {
                        <li class="lotus-breadcrumb-item-wrap">
                            @if (renderItem) {
                                <span class="lotus-breadcrumb-item">{renderItem(item.route)}</span>
                            } @else {
                                @if (item.route.href) {
                                    <a
                                        class="lotus-breadcrumb-item lotus-breadcrumb-item-link"
                                        href={item.route.href}
                                        aria-current={item.isLast ? 'page' : undefined}
                                        onClick={(event: MouseEvent) => handleItemClick(item.route, event)}
                                    >
                                        @if (item.route.icon) {
                                            <span class="lotus-breadcrumb-icon">{item.route.icon}</span>
                                        }
                                        @if (item.route.name) {
                                            <BreadcrumbLabel name={item.route.name} showTooltip={showTooltip} />
                                        }
                                    </a>
                                } @else {
                                    <span
                                        class="lotus-breadcrumb-item"
                                        aria-current={item.isLast ? 'page' : undefined}
                                        onClick={(event: MouseEvent) => handleItemClick(item.route, event)}
                                    >
                                        @if (item.route.icon) {
                                            <span class="lotus-breadcrumb-icon">{item.route.icon}</span>
                                        }
                                        @if (item.route.name) {
                                            <BreadcrumbLabel name={item.route.name} showTooltip={showTooltip} />
                                        }
                                    </span>
                                }
                            }
                            @if (!item.isLast) {
                                <span class="lotus-breadcrumb-separator">{separator}</span>
                            }
                        </li>
                    }
                }
            </ol>
        </nav>

        <style>
            .lotus-breadcrumb-list {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .lotus-breadcrumb-item-wrap {
                display: inline-flex;
                align-items: center;
            }

            .lotus-breadcrumb-item {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                color: var(--lotus-color-text-2);
                text-decoration: none;
                cursor: default;
            }

            .lotus-breadcrumb-item-link {
                cursor: pointer;
            }

            .lotus-breadcrumb-item-link:hover {
                color: var(--lotus-color-primary);
            }

            .lotus-breadcrumb-item[aria-current='page'] {
                color: var(--lotus-color-text-0);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-breadcrumb-item-more {
                cursor: pointer;
                letter-spacing: 1px;
            }

            .lotus-breadcrumb-item-more:hover {
                color: var(--lotus-color-primary);
            }

            .lotus-breadcrumb-separator {
                margin: 0 8px;
                color: var(--lotus-color-text-3);
            }

            .lotus-breadcrumb-compact .lotus-breadcrumb-item,
            .lotus-breadcrumb-compact .lotus-breadcrumb-item-more {
                font-size: var(--lotus-font-label-size);
            }

            .lotus-breadcrumb-loose .lotus-breadcrumb-item,
            .lotus-breadcrumb-loose .lotus-breadcrumb-item-more {
                font-size: var(--lotus-font-body-size);
            }

            .lotus-breadcrumb-loose .lotus-breadcrumb-icon {
                font-size: 1.15em;
            }

            .lotus-breadcrumb-popover-list {
                display: flex;
                flex-direction: column;
                gap: 4px;
                min-width: 120px;
            }

            .lotus-breadcrumb-popover-item {
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-breadcrumb-label {
                display: inline-block;
                vertical-align: bottom;
            }

            .lotus-breadcrumb-label-truncate-end {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }
        </style>
    </>
}
