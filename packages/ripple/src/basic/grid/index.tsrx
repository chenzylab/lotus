import { track, effect, untrack, Context, type Tracked } from 'ripple';
import { RowFoundation, type RowState, type Breakpoint } from '@lotus/foundation/basic/grid';

export type Gutter = number | Partial<Record<Breakpoint, number>>;

export interface RowProps {
    children?: any;
    align?: 'top' | 'middle' | 'bottom';
    justify?: 'start' | 'end' | 'center' | 'space-around' | 'space-between';
    gutter?: Gutter | [Gutter, Gutter];
    style?: Record<string, any>;
    class?: string;
}

export interface RowContextValue {
    screens: Partial<Record<Breakpoint, boolean>>;
    horizontalGutter: number;
}

/**
 * 存放 Tracked<RowContextValue>（而非解构出的 plain object）——Context.set/get 本身不做任何
 * 响应式包装，只是树形作用域的值传递（见 ripple 源码 runtime/internal/client/context.js），
 * 真正的响应式必须来自值本身是 Tracked 对象，Col 读取 `.value` 才能正确建立依赖追踪。
 * 早期实现误传了解构后的 plain object，导致 Row 断点变化后 Col 不重新渲染，浏览器实测发现，
 * 详见 specs/cross-cutting/foundation-adapter-pattern.md 的踩坑记录。
 */
export const RowContext = new Context<Tracked<RowContextValue>>();

function resolveGutterSide(gutter: Gutter | undefined, screens: Partial<Record<Breakpoint, boolean>>): number {
    if (gutter == null) return 0;
    if (typeof gutter === 'number') return gutter;
    return RowFoundation.resolveResponsiveValue(screens, gutter) ?? 0;
}

export function Row(&{ children, align = 'top', justify = 'start', gutter = 0, style, class: className }: RowProps) @{
    let &[state] = track<RowState>({ screens: { xs: true } });

    const foundation = new RowFoundation({
        // getState 用 untrack 包裹：foundation.init() 内部同步读取 state 只是为了拿当前值做
        // patch 合并，不代表"订阅注册"这个副作用应该依赖 state 本身——否则 init() 内部的首次
        // setState 调用会被外层 effect 追踪为依赖，state 变化触发 effect 重跑 → 重新调用
        // init() → 再次触发 setState → 再次重跑，形成无限更新循环（浏览器实测复现，
        // Ripple 运行时报错 "Maximum update depth exceeded"，详见
        // specs/cross-cutting/foundation-adapter-pattern.md 的踩坑记录）。
        getState: () => untrack(() => state),
        setState: (patch: Partial<RowState>) => { state = { ...state, ...patch }; },
    });

    // 只在挂载时注册一次订阅、卸载时清理，不应对 state 变化产生任何响应式依赖。
    effect(() => {
        const cleanup = untrack(() => foundation.init());
        return cleanup;
    });

    const [horizontalRaw, verticalRaw] = Array.isArray(gutter) ? gutter : [gutter, 0];

    // 派生 track（函数式 track(() => expr)）：函数体内读取 `state.screens` 建立响应式依赖，
    // state 变化（断点命中变化）时自动重新求值。直接在模板作用域内做一次性赋值（`x = {...}`）
    // 只执行一次，不会响应式更新——早期实现误用该写法导致 Row 断点变化后 Col 不重新渲染，
    // 浏览器实测发现，详见 specs/cross-cutting/foundation-adapter-pattern.md 的踩坑记录。
    let &[horizontalGutter] = track<number>(() => resolveGutterSide(horizontalRaw, state.screens));
    let &[verticalGutter] = track<number>(() => resolveGutterSide(verticalRaw, state.screens));
    let &[, contextValueTracked] = track<RowContextValue>(() => ({
        screens: state.screens,
        horizontalGutter: resolveGutterSide(horizontalRaw, state.screens),
    }));
    RowContext.set(contextValueTracked);

    // 用显式 track()（而非普通 const）：tsrx 编译器判定 JSX 属性是否需要响应式更新是纯语法
    // 层面的，即使当前 align/justify/className 均来自 props、不会在本组件生命周期内变化，
    // 裸 const 也是一个潜在地雷——一旦这些 props 未来变成响应式来源就会静默失效，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #19。
    let &[classes] = track(() =>
        ['lotus-row', `lotus-row-align-${align}`, `lotus-row-justify-${justify}`, className ?? '']
            .filter(Boolean)
            .join(' '),
    );

    <>
        <div
            class={classes}
            style={{
                ...style,
                marginLeft: horizontalGutter ? `-${horizontalGutter / 2}px` : '',
                marginRight: horizontalGutter ? `-${horizontalGutter / 2}px` : '',
                rowGap: verticalGutter ? `${verticalGutter}px` : '',
            }}
        >
            {children}
        </div>

        <style>
            .lotus-row {
                display: flex;
                flex-flow: row wrap;
                box-sizing: border-box;
            }

            .lotus-row-align-top {
                align-items: flex-start;
            }

            .lotus-row-align-middle {
                align-items: center;
            }

            .lotus-row-align-bottom {
                align-items: flex-end;
            }

            .lotus-row-justify-start {
                justify-content: flex-start;
            }

            .lotus-row-justify-end {
                justify-content: flex-end;
            }

            .lotus-row-justify-center {
                justify-content: center;
            }

            .lotus-row-justify-space-around {
                justify-content: space-around;
            }

            .lotus-row-justify-space-between {
                justify-content: space-between;
            }
        </style>
    </>
}

export interface ColSize {
    span?: number;
    offset?: number;
    order?: number;
}

export interface ColProps {
    children?: any;
    span?: number;
    offset?: number;
    order?: number;
    /** 栅格向左移动的格数（基于 relative 定位的负向 left 偏移，不影响文档流占位，对齐 Semi 语义）。 */
    pull?: number;
    /** 栅格向右移动的格数（基于 relative 定位的正向 left 偏移，不影响文档流占位，对齐 Semi 语义）。 */
    push?: number;
    xs?: number | ColSize;
    sm?: number | ColSize;
    md?: number | ColSize;
    lg?: number | ColSize;
    xl?: number | ColSize;
    xxl?: number | ColSize;
    style?: Record<string, any>;
    class?: string;
}

function normalizeColSize(value: number | ColSize | undefined): ColSize | undefined {
    if (value == null) return undefined;
    return typeof value === 'number' ? { span: value } : value;
}

function resolveColSize(
    screens: Partial<Record<Breakpoint, boolean>>,
    props: { span?: number; offset?: number; order?: number; xs?: number | ColSize; sm?: number | ColSize; md?: number | ColSize; lg?: number | ColSize; xl?: number | ColSize; xxl?: number | ColSize },
): { span: number; offset: number; order: number | undefined } {
    const responsiveConfig: Partial<Record<Breakpoint, ColSize>> = {};
    const xsSize = normalizeColSize(props.xs);
    const smSize = normalizeColSize(props.sm);
    const mdSize = normalizeColSize(props.md);
    const lgSize = normalizeColSize(props.lg);
    const xlSize = normalizeColSize(props.xl);
    const xxlSize = normalizeColSize(props.xxl);
    if (xsSize) responsiveConfig.xs = xsSize;
    if (smSize) responsiveConfig.sm = smSize;
    if (mdSize) responsiveConfig.md = mdSize;
    if (lgSize) responsiveConfig.lg = lgSize;
    if (xlSize) responsiveConfig.xl = xlSize;
    if (xxlSize) responsiveConfig.xxl = xxlSize;

    const hasResponsiveConfig = Object.keys(responsiveConfig).length > 0;
    const resolved = hasResponsiveConfig
        ? RowFoundation.resolveResponsiveValue(screens, responsiveConfig)
        : undefined;

    return {
        span: resolved?.span ?? props.span ?? 24,
        offset: resolved?.offset ?? props.offset ?? 0,
        order: resolved?.order ?? props.order,
    };
}

export function Col(&{ children, span, offset, order, pull, push, xs, sm, md, lg, xl, xxl, style, class: className }: ColProps) @{
    const contextTracked = RowContext.get();

    // 派生 track：函数体内读取 `contextTracked.value` 建立响应式依赖，Row 断点变化时自动重新
    // 求值。早期实现在这里用普通 const 一次性计算 widthPercent/offsetPercent，只在 Col 函数体
    // 首次求值时执行一次，Row 断点变化后不会重新计算——tsrx 组件的 setup 阶段只跑一次，真正
    // 响应式更新必须来自模板内联表达式或显式的派生 track，浏览器实测发现，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 的踩坑记录。
    let &[resolvedSpan] = track(() => {
        const screens = contextTracked?.value.screens ?? { xs: true };
        return resolveColSize(screens, { span, offset, order, xs, sm, md, lg, xl, xxl }).span;
    });
    let &[widthPercent] = track(() => (resolvedSpan / 24) * 100);
    let &[offsetPercent] = track(() => {
        const screens = contextTracked?.value.screens ?? { xs: true };
        return (resolveColSize(screens, { span, offset, order, xs, sm, md, lg, xl, xxl }).offset / 24) * 100;
    });
    let &[finalOrder] = track(() => {
        const screens = contextTracked?.value.screens ?? { xs: true };
        return resolveColSize(screens, { span, offset, order, xs, sm, md, lg, xl, xxl }).order ?? 0;
    });
    let &[gutterHalf] = track(() => (contextTracked?.value.horizontalGutter ?? 0) / 2);
    const pullPercent = pull ? (pull / 24) * 100 : 0;
    const pushPercent = push ? (push / 24) * 100 : 0;

    // span 为 0 时相当于 display: none（对齐 Semi 语义），不占据栅格空间。
    let &[classes] = track<string>(() =>
        ['lotus-col', resolvedSpan === 0 ? 'lotus-col-hidden' : '', className ?? ''].filter(Boolean).join(' '),
    );

    <>
        <div
            class={classes}
            style={{
                ...style,
                flex: `0 0 ${widthPercent}%`,
                maxWidth: `${widthPercent}%`,
                marginLeft: offsetPercent ? `${offsetPercent}%` : '',
                order: finalOrder,
                paddingLeft: gutterHalf ? `${gutterHalf}px` : '',
                paddingRight: gutterHalf ? `${gutterHalf}px` : '',
                left: pullPercent ? `-${pullPercent}%` : (pushPercent ? `${pushPercent}%` : ''),
                position: (pullPercent || pushPercent) ? 'relative' : '',
            }}
        >
            {children}
        </div>

        <style>
            .lotus-col {
                box-sizing: border-box;
            }

            .lotus-col-hidden {
                display: none;
            }
        </style>
    </>
}
