/**
 * 响应式断点检测：基于 `window.matchMedia`，供 Grid/Layout 等组件监听视口变化。
 * 不是组件状态机，不继承 `Foundation<S>`——参照 Semi `registerMediaQuery` 的设计（纯函数式
 * 订阅工具，无内部状态），但重新实现（不搬运代码）。`matchMedia` 是浏览器运行时环境查询 API，
 * 不属于渲染操作，故直接放在 Foundation 层而非 Adapter；SSR/无 window 环境下安全降级为空操作。
 */

export interface MediaQueryHandlers {
  match?: (e: MediaQueryList | MediaQueryListEvent) => void;
  unmatch?: (e: MediaQueryList | MediaQueryListEvent) => void;
  /** 是否在注册时立即以当前匹配状态调用一次 match/unmatch，默认 true。 */
  callOnInit?: boolean;
}

/** 注册一个媒体查询监听，返回取消订阅函数。调用方（Adapter 层）负责在组件卸载时调用返回值清理监听。 */
export function watchMediaQuery(query: string, handlers: MediaQueryHandlers): () => void {
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') {
    return () => undefined;
  }

  const { match, unmatch, callOnInit = true } = handlers;
  const mql = window.matchMedia(query);

  const handleChange = (e: MediaQueryList | MediaQueryListEvent) => {
    if (e.matches) match?.(e);
    else unmatch?.(e);
  };

  if (callOnInit) handleChange(mql);

  mql.addEventListener('change', handleChange);
  return () => mql.removeEventListener('change', handleChange);
}

/**
 * 断点定义（min-width，px）。数值对齐 `@lotus/tokens` 的 `breakpoint` 常量，
 * 此处独立声明是因为 Foundation 层不应依赖 `@lotus/tokens`（避免包间循环耦合可能性），
 * 两处数值变更需同步——若未来出现第三处消费方，再评估是否值得抽一个共享的纯数值包。
 */
export const BREAKPOINTS = {
  sm: 576,
  md: 768,
  lg: 992,
  xl: 1200,
  xxl: 1600,
} as const;

export type BreakpointKey = keyof typeof BREAKPOINTS | 'xs';

/** 按从大到小顺序排列的断点键，用于"取当前视口命中的最大断点"这类判断。 */
export const BREAKPOINT_ORDER: BreakpointKey[] = ['xxl', 'xl', 'lg', 'md', 'sm', 'xs'];

export function breakpointMinWidthQuery(key: keyof typeof BREAKPOINTS): string {
  return `(min-width: ${BREAKPOINTS[key]}px)`;
}
