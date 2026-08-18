import { Foundation, type Adapter } from '../../base/adapter.js';

export interface SpinState {
  loading: boolean;
}

export interface SpinTimers {
  setTimeout: (fn: () => void, ms: number) => number;
  clearTimeout: (handle: number) => void;
}

const DEFAULT_TIMERS: SpinTimers = { setTimeout, clearTimeout };

/**
 * Spin 的 delay 状态机：`spinning=true` 且 `delay>0` 时，不立即显示 loading，
 * 延迟 delay ms 后才切换（避免请求极快完成时的转圈闪烁）；`spinning=false`
 * 或 `delay` 未设置时立即生效。定时器通过构造参数注入（默认用全局
 * setTimeout/clearTimeout），保持可脱离浏览器环境单测。
 */
export class SpinFoundation extends Foundation<SpinState> {
  private timerHandle: number | null = null;
  private timers: SpinTimers;

  constructor(adapter: Adapter<SpinState>, timers: SpinTimers = DEFAULT_TIMERS) {
    super(adapter);
    this.timers = timers;
  }

  /**
   * 根据最新的 spinning/delay props 更新 loading 状态。每次 spinning/delay
   * 变化时由 Adapter 调用；内部会清理上一次挂起的计时器，避免重叠。
   */
  syncFromProps(spinning: boolean, delay: number): void {
    this.clearTimer();

    if (!delay || !spinning) {
      this.setState({ loading: spinning });
      return;
    }

    this.timerHandle = this.timers.setTimeout(() => {
      this.timerHandle = null;
      this.setState({ loading: spinning });
    }, delay);
  }

  destroy(): void {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.timerHandle !== null) {
      this.timers.clearTimeout(this.timerHandle);
      this.timerHandle = null;
    }
  }
}
