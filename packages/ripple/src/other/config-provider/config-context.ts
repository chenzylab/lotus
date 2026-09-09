import { Context, type Tracked } from 'ripple';
import type { ResponsiveMap, BreakpointScreens, ResponsiveBreakpoint } from '@lotus/foundation/base/responsive';

export type { ResponsiveMap, BreakpointScreens, ResponsiveBreakpoint };

/**
 * ConfigProvider 下发的全局配置。未被 <ConfigProvider> 包裹时 `ConfigContext.get()`
 * 返回 undefined，各消费方自行 fallback（getPopupContainer 缺省用 document.body，
 * timeZone 缺省不做任何时区转换，与本地时间一致）。
 */
export interface ConfigContextValue {
  /** 全局默认的浮层挂载容器，浮层类组件自身未显式传 getPopupContainer 时使用。 */
  getPopupContainer?: () => HTMLElement | null;
  /** 全局默认时区，DatePicker/TimePicker 自身未显式传 timeZone 时使用。 */
  timeZone?: string | number;
  /** 自定义响应式断点媒体查询，未传时使用 DEFAULT_RESPONSIVE_MAP。 */
  responsiveMap: ResponsiveMap;
  /** 是否启用断点监听；默认 false——保持与 Semi 一致的“默认不订阅、按需注册”。 */
  responsiveObserve: boolean;
  /** 当前各断点的匹配状态（未启用 responsiveObserve 时始终全 false）。 */
  screens: BreakpointScreens;
  /** 订阅断点变化；两种重载对齐 Semi：整表回调 / 指定断点回调。 */
  onBreakpoint: {
    (callback: (screens: BreakpointScreens) => void): () => void;
    (breakpoints: ResponsiveBreakpoint[], callback: (screen: ResponsiveBreakpoint, matches: boolean) => void): () => void;
  };
}

export const ConfigContext = new Context<Tracked<ConfigContextValue> | undefined>();
