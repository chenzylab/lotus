import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcFloatingStyle, type FloatingPosition, type FloatingRect, type FloatingStyle } from '../../base/floating-position.js';

export type UserGuideMode = 'popup' | 'modal';

export interface UserGuideStepData {
  target?: (() => Element | null | undefined) | Element | null;
  title?: unknown;
  description?: unknown;
  cover?: unknown;
  showArrow?: boolean;
  spotlightPadding?: number;
  theme?: 'default' | 'primary';
  position?: FloatingPosition;
}

export interface UserGuideState {
  current: number;
}

const DEFAULT_SPOTLIGHT_PADDING = 5;

/** 解出某一步的目标元素：`target` 可以是 Element 直接引用，也可以是惰性函数——每次都
 * 重新求值，不缓存，允许目标元素在步骤之间被重新挂载。对齐 Semi 行为。 */
export function resolveStepTarget(step: UserGuideStepData | undefined): Element | null {
  if (!step || !step.target) return null;
  const target = typeof step.target === 'function' ? step.target() : step.target;
  return target ?? null;
}

/** padding 优先级：step 级 > 全局 prop > 默认值。用 `??` 而非 `||`，
 * 修正 Semi 源码里 `spotlightPadding: 0` 被当作 falsy 吞掉回退到默认值的 bug。
 * 这是唯一权威实现，不像 Semi 那样在 UI 层和 Foundation 各写一遍且行为不一致。 */
export function resolveSpotlightPadding(step: UserGuideStepData | undefined, globalPadding: number | undefined): number {
  return step?.spotlightPadding ?? globalPadding ?? DEFAULT_SPOTLIGHT_PADDING;
}

/** 目标元素视口矩形 + padding，算出高亮框（spotlight）矩形。rect 全 0（如目标元素
 * `display:none`）时按 Semi 行为原样返回，不做额外降级——上层可自行判断是否要隐藏。 */
export function computeSpotlightRect(targetRect: FloatingRect, padding: number): FloatingRect {
  return {
    left: targetRect.left - padding,
    top: targetRect.top - padding,
    right: targetRect.right + padding,
    bottom: targetRect.bottom + padding,
    width: targetRect.width + padding * 2,
    height: targetRect.height + padding * 2,
  };
}

/** 目标元素是否完全在视口内（4 个边界条件），用于判断要不要 scrollIntoView。对齐 Semi。 */
export function isRectInViewport(rect: FloatingRect, viewportWidth: number, viewportHeight: number): boolean {
  return rect.top >= 0 && rect.left >= 0 && rect.bottom <= viewportHeight && rect.right <= viewportWidth;
}

export interface UserGuideFloatingInput {
  spotlightRect: FloatingRect;
  position: FloatingPosition;
  floatingSize: { width: number; height: number };
  spacing?: number;
}

/** popup 模式浮层定位：以高亮框（非目标元素本身）作为虚拟锚点传给共享定位引擎，
 * 箭头指向与镂空区域视觉对齐。直接复用 calcFloatingStyle，不重新实现浮层坐标数学。 */
export function computeUserGuideFloatingStyle(input: UserGuideFloatingInput): FloatingStyle {
  return calcFloatingStyle({
    position: input.position,
    triggerRect: input.spotlightRect,
    floatingSize: input.floatingSize,
    spacing: input.spacing,
  });
}

export interface UserGuideChangeResult {
  current: number;
  /** 本次操作是否已到达"结束"语义（最后一步点下一步/完成）。 */
  finished: boolean;
}

/**
 * 状态机纯函数集合：显式钳制边界（`current` 永远落在 `[0, stepCount - 1]`），修正
 * Semi 源码 `handlePrev` 在 `current===0` 时会算出 `-1` 的边界 bug（Semi 靠"第一步
 * 不渲染上一步按钮"这种脆弱的 UI 层隐式保护，绕过 UI 直接调用会产生非法状态）。
 *
 * `finish`/`skip` 均不修改 `current`——语义上代表"引导流程结束"，由业务方在回调里
 * 自行把 `visible` 设为 false（对齐 Semi 的既有约定，Foundation 不擅自决定隐藏）。
 */
export function computeNext(current: number, stepCount: number): UserGuideChangeResult {
  const isLast = current >= stepCount - 1;
  if (isLast) return { current, finished: true };
  return { current: current + 1, finished: false };
}

export function computePrev(current: number): UserGuideChangeResult {
  const next = Math.max(0, current - 1);
  return { current: next, finished: false };
}

/**
 * 有状态 Foundation：持有 `current`，`isControlled` 由调用方（组件层）判定后传入
 * （Foundation 不读 props，只接受显式参数——对齐 Resizable/Form 等既有组件的模式）。
 */
export class UserGuideFoundation extends Foundation<UserGuideState> {
  constructor(adapter: Adapter<UserGuideState>) {
    super(adapter);
  }

  /** @returns 本次实际生效的新 current；若已在第一步则返回当前值（未变化）。 */
  prev(isControlled: boolean): number {
    const { current } = this.getState();
    const result = computePrev(current);
    if (!isControlled) this.setState({ current: result.current });
    return result.current;
  }

  /** @returns `{ current, finished }`——`finished=true` 表示已是最后一步，`current` 不变。 */
  next(stepCount: number, isControlled: boolean): UserGuideChangeResult {
    const { current } = this.getState();
    const result = computeNext(current, stepCount);
    if (!result.finished && !isControlled) this.setState({ current: result.current });
    return result;
  }

  /** 重新打开引导（`visible: false -> true`）时强制回到第一步，对齐 Semi。 */
  reset(): void {
    this.setState({ current: 0 });
  }
}
