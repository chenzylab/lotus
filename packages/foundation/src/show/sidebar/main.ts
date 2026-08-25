export type SidebarMode = 'main' | 'code' | 'file' | string;

export interface SidebarOption {
  icon?: any;
  name?: string;
  key: string;
}

/**
 * onBackWard 可能返回 Promise（对齐 Semi），调用方需要在 pending 期间忽略
 * 重复触发——这是对 Semi 源码"同步调用不 await、可被连点重复触发"的主动
 * 增强，`isBackWardPending` 是这个防重复触发状态机的唯一读值点。
 */
export function isBackWardPending(status: 'idle' | 'pending'): boolean {
  return status === 'pending';
}
