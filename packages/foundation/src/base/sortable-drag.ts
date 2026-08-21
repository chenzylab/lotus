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
