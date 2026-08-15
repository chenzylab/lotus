import { watchMediaQuery, BREAKPOINTS, type BreakpointKey } from '../../base/responsive.js';

export type SiderBreakpoint = BreakpointKey;

/** `xs` 断点语义特殊（视口本身很小时命中），其余断点复用 `min-width` 语义。 */
function breakpointQuery(key: SiderBreakpoint): string {
  if (key === 'xs') return '(max-width: 575px)';
  return `(min-width: ${BREAKPOINTS[key]}px)`;
}

/**
 * Sider 的响应式断点订阅：为 `breakpoint` 数组里声明的每个断点注册 matchMedia 监听，
 * 命中/不命中都触发 `onBreakpoint(screen, matched)` 回调（对齐 Semi 语义——纯粹的
 * 通知机制，不反过来驱动任何视觉状态，折叠与否完全由业务方在回调里自行决定）。
 * 无内部状态，不继承 Foundation<S>，与 watchMediaQuery 同属"纯函数式订阅工具"定位。
 */
export function watchSiderBreakpoints(
  breakpoints: SiderBreakpoint[],
  onBreakpoint: (screen: SiderBreakpoint, matched: boolean) => void,
): () => void {
  const unsubscribers = breakpoints.map((key) =>
    watchMediaQuery(breakpointQuery(key), {
      match: () => onBreakpoint(key, true),
      unmatch: () => onBreakpoint(key, false),
    }),
  );
  return () => unsubscribers.forEach((unsub) => unsub());
}
