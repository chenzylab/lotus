/**
 * 列宽调整：拖拽列右边界改变宽度，与列表拖拽排序（sortable-drag.ts 的
 * "越过中心线换算目标索引"）是完全不同的算法域——这是"改尺寸"不是
 * "换序"，不应该复用/扩展 sortable-drag.ts（调研已核实 Semi 用的是
 * react-resizable 的 resize-handle 拖边界模式，与列表重排是两个问题）。
 * 核心只是一个 clamp 换算，比拖拽排序简单得多。
 */
export function calcResizedWidth(startWidth: number, deltaX: number, minWidth = 40, maxWidth?: number): number {
  const raw = startWidth + deltaX;
  const clamped = Math.max(minWidth, raw);
  return maxWidth !== undefined ? Math.min(maxWidth, clamped) : clamped;
}
