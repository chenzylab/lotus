export interface ScrollListItemData<T = any> {
  value: T;
  text?: string;
  disabled?: boolean;
}

/** 找到几何位置离选择框（中心线）最近的、非 disabled 的项索引。对齐 Semi 的吸附判定：
 * 纯粹的"当前滚动位置下谁离中心线最近"几何比较，与滚动速度/方向无关。
 *
 * @param itemOffsets 每一项相对容器顶部的 offsetTop（px），下标与 items 对应
 * @param itemHeight 单项高度（px），恒定
 * @param scrollTop 容器当前滚动位置（px）
 * @param containerHeight 容器可视高度（px）
 */
export function findNearestIndex<T>(
  items: ScrollListItemData<T>[],
  itemHeight: number,
  scrollTop: number,
  containerHeight: number,
): number {
  if (items.length === 0) return -1;
  const centerOffset = scrollTop + containerHeight / 2;

  let nearestIndex = -1;
  let minDistance = Infinity;
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    if (item?.disabled) continue;
    const itemCenter = i * itemHeight + itemHeight / 2;
    const distance = Math.abs(itemCenter - centerOffset);
    if (distance < minDistance) {
      minDistance = distance;
      nearestIndex = i;
    }
  }
  return nearestIndex;
}

/** 索引对齐后应该滚到的 scrollTop，使该项精确居中。 */
export function getScrollTopForIndex(index: number, itemHeight: number, containerHeight: number): number {
  return index * itemHeight + itemHeight / 2 - containerHeight / 2;
}

export interface CycledListLayout {
  /** 前置补的完整数据副本份数 */
  prependCount: number;
  /** 后置补的完整数据副本份数 */
  appendCount: number;
}

/**
 * circular 模式下，为保证视口滚动范围内不露出空白，需要在原始数据前后各补多少组完整副本。
 * 对齐 Semi 的 shouldAppend/shouldPrepend：按可视区域倍数（ratio）计算最少需要的副本组数。
 */
export function calcCycledListLayout(
  itemCount: number,
  itemHeight: number,
  containerHeight: number,
  ratio: number = 2,
): CycledListLayout {
  if (itemCount === 0) return { prependCount: 0, appendCount: 0 };
  const listHeight = itemCount * itemHeight;
  const visibleRange = containerHeight * ratio;
  const copiesNeeded = Math.max(1, Math.ceil(visibleRange / listHeight));
  return { prependCount: copiesNeeded, appendCount: copiesNeeded };
}

/** circular 模式下，把"渲染副本里的索引"归一化回原始数据数组的索引。 */
export function normalizeIndex(renderedIndex: number, itemCount: number): number {
  if (itemCount === 0) return -1;
  return ((renderedIndex % itemCount) + itemCount) % itemCount;
}
