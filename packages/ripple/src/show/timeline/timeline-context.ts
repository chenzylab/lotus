import { Context, type Tracked } from 'ripple';
import type { TimelineMode } from './index.tsrx';

/**
 * Timeline 下发给 TimelineItem 的共享状态（mode），参考 Nav/Collapse/List 的既有
 * Context 模式。index 由 TimelineItem 自己通过 @for 的 index 修饰符拿到（Ripple
 * 没有 React.Children.map，不能像 Semi 那样在父组件里遍历 children 算 idx），
 * 用于 mode=alternate/center 时的左右交替位置计算。
 */
export interface TimelineContextValue {
  mode: TimelineMode;
}

export const TimelineContext = new Context<Tracked<TimelineContextValue>>();
