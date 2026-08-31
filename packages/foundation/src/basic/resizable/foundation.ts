import { Foundation, type Adapter } from '../../base/adapter.js';

export * from './group-foundation.js';

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
  /** 拖动像素与实际尺寸变化的比例，默认 1（对齐 Semi `ratio`）。 */
  ratio?: number;
  /** 容器被 CSS transform scale 缩放时的还原系数，默认 1（对齐 Semi `scale`）。 */
  scale?: number;
  /** 增量对齐步长，默认不启用（对齐 Semi `grid`，[1,1] 等价于不生效）。 */
  grid?: [number, number];
  /** 吸附到指定绝对像素点（对齐 Semi `snap`）。 */
  snap?: { x?: number[]; y?: number[] };
  /** 吸附生效的最小间隙阈值，默认 0 表示总是吸附到最近的 grid/snap 目标（对齐 Semi `snapGap`）。 */
  snapGap?: number;
}

export type ResizeStartCallback = (direction: ResizeDirection, event: MouseEvent) => void;
export type ResizeChangeCallback = (size: ResizableSize, direction: ResizeDirection) => void;

function snapToGrid(value: number, gridSize: number): number {
  return Math.round(value / gridSize) * gridSize;
}

function findNearestSnap(value: number, snapPoints: number[], snapGap: number): number {
  if (snapPoints.length === 0) return value;
  let nearest = snapPoints[0]!;
  let minDistance = Math.abs(value - nearest);
  for (const point of snapPoints) {
    const distance = Math.abs(value - point);
    if (distance < minDistance) {
      nearest = point;
      minDistance = distance;
    }
  }
  return snapGap === 0 || minDistance < snapGap ? nearest : value;
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
    const scale = constraints.scale ?? 1;
    const ratio = constraints.ratio ?? 1;

    const dx = ((pointerX - startX) * ratio) / scale;
    const dy = ((pointerY - startY) * ratio) / scale;

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
      const aspectRatio = startWidth / startHeight;
      const isHorizontalDrive = HORIZONTAL_LEFT.includes(direction) || HORIZONTAL_RIGHT.includes(direction);
      if (isHorizontalDrive) {
        height = clamp(width / aspectRatio, constraints.minHeight, constraints.maxHeight);
        width = clamp(height * aspectRatio, constraints.minWidth, constraints.maxWidth);
      } else {
        width = clamp(height * aspectRatio, constraints.minWidth, constraints.maxWidth);
        height = clamp(width / aspectRatio, constraints.minHeight, constraints.maxHeight);
      }
    }

    const snapGap = constraints.snapGap ?? 0;
    if (constraints.snap?.x) width = findNearestSnap(width, constraints.snap.x, snapGap);
    if (constraints.snap?.y) height = findNearestSnap(height, constraints.snap.y, snapGap);

    if (constraints.grid) {
      const [gridW, gridH] = constraints.grid;
      const griddedWidth = snapToGrid(width, gridW);
      const griddedHeight = snapToGrid(height, gridH);
      width = snapGap === 0 || Math.abs(griddedWidth - width) <= snapGap ? griddedWidth : width;
      height = snapGap === 0 || Math.abs(griddedHeight - height) <= snapGap ? griddedHeight : height;
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
