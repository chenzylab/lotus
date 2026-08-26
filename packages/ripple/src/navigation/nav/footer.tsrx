import { track, untrack } from 'ripple';
import { NavContext } from './nav-context.js';
import { IconSidebar } from '@lotus/icons';
import { zhCN, type LocaleShape } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface NavFooterProps {
    children?: any;
    collapseButton?: boolean;
    collapseText?: (collapsed: boolean) => any;
    onClick?: (event: MouseEvent) => void;
    style?: Record<string, any>;
    class?: string;
}

/**
 * 折叠/展开切换按钮的默认 UI，`collapseText` 允许自定义收起/展开态的文案。
 *
 * 必须用 `@{}` 语句容器写法（而非普通 `{ return <JSX>; }`）——这是踩坑 #16 的 SSR
 * 变种：tsrx 编译器判定"是否为组件函数"的门槛（`is_tsrx_component_function`）只认
 * `@{}` 语句容器，普通 `return` 函数体不会被标记为组件。client 端编译器对这类"非组件
 * 但含 JSX 的纯函数"有专门的补偿通道（`jsx_to_tsrx_element` 状态注入），使其表现正常；
 * 但 server 端编译器没有对等的补偿逻辑，导致内部嵌套的 `@if` 条件判断在 SSR 下失效——
 * 即使条件是 `typeof collapseText === 'function'` 这种显式类型判断，SSR 渲染时依然会
 * 无视判断结果直接执行分支内容，导致 `collapseText(isCollapsed)` 在 `collapseText`
 * 为 `undefined` 时被调用，抛出 `TypeError: collapseText is not a function` 且页面
 * 完全空白。真机复现：docs 站（走 SSR）访问 Nav 页面白屏，playground（纯 CSR）完全
 * 正常，两侧行为不一致直接暴露了这个 client/server 编译路径不对称的 bug。详见
 * specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #20。
 */
function DefaultCollapseButton(&{ isCollapsed, collapseText, onToggle, locale }: { isCollapsed: boolean; collapseText?: (collapsed: boolean) => any; onToggle: () => void; locale: LocaleShape }) @{
    const hasCollapseText = typeof collapseText === 'function';
    <button type="button" class="lotus-nav-footer-collapse-btn" aria-label={isCollapsed ? locale.Nav.expandNav : locale.Nav.collapseNav} onClick={onToggle}>
        <IconSidebar />
        @if (hasCollapseText) {
            <span class="lotus-nav-footer-collapse-text">{collapseText?.(isCollapsed)}</span>
        }
    </button>
}

export function NavFooter(&{ children, collapseButton = false, collapseText, onClick, style, class: className }: NavFooterProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const contextTracked = NavContext.get();

    let &[isCollapsed] = track(() => contextTracked?.value.isCollapsed ?? false);
    let &[mode] = track(() => contextTracked?.value.mode ?? 'vertical');

    // 必须用显式 track()（而非普通 const）——见 item.tsrx 踩坑记录（踩坑 #19）。
    let &[classes] = track(() =>
        ['lotus-nav-footer', isCollapsed ? 'lotus-nav-footer-collapsed' : '', className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    const handleToggle = () => {
        const ctx = untrack(() => contextTracked);
        ctx?.value.onCollapseToggle();
    };

    let &[showDefaultCollapseButton] = track(() => children == null && collapseButton && mode !== 'horizontal');

    <>
        <div class={classes} style={style} onClick={onClick}>
            @if (children != null) {
                {children}
            } @else {
                @if (showDefaultCollapseButton) {
                    <DefaultCollapseButton isCollapsed={isCollapsed} collapseText={collapseText} onToggle={handleToggle} locale={locale} />
                }
            }
        </div>

        <style>
            .lotus-nav-footer {
                padding: 12px 24px;
                box-sizing: border-box;
                overflow: hidden;
            }

            .lotus-nav-footer-collapsed {
                padding: 12px;
                display: flex;
                justify-content: center;
            }

            .lotus-nav-footer-collapse-btn {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                padding: 6px;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-nav-footer-collapse-btn:hover {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-nav-footer-collapse-text {
                font-size: var(--lotus-font-body-size);
            }
        </style>
    </>
}
