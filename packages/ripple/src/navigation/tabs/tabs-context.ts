import { Context, type Tracked } from 'ripple';

/**
 * Tabs 根 Context：TabPane 声明式写法下，子组件 mount 时把自己的
 * itemKey/tab/icon/disabled/closable 注册进这里（对齐 Anchor AnchorLink
 * 的 registerLink/unregisterLink 模式），unmount 时注销——Tabs 需要
 * 知道全部 pane 的元数据才能渲染 TabBar。TabPane 自己只负责在自己是
 * activeKey 时渲染 children，不需要向 Tabs 索取渲染函数（与 tabList
 * 数组方案里 `render: () => any` 反过来）。
 */
export interface TabsRegisteredPane {
  itemKey: string;
  tab?: any;
  icon?: any;
  disabled?: boolean;
  closable?: boolean;
}

export interface TabsContextValue {
  activeKey: string;
  registerPane: (pane: TabsRegisteredPane) => void;
  unregisterPane: (itemKey: string) => void;
}

export const TabsContext = new Context<Tracked<TabsContextValue>>();
