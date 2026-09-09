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

export type ScrollAlign = 'auto' | 'smart' | 'center' | 'end' | 'start';

/** 固定行高场景下，算出把第 index 项滚动到可见区间所需的目标 scrollTop。
 * 移植自 react-window List.scrollToItem 的对齐语义（Semi Table 的
 * getVirtualizedListRef 直接透传 react-window 实例给用户调用这个方法，
 * lotus 没有第三方库实例可透传，改为自研同语义的纯函数——align 参数的
 * 行为对照保持一致，供组件层包一层暴露给用户）：
 * - start：目标行顶对齐容器顶
 * - end：目标行底对齐容器底
 * - center：目标行居中
 * - auto：已在可视区间内不滚动，否则滚动最小距离使其可见（等价 smart，
 *   react-window 的 smart 在"简单场景"下退化为 auto 的行为，这里不区分
 *   一屏内/一屏外的额外阈值判断，是被验证过的合理简化）
 */
export function calcScrollToItemTop(
  index: number,
  options: { itemCount: number; itemHeight: number; containerHeight: number; scrollTop: number; align?: ScrollAlign },
): number {
  const { itemCount, itemHeight, containerHeight, scrollTop, align = 'auto' } = options;
  if (itemCount === 0 || itemHeight <= 0) return 0;

  const clampedIndex = Math.max(0, Math.min(itemCount - 1, index));
  const itemTop = clampedIndex * itemHeight;
  const itemBottom = itemTop + itemHeight;
  const maxScrollTop = Math.max(0, itemCount * itemHeight - containerHeight);

  let target: number;
  switch (align) {
    case 'start':
      target = itemTop;
      break;
    case 'end':
      target = itemBottom - containerHeight;
      break;
    case 'center':
      target = itemTop - containerHeight / 2 + itemHeight / 2;
      break;
    case 'auto':
    case 'smart':
    default: {
      if (itemTop >= scrollTop && itemBottom <= scrollTop + containerHeight) {
        target = scrollTop;
      } else if (itemTop < scrollTop) {
        target = itemTop;
      } else {
        target = itemBottom - containerHeight;
      }
      break;
    }
  }

  return Math.max(0, Math.min(maxScrollTop, target));
}
