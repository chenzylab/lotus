/**
 * 浮层定位算法：纯函数式计算触发元素与浮层之间的相对位置，不依赖任何第三方定位库
 * （对齐 AGENTS.md「基础能力自研」条款）。设计参考 Semi TooltipFoundation.calcPosStyle
 * 的思路——用 `position: fixed` + `left/top` + `translate()` 百分比平移，不需要提前
 * 知道浮层自身尺寸即可精确对齐触发元素的十二个基准点；重新设计实现，不搬运代码。
 *
 * 简化范围：只支持 12 种基础 position（不含 Semi 的 4 种 `xxxOver` 边缘变体），
 * `autoAdjustOverflow` 用「原方向空间不足且对侧空间足够则整体翻转」的简化策略
 * （不做 Semi 那种半空间独立判断+两轴分别调整的精细吸附），足够覆盖 Tooltip/Popover/
 * Breadcrumb 等场景的实际需要。
 */

export type FloatingPosition =
  | 'top' | 'topLeft' | 'topRight'
  | 'bottom' | 'bottomLeft' | 'bottomRight'
  | 'left' | 'leftTop' | 'leftBottom'
  | 'right' | 'rightTop' | 'rightBottom';

export interface FloatingRect {
  top: number;
  left: number;
  right: number;
  bottom: number;
  width: number;
  height: number;
}

export interface FloatingStyle {
  position: FloatingPosition;
  left: number;
  top: number;
  transform: string;
  /** `arrowPointAtCenter=false` 时箭头需要偏离浮层中心的百分比（如 `'20%'`），未偏移时为 undefined。 */
  arrowOffsetX?: string;
  arrowOffsetY?: string;
}

/** 触发元素中点/边界基准点 + spacing 间距，算出浮层的 left/top 锚点与 CSS transform 平移量。 */
function calcAnchor(position: FloatingPosition, trigger: FloatingRect, spacing: number): { left: number; top: number; transform: string } {
  const midX = trigger.left + trigger.width / 2;
  const midY = trigger.top + trigger.height / 2;

  switch (position) {
    case 'top':
      return { left: midX, top: trigger.top - spacing, transform: 'translate(-50%, -100%)' };
    case 'topLeft':
      return { left: trigger.left, top: trigger.top - spacing, transform: 'translate(0, -100%)' };
    case 'topRight':
      return { left: trigger.right, top: trigger.top - spacing, transform: 'translate(-100%, -100%)' };
    case 'bottom':
      return { left: midX, top: trigger.bottom + spacing, transform: 'translate(-50%, 0)' };
    case 'bottomLeft':
      return { left: trigger.left, top: trigger.bottom + spacing, transform: 'translate(0, 0)' };
    case 'bottomRight':
      return { left: trigger.right, top: trigger.bottom + spacing, transform: 'translate(-100%, 0)' };
    case 'left':
      return { left: trigger.left - spacing, top: midY, transform: 'translate(-100%, -50%)' };
    case 'leftTop':
      return { left: trigger.left - spacing, top: trigger.top, transform: 'translate(-100%, 0)' };
    case 'leftBottom':
      return { left: trigger.left - spacing, top: trigger.bottom, transform: 'translate(-100%, -100%)' };
    case 'right':
      return { left: trigger.right + spacing, top: midY, transform: 'translate(0, -50%)' };
    case 'rightTop':
      return { left: trigger.right + spacing, top: trigger.top, transform: 'translate(0, 0)' };
    case 'rightBottom':
      return { left: trigger.right + spacing, top: trigger.bottom, transform: 'translate(0, -100%)' };
  }
}

const OPPOSITE: Record<FloatingPosition, FloatingPosition> = {
  top: 'bottom', topLeft: 'bottomLeft', topRight: 'bottomRight',
  bottom: 'top', bottomLeft: 'topLeft', bottomRight: 'topRight',
  left: 'right', leftTop: 'rightTop', leftBottom: 'rightBottom',
  right: 'left', rightTop: 'leftTop', rightBottom: 'leftBottom',
};

function isVerticalAxis(position: FloatingPosition): boolean {
  return position === 'top' || position === 'topLeft' || position === 'topRight'
    || position === 'bottom' || position === 'bottomLeft' || position === 'bottomRight';
}

/**
 * 检测浮层在给定 position 下是否会溢出视口边界（用估算尺寸做保守判断，实际渲染后
 * 浏览器会再做像素级裁剪，这里只需要判断「是否需要翻转到对侧」这一个决策）。
 */
function wouldOverflow(position: FloatingPosition, trigger: FloatingRect, floatingSize: { width: number; height: number }, spacing: number, viewportWidth: number, viewportHeight: number): boolean {
  if (isVerticalAxis(position)) {
    const isTop = position.startsWith('top');
    return isTop ? trigger.top - spacing - floatingSize.height < 0 : trigger.bottom + spacing + floatingSize.height > viewportHeight;
  }
  const isLeft = position.startsWith('left');
  return isLeft ? trigger.left - spacing - floatingSize.width < 0 : trigger.right + spacing + floatingSize.width > viewportWidth;
}

export interface CalcFloatingStyleOptions {
  position: FloatingPosition;
  triggerRect: FloatingRect;
  /** 浮层自身尺寸的估算值（可以是上一次渲染结果，首次渲染前用保守估算）；仅用于溢出判断，不影响最终定位精度（定位本身用 transform 百分比，不依赖精确尺寸）。 */
  floatingSize: { width: number; height: number };
  spacing?: number;
  autoAdjustOverflow?: boolean;
  viewportWidth?: number;
  viewportHeight?: number;
  /**
   * `top`/`bottom`/`left`/`right` 四个居中方向下箭头是否指向 trigger 中心。
   * `true`（默认，对齐 Semi）：浮层本身已居中对齐 trigger，箭头天然在浮层中心，
   * 不需要额外偏移。`false`：箭头挪到 trigger 在视口中更靠近的一侧边缘（对齐
   * Semi `isTriggerNearLeft`/`isTriggerNearTop` 的简化版——只判断 trigger 中点
   * 相对视口中点的左右/上下侧，不做 Semi 那样基于箭头自身宽度的像素级钳制）。
   */
  arrowPointAtCenter?: boolean;
  showArrow?: boolean;
}

/**
 * 计算浮层最终定位样式。`autoAdjustOverflow` 开启时，若首选方向会溢出视口且翻转到
 * 对侧后不会溢出，则采用翻转后的方向；否则保留首选方向（即使仍溢出——交给业务方
 * 通过 `spacing`/自定义 style 处理极端情况，不做过度复杂的多级降级）。
 */
const CENTER_POSITIONS: FloatingPosition[] = ['top', 'bottom', 'left', 'right'];

/**
 * `arrowPointAtCenter=false` 时箭头相对浮层中心的偏移百分比：挪到 trigger
 * 在视口中更靠近的一侧边缘（简化版，不做像素级钳制）。只对居中方向（非
 * Left/Right/Top/Bottom 变体）生效——边缘对齐方向箭头位置由 CSS 固定在角落，
 * 不需要动态偏移。
 */
function calcArrowOffset(position: FloatingPosition, triggerRect: FloatingRect, viewportWidth: number, viewportHeight: number): { arrowOffsetX?: string; arrowOffsetY?: string } {
  if (!CENTER_POSITIONS.includes(position)) return {};
  const midX = triggerRect.left + triggerRect.width / 2;
  const midY = triggerRect.top + triggerRect.height / 2;

  if (position === 'top' || position === 'bottom') {
    const isNearLeft = midX < viewportWidth / 2;
    return { arrowOffsetX: isNearLeft ? '25%' : '75%' };
  }
  const isNearTop = midY < viewportHeight / 2;
  return { arrowOffsetY: isNearTop ? '25%' : '75%' };
}

export function calcFloatingStyle(options: CalcFloatingStyleOptions): FloatingStyle {
  const {
    position,
    triggerRect,
    floatingSize,
    spacing = 8,
    autoAdjustOverflow = true,
    viewportWidth = typeof window !== 'undefined' ? window.innerWidth : 1920,
    viewportHeight = typeof window !== 'undefined' ? window.innerHeight : 1080,
    arrowPointAtCenter = true,
    showArrow = false,
  } = options;

  let finalPosition = position;
  if (autoAdjustOverflow) {
    const overflowsOriginal = wouldOverflow(position, triggerRect, floatingSize, spacing, viewportWidth, viewportHeight);
    if (overflowsOriginal) {
      const opposite = OPPOSITE[position];
      const overflowsOpposite = wouldOverflow(opposite, triggerRect, floatingSize, spacing, viewportWidth, viewportHeight);
      if (!overflowsOpposite) finalPosition = opposite;
    }
  }

  const anchor = calcAnchor(finalPosition, triggerRect, spacing);
  const arrowOffset = showArrow && !arrowPointAtCenter
    ? calcArrowOffset(finalPosition, triggerRect, viewportWidth, viewportHeight)
    : {};
  return { position: finalPosition, left: anchor.left, top: anchor.top, transform: anchor.transform, ...arrowOffset };
}
