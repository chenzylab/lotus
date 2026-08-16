import { track, untrack } from 'ripple';
import { Popover } from '../../show/popover/index.tsrx';
import { NavContext, type NavContextValue } from './nav-context.js';
import type { ItemKey } from '@lotus/foundation/navigation/nav';
import { IconChevronDown, IconChevronRight } from '@lotus/icons';

export interface NavSubProps {
    children?: any;
    itemKey?: ItemKey;
    text?: any;
    icon?: any;
    disabled?: boolean;
    indent?: boolean;
    level?: number;
    maxHeight?: number;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
}

/**
 * 必须用 `@{}` 语句容器写法（而非普通 `{ return <>...</>; }`）——踩坑 #20（SSR 下
 * `@if` 条件判断在非 `@{}` 组件函数体内失效），详见 footer.tsrx 的 DefaultCollapseButton
 * 注释与 specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #20。
 */
function SubNavTitleContent(&{ text, icon, indent, isOpen, toggleIconPosition, showChevron, useChevronRight }: { text: any; icon: any; indent?: boolean; isOpen: boolean; toggleIconPosition: string; showChevron: boolean; useChevronRight: boolean }) @{
    <>
        @if (toggleIconPosition === 'left' && showChevron) {
            <i class={['lotus-nav-item-icon', 'lotus-nav-subnav-toggle', !useChevronRight && isOpen ? 'lotus-nav-subnav-toggle-open' : ''].filter(Boolean).join(' ')}>
                @if (useChevronRight) {
                    <IconChevronRight />
                } @else {
                    <IconChevronDown />
                }
            </i>
        }
        @if (icon != null || indent) {
            <i class="lotus-nav-item-icon">{icon}</i>
        }
        @if (text != null) {
            <span class="lotus-nav-item-text">{text}</span>
        }
        @if (toggleIconPosition === 'right' && showChevron) {
            <i class={['lotus-nav-item-icon', 'lotus-nav-subnav-toggle', !useChevronRight && isOpen ? 'lotus-nav-subnav-toggle-open' : ''].filter(Boolean).join(' ')}>
                @if (useChevronRight) {
                    <IconChevronRight />
                } @else {
                    <IconChevronDown />
                }
            </i>
        }
    </>
}

export function NavSub(&{
    children,
    itemKey,
    text,
    icon,
    disabled = false,
    indent = false,
    level = 0,
    maxHeight = 999,
    onMouseEnter,
    onMouseLeave,
    style,
    class: className,
}: NavSubProps) @{
    const contextTracked = NavContext.get();

    let &[isCollapsed] = track(() => contextTracked?.value.isCollapsed ?? false);
    let &[mode] = track(() => contextTracked?.value.mode ?? 'vertical');
    let &[openKeys] = track(() => contextTracked?.value.openKeys ?? []);
    let &[toggleIconPosition] = track(() => contextTracked?.value.toggleIconPosition ?? 'right');
    let &[isInSubNav] = track(() => contextTracked?.value.isInSubNav ?? false);

    let &[isOpen] = track(() => itemKey != null && openKeys.includes(itemKey));

    // SubNav 的子孙需要知道自己身处某个 SubNav 内部（isInSubNav=true），影响子项选中态样式与
    // 折叠态 Tooltip 显示逻辑。Ripple Context 是树形作用域值传递，在这里重新 set 一份
    // 只在当前 SubNav 子树内生效的新值，不影响树外的兄弟节点（同 Grid RowContext 的范式）。
    // 派生 track 表达式内部不能用 untrack 包裹对 contextTracked 的读取——那样会切断对父级
    // Context 变化的响应式依赖，导致子树永远拿着 mount 时刻的旧值（真机实测：选中态点击后
    // 高亮不更新，即本文件的踩坑 #18）。
    let &[, childContextTracked] = track<NavContextValue>(() => ({
        ...(contextTracked?.value as NavContextValue),
        isInSubNav: true,
    }));
    NavContext.set(childContextTracked);

    const handleToggle = () => {
        if (disabled || itemKey == null) return;
        const ctx = untrack(() => contextTracked);
        ctx?.value.onSubNavToggle(itemKey);
    };

    // 必须用显式 track()（而非普通 const）——tsrx 编译器判定 JSX 属性/条件分支是否需要
    // 响应式更新是纯语法层面的，裸 const 只在挂载时求值一次，详见 item.tsrx 里的踩坑记录
    // 与 specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #19。
    let &[usePopover] = track(() => isCollapsed || mode === 'horizontal');
    let &[showChevron] = track(() => (!isCollapsed && mode !== 'horizontal') || (isCollapsed && isInSubNav));
    // 对齐 Semi SubNav.tsx 的 isIconChevronRightShow：折叠态子菜单，或非折叠态下水平模式的
    // 二级子菜单（isInSubNav && horizontal），箭头朝右；其余情况箭头朝下并随展开状态旋转。
    let &[useChevronRight] = track(() => (isCollapsed && isInSubNav) || (!isCollapsed && mode === 'horizontal' && isInSubNav));

    let &[classes] = track(() =>
        [
            'lotus-nav-item',
            'lotus-nav-subnav-title',
            disabled ? 'lotus-nav-item-disabled' : '',
            isCollapsed ? 'lotus-nav-item-collapsed' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <li
            class="lotus-nav-subnav"
            style={style}
            onMouseEnter={onMouseEnter}
            onMouseLeave={onMouseLeave}
        >
            @if (usePopover) {
                <Popover
                    trigger="hover"
                    position={mode === 'horizontal' && !isInSubNav ? 'bottom' : 'rightTop'}
                    content={
                        <ul class="lotus-nav-subnav-popover-list" role="menu">
                            {children}
                        </ul>
                    }
                >
                    <div
                        role="button"
                        tabIndex={disabled ? -1 : 0}
                        aria-disabled={disabled}
                        aria-expanded={isOpen}
                        class={classes}
                    >
                        <SubNavTitleContent text={text} icon={icon} indent={indent} isOpen={isOpen} toggleIconPosition={toggleIconPosition} showChevron={showChevron} useChevronRight={useChevronRight} />
                    </div>
                </Popover>
            } @else {
                <>
                    <div
                        role="button"
                        tabIndex={disabled ? -1 : 0}
                        aria-disabled={disabled}
                        aria-expanded={isOpen}
                        class={classes}
                        onClick={handleToggle}
                    >
                        <SubNavTitleContent text={text} icon={icon} indent={indent} isOpen={isOpen} toggleIconPosition={toggleIconPosition} showChevron={showChevron} useChevronRight={useChevronRight} />
                    </div>
                    @if (isOpen) {
                        <ul class="lotus-nav-subnav-list" style={{ maxHeight: `${maxHeight}px` }} role="menu">
                            {children}
                        </ul>
                    }
                </>
            }
        </li>

        <style>
            .lotus-nav-subnav {
                list-style: none;
            }

            .lotus-nav-subnav-title {
                justify-content: space-between;
            }

            .lotus-nav-subnav-toggle {
                width: 14px;
                height: 14px;
                transition: transform 0.2s ease;
            }

            .lotus-nav-subnav-toggle-open {
                transform: rotate(180deg);
            }

            .lotus-nav-subnav-list {
                list-style: none;
                margin: 0;
                padding: 0;
                overflow: hidden;
            }

            .lotus-nav-subnav-popover-list {
                list-style: none;
                margin: 0;
                padding: 4px;
                min-width: 160px;
            }
        </style>
    </>
}
