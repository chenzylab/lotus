export type OverflowListCollapseFrom = 'start' | 'end';

export interface OverflowLayoutResult<T> {
  visible: T[];
  overflow: T[];
}

/**
 * 逐项累加宽度，超出容器宽度即停止，对齐 Semi 的线性扫描算法（非二分查找——
 * 每项宽度不均匀，二分在这种非单调分段场景没有意义）。
 *
 * @param items 数据源，顺序与 itemSizes 一一对应
 * @param itemSizes 每项的实测宽度（px），下标与 items 对应
 * @param containerWidth 容器可用宽度（px）
 * @param collapseFrom 从哪一端开始折叠：'end' 保留头部、折叠尾部；'start' 保留尾部、折叠头部
 * @param minVisibleItems 至少保留可见的项数，即便超出容器也强制显示这么多项
 */
export function layoutOverflowList<T>(
  items: T[],
  itemSizes: number[],
  containerWidth: number,
  collapseFrom: OverflowListCollapseFrom = 'end',
  minVisibleItems: number = 0,
): OverflowLayoutResult<T> {
  if (items.length === 0) return { visible: [], overflow: [] };

  const orderedIndices = collapseFrom === 'start'
    ? Array.from({ length: items.length }, (_, i) => items.length - 1 - i)
    : Array.from({ length: items.length }, (_, i) => i);

  let widthSum = 0;
  let visibleCount = 0;
  for (const index of orderedIndices) {
    const size = itemSizes[index] ?? 0;
    widthSum += size;
    if (widthSum > containerWidth && visibleCount >= minVisibleItems) break;
    visibleCount += 1;
  }

  visibleCount = Math.max(visibleCount, Math.min(minVisibleItems, items.length));

  if (collapseFrom === 'start') {
    const splitAt = items.length - visibleCount;
    return { visible: items.slice(splitAt), overflow: items.slice(0, splitAt) };
  }
  return { visible: items.slice(0, visibleCount), overflow: items.slice(visibleCount) };
}

/** 首次渲染前的粗略上限估算，避免一次性渲染过多 DOM 节点（对齐 Semi 的 MINIMUM_HTML_ELEMENT_WIDTH 策略）。 */
export const MINIMUM_ITEM_WIDTH = 4;

export function estimateMaxRenderCount(containerWidth: number, itemCount: number): number {
  if (containerWidth <= 0) return 0;
  return Math.min(itemCount, Math.floor(containerWidth / MINIMUM_ITEM_WIDTH));
}
