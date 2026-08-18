import { Context, type Tracked } from 'ripple';

/**
 * Collapse 下发给所有 CollapsePanel 的共享状态，设计参考 Nav/NavContext 的模式：
 * 父组件持有 activeKeys 状态机 + toggle 回调，子组件（Panel）通过 Context.get()
 * 读取自己是否展开，不需要 Collapse 遍历/读取 children 的 props（Ripple 没有
 * React.Children.map 那类机制，父子协调只能走 Context 或显式数组配置）。
 */
export interface CollapseContextValue {
  activeKeys: Set<string>;
  clickHeaderToExpand: boolean;
  expandIconPosition: 'left' | 'right';
  onToggle: (key: string, event: MouseEvent) => void;
}

export const CollapseContext = new Context<Tracked<CollapseContextValue>>();
