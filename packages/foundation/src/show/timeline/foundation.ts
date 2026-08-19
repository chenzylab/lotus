/**
 * Timeline 是纯展示型组件，没有内部状态机，Foundation 层只承载"某个节点
 * 该渲染在左侧还是右侧"这一条与渲染无关的纯函数判定逻辑，移植自 Semi
 * 的 getPosCls 规则。
 */

export type TimelineMode = 'left' | 'right' | 'center' | 'alternate';
export type TimelinePosition = 'left' | 'right';

/**
 * 解析单个节点的最终左右位置：
 * - mode 为 left/right 时，忽略节点自己的 position，统一用 mode 值（对齐 Semi：
 *   这个分支不读 item 的 position，与 center/alternate 分支不同）。
 * - mode 为 center/alternate 时，节点显式 position 优先；否则 alternate 按
 *   index 奇偶交替（偶数在左），center 统一在左。
 */
export function resolvePosition(
  mode: TimelineMode,
  index: number,
  itemPosition: TimelinePosition | undefined,
): TimelinePosition {
  if (mode === 'left' || mode === 'right') return mode;
  if (itemPosition) return itemPosition;
  if (mode === 'alternate') return index % 2 === 0 ? 'left' : 'right';
  return 'left';
}
