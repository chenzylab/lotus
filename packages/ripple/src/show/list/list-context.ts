import { Context, type Tracked } from 'ripple';
import type { ListGrid } from './index.tsrx';

/**
 * List 下发给所有 ListItem 的共享状态，设计参考 Nav/Collapse 的既有 Context 模式：
 * List 持有 grid 配置 + onClick/onRightClick 回调，通过 Context 下发给 ListItem，
 * item 自己的同名 prop 优先于 Context（对齐 Semi "item 级覆盖 List 级"的行为）。
 */
export interface ListContextValue {
  grid?: ListGrid;
  onClick?: (event: MouseEvent) => void;
  onRightClick?: (event: MouseEvent) => void;
}

export const ListContext = new Context<Tracked<ListContextValue>>();
