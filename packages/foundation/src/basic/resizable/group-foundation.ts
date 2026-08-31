/**
 * ResizeGroup 的分栏比例分配算法：纯函数实现，移植自 Semi
 * `semi-foundation/resizable/group/index.ts` 的核心计算逻辑（`initSpace`/
 * `onResizing`/`ensureConstraint`），改写为不依赖 DOM ref 注册的纯函数——
 * Ripple 没有 React 那种"子组件向上注册自己"的机制，Group 侧改为直接接收
 * 一份 items 元信息数组，内部只做百分比计算，不持有任何 DOM 引用。
 */

export interface GroupItemSpec {
  /** 'px'/'%' 固定语义，或纯数字字符串/number 表示按比例分配剩余空间（对齐 Semi defaultSize 三态）。 */
  defaultSize?: string | number;
  /** 百分比（'20%'）或像素（'100px'）字符串，未指定视为 0%。 */
  min?: string;
  /** 百分比或像素字符串，未指定视为 100%。 */
  max?: string;
}

export function getPixelSize(size: string | number | undefined, parentSize: number): number {
  if (size === undefined) return NaN;
  const str = String(size);
  if (str.endsWith('px')) return Number(str.slice(0, -2));
  if (str.endsWith('%')) return (Number(str.slice(0, -1)) / 100) * parentSize;
  return Number(str);
}

/** 初始化各 item 的百分比：固定 px/% 直接换算，纯数字/无单位视为 flex 比例分配剩余空间。 */
export function initializeItemPercents(items: GroupItemSpec[], parentSize: number): number[] {
  const percents = new Array(items.length).fill(0);
  let totalFixedPercent = 0;
  const flexIndices: number[] = [];
  let flexTotal = 0;

  items.forEach((item, index) => {
    const { defaultSize } = item;
    if (defaultSize === undefined) {
      flexIndices.push(index);
      flexTotal += 1;
      return;
    }
    if (typeof defaultSize === 'string' && /^-?\d+(\.\d+)?$/.test(defaultSize)) {
      flexIndices.push(index);
      flexTotal += parseFloat(defaultSize);
      return;
    }
    if (typeof defaultSize === 'number') {
      flexIndices.push(index);
      flexTotal += defaultSize;
      return;
    }
    let percent: number;
    if (defaultSize.endsWith('%')) {
      percent = parseFloat(defaultSize.slice(0, -1));
    } else {
      percent = (parseFloat(defaultSize.replace('px', '')) / parentSize) * 100;
    }
    percents[index] = percent;
    totalFixedPercent += percent;
  });

  // 固定项总和超过 100% 时，剩余给 flex 项预留 10%（对齐 Semi 的兜底策略）。
  const remainingPercent = totalFixedPercent > 100 ? 10 : 100 - totalFixedPercent;
  flexIndices.forEach((index) => {
    const itemDefaultSize = items[index]?.defaultSize;
    const weight = itemDefaultSize === undefined ? 1
      : typeof itemDefaultSize === 'number' ? itemDefaultSize
        : parseFloat(itemDefaultSize);
    percents[index] = flexTotal === 0 ? 0 : (weight / flexTotal) * remainingPercent;
  });

  return percents;
}

/** min/max 是否越界（像素维度，offset 是相邻手柄占据的空间需要预留）。 */
export function violatesConstraint(sizePx: number, min: string | undefined, max: string | undefined, parentSize: number, offset = 0): boolean {
  const minPx = min ? getPixelSize(min, parentSize) : 0;
  const maxPx = max ? getPixelSize(max, parentSize) : parentSize;
  return sizePx < minPx + offset || sizePx > maxPx;
}

/** 把越界的像素尺寸夹回 min/max 范围内。 */
export function clampToConstraint(sizePx: number, min: string | undefined, max: string | undefined, parentSize: number, offset = 0): number {
  const minPx = min ? getPixelSize(min, parentSize) : 0;
  const maxPx = max ? getPixelSize(max, parentSize) : parentSize;
  if (sizePx < minPx + offset) return minPx + offset;
  if (sizePx > maxPx) return maxPx;
  return sizePx;
}

export interface ResizeAdjacentResult {
  lastPercent: number;
  nextPercent: number;
}

/**
 * 拖拽某个 handler：只影响紧邻的前后两个 item，一个变大另一个按相同像素量变小，
 * 越界时把 delta 让给未越界的一侧（对齐 Semi `onResizing` 逻辑）。
 */
export function resizeAdjacentItems(
  lastSizePx: number,
  nextSizePx: number,
  deltaPx: number,
  lastConstraint: { min?: string; max?: string },
  nextConstraint: { min?: string; max?: string },
  parentSize: number,
  lastOffset = 0,
  nextOffset = 0,
): ResizeAdjacentResult {
  let lastNewSize = lastSizePx + deltaPx;
  let nextNewSize = nextSizePx - deltaPx;

  if (violatesConstraint(lastNewSize, lastConstraint.min, lastConstraint.max, parentSize, lastOffset)) {
    lastNewSize = clampToConstraint(lastNewSize, lastConstraint.min, lastConstraint.max, parentSize, lastOffset);
    nextNewSize = lastSizePx + nextSizePx - lastNewSize;
  }
  if (violatesConstraint(nextNewSize, nextConstraint.min, nextConstraint.max, parentSize, nextOffset)) {
    nextNewSize = clampToConstraint(nextNewSize, nextConstraint.min, nextConstraint.max, parentSize, nextOffset);
    lastNewSize = lastSizePx + nextSizePx - nextNewSize;
  }

  return {
    lastPercent: (lastNewSize / parentSize) * 100,
    nextPercent: (nextNewSize / parentSize) * 100,
  };
}
