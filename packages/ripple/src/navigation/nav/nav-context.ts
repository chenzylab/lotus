import { Context, type Tracked } from 'ripple';
import type { ItemKey } from '@lotus/foundation/navigation/nav';
import type { NavMode, NavToggleIconPosition } from '@lotus/foundation/navigation/nav';

/**
 * Nav 树形结构下发给所有层级 Item/SubNav 的共享状态。设计参考 Semi nav-context.ts 的
 * 传值范围，用 Ripple 的 Context API 重新表达——必须存 Tracked<NavContextValue> 本身
 * （而非解构出的 plain object），Context.set/get 只做树形作用域值传递，不做响应式包装，
 * 消费方在自己的派生 track 里读取 `.value.xxx` 才能建立正确的响应式依赖（同 Grid RowContext）。
 */
export interface NavContextValue {
  mode: NavMode;
  isCollapsed: boolean;
  selectedKeys: ItemKey[];
  openKeys: ItemKey[];
  toggleIconPosition: NavToggleIconPosition;
  limitIndent: boolean;
  /** 是否处于某个 SubNav 内部（顶层 items 直接渲染时为 false，SubNav 的子孙节点为 true）。 */
  isInSubNav: boolean;
  onItemClick: (itemKey: ItemKey) => void;
  onSubNavToggle: (itemKey: ItemKey) => void;
  onCollapseToggle: () => void;
}

export const NavContext = new Context<Tracked<NavContextValue>>();
