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
  /** SubNav 悬浮展开浮层（折叠态/水平模式）挂载的目标容器。 */
  getPopupContainer?: () => HTMLElement | null;
  /** 悬浮触发展开的延迟（ms），透传给内部 Popover 的 mouseEnterDelay。 */
  subNavOpenDelay: number;
  /** 悬浮收起的延迟（ms），透传给内部 Popover 的 mouseLeaveDelay。 */
  subNavCloseDelay: number;
  /** 自定义展开图标，替换默认的 IconChevronDown/IconChevronRight。 */
  expandIcon?: any;
  /** 透传给内部 Popover 的额外配置（如 position/spacing 等）。 */
  subDropdownProps?: Record<string, any>;
  /** 展开/收起动画开关。 */
  subNavMotion: boolean;
  /** 折叠态下单项 Tooltip 的显示延迟（ms）。 */
  tooltipShowDelay: number;
  /** 折叠态下单项 Tooltip 的隐藏延迟（ms）。 */
  tooltipHideDelay: number;
}

export const NavContext = new Context<Tracked<NavContextValue>>();
