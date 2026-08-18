/**
 * 数值插值动画：BackTop 的滚动位置缓动、Progress 的百分比变化动画共用此工具。
 * 不引入第三方动画库（AGENTS.md 第 0 节"基础能力自研"），用 requestAnimationFrame
 * 手写 easeInOutCubic 插值，逻辑量小、无需框架依赖即可脱离浏览器单测（时间函数可注入）。
 */

export type Easing = 'linear' | 'easeInOutCubic';

export interface AnimateValueOptions {
  from: number;
  to: number;
  duration: number;
  easing?: Easing;
  onFrame: (value: number) => void;
  onRest?: () => void;
  /** 时间源注入点，便于单测无需真实等待动画帧；默认 Date.now。 */
  now?: () => number;
  /** 帧调度注入点，默认 requestAnimationFrame；单测传同步 mock 驱动。 */
  raf?: (cb: () => void) => number;
  /** 帧调度取消，默认 cancelAnimationFrame。 */
  cancelRaf?: (handle: number) => void;
}

export interface AnimateValueHandle {
  destroy(): void;
}

const EASINGS: Record<Easing, (t: number) => number> = {
  linear: (t) => t,
  easeInOutCubic: (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2),
};

/** 启动一次数值插值动画，返回可提前销毁的句柄。destroy() 后不再触发任何回调。 */
export function animateValue(options: AnimateValueOptions): AnimateValueHandle {
  const { from, to, duration, easing = 'linear', onFrame, onRest, now = Date.now } = options;
  // raf/cancelRaf 的浏览器全局默认值延迟到实际需要时才读取（duration<=0 分支完全不会用到），
  // 避免在无 DOM 的 Foundation 单测环境（Node）里因为默认参数立即求值而报 ReferenceError。
  const raf = options.raf ?? ((cb: () => void) => requestAnimationFrame(cb));
  const cancelRaf = options.cancelRaf ?? ((handle: number) => cancelAnimationFrame(handle));

  const easingFn = EASINGS[easing];
  const startTime = now();
  let destroyed = false;
  let frameHandle: number | null = null;

  function tick() {
    if (destroyed) return;
    const elapsed = now() - startTime;
    const progress = duration <= 0 ? 1 : Math.min(elapsed / duration, 1);
    const value = from + (to - from) * easingFn(progress);
    onFrame(value);

    if (progress >= 1) {
      onRest?.();
      return;
    }
    frameHandle = raf(tick);
  }

  if (duration <= 0) {
    onFrame(to);
    onRest?.();
  } else {
    frameHandle = raf(tick);
  }

  return {
    destroy() {
      destroyed = true;
      if (frameHandle !== null) cancelRaf(frameHandle);
    },
  };
}

/**
 * 节流（leading + trailing）：距上次触发不足 ms 毫秒时不立即执行，但会
 * 安排一次窗口结束后的补偿调用，保证"最后一次调用的最终状态"总会被
 * 同步——纯 leading-only 节流会丢失窗口内最后一次调用（例如用户滚动
 * 停止的那一刻恰好落在节流窗口内，状态永远不会更新，这在快速连续两次
 * 滚动场景下是真实 bug，不只是测试时序问题，见 specs 踩坑记录）。
 * Anchor/BackTop 的滚动监听共用。
 */
export function throttle<T extends (...args: any[]) => void>(
  fn: T,
  ms: number,
  now: () => number = Date.now,
  setTimeoutFn: (cb: () => void, ms: number) => number = setTimeout,
  clearTimeoutFn: (handle: number) => void = clearTimeout,
): T {
  let last: number | null = null;
  let trailingTimer: number | null = null;
  let trailingArgs: Parameters<T> | null = null;

  return ((...args: Parameters<T>) => {
    const current = now();
    if (last === null || current - last >= ms) {
      last = current;
      fn(...args);
      return;
    }
    trailingArgs = args;
    if (trailingTimer !== null) return;
    const remaining = ms - (current - last);
    trailingTimer = setTimeoutFn(() => {
      trailingTimer = null;
      last = now();
      if (trailingArgs) fn(...trailingArgs);
      trailingArgs = null;
    }, remaining);
  }) as T;
}
