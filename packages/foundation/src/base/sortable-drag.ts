/**
 * 列表拖拽排序的纯算法层：像素位移 → 目标索引换算 + 拖拽状态机。
 * 不依赖任何 DOM API，元素尺寸/位置由调用方（.tsrx 组件）用
 * getBoundingClientRect() 采样后传入。采用 pointer 事件 + CSS transform
 * 位移的技术路线，不使用原生 HTML5 Drag and Drop API——这是 Semi
 * （@dnd-kit/sortable）和参考实现 chenzy.design（自研 pointer 方案）两个
 * 独立实现殊途同归选择的路线，是业界对列表拖拽排序场景的共识做法，不是
 * 各自的权宜之计（详见 Transfer 组件调研报告）。设计为跨组件可复用的
 * 基础能力，不与 Transfer 耦合，后续可排序 List/Table 行等场景直接复用。
 */

export interface ItemRect {
  /** item 在列表中的索引。 */
  index: number;
  /** item 中心点在拖拽轴上的坐标（垂直列表用 top+height/2，水平列表用 left+width/2）。 */
  center: number;
}

export interface SortableDragState {
  /** 正在拖拽的 item 索引，null 表示未拖拽。 */
  draggingIndex: number | null;
  /** 拖拽起点在轴上的坐标。 */
  startPos: number;
  /** 当前指针在轴上的坐标。 */
  currentPos: number;
}

/** 拖拽偏移量（当前指针位置 - 起点），用于渲染层给被拖拽项加 CSS transform。 */
export function getDragOffset(state: SortableDragState): number {
  if (state.draggingIndex === null) return 0;
  return state.currentPos - state.startPos;
}

/**
 * 根据被拖拽项的实时中心位置和其它各项的静态中心位置，算出应该插入的目标
 * 索引——"当前中心点越过了哪一项的中心线，就该排到那一项的位置"，这是
 * 列表拖拽排序的标准判定方式（对齐 dnd-kit 的 closestCenter 策略思路）。
 */
export function calcTargetIndex(
  draggingIndex: number,
  draggingCenter: number,
  itemRects: ItemRect[],
): number {
  const others = itemRects.filter((r) => r.index !== draggingIndex);
  if (others.length === 0) return draggingIndex;

  // 统计"越过了多少条中心线"：拖拽项原本排在 draggingIndex，向前/向后每
  // 越过一条其它项的中心线，目标索引就相应前移/后移一位。
  let crossedBefore = 0;
  let crossedAfter = 0;
  for (const rect of others) {
    if (rect.index < draggingIndex && draggingCenter < rect.center) crossedBefore++;
    if (rect.index > draggingIndex && draggingCenter > rect.center) crossedAfter++;
  }
  return draggingIndex - crossedBefore + crossedAfter;
}

/** 数组元素从 oldIndex 移到 newIndex（不改变原数组，返回新数组）。 */
export function arrayMove<T>(arr: T[], oldIndex: number, newIndex: number): T[] {
  const next = arr.slice();
  const [moved] = next.splice(oldIndex, 1);
  if (moved !== undefined) next.splice(newIndex, 0, moved);
  return next;
}

// ===================== flex-wrap 多行二维拖拽（TagInput 等标签换行场景） =====================

export interface WrapRect {
  left: number;
  top: number;
  width: number;
  height: number;
}

/**
 * flex-wrap 多行布局下的二维拖拽目标索引：用"最近中心点"（欧几里得距离）
 * 而非 1D 版本的"越过中心线计数"——1D 的中线扫描法在跨行移动时会失效
 * （同一行内左右相邻和跨行的"上一行末尾/下一行开头"在几何上不构成单调
 * 序列），移植自参考实现 chenzy.design 的 computeTargetIndexWrap 纯函数
 * 算法（对齐 dnd-kit closestCenter 策略思路，已用单测验证覆盖同行/跨行/
 * 不等宽列等边界情况）。
 */
export function computeTargetIndexWrap(pointerX: number, pointerY: number, rects: readonly WrapRect[]): number {
  let best = 0;
  let bestDist = Infinity;
  for (let i = 0; i < rects.length; i++) {
    const r = rects[i]!;
    const cx = r.left + r.width / 2;
    const cy = r.top + r.height / 2;
    const dx = pointerX - cx;
    const dy = pointerY - cy;
    const dist = dx * dx + dy * dy;
    if (dist < bestDist) {
      bestDist = dist;
      best = i;
    }
  }
  return best;
}

/**
 * flex-wrap 布局下每一项应该产生的 CSS transform 位移：被拖拽项跟随指针，
 * 其余受影响项精确滑动到"目标邻居的实际矩形位置"（而非 1D 版本的统一轴向
 * 位移）——因为 wrap 布局下每个标签宽度不同，"精确对齐到邻居的真实矩形"
 * 才能在不等宽标签之间正确让位，统一位移量的方案在这里不成立。
 */
export function computeItemTransformsWrap(
  activeIndex: number,
  targetIndex: number,
  pointerDeltaX: number,
  pointerDeltaY: number,
  rects: readonly WrapRect[],
): Array<{ x: number; y: number }> {
  const transforms: Array<{ x: number; y: number }> = rects.map(() => ({ x: 0, y: 0 }));
  if (activeIndex < 0 || activeIndex >= rects.length) return transforms;

  transforms[activeIndex] = { x: pointerDeltaX, y: pointerDeltaY };
  if (targetIndex === activeIndex) return transforms;

  const activeRect = rects[activeIndex]!;
  if (targetIndex > activeIndex) {
    for (let i = activeIndex + 1; i <= targetIndex; i++) {
      const rect = rects[i]!;
      const prevRect = i === activeIndex + 1 ? activeRect : rects[i - 1]!;
      transforms[i] = { x: prevRect.left - rect.left, y: prevRect.top - rect.top };
    }
  } else {
    for (let i = activeIndex - 1; i >= targetIndex; i--) {
      const rect = rects[i]!;
      const nextRect = i === activeIndex - 1 ? activeRect : rects[i + 1]!;
      transforms[i] = { x: nextRect.left - rect.left, y: nextRect.top - rect.top };
    }
  }
  return transforms;
}
