import { track, untrack, effect } from 'ripple';
import { TabsFoundation, type TabsState, type TabItemMeta } from '@lotus/foundation/navigation/tabs';
import { computeOverflowScrollState, resolveScrollToStart, resolveScrollToEnd, type TabItemRect } from '@lotus/foundation/navigation/tabs';
import { Dropdown } from '../../show/dropdown/index.tsrx';
import { DropdownMenu } from '../../show/dropdown/menu.tsrx';
import { DropdownItem } from '../../show/dropdown/item.tsrx';
import { IconChevronLeft, IconChevronRight } from '@lotus/icons';
import { TabsContext, type TabsRegisteredPane } from './tabs-context.js';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export { TabPane } from './pane.tsrx';
export type { TabPaneProps } from './pane.tsrx';

export type TabsType = 'line' | 'card' | 'button';
export type TabsPosition = 'top' | 'left';
export type TabsSize = 'small' | 'medium' | 'large';
export type TabsCollapsible = boolean | 'auto';
export type TabsArrowPosition = 'start' | 'end' | 'both';

export interface TabItem {
    itemKey: string;
    tab?: any;
    disabled?: boolean;
    closable?: boolean;
    icon?: any;
    /** 该面板的内容渲染函数：仅在自己是激活项（或 keepDOM 且曾经激活过）时被调用。 */
    render: () => any;
}

export interface TabsMoreConfig {
    count: number;
    render?: () => any;
}

export interface TabsProps {
    /** 声明式 tab 数组写法；也可以省略此项，改用嵌套的 `<TabPane>` 子组件声明式
     * 写法（二选一，对齐 Radio 既支持 options 也支持 children 的先例）。 */
    tabList?: TabItem[];
    children?: any;
    activeKey?: string;
    defaultActiveKey?: string;
    type?: TabsType;
    tabPosition?: TabsPosition;
    size?: TabsSize;
    /** 未激活的面板是否仍保留在 DOM 中（默认 true，对齐 Semi 默认值，便于配合 CSS 做切换动画）。 */
    keepDOM?: boolean;
    /** 面板内容是否懒挂载：首次激活前不渲染 render()（默认 false）。 */
    lazyRender?: boolean;
    /** 切换面板时是否带过渡动画。 */
    tabPaneMotion?: boolean;
    /** 键盘方向导航切换焦点时是否阻止浏览器自动滚动到目标 tab。 */
    preventScroll?: boolean;
    /** tab 栏是否在放不下时折叠为溢出下拉菜单；`'auto'` 由 ResizeObserver 自动检测换行/溢出。 */
    collapsible?: TabsCollapsible;
    /** 折叠态下，被折叠的 tab 是否收进下拉菜单展示（false 时溢出项直接被截断不可见）。 */
    showRestInDropdown?: boolean;
    /** 溢出下拉菜单的自定义触发内容：数字表示强制折叠的固定数量，对象可自定义渲染。 */
    more?: number | TabsMoreConfig;
    /** 溢出滚动箭头的位置。 */
    arrowPosition?: TabsArrowPosition;
    /** 自定义溢出滚动箭头渲染。 */
    renderArrow?: (direction: 'start' | 'end', onClick: () => void) => any;
    /** 可见/折叠 tab 集合变化时的回调。 */
    onVisibleTabsChange?: (visibleKeys: Set<string>) => void;
    /** 透传给溢出下拉菜单内部 Dropdown 的额外配置。 */
    dropdownProps?: Record<string, any>;
    /** tab 栏右侧额外内容，常用于放置操作按钮。 */
    tabBarExtraContent?: any;
    contentStyle?: Record<string, any>;
    tabBarStyle?: Record<string, any>;
    tabBarClassName?: string;
    onChange?: (activeKey: string) => void;
    onTabClick?: (activeKey: string, event: MouseEvent) => void;
    onTabClose?: (itemKey: string) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function panesFromTabList(tabList: TabItem[]): TabItemMeta[] {
    return tabList.map(({ itemKey, tab, disabled, closable, icon }) => ({ itemKey, tab, disabled, closable, icon }));
}

interface TabButtonProps {
    pane: TabItemMeta;
    displayActiveKey: string;
    closeTabLabel: string;
    onTabClick: (itemKey: string, event: MouseEvent) => void;
    onTabClose: (itemKey: string, event: MouseEvent) => void;
    onKeyDownTab: (itemKey: string, event: KeyboardEvent) => void;
}

/** 单个 tab 按钮渲染，抽成独立组件供 OverflowList 的 visibleItemRenderer/
 * 直接渲染两条路径共用（对齐 Select/Cascader 已验证的同一模式）。 */
function TabButton(&{ pane, displayActiveKey, closeTabLabel, onTabClick, onTabClose, onKeyDownTab }: TabButtonProps) @{
    <div
        id={`lotus-tab-${pane.itemKey}`}
        class={[
            'lotus-tabs-tab',
            displayActiveKey === pane.itemKey ? 'lotus-tabs-tab-active' : '',
            pane.disabled ? 'lotus-tabs-tab-disabled' : '',
        ].filter(Boolean).join(' ')}
        role="tab"
        aria-selected={displayActiveKey === pane.itemKey}
        aria-disabled={!!pane.disabled}
        aria-controls={`lotus-tabpanel-${pane.itemKey}`}
        tabIndex={displayActiveKey === pane.itemKey ? 0 : -1}
        onClick={(event: MouseEvent) => !pane.disabled && onTabClick(pane.itemKey, event)}
        onKeyDown={(event: KeyboardEvent) => !pane.disabled && onKeyDownTab(pane.itemKey, event)}
    >
        @if (pane.icon) {
            <span class="lotus-tabs-tab-icon">{pane.icon}</span>
        }
        <span class="lotus-tabs-tab-label">{pane.tab}</span>
        @if (pane.closable) {
            <span
                class="lotus-tabs-tab-close"
                aria-label={closeTabLabel}
                onClick={(event: MouseEvent) => onTabClose(pane.itemKey, event)}
            >
                ×
            </span>
        }
    </div>
}

interface OverflowRestMenuProps {
    overflowPanes: TabItemMeta[];
    showRestInDropdown: boolean;
    more?: number | TabsMoreConfig;
    dropdownProps?: Record<string, any>;
    closeTabLabel: string;
    onTabClick: (itemKey: string, event: MouseEvent) => void;
}

/** 被滚动隐藏的 tab 集合的下拉菜单入口，对齐 Semi showRestInDropdown 语义：
 * 滚动隐藏不等于不可达，仍可通过下拉菜单直接跳转，不强制用户来回点箭头。 */
function OverflowRestMenu(&{ overflowPanes, showRestInDropdown, more, dropdownProps, closeTabLabel, onTabClick }: OverflowRestMenuProps) @{
    <>
        @if (showRestInDropdown) {
            <Dropdown
                trigger="click"
                position="bottomRight"
                {...(dropdownProps ?? {})}
                render={
                    <DropdownMenu>
                        @for (const pane of overflowPanes; key pane.itemKey) {
                            <DropdownItem disabled={pane.disabled} onClick={(event: MouseEvent) => onTabClick(pane.itemKey, event)}>
                                {pane.tab}
                            </DropdownItem>
                        }
                    </DropdownMenu>
                }
            >
                @if (typeof more === 'object' && more?.render) {
                    <span style="display:contents">{more.render()}</span>
                } @else {
                    <button type="button" class="lotus-tabs-more-trigger" aria-label={closeTabLabel}>
                        <IconChevronRight />
                    </button>
                }
            </Dropdown>
        }
    </>
}

interface TabsArrowButtonProps {
    direction: 'start' | 'end';
    disabled: boolean;
    onClick: () => void;
    renderArrow?: (direction: 'start' | 'end', onClick: () => void) => any;
}

/** 滚动箭头按钮：点击把隐藏在对应方向的最近一项滚动进视口（对齐 Semi
 * TabBar handleArrowClick 的 scrollIntoView 语义，不是把项摘出来隐藏）。
 * 没有内容可滚时禁用但仍占位显示（对齐 Semi renderCollapse 空列表分支）。 */
function TabsArrowButton(&{ direction, disabled, onClick, renderArrow }: TabsArrowButtonProps) @{
    <>
        @if (renderArrow) {
            <span style="display:contents">{renderArrow(direction, onClick)}</span>
        } @else {
            <button
                type="button"
                class={['lotus-tabs-arrow', `lotus-tabs-arrow-${direction}`].join(' ')}
                disabled={disabled}
                onClick={onClick}
            >
                @if (direction === 'start') {
                    <IconChevronLeft />
                } @else {
                    <IconChevronRight />
                }
            </button>
        }
    </>
}

export function Tabs(&{
    tabList,
    children,
    activeKey: activeKeyProp,
    defaultActiveKey,
    type = 'line',
    tabPosition = 'top',
    size = 'large',
    keepDOM = true,
    lazyRender = false,
    tabPaneMotion = true,
    preventScroll = false,
    collapsible = false,
    showRestInDropdown = true,
    more,
    arrowPosition = 'end',
    renderArrow,
    onVisibleTabsChange,
    dropdownProps,
    tabBarExtraContent,
    contentStyle,
    tabBarStyle,
    tabBarClassName,
    onChange,
    onTabClick,
    onTabClose,
    style,
    class: className,
    'aria-label': ariaLabel,
}: TabsProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    // 声明式写法下 TabPane 注册进这个 Map；tabList 数组写法直接转换，
    // 不经过这个 Map（两条数据源互斥，tabList 存在时优先，同 Anchor 的
    // links/AnchorLink 二选一先例）。
    let &[registeredPanes] = track<Map<string, TabsRegisteredPane>>(new Map());

    function registerPane(pane: TabsRegisteredPane) {
        const next = new Map(untrack(() => registeredPanes));
        next.set(pane.itemKey, pane);
        registeredPanes = next;
    }

    function unregisterPane(itemKey: string) {
        const next = new Map(untrack(() => registeredPanes));
        next.delete(itemKey);
        registeredPanes = next;
    }

    let &[panes] = track<TabItemMeta[]>(() => {
        if (tabList) return panesFromTabList(tabList);
        return [...registeredPanes.values()];
    });

    const isControlled = activeKeyProp !== undefined;
    const initialActiveKey = isControlled
        ? activeKeyProp!
        : (defaultActiveKey ?? TabsFoundation.resolveDefaultActiveKey(untrack(() => panes)));

    let &[state] = track<TabsState>({ activeKey: initialActiveKey, panes: untrack(() => panes) });
    // 曾经激活过的 itemKey 集合，用于 lazyRender：一旦渲染过就常驻，不随切换卸载
    // （对齐 Semi TabPane 的 `_active` 语义——懒挂载但挂载后不再卸载）。
    let &[everActivated] = track<Set<string>>(new Set(initialActiveKey ? [initialActiveKey] : []));

    const foundation = new TabsFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TabsState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    // panes 数组变化（tabList prop 变化，或声明式 TabPane 增删）时同步进 state，
    // 供 Foundation 的 handleTabClick/resolveArrowNavigation 读取最新的 pane 列表。
    effect(() => {
        state = { ...untrack(() => state), panes };
    });

    // 受控模式下，视觉激活项直接跟随外部传入的 activeKey，不依赖内部 state.activeKey
    // （同 Switch/Grid 已验证的受控模式范式：Foundation 受控分支不改写 state）。
    let &[displayActiveKey] = track<string>(() => (isControlled ? activeKeyProp! : state.activeKey));

    let &[, tabsContextValue] = track(() => ({
        activeKey: displayActiveKey,
        registerPane,
        unregisterPane,
    }));
    TabsContext.set(tabsContextValue);

    let &[classes] = track<string>(() =>
        [
            'lotus-tabs',
            `lotus-tabs-${type}`,
            `lotus-tabs-${tabPosition}`,
            `lotus-tabs-${size}`,
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const handleTabClick = (itemKey: string, event: MouseEvent) => {
        foundation.handleTabClick(itemKey, isControlled, onChange);
        onTabClick?.(itemKey, event);
        if (!untrack(() => everActivated).has(itemKey)) {
            everActivated = new Set(untrack(() => everActivated)).add(itemKey);
        }
    };

    const handleTabClose = (itemKey: string, event: MouseEvent) => {
        event.stopPropagation();
        onTabClose?.(itemKey);
    };

    const handleKeyDown = (itemKey: string, event: KeyboardEvent) => {
        const isVertical = tabPosition === 'left';
        const nextKey = isVertical
            ? (event.key === 'ArrowDown' ? foundation.resolveArrowNavigation(itemKey, 1)
                : event.key === 'ArrowUp' ? foundation.resolveArrowNavigation(itemKey, -1) : null)
            : (event.key === 'ArrowRight' ? foundation.resolveArrowNavigation(itemKey, 1)
                : event.key === 'ArrowLeft' ? foundation.resolveArrowNavigation(itemKey, -1) : null);

        if (nextKey && nextKey !== itemKey) {
            event.preventDefault();
            handleTabClick(nextKey, event as unknown as MouseEvent);
            queueMicrotask(() => {
                document.getElementById(`lotus-tab-${nextKey}`)?.focus({ preventScroll });
            });
            return;
        }

        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            handleTabClick(itemKey, event as unknown as MouseEvent);
        }
    };

    const shouldRenderPane = (itemKey: string): boolean => {
        if (!lazyRender) return true;
        return untrack(() => everActivated).has(itemKey);
    };

    // ===================== 溢出滚动（collapsible + arrowPosition，对齐 Semi
    // TabBar renderMode="scroll" 语义：tab 栏本身可横向滚动，箭头把滚动位置
    // 移动到下一个隐藏项，不是把溢出项摘掉塞进下拉菜单隐藏） =====================

    let &[shouldCollapseAuto] = track<boolean>(false);
    let &[effectiveCollapsible] = track<boolean>(() => (collapsible === 'auto' ? shouldCollapseAuto : !!collapsible));

    let tabBarNode: HTMLElement | null = null;
    let &[scrollLeft] = track<number>(0);
    let &[viewportWidth] = track<number>(0);
    let &[itemRects] = track<TabItemRect[]>([]);

    function measureItemRects(): TabItemRect[] {
        if (!tabBarNode) return [];
        const scroller = tabBarNode.querySelector('.lotus-tabs-bar-scroller') as HTMLElement | null;
        if (!scroller) return [];
        return panes.map((pane) => {
            // 测量对象是 [data-tab-key] 包裹 span 内部实际渲染的 .lotus-tabs-tab——
            // 包裹 span 是 display:contents（不生成盒子，offsetLeft/offsetWidth
            // 恒为 0，真机验证已确认此坑），必须测量真正参与布局的子元素。
            const wrapper = scroller.querySelector(`[data-tab-key="${CSS.escape(pane.itemKey)}"]`) as HTMLElement | null;
            const el = wrapper?.querySelector('.lotus-tabs-tab') as HTMLElement | null;
            return { itemKey: pane.itemKey, offsetLeft: el?.offsetLeft ?? 0, width: el?.offsetWidth ?? 0 };
        });
    }

    function remeasure() {
        untrack(() => {
            itemRects = measureItemRects();
            if (tabBarNode) {
                viewportWidth = tabBarNode.clientWidth;
                scrollLeft = tabBarNode.querySelector('.lotus-tabs-bar-scroller')?.scrollLeft ?? 0;
            }
        });
    }

    function handleTabBarRef(node: HTMLElement | null) {
        tabBarNode = node;
        if (!node) return;
        remeasure();
        if (typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver(() => {
            remeasure();
            if (collapsible === 'auto' && !untrack(() => shouldCollapseAuto)) {
                const scroller = node.querySelector('.lotus-tabs-bar-scroller') as HTMLElement | null;
                if (scroller && scroller.scrollWidth > scroller.clientWidth + 1) {
                    shouldCollapseAuto = true;
                }
            }
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    function handleScrollerRef(node: HTMLElement | null) {
        if (!node) return;
        const onScroll = () => remeasure();
        node.addEventListener('scroll', onScroll);
        return () => node.removeEventListener('scroll', onScroll);
    }

    let &[overflowState] = track(() => computeOverflowScrollState(itemRects, scrollLeft, viewportWidth));

    function scrollToStart() {
        const scroller = tabBarNode?.querySelector('.lotus-tabs-bar-scroller') as HTMLElement | null;
        const target = resolveScrollToStart(itemRects, overflowState.hiddenStart);
        if (!scroller || target === null) return;
        scroller.scrollTo({ left: target, behavior: 'smooth' });
    }

    function scrollToEnd() {
        const scroller = tabBarNode?.querySelector('.lotus-tabs-bar-scroller') as HTMLElement | null;
        const target = resolveScrollToEnd(itemRects, overflowState.hiddenEnd, viewportWidth);
        if (!scroller || target === null) return;
        scroller.scrollTo({ left: target, behavior: 'smooth' });
    }

    let &[forcedOverflowCount] = track<number>(() => typeof more === 'number' ? more : (typeof more === 'object' ? more.count : 0));
    // 显式指定 more 时，强制把末尾 forcedOverflowCount 个 tab 视为隐藏（不管实际
    // 滚动状态如何），对齐 Semi more 语义——常用于"固定只展示前 N 个，其余一律
    // 收进下拉菜单"的场景，与 collapsible 的按需折叠是两种独立触发路径。
    let &[hiddenEndKeys] = track<string[]>(() => {
        if (forcedOverflowCount > 0) return panes.slice(Math.max(0, panes.length - forcedOverflowCount)).map((p) => p.itemKey);
        return overflowState.hiddenEnd;
    });

    effect(() => {
        const visible = new Set(panes.map((p) => p.itemKey).filter((k) => !overflowState.hiddenStart.includes(k) && !hiddenEndKeys.includes(k)));
        onVisibleTabsChange?.(visible);
    });

    <>
        <div class={classes} style={style} aria-label={ariaLabel}>
            <div
                class={['lotus-tabs-bar', effectiveCollapsible ? 'lotus-tabs-bar-collapsible' : '', tabBarClassName ?? ''].filter(Boolean).join(' ')}
                style={tabBarStyle}
                role="tablist"
                aria-orientation={tabPosition === 'left' ? 'vertical' : 'horizontal'}
                ref={handleTabBarRef}
            >
                @if (effectiveCollapsible) {
                    <>
                    @if (arrowPosition === 'start' || arrowPosition === 'both') {
                        <TabsArrowButton direction="start" renderArrow={renderArrow} disabled={overflowState.hiddenStart.length === 0} onClick={scrollToStart} />
                    }
                    <div class="lotus-tabs-bar-scroller" ref={handleScrollerRef}>
                        @for (const pane of panes; key pane.itemKey) {
                            <span data-tab-key={pane.itemKey} style="display:contents">
                                <TabButton
                                    pane={pane}
                                    displayActiveKey={displayActiveKey}
                                    closeTabLabel={locale.Tabs.closeTab}
                                    onTabClick={handleTabClick}
                                    onTabClose={handleTabClose}
                                    onKeyDownTab={handleKeyDown}
                                />
                            </span>
                        }
                    </div>
                    @if (arrowPosition === 'end' || arrowPosition === 'both') {
                        <TabsArrowButton direction="end" renderArrow={renderArrow} disabled={hiddenEndKeys.length === 0} onClick={scrollToEnd} />
                    }
                    @if (showRestInDropdown && hiddenEndKeys.length > 0) {
                        <OverflowRestMenu
                            overflowPanes={panes.filter((p) => hiddenEndKeys.includes(p.itemKey))}
                            showRestInDropdown={showRestInDropdown}
                            more={more}
                            dropdownProps={dropdownProps}
                            closeTabLabel={locale.Tabs.closeTab}
                            onTabClick={handleTabClick}
                        />
                    }
                    </>
                } @else {
                    @for (const pane of panes; key pane.itemKey) {
                        <TabButton
                            pane={pane}
                            displayActiveKey={displayActiveKey}
                            closeTabLabel={locale.Tabs.closeTab}
                            onTabClick={handleTabClick}
                            onTabClose={handleTabClose}
                            onKeyDownTab={handleKeyDown}
                        />
                    }
                }
                @if (tabBarExtraContent) {
                    <div class="lotus-tabs-bar-extra">{tabBarExtraContent}</div>
                }
            </div>

            <div class="lotus-tabs-content" style={contentStyle}>
                @if (tabList) {
                    @for (const item of tabList; key item.itemKey) {
                        @if (keepDOM) {
                            <div
                                id={`lotus-tabpanel-${item.itemKey}`}
                                class={['lotus-tabs-pane', tabPaneMotion ? 'lotus-tabs-pane-motion' : ''].filter(Boolean).join(' ')}
                                role="tabpanel"
                                aria-hidden={displayActiveKey !== item.itemKey}
                                style={{ display: displayActiveKey === item.itemKey ? '' : 'none' }}
                            >
                                @if (shouldRenderPane(item.itemKey)) {
                                    <{item.render} />
                                }
                            </div>
                        } @else {
                            @if (displayActiveKey === item.itemKey) {
                                <div id={`lotus-tabpanel-${item.itemKey}`} class="lotus-tabs-pane" role="tabpanel">
                                    <{item.render} />
                                </div>
                            }
                        }
                    }
                } @else {
                    <span style="display:contents">{children}</span>
                }
            </div>
        </div>

        <style>
            .lotus-tabs {
                display: flex;
                box-sizing: border-box;
            }

            .lotus-tabs-top {
                flex-direction: column;
            }

            .lotus-tabs-left {
                flex-direction: row;
            }

            .lotus-tabs-bar {
                display: flex;
                gap: var(--lotus-spacing-base);
            }

            .lotus-tabs-top .lotus-tabs-bar {
                flex-direction: row;
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-tabs-left .lotus-tabs-bar {
                flex-direction: column;
                border-inline-end: 1px solid var(--lotus-color-border);
                padding-inline-end: var(--lotus-spacing-base);
                margin-inline-end: var(--lotus-spacing-base);
            }

            .lotus-tabs-tab {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                box-sizing: border-box;
                padding: var(--lotus-spacing-base-tight) var(--lotus-spacing-tight);
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-body-size);
                cursor: pointer;
                user-select: none;
                white-space: nowrap;
            }

            .lotus-tabs-small .lotus-tabs-tab {
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-tight);
                font-size: var(--lotus-font-label-size);
            }

            .lotus-tabs-tab:hover:not(.lotus-tabs-tab-disabled) {
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-tab-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-tabs-line .lotus-tabs-tab-active {
                color: var(--lotus-color-primary);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-tabs-line.lotus-tabs-top .lotus-tabs-tab-active {
                box-shadow: inset 0 -2px 0 0 var(--lotus-color-primary);
            }

            .lotus-tabs-line.lotus-tabs-left .lotus-tabs-tab-active {
                box-shadow: inset 2px 0 0 0 var(--lotus-color-primary);
            }

            .lotus-tabs-card .lotus-tabs-tab {
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small) var(--lotus-border-radius-small) 0 0;
                background: var(--lotus-color-bg-2);
            }

            .lotus-tabs-card .lotus-tabs-tab-active {
                background: var(--lotus-color-bg-1);
                border-bottom-color: transparent;
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-button .lotus-tabs-tab {
                border-radius: var(--lotus-border-radius-full);
                background: transparent;
            }

            .lotus-tabs-button .lotus-tabs-tab-active {
                background: var(--lotus-color-fill-1);
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-tab-close {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-inline-start: 2px;
                opacity: 0.6;
                line-height: 1;
            }

            .lotus-tabs-tab-close:hover {
                opacity: 1;
            }

            .lotus-tabs-content {
                flex: 1;
                min-width: 0;
            }

            .lotus-tabs-pane-motion {
                transition: opacity 0.2s ease;
            }

            .lotus-tabs-bar-collapsible {
                flex-wrap: nowrap;
                overflow: hidden;
                min-width: 0;
                align-items: center;
            }

            .lotus-tabs-bar-scroller {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-base);
                overflow-x: auto;
                overflow-y: hidden;
                scrollbar-width: none;
                min-width: 0;
                flex: 1;
            }

            .lotus-tabs-bar-scroller::-webkit-scrollbar {
                display: none;
            }

            .lotus-tabs-top .lotus-tabs-bar-collapsible .lotus-tabs-bar-scroller {
                flex-direction: row;
            }

            .lotus-tabs-left .lotus-tabs-bar-collapsible .lotus-tabs-bar-scroller {
                flex-direction: column;
                overflow-x: hidden;
                overflow-y: auto;
            }

            .lotus-tabs-arrow {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                padding: 0;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-1);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-tabs-arrow:hover:not(:disabled) {
                color: var(--lotus-color-primary);
            }

            .lotus-tabs-arrow:disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
            }

            .lotus-tabs-more-trigger {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                padding: 0;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-1);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-tabs-more-trigger:hover {
                color: var(--lotus-color-text-0);
            }

            .lotus-tabs-bar-extra {
                margin-inline-start: auto;
                flex-shrink: 0;
            }

            .lotus-tabs-top .lotus-tabs-bar-collapsible {
                flex-direction: row;
            }
        </style>
    </>
}
