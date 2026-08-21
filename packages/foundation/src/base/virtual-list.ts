/**
 * 固定行高虚拟滚动的纯算法层：可见区间计算 + 总高度/偏移量。不依赖 DOM，
 * 容器高度/滚动位置由调用方在 scroll 事件里采样后传入。只做固定行高
 * （不支持可变行高）——这是 Semi（react-window FixedSizeList）和参考实现
 * chenzy.design 两个独立实现都验证过的合理最小范围（详见 Transfer 组件
 * 调研报告），不需要一开始就做可变行高虚拟化。设计为跨组件可复用的基础
 * 能力，不与 Transfer 耦合。
 */

export interface VirtualRange {
  /** 第一个应渲染的 item 索引（含 overscan）。 */
  startIndex: number;
  /** 最后一个应渲染的 item 索引（含 overscan，闭区间）。 */
  endIndex: number;
  /** 列表内容总高度，用于撑开滚动容器。 */
  totalHeight: number;
  /** startIndex 对应的像素偏移量，用于给可见区间的第一项定位。 */
  offsetY: number;
}

export interface VirtualListOptions {
  itemCount: number;
  itemHeight: number;
  containerHeight: number;
  scrollTop: number;
  /** 视口外额外渲染的行数，缓解快速滚动时的白屏闪烁，默认 3。 */
  overscan?: number;
}

/** 根据滚动位置和容器高度算出当前应渲染的行区间。 */
export function calcVirtualRange(options: VirtualListOptions): VirtualRange {
  const { itemCount, itemHeight, containerHeight, scrollTop, overscan = 3 } = options;
  const totalHeight = itemCount * itemHeight;

  if (itemCount === 0 || itemHeight <= 0) {
    return { startIndex: 0, endIndex: -1, totalHeight: 0, offsetY: 0 };
  }

  const rawStart = Math.floor(scrollTop / itemHeight);
  const visibleCount = Math.ceil(containerHeight / itemHeight);

  const startIndex = Math.max(0, rawStart - overscan);
  const endIndex = Math.min(itemCount - 1, rawStart + visibleCount + overscan);

  return { startIndex, endIndex, totalHeight, offsetY: startIndex * itemHeight };
}
