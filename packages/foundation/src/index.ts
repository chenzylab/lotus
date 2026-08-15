export { Foundation, type Adapter } from './base/adapter.js';
export {
  watchMediaQuery,
  BREAKPOINTS,
  BREAKPOINT_ORDER,
  breakpointMinWidthQuery,
  type MediaQueryHandlers,
  type BreakpointKey,
} from './base/responsive.js';
export {
  calcFloatingStyle,
  type FloatingPosition,
  type FloatingRect,
  type FloatingStyle,
  type CalcFloatingStyleOptions,
} from './base/floating-position.js';
export { ButtonFoundation, type ButtonState } from './basic/button/foundation.js';
export { watchSiderBreakpoints, type SiderBreakpoint } from './basic/layout/foundation.js';
export { SwitchFoundation, type SwitchState } from './input/switch/foundation.js';
export { TabsFoundation, type TabsState, type TabItemMeta } from './navigation/tabs/foundation.js';
export {
  BreadcrumbFoundation,
  type BreadcrumbState,
  type BreadcrumbRoute,
  type NormalizedRoute,
} from './navigation/breadcrumb/foundation.js';
export { AvatarFoundation, type AvatarState } from './show/avatar/foundation.js';
export { TooltipFoundation, type TooltipState, type TooltipTrigger } from './show/tooltip/foundation.js';
