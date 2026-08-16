import { track, untrack } from 'ripple';
import {
    NavFoundation,
    normalizeNavItems,
    type NavState,
    type NormalizedNavItem,
    type NavItemInput,
    type ItemKey,
    type NavMode,
    type NavToggleIconPosition,
} from '@lotus/foundation/navigation/nav';
import { NavItem } from './item.tsrx';
import { NavSub } from './sub.tsrx';
import { NavHeader, type NavHeaderProps } from './header.tsrx';
import { NavFooter, type NavFooterProps } from './footer.tsrx';
import { NavContext, type NavContextValue } from './nav-context.js';

export type { NavMode, NavToggleIconPosition, ItemKey, NavItemInput, NormalizedNavItem } from '@lotus/foundation/navigation/nav';
export { NavItem } from './item.tsrx';
export type { NavItemProps } from './item.tsrx';
export { NavSub } from './sub.tsrx';
export type { NavSubProps } from './sub.tsrx';
export { NavHeader } from './header.tsrx';
export type { NavHeaderProps } from './header.tsrx';
export { NavFooter } from './footer.tsrx';
export type { NavFooterProps } from './footer.tsrx';

export interface OnSelectData {
    itemKey: ItemKey;
    selectedKeys: ItemKey[];
    isOpen: boolean;
}

export interface OnOpenChangeData {
    itemKey: ItemKey;
    openKeys: ItemKey[];
    isOpen: boolean;
}

export interface NavProps {
    /** 声明式导航项配置数组，支持字符串简写或对象（含嵌套 `items` 表示子导航）。这是
     * Semi 官方推荐且完整支持的用法，也是 lotus 的首选模式：itemKey→祖先路径映射
     * （`itemKeysMap`）、选中项自动展开祖先 SubNav 等高级联动都基于这份数据计算。
     * 若需要自定义单个节点的渲染，用 `renderItem`。 */
    items?: NavItemInput[];
    /** JSX 组合写法：直接传入 `NavHeader`/`NavItem`/`NavSub`/`NavFooter` 组件作为
     * children（对齐 Semi 的 `<Nav.Item>`/`<Nav.Sub>` 用法，用独立命名导出组件替代
     * `Nav.Xxx` 静态属性——Ripple 没有 children 反射能力，无法运行时挂载子组件）。
     * `items` 与 `children` 二选一，同时传入时 `items` 优先。children 模式下选中项
     * 不会自动展开祖先 SubNav（这份联动依赖 items 数组结构计算 itemKeysMap，children
     * 模式没有这份结构化数据），这是仅支持基础选中/展开/点击的诚实设计取舍。 */
    children?: any;
    mode?: NavMode;
    /** 头部区域配置对象（`{ logo, text, link, ... }`）。lotus 版本只接受 config 对象，
     * 不像 Semi 那样同时接受任意 ReactNode——Ripple 无法在运行时区分"JSX 元素"与
     * "plain object"（JSX children 编译后统一变成渲染函数），这是 Ripple 约束下的诚实
     * 设计取舍。若只需要展示一个 logo，传 `{ logo: <YourLogo /> }` 即可。 */
    header?: NavHeaderProps;
    /** 底部区域配置对象（`{ children, collapseButton, ... }`），设计取舍同 `header`。 */
    footer?: NavFooterProps;
    defaultSelectedKeys?: ItemKey[];
    selectedKeys?: ItemKey[];
    defaultOpenKeys?: ItemKey[];
    openKeys?: ItemKey[];
    defaultIsCollapsed?: boolean;
    isCollapsed?: boolean;
    toggleIconPosition?: NavToggleIconPosition;
    /** 关闭后，垂直模式下子级按 `level` 自定义缩进（用左侧占位图标撑开层级），默认 true（不缩进）。 */
    limitIndent?: boolean;
    /** 自定义单个节点渲染，返回值替换默认的 NavItem/NavSub 渲染。 */
    renderItem?: (item: NormalizedNavItem, level: number) => any;
    /** 包裹每个渲染出的导航节点（NavItem/NavSub），常用于集成路由库的 Link/NavLink 组件——
     * 用 `isSubNav` 区分当前节点是否为 SubNav 标题，`item` 是规范化后的节点数据。 */
    renderWrapper?: (args: { itemElement: any; isSubNav: boolean; isInSubNav: boolean; item: NormalizedNavItem }) => any;
    style?: Record<string, any>;
    bodyStyle?: Record<string, any>;
    class?: string;
    onSelect?: (data: OnSelectData) => void;
    onOpenChange?: (data: OnOpenChangeData) => void;
    onCollapseChange?: (isCollapsed: boolean) => void;
    onClick?: (data: { itemKey: ItemKey; isOpen: boolean }) => void;
}

/**
 * 递归渲染 items 树：每个节点映射为恰好一个 NavItem 或 NavSub，不做条件跳过（对齐
 * Breadcrumb 踩坑 #13 的教训——@for 循环体内让部分项不产生 DOM 在 Ripple 下不可靠）。
 *
 * 必须用 `@{}` 语句容器写法（而非普通 `{ return <>...</>; }`）——组件函数体是普通
 * `return` 时，Ripple 编译器 analyze 阶段判定"是否在组件内"的 `is_inside_component`
 * 检查会漏判，导致 `@for` 的 `key`/`index` 修饰符对应的 TrackedValue unwrap
 * （`_$_.get(pattern)`）被跳过，循环体内 `item.itemKey` 等属性访问全部读到 undefined。
 *
 * 且 `@{}` 语句容器的顶层内容必须显式包一层 `<>...</>` fragment，不能把 `@for` 直接
 * 写在语句容器的顶层——直接写顶层 `@for` 时，函数体确实会执行（console.log 能看到
 * 循环正常跑），但编译产物不会把循环结果挂载到实际 DOM 树上，是彻底静默失败（无编译期
 * /运行时报错）。这两个坑都是真机 console.log 逐层排查实测确认，已记录进
 * specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #16、#17。
 */
function NavItemTree(&{ items, level, isInSubNav, renderItem, renderWrapper }: {
    items: NormalizedNavItem[];
    level: number;
    isInSubNav: boolean;
    renderItem?: (item: NormalizedNavItem, level: number) => any;
    renderWrapper?: NavProps['renderWrapper'];
}) @{
    <>
        @for (const item of items; key item.itemKey) {
            @if (renderItem) {
                <>{renderItem(item, level)}</>
            } @else {
                @if (item.items) {
                    @if (renderWrapper) {
                        <>
                            {renderWrapper({
                                itemElement: (
                                    <NavSub
                                        itemKey={item.itemKey}
                                        text={item.text}
                                        icon={item.icon}
                                        disabled={item.disabled}
                                        indent={item.indent}
                                        level={level}
                                    >
                                        <NavItemTree items={item.items ?? []} level={level + 1} isInSubNav={true} renderItem={renderItem} renderWrapper={renderWrapper} />
                                    </NavSub>
                                ),
                                isSubNav: true,
                                isInSubNav,
                                item,
                            })}
                        </>
                    } @else {
                        <NavSub
                            itemKey={item.itemKey}
                            text={item.text}
                            icon={item.icon}
                            disabled={item.disabled}
                            indent={item.indent}
                            level={level}
                        >
                            <NavItemTree items={item.items ?? []} level={level + 1} isInSubNav={true} renderItem={renderItem} renderWrapper={renderWrapper} />
                        </NavSub>
                    }
                } @else {
                    @if (renderWrapper) {
                        <>
                            {renderWrapper({
                                itemElement: (
                                    <NavItem
                                        itemKey={item.itemKey}
                                        text={item.text}
                                        icon={item.icon}
                                        link={item.link}
                                        disabled={item.disabled}
                                        indent={item.indent}
                                        level={level}
                                        isInSubNav={isInSubNav}
                                    />
                                ),
                                isSubNav: false,
                                isInSubNav,
                                item,
                            })}
                        </>
                    } @else {
                        <NavItem
                            itemKey={item.itemKey}
                            text={item.text}
                            icon={item.icon}
                            link={item.link}
                            disabled={item.disabled}
                            indent={item.indent}
                            level={level}
                            isInSubNav={isInSubNav}
                        />
                    }
                }
            }
        }
    </>
}

export function Nav(&{
    items = [],
    children,
    mode = 'vertical',
    header,
    footer,
    defaultSelectedKeys,
    selectedKeys: selectedKeysProp,
    defaultOpenKeys,
    openKeys: openKeysProp,
    defaultIsCollapsed = false,
    isCollapsed: isCollapsedProp,
    toggleIconPosition = 'right',
    limitIndent = true,
    renderItem,
    renderWrapper,
    style,
    bodyStyle,
    class: className,
    onSelect,
    onOpenChange,
    onCollapseChange,
    onClick,
}: NavProps) @{
    const isSelectedKeysControlled = selectedKeysProp !== undefined;
    const isOpenKeysControlled = openKeysProp !== undefined;
    const isCollapsedControlled = isCollapsedProp !== undefined;

    let &[normalizedItems] = track(() => normalizeNavItems(items));
    let &[itemKeysMap] = track(() => NavFoundation.buildItemKeysMap(normalizedItems));

    const initialSelectedKeys = selectedKeysProp ?? defaultSelectedKeys ?? [];
    const ancestorOpenKeys = NavFoundation.resolveAncestorOpenKeys(itemKeysMap, initialSelectedKeys);
    const initialOpenKeys = openKeysProp ?? defaultOpenKeys ?? (mode === 'vertical' ? ancestorOpenKeys : []);

    let &[state] = track<NavState>({
        selectedKeys: initialSelectedKeys,
        openKeys: initialOpenKeys,
        isCollapsed: isCollapsedProp ?? defaultIsCollapsed,
    });

    const foundation = new NavFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<NavState>) => { state = { ...state, ...patch }; },
    });

    let &[selectedKeys] = track(() => selectedKeysProp ?? state.selectedKeys);
    let &[openKeys] = track(() => openKeysProp ?? state.openKeys);
    let &[isCollapsed] = track(() => isCollapsedProp ?? state.isCollapsed);

    const handleItemClick = (itemKey: ItemKey) => {
        foundation.handleItemClick(itemKey, isSelectedKeysControlled, onSelect);
        onClick?.({ itemKey, isOpen: true });
    };

    const handleSubNavToggle = (itemKey: ItemKey) => {
        foundation.handleSubNavToggle(itemKey, isOpenKeysControlled, onOpenChange);
        onClick?.({ itemKey, isOpen: !openKeys.includes(itemKey) });
    };

    const handleCollapseToggle = () => {
        foundation.handleCollapseToggle(isCollapsedControlled, onCollapseChange);
    };

    let &[, contextTracked] = track<NavContextValue>(() => ({
        mode,
        isCollapsed,
        selectedKeys,
        openKeys,
        toggleIconPosition,
        limitIndent,
        isInSubNav: false,
        onItemClick: handleItemClick,
        onSubNavToggle: handleSubNavToggle,
        onCollapseToggle: handleCollapseToggle,
    }));
    NavContext.set(contextTracked);

    // 必须用显式 track()（而非普通 const）——见 item.tsrx 踩坑记录（踩坑 #19）。
    let &[classes] = track(() =>
        ['lotus-nav', `lotus-nav-${mode}`, isCollapsed ? 'lotus-nav-collapsed' : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        <nav class={classes} style={style} role="navigation">
            @if (normalizedItems.length > 0) {
                <>
                    @if (header != null) {
                        <NavHeader {...header} />
                    }
                    <div class="lotus-nav-body" style={bodyStyle}>
                        <ul class="lotus-nav-list" role="menu">
                            <NavItemTree items={normalizedItems} level={0} isInSubNav={false} renderItem={renderItem} renderWrapper={renderWrapper} />
                        </ul>
                    </div>
                    @if (footer != null) {
                        <NavFooter {...footer} />
                    }
                </>
            } @else {
                <>{children}</>
            }
        </nav>

        <style>
            .lotus-nav {
                display: flex;
                flex-direction: column;
                background: var(--lotus-color-bg-0);
                box-sizing: border-box;
                height: 100%;
                overflow: hidden;
            }

            .lotus-nav-body {
                flex: 1;
                overflow-y: auto;
                overflow-x: hidden;
            }

            .lotus-nav-list {
                list-style: none;
                margin: 0;
                padding: 4px;
                display: flex;
                flex-direction: column;
                gap: 2px;
            }

            .lotus-nav-horizontal {
                flex-direction: row;
                align-items: center;
                height: 60px;
            }

            .lotus-nav-horizontal .lotus-nav-body {
                flex: 1;
                overflow: visible;
            }

            .lotus-nav-horizontal .lotus-nav-list {
                flex-direction: row;
                align-items: center;
                padding: 0 12px;
            }

            .lotus-nav-collapsed {
                width: 60px;
            }
        </style>
    </>
}
