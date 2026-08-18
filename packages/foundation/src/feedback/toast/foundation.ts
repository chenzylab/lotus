export type ToastType = 'success' | 'warning' | 'error' | 'info' | 'default';

export interface ToastItem {
  id: string;
  content: any;
  type: ToastType;
  duration: number;
  showClose: boolean;
  icon?: any;
  stack: boolean;
}

export interface ToastListState {
  list: ToastItem[];
}

export interface ToastTimers {
  setTimeout: (fn: () => void, ms: number) => number;
  clearTimeout: (handle: number) => void;
}

// 不能直接写 { setTimeout, clearTimeout }——原生 setTimeout/clearTimeout
// 从 window 上解构剥离后会丢失隐式 this 绑定，浏览器实现内部依赖
// this===window，调用时抛 `TypeError: Illegal invocation`（真机 e2e
// 才会暴露，这两个函数从未在 Node 单测环境的 mock 里复现这个问题）。
const DEFAULT_TIMERS: ToastTimers = {
  setTimeout: (fn, ms) => setTimeout(fn, ms) as unknown as number,
  clearTimeout: (handle) => clearTimeout(handle),
};

/**
 * Toast 队列管理：每条通知有独立的自动关闭计时器（duration 秒后移除）。
 * update() 复用同一 id 时会重启计时器（对齐 Semi 的行为——重复调用同一
 * id 的 Toast 相当于刷新这条通知，不会计时器重叠）。定时器通过构造参数
 * 注入，保持可脱离浏览器环境单测。
 */
export class ToastListFoundation {
  private list: ToastItem[] = [];
  private timers = new Map<string, number>();
  private timerImpl: ToastTimers;
  private onChange: (list: ToastItem[]) => void;

  constructor(onChange: (list: ToastItem[]) => void, timerImpl: ToastTimers = DEFAULT_TIMERS) {
    this.onChange = onChange;
    this.timerImpl = timerImpl;
  }

  getList(): ToastItem[] {
    return this.list;
  }

  add(item: ToastItem): void {
    const existingIndex = this.list.findIndex((t) => t.id === item.id);
    if (existingIndex === -1) {
      this.list = [...this.list, item];
    } else {
      this.list = this.list.map((t, i) => (i === existingIndex ? item : t));
    }
    this.restartTimer(item);
    this.emit();
  }

  remove(id: string): void {
    this.clearTimer(id);
    this.list = this.list.filter((t) => t.id !== id);
    this.emit();
  }

  destroyAll(): void {
    for (const id of this.timers.keys()) this.clearTimer(id);
    this.list = [];
    this.emit();
  }

  private restartTimer(item: ToastItem): void {
    this.clearTimer(item.id);
    if (!item.duration) return;
    const handle = this.timerImpl.setTimeout(() => this.remove(item.id), item.duration * 1000);
    this.timers.set(item.id, handle);
  }

  private clearTimer(id: string): void {
    const handle = this.timers.get(id);
    if (handle !== undefined) {
      this.timerImpl.clearTimeout(handle);
      this.timers.delete(id);
    }
  }

  private emit(): void {
    this.onChange(this.list);
  }
}
