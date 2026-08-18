export type NotificationPosition = 'top' | 'bottom' | 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight';
export type NotificationType = 'success' | 'warning' | 'error' | 'info' | 'default';

export interface NotificationItem {
  id: string;
  title?: any;
  content: any;
  type: NotificationType;
  position: NotificationPosition;
  duration: number;
  showClose: boolean;
  icon?: any;
}

/**
 * Notification 队列管理：结构与 ToastListFoundation 几乎同构（每条
 * 通知有独立自动关闭计时器，update() 重启计时器），核心差异是新通知
 * 插入队列头部（unshift，对齐 Semi 的行为——最新通知显示在最上面）
 * 而非 Toast 的 push 追加，且需要额外的 position 字段供渲染层分组。
 */
export class NotificationListFoundation {
  private list: NotificationItem[] = [];
  private timers = new Map<string, number>();
  private timerImpl: { setTimeout: (fn: () => void, ms: number) => number; clearTimeout: (handle: number) => void };
  private onChange: (list: NotificationItem[]) => void;

  constructor(
    onChange: (list: NotificationItem[]) => void,
    timerImpl: { setTimeout: (fn: () => void, ms: number) => number; clearTimeout: (handle: number) => void } = {
      setTimeout: (fn, ms) => setTimeout(fn, ms) as unknown as number,
      clearTimeout: (handle) => clearTimeout(handle),
    },
  ) {
    this.onChange = onChange;
    this.timerImpl = timerImpl;
  }

  getList(): NotificationItem[] {
    return this.list;
  }

  add(item: NotificationItem): void {
    const existingIndex = this.list.findIndex((n) => n.id === item.id);
    if (existingIndex === -1) {
      this.list = [item, ...this.list];
    } else {
      this.list = this.list.map((n, i) => (i === existingIndex ? item : n));
    }
    this.restartTimer(item);
    this.emit();
  }

  remove(id: string): void {
    this.clearTimer(id);
    this.list = this.list.filter((n) => n.id !== id);
    this.emit();
  }

  destroyAll(): void {
    for (const id of this.timers.keys()) this.clearTimer(id);
    this.list = [];
    this.emit();
  }

  private restartTimer(item: NotificationItem): void {
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

/** 按 position 把队列分组，供渲染层每个 position 独立生成一个定位容器。 */
export function groupByPosition(list: NotificationItem[]): Record<NotificationPosition, NotificationItem[]> {
  const groups: Record<NotificationPosition, NotificationItem[]> = {
    top: [],
    bottom: [],
    topLeft: [],
    topRight: [],
    bottomLeft: [],
    bottomRight: [],
  };
  for (const item of list) {
    groups[item.position].push(item);
  }
  return groups;
}
