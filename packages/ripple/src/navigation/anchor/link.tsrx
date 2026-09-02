import { track, effect, untrack } from 'ripple';
import { AnchorContext, AnchorLevelContext } from './anchor-context.js';

export interface AnchorLinkProps {
    href: string;
    title?: any;
    disabled?: boolean;
    children?: any;
    class?: string;
    style?: Record<string, any>;
}

/**
 * AnchorLink：Anchor 的声明式子组件写法，还原 Semi `<Anchor><Link href=
 * "#a" title="A"><Link href="#a1" title="A1" /></Link></Anchor>` 的 JSX
 * 嵌套语义。mount 时把自己注册进 AnchorContext（对齐 Form.Field 的
 * registerField 模式——Anchor 需要知道全部 href 列表才能算滚动高亮），
 * unmount 时注销；层级通过 AnchorLevelContext 链式传递给 children 里
 * 嵌套的 AnchorLink（Ripple 无 children 遍历/克隆能力，层级只能靠子
 * 组件自己读祖先 Context 累加，不能像 Semi 那样父组件反向推导）。
 *
 * 只负责注册数据、渲染 children（供更深层嵌套的 AnchorLink 读取
 * level）——不渲染任何可见 DOM，实际的链接可视化完全由 Anchor 根据
 * 注册表统一渲染（同一套渲染逻辑服务 links 数组和声明式两种写法）。
 */
export function AnchorLink(&{ href, title, disabled = false, children, class: className, style }: AnchorLinkProps) @{
    const anchorTracked = AnchorContext.get();
    const levelTracked = AnchorLevelContext.get();
    const level = levelTracked?.value.level ?? 0;
    const parentHref = levelTracked?.value.parentHref ?? null;

    effect(() => {
        untrack(() => anchorTracked?.value.registerLink({ href, title, disabled, level, parentHref }));
        return () => untrack(() => anchorTracked?.value.unregisterLink(href));
    });

    let &[, childLevelContext] = track(() => ({ level: level + 1, parentHref: href }));
    AnchorLevelContext.set(childLevelContext);

    <span class={className} style={{ display: 'contents', ...style }}>{children}</span>
}
