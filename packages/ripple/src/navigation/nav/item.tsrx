import { track, untrack } from 'ripple';
import { Tooltip } from '../../show/tooltip/index.tsrx';
import { NavContext } from './nav-context.js';
import type { ItemKey } from '@lotus/foundation/navigation/nav';

export interface NavItemProps {
    itemKey?: ItemKey;
    text?: any;
    icon?: any;
    link?: string;
    linkOptions?: Record<string, any>;
    disabled?: boolean;
    indent?: boolean;
    level?: number;
    /** 是否处于某个 SubNav 弹层（Popover）内——影响选中态高亮 class 与是否显示折叠态 Tooltip。 */
    isInSubNav?: boolean;
    onMouseEnter?: (event: MouseEvent) => void;
    onMouseLeave?: (event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
}

/** 用于 limitIndent=false 时按层级缩进的占位图标数组，非导出的纯函数（不涉及模板渲染）。 */
function buildPlaceholders(count: number): number[] {
    return Array.from({ length: Math.max(0, count) }, (_, i) => i);
}

/**
 * 必须用 `@{}` 语句容器写法——内部 `@for` 带 `key` 修饰符，普通 `return <>...</>;` 会
 * 触发踩坑 #16（TrackedValue 不会被正确 unwrap）。
 */
function NavItemContent(&{ text, icon, indent, isInSubNav, placeholderCount }: { text: any; icon: any; indent?: boolean; isInSubNav?: boolean; placeholderCount: number }) @{
    const placeholders = buildPlaceholders(placeholderCount);
    <>
        @for (const p of placeholders; key p) {
            <i class="lotus-nav-item-icon" aria-hidden={true} />
        }
        @if (icon != null || indent || isInSubNav) {
            <i class="lotus-nav-item-icon">{icon}</i>
        }
        @if (text != null) {
            <span class="lotus-nav-item-text">{text}</span>
        }
    </>
}

export function NavItem(&{
    itemKey,
    text,
    icon,
    link,
    linkOptions,
    disabled = false,
    indent = false,
    level = 0,
    isInSubNav = false,
    onMouseEnter,
    onMouseLeave,
    style,
    class: className,
}: NavItemProps) @{
    const contextTracked = NavContext.get();

    let &[isCollapsed] = track(() => contextTracked?.value.isCollapsed ?? false);
    let &[selectedKeys] = track(() => contextTracked?.value.selectedKeys ?? []);
    let &[mode] = track(() => contextTracked?.value.mode ?? 'vertical');
    let &[limitIndent] = track(() => contextTracked?.value.limitIndent ?? true);

    let &[selected] = track(() => itemKey != null && selectedKeys.includes(itemKey));

    // limitIndent=false 时垂直模式下按 level 用占位图标撑开缩进（对齐 Semi 的设计意图）。
    // icon 存在且不需要 indent 占位时，从 level 个占位符起（图标本身占一级）；否则
    // level - 1 个（indent 占位符已经代表了当前层级）。
    let &[placeholderCount] = track(() => {
        if (mode !== 'vertical' || limitIndent || isCollapsed) return 0;
        return icon != null && !indent ? level : level - 1;
    });

    const handleClick = () => {
        if (disabled || itemKey == null) return;
        const ctx = untrack(() => contextTracked);
        ctx?.value.onItemClick(itemKey);
    };

    const handleKeyPress = (event: KeyboardEvent) => {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            handleClick();
        }
    };

    // 必须用显式 track()（而非普通 const）——tsrx 编译器判定 JSX 属性是否需要生成响应式
    // 更新是纯语法层面的：只有属性表达式里直接出现 track() 解构绑定或 CallExpression 才会
    // 标记为响应式，裸 const（哪怕计算过程读取了 tracked 值）只会在挂载时 set 一次，
    // 之后永远不再更新。真机点击选中项不高亮的踩坑实测确认，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #19。
    let &[classes] = track(() =>
        [
            'lotus-nav-item',
            selected ? 'lotus-nav-item-selected' : '',
            disabled ? 'lotus-nav-item-disabled' : '',
            isCollapsed ? 'lotus-nav-item-collapsed' : '',
            isInSubNav ? 'lotus-nav-item-in-subnav' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[shouldShowTooltip] = track(() => isCollapsed && !isInSubNav);

    <>
        <li
            role="menuitem"
            tabIndex={disabled ? -1 : 0}
            aria-disabled={disabled}
            style={style}
            class={classes}
            onClick={handleClick}
            onMouseEnter={onMouseEnter}
            onMouseLeave={onMouseLeave}
            onKeyDown={handleKeyPress}
        >
            @if (shouldShowTooltip) {
                <Tooltip content={text} position="right" trigger="hover">
                    @if (typeof link === 'string') {
                        <a class="lotus-nav-item-link" href={link} tabIndex={-1} {...(linkOptions ?? {})}>
                            <NavItemContent text={text} icon={icon} indent={indent} isInSubNav={isInSubNav} placeholderCount={placeholderCount} />
                        </a>
                    } @else {
                        <NavItemContent text={text} icon={icon} indent={indent} isInSubNav={isInSubNav} placeholderCount={placeholderCount} />
                    }
                </Tooltip>
            } @else {
                @if (typeof link === 'string') {
                    <a class="lotus-nav-item-link" href={link} tabIndex={-1} {...(linkOptions ?? {})}>
                        <NavItemContent text={text} icon={icon} indent={indent} isInSubNav={isInSubNav} placeholderCount={placeholderCount} />
                    </a>
                } @else {
                    <NavItemContent text={text} icon={icon} indent={indent} isInSubNav={isInSubNav} placeholderCount={placeholderCount} />
                }
            }
        </li>

        <style>
            .lotus-nav-item {
                display: flex;
                align-items: center;
                height: 40px;
                padding: 0 24px;
                box-sizing: border-box;
                cursor: pointer;
                color: var(--lotus-color-text-1);
                white-space: nowrap;
                overflow: hidden;
                list-style: none;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-nav-item:hover {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-nav-item-selected {
                background: var(--lotus-color-primary-light-default);
                color: var(--lotus-color-primary);
                font-weight: var(--lotus-font-weight-semibold);
            }

            .lotus-nav-item-disabled {
                color: var(--lotus-color-disabled-text);
                cursor: not-allowed;
                pointer-events: none;
            }

            .lotus-nav-item-collapsed {
                justify-content: center;
                padding: 0;
            }

            .lotus-nav-item-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 20px;
                height: 20px;
                flex-shrink: 0;
                font-style: normal;
            }

            .lotus-nav-item-collapsed .lotus-nav-item-icon {
                margin: 0;
            }

            .lotus-nav-item-text {
                margin-left: 12px;
                overflow: hidden;
                text-overflow: ellipsis;
            }

            .lotus-nav-item-collapsed .lotus-nav-item-text {
                display: none;
            }

            .lotus-nav-item-link {
                display: flex;
                align-items: center;
                width: 100%;
                height: 100%;
                text-decoration: none;
                color: inherit;
            }
        </style>
    </>
}
