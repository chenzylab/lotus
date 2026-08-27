import { Foundation, type Adapter } from '../../base/adapter.js';

export type ResizeDirection = 'top' | 'right' | 'bottom' | 'left' | 'topRight' | 'bottomRight' | 'bottomLeft' | 'topLeft';

export interface ResizableSize {
  width: number;
  height: number;
}

export interface ResizableState {
  width: number;
  height: number;
  isResizing: boolean;
  direction: ResizeDirection | null;
}

export interface ResizableConstraints {
  minWidth: number;
  minHeight: number;
  maxWidth: number;
  maxHeight: number;
  lockAspectRatio: boolean;
}

/** 拖拽起点快照：记录手柄按下瞬间的指针坐标与容器尺寸，作为后续 delta 计算的基准。 */
interface ResizeOrigin {
  direction: ResizeDirection;
  startX: number;
  startY: number;
  startWidth: number;
  startHeight: number;
}

const HORIZONTAL_LEFT: ResizeDirection[] = ['left', 'topLeft', 'bottomLeft'];
const HORIZONTAL_RIGHT: ResizeDirection[] = ['right', 'topRight', 'bottomRight'];
const VERTICAL_TOP: ResizeDirection[] = ['top', 'topLeft', 'topRight'];
const VERTICAL_BOTTOM: ResizeDirection[] = ['bottom', 'bottomLeft', 'bottomRight'];

/**
 * Resizable 的拖拽状态机：8 方向指针跟踪 + 边界约束 + 可选宽高比锁定。
 * 参考 re-resizable 的方向-delta 计算思路自研（不依赖该库本身，AGENTS.md 第 0 节
 * "基础能力自研"硬性要求），只处理数值坐标，不接触 DOM/事件对象——指针事件的
 * 注册/坐标提取留给 Adapter 层，保持 Foundation 框架无关、可脱离浏览器单测。
 */
export class ResizableFoundation extends Foundation<ResizableState> {
  private origin: ResizeOrigin | null = null;

  constructor(adapter: Adapter<ResizableState>) {
    super(adapter);
  }

  /** 手柄按下：记录起点快照，进入 resizing 态。 */
  onResizeStart(direction: ResizeDirection, pointerX: number, pointerY: number): void {
    const { width, height } = this.getState();
    this.origin = { direction, startX: pointerX, startY: pointerY, startWidth: width, startHeight: height };
    this.setState({ isResizing: true, direction });
  }

  /**
   * 指针移动：按方向计算 delta，应用 min/max 边界约束与可选宽高比锁定，写回新尺寸。
   * 缺少 origin（未先调用 onResizeStart）时是不合法调用，直接忽略。
   */
  onResize(pointerX: number, pointerY: number, constraints: ResizableConstraints): ResizableSize | null {
    if (!this.origin) return null;
    const { direction, startX, startY, startWidth, startHeight } = this.origin;

    const dx = pointerX - startX;
    const dy = pointerY - startY;

    let width = startWidth;
    let height = startHeight;

    if (HORIZONTAL_RIGHT.includes(direction)) {
      width = startWidth + dx;
    } else if (HORIZONTAL_LEFT.includes(direction)) {
      width = startWidth - dx;
    }

    if (VERTICAL_BOTTOM.includes(direction)) {
      height = startHeight + dy;
    } else if (VERTICAL_TOP.includes(direction)) {
      height = startHeight - dy;
    }

    width = clamp(width, constraints.minWidth, constraints.maxWidth);
    height = clamp(height, constraints.minHeight, constraints.maxHeight);

    if (constraints.lockAspectRatio) {
      const ratio = startWidth / startHeight;
      const isHorizontalDrive = HORIZONTAL_LEFT.includes(direction) || HORIZONTAL_RIGHT.includes(direction);
      if (isHorizontalDrive) {
        height = clamp(width / ratio, constraints.minHeight, constraints.maxHeight);
        width = clamp(height * ratio, constraints.minWidth, constraints.maxWidth);
      } else {
        width = clamp(height * ratio, constraints.minWidth, constraints.maxWidth);
        height = clamp(width / ratio, constraints.minHeight, constraints.maxHeight);
      }
    }

    this.setState({ width, height });
    return { width, height };
  }

  /** 指针松开：退出 resizing 态，清空起点快照。 */
  onResizeEnd(): void {
    this.origin = null;
    this.setState({ isResizing: false, direction: null });
  }

  /** 键盘无障碍：聚焦某个方向手柄后按方向键，以固定步长直接调整宽高
   * （没有连续指针坐标可用，不能复用 onResize 的 delta 计算，直接基于当前
   * state 的宽高做一次性加减）。deltaWidth/deltaHeight 由调用方根据按下的
   * 方向键与手柄的 direction 换算好符号后传入（如 left 手柄按 ArrowLeft
   * 应该是宽度增大，对应 deltaWidth 为正）。 */
  resizeByStep(deltaWidth: number, deltaHeight: number, constraints: ResizableConstraints): ResizableSize {
    const { width: currentWidth, height: currentHeight } = this.getState();
    let width = clamp(currentWidth + deltaWidth, constraints.minWidth, constraints.maxWidth);
    let height = clamp(currentHeight + deltaHeight, constraints.minHeight, constraints.maxHeight);

    if (constraints.lockAspectRatio) {
      const ratio = currentWidth / currentHeight;
      if (deltaWidth !== 0) {
        height = clamp(width / ratio, constraints.minHeight, constraints.maxHeight);
        width = clamp(height * ratio, constraints.minWidth, constraints.maxWidth);
      } else if (deltaHeight !== 0) {
        width = clamp(height * ratio, constraints.minWidth, constraints.maxWidth);
        height = clamp(width / ratio, constraints.minHeight, constraints.maxHeight);
      }
    }

    this.setState({ width, height });
    return { width, height };
  }
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
