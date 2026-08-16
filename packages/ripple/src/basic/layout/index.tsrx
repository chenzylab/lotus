import { track, effect, untrack } from 'ripple';
import { watchSiderBreakpoints, type SiderBreakpoint } from '@lotus/foundation/basic/layout';

export interface LayoutProps {
    children?: any;
    /**
     * 表示子元素里有 Sider，用于决定 flex-direction 是 row（横向，含侧边栏）还是
     * column（纵向，三行布局）。Semi 版本靠 React.Children 反射自动检测子元素类型，
     * Ripple 没有等价的 children 反射能力，因此 lotus 版本把这个 prop 从 Semi 文档里
     * "一般不用指定，仅用于避免 SSR 闪动" 的可选优化项，变成了必需的显式声明——
     * 这是在 Ripple 约束下的诚实设计取舍，不是简化阉割。
     */
    hasSider?: boolean;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
    role?: string;
}

export function Layout(&{ children, hasSider = false, style, class: className, 'aria-label': ariaLabel, role }: LayoutProps) @{
    const classes = ['lotus-layout', hasSider ? 'lotus-layout-has-sider' : '', className ?? ''].filter(Boolean).join(' ');

    <>
        <section class={classes} style={style} aria-label={ariaLabel} role={role}>
            {children}
        </section>

        <style>
            .lotus-layout {
                display: flex;
                flex: auto;
                flex-direction: column;
                box-sizing: border-box;
                min-height: auto;
            }

            .lotus-layout-has-sider {
                flex-direction: row;
            }
        </style>
    </>
}

export interface LayoutSectionProps {
    children?: any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
    role?: string;
}

export function Header(&{ children, style, class: className, 'aria-label': ariaLabel, role }: LayoutSectionProps) @{
    const classes = ['lotus-layout-header', className ?? ''].filter(Boolean).join(' ');
    <>
        <header class={classes} style={style} aria-label={ariaLabel} role={role}>{children}</header>
        <style>
            .lotus-layout-header {
                box-sizing: border-box;
                flex: 0 0 auto;
            }
        </style>
    </>
}

export function Footer(&{ children, style, class: className, 'aria-label': ariaLabel, role }: LayoutSectionProps) @{
    const classes = ['lotus-layout-footer', className ?? ''].filter(Boolean).join(' ');
    <>
        <footer class={classes} style={style} aria-label={ariaLabel} role={role}>{children}</footer>
        <style>
            .lotus-layout-footer {
                box-sizing: border-box;
                flex: 0 0 auto;
            }
        </style>
    </>
}

export function Content(&{ children, style, class: className, 'aria-label': ariaLabel, role }: LayoutSectionProps) @{
    const classes = ['lotus-layout-content', className ?? ''].filter(Boolean).join(' ');
    <>
        <main class={classes} style={style} aria-label={ariaLabel} role={role}>{children}</main>
        <style>
            .lotus-layout-content {
                box-sizing: border-box;
                flex: auto;
                min-height: auto;
            }
        </style>
    </>
}

export interface SiderProps {
    children?: any;
    /** 触发响应式回调的断点集合，可选值 `xs`、`sm`、`md`、`lg`、`xl`、`xxl`。 */
    breakpoint?: SiderBreakpoint[];
    /** 断点命中状态变化时的回调，业务方据此自行决定是否折叠 Sider（组件本身不自动折叠）。 */
    onBreakpoint?: (screen: SiderBreakpoint, matched: boolean) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
    role?: string;
}

export function Sider(&{ children, breakpoint, onBreakpoint, style, class: className, 'aria-label': ariaLabel, role }: SiderProps) @{
    // 只在挂载时注册一次断点订阅、卸载时清理，不依赖任何响应式 state（同 Grid Row 的
    // untrack 范式，详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑记录）。
    effect(() => {
        const cleanup = untrack(() =>
            breakpoint && breakpoint.length > 0
                ? watchSiderBreakpoints(breakpoint, (screen, matched) => onBreakpoint?.(screen, matched))
                : () => undefined,
        );
        return cleanup;
    });

    const classes = ['lotus-layout-sider', className ?? ''].filter(Boolean).join(' ');

    <>
        <aside class={classes} style={style} aria-label={ariaLabel} role={role}>
            <div class="lotus-layout-sider-children">{children}</div>
        </aside>

        <style>
            .lotus-layout-sider {
                position: relative;
                box-sizing: border-box;
                min-width: auto;
            }

            .lotus-layout-sider-children {
                box-sizing: border-box;
                height: 100%;
            }
        </style>
    </>
}
