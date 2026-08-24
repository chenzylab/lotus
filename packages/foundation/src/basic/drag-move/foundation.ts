import { Foundation, type Adapter } from '../../base/adapter.js';

export type DragPositionStrategy = 'absolute' | 'relative';

export interface DragMoveState {
  top: number;
  left: number;
  isDragging: boolean;
}

/** 元素/约束容器的几何矩形（对齐 getBoundingClientRect 的最小必要字段）。 */
export interface DragRect {
  left: number;
  top: number;
  right: number;
  bottom: number;
  width: number;
  height: number;
}

/** absolute 策略：约束容器相对于元素 offsetParent 链路累积的偏移起点。 */
export interface AbsoluteConstrainerOrigin {
  offsetParentAccumX: number;
  offsetParentAccumY: number;
  constrainerWidth: number;
  constrainerHeight: number;
  elementWidth: number;
  elementHeight: number;
}

interface MoveRange {
  xMin: number;
  xMax: number;
  yMin: number;
  yMax: number;
}

/** 拖拽起点快照：mousedown 那一刻缓存，全程复用，不在 mousemove 里重新测量
 * （TagInput 组件踩坑 #88 的教训——被拖拽元素一旦叠加了 transform/style.top-left
 * 位移，再次调用 getBoundingClientRect() 读到的是视觉位置而非原始布局位置）。 */
interface DragOrigin {
  positionStrategy: DragPositionStrategy;
  range: MoveRange | null;
  // absolute 策略：鼠标位置相对元素左上角的固定偏移。
  startOffsetX: number;
  startOffsetY: number;
  // relative 策略：鼠标起点与元素当前 top/left 起点，用差值算新位置。
  startClientX: number;
  startClientY: number;
  startLeft: number;
  startTop: number;
}

export function clampValueInRange(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

/**
 * absolute 策略下的可移动范围：约束容器坐标系相对元素 offsetParent 链路的累积偏移
 * （对齐 Semi _calcMoveRange 的 while 循环累加 offsetLeft/offsetTop 语义）。
 */
export function calcMoveRangeAbsolute(origin: AbsoluteConstrainerOrigin): MoveRange {
  const { offsetParentAccumX, offsetParentAccumY, constrainerWidth, constrainerHeight, elementWidth, elementHeight } = origin;
  return {
    xMin: offsetParentAccumX,
    xMax: offsetParentAccumX + constrainerWidth - elementWidth,
    yMin: offsetParentAccumY,
    yMax: offsetParentAccumY + constrainerHeight - elementHeight,
  };
}

/**
 * relative 策略下的可移动范围：约束容器与元素的真实矩形差 + 元素当前 top/left
 * 当前值（对齐 Semi _calcMoveRange relative 分支）。
 */
export function calcMoveRangeRelative(elementRect: DragRect, constrainerRect: DragRect, currentLeft: number, currentTop: number): MoveRange {
  return {
    xMin: currentLeft + constrainerRect.left - elementRect.left,
    xMax: currentLeft + constrainerRect.right - elementRect.right,
    yMin: currentTop + constrainerRect.top - elementRect.top,
    yMax: currentTop + constrainerRect.bottom - elementRect.bottom,
  };
}

/** 计算鼠标移动后的新位置（对齐 Semi _changePos），越界时钳制到 range 内。 */
export function computeNextPosition(
  clientX: number,
  clientY: number,
  origin: DragOrigin,
): { top: number; left: number } {
  const useRelative = origin.positionStrategy === 'relative';
  let left = useRelative
    ? origin.startLeft + clientX - origin.startClientX
    : clientX - origin.startOffsetX;
  let top = useRelative
    ? origin.startTop + clientY - origin.startClientY
    : clientY - origin.startOffsetY;

  if (origin.range) {
    left = clampValueInRange(left, origin.range.xMin, origin.range.xMax);
    top = clampValueInRange(top, origin.range.yMin, origin.range.yMax);
  }

  return { top, left };
}

/**
 * DragMove 状态机：三段式生命周期（onDragStart 缓存起点快照 → onDragMove 纯
 * 计算新位置 → onDragEnd 清理快照），对齐 ResizableFoundation 同构模式——
 * 起点快照留在私有字段而非 state，只有最终结果进 setState，避免引入不必要
 * 的响应式依赖。真实的 DOM 读写（getBoundingClientRect、style.cursor 等）
 * 由 .tsrx 渲染层负责，Foundation 本身不碰 DOM。
 */
export class DragMoveFoundation extends Foundation<DragMoveState> {
  private origin: DragOrigin | null = null;

  constructor(adapter: Adapter<DragMoveState>) {
    super(adapter);
  }

  /**
   * 拖拽开始：缓存起点快照（含约束范围，全程复用不重算）。
   *
   * absolute 策略需要 elementOffsetLeft/elementOffsetTop——必须是
   * `element.offsetLeft`/`offsetTop`（相对 offsetParent 的坐标，与
   * `style.left`/`style.top` 同一坐标系），不能传视口坐标
   * （`getBoundingClientRect().left/top`）：这是排查中定位到的一个真实
   * bug——两者只有当 offsetParent 恰好是视口原点时才相等，一旦页面滚动或
   * offsetParent 不是 body，用视口坐标算出的偏移量写回 style.left 会产生
   * 系统性偏差（e2e 测试连续两段等距拖拽复现：第一段位移 61px 而非预期
   * 20px，第二段却精确是 20px——第一次 mousedown 时的坐标系错位造成的
   * 常数偏移，被第二段的相对位移抵消后才"看起来正确"）。
   * relative 策略需要 currentTop/currentLeft（元素当前的 top/left 值）。
   */
  onDragStart(
    positionStrategy: DragPositionStrategy,
    clientX: number,
    clientY: number,
    elementOffsetLeft: number,
    elementOffsetTop: number,
    range: MoveRange | null,
  ): void {
    const { top, left } = this.getState();
    if (positionStrategy === 'relative') {
      this.origin = {
        positionStrategy,
        range,
        startOffsetX: 0,
        startOffsetY: 0,
        startClientX: clientX,
        startClientY: clientY,
        startLeft: left,
        startTop: top,
      };
    } else {
      this.origin = {
        positionStrategy,
        range,
        startOffsetX: clientX - elementOffsetLeft,
        startOffsetY: clientY - elementOffsetTop,
        startClientX: clientX,
        startClientY: clientY,
        startLeft: left,
        startTop: top,
      };
    }
    this.setState({ isDragging: true });
  }

  /** 拖拽中：纯计算新位置并写回 state；缺少 origin（未先调用 onDragStart）时忽略。 */
  onDragMove(clientX: number, clientY: number): { top: number; left: number } | null {
    if (!this.origin) return null;
    const next = computeNextPosition(clientX, clientY, this.origin);
    this.setState(next);
    return next;
  }

  onDragEnd(): void {
    this.origin = null;
    this.setState({ isDragging: false });
  }
}
