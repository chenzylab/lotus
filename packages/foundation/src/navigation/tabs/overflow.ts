/**
 * Tabs 溢出滚动纯算法：tab 栏本身可横向滚动（对齐 Semi TabBar 的
 * renderMode="scroll" 语义——不是把溢出项直接摘掉塞进下拉菜单隐藏，
 * 而是让它们留在可滚动容器里，通过箭头把滚动位置移动过去）。
 * 只做测量结果的纯计算，不碰 DOM（DOM 测量由 .tsrx 层用
 * getBoundingClientRect/scrollLeft 采样后传入）。
 */

export interface TabItemRect {
  itemKey: string;
  /** 相对滚动容器内容区左边缘的偏移量。 */
  offsetLeft: number;
  width: number;
}

export interface OverflowScrollState {
  /** 完全或部分被裁在可视区左侧之外的 itemKey 列表，从最靠左的开始排列。 */
  hiddenStart: string[];
  /** 完全或部分被裁在可视区右侧之外的 itemKey 列表，从最靠右的开始排列。 */
  hiddenEnd: string[];
}

/**
 * 根据每个 tab 的位置/宽度、当前滚动位置、可视区宽度，算出左右两侧
 * 各自被裁剪掉的 tab key 列表。判定阈值 1px 容差，避免浮点误差导致
 * 刚好贴边的 tab 被误判为隐藏。
 */
export function computeOverflowScrollState(
  items: TabItemRect[],
  scrollLeft: number,
  viewportWidth: number,
): OverflowScrollState {
  const visibleStart = scrollLeft;
  const visibleEnd = scrollLeft + viewportWidth;
  const EPS = 1;

  const hiddenStart: string[] = [];
  const hiddenEnd: string[] = [];

  for (const item of items) {
    const itemEnd = item.offsetLeft + item.width;
    if (itemEnd <= visibleStart + EPS) {
      hiddenStart.push(item.itemKey);
    } else if (item.offsetLeft >= visibleEnd - EPS) {
      hiddenEnd.push(item.itemKey);
    }
  }

  return { hiddenStart, hiddenEnd };
}

/** 点击"向前"箭头后应该滚动到的目标位置：让当前隐藏在左侧、最靠近可视区的
 * 一项完全进入视口左边缘。hiddenStart 为空（无内容可滚）时返回 null。 */
export function resolveScrollToStart(items: TabItemRect[], hiddenStart: string[]): number | null {
  if (hiddenStart.length === 0) return null;
  const targetKey = hiddenStart[hiddenStart.length - 1]!;
  const target = items.find((i) => i.itemKey === targetKey);
  return target ? target.offsetLeft : null;
}

/** 点击"向后"箭头后应该滚动到的目标位置：让当前隐藏在右侧、最靠近可视区的
 * 一项完全进入视口右边缘。hiddenEnd 为空时返回 null。 */
export function resolveScrollToEnd(items: TabItemRect[], hiddenEnd: string[], viewportWidth: number): number | null {
  if (hiddenEnd.length === 0) return null;
  const targetKey = hiddenEnd[0]!;
  const target = items.find((i) => i.itemKey === targetKey);
  if (!target) return null;
  return target.offsetLeft + target.width - viewportWidth;
}
