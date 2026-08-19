import { Foundation, type Adapter } from '../../base/adapter.js';

export interface CarouselState {
  activeIndex: number;
  /** 记录上一次切换的方向，决定 slide 动画走正向还是反向 keyframe。 */
  isReverse: boolean;
}

export interface CarouselTimers {
  setInterval: (fn: () => void, ms: number) => number;
  clearInterval: (handle: number) => void;
}

const DEFAULT_TIMERS: CarouselTimers = {
  setInterval: (fn, ms) => setInterval(fn, ms) as unknown as number,
  clearInterval: (handle) => clearInterval(handle),
};

/** 索引取模，天然支持首尾循环，不需要边界 if 分支。 */
export function getValidIndex(index: number, length: number): number {
  if (length === 0) return 0;
  return ((index % length) + length) % length;
}

export class CarouselFoundation extends Foundation<CarouselState> {
  private timerImpl: CarouselTimers;
  private intervalHandle: number | null = null;

  constructor(adapter: Adapter<CarouselState>, timers: CarouselTimers = DEFAULT_TIMERS) {
    super(adapter);
    this.timerImpl = timers;
  }

  goTo(targetIndex: number, length: number): number {
    const current = this.getState().activeIndex;
    const next = getValidIndex(targetIndex, length);
    this.setState({ activeIndex: next, isReverse: next < current });
    return next;
  }

  next(length: number): number {
    const current = this.getState().activeIndex;
    return this.goTo(current + 1, length);
  }

  prev(length: number): number {
    const current = this.getState().activeIndex;
    const next = getValidIndex(current - 1, length);
    this.setState({ activeIndex: next, isReverse: true });
    return next;
  }

  play(length: number, intervalMs: number): void {
    this.stop();
    if (length <= 1) return;
    this.intervalHandle = this.timerImpl.setInterval(() => {
      this.next(length);
    }, intervalMs);
  }

  stop(): void {
    if (this.intervalHandle !== null) {
      this.timerImpl.clearInterval(this.intervalHandle);
      this.intervalHandle = null;
    }
  }

  destroy(): void {
    this.stop();
  }
}
