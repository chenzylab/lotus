export type PageListItem = number | '...';

export interface PageListResult {
  pageList: PageListItem[];
}

const PAGE_SHOW_MAX = 7;

/**
 * 分页器省略号截断算法（t=总页数，c=当前页），对齐 Semi 的分支逻辑重写：
 * - t<=7：不截断，展示全部页码
 * - t>7：
 *   - c<4：[1,2,3,4,'...',t-1,t]
 *   - c===4：[1,2,3,4,5,'...',t]
 *   - 4<c<t-3：[1,'...',c-1,c,c+1,'...',t]
 *   - t-3<=c<=t：[1,'...',t-4,t-3,t-2,t-1,t]
 * 纯函数，无框架依赖，可完全脱离渲染单测。
 */
export function computePageList(currentPage: number, totalPageNum: number): PageListResult {
  if (totalPageNum <= PAGE_SHOW_MAX) {
    return { pageList: Array.from({ length: totalPageNum }, (_, i) => i + 1) };
  }

  if (currentPage < 4) {
    return { pageList: [1, 2, 3, 4, '...', totalPageNum - 1, totalPageNum] };
  }

  if (currentPage === 4) {
    return { pageList: [1, 2, 3, 4, 5, '...', totalPageNum] };
  }

  if (currentPage > 4 && currentPage < totalPageNum - 3) {
    const middle = [currentPage - 1, currentPage, currentPage + 1];
    return { pageList: [1, '...', ...middle, '...', totalPageNum] };
  }

  // totalPageNum - 3 <= currentPage <= totalPageNum
  const right = Array.from({ length: 5 }, (_, i) => totalPageNum - (4 - i));
  return { pageList: [1, '...', ...right] };
}

export function getTotalPageNumber(total: number, pageSize: number): number {
  if (pageSize <= 0) return 0;
  return Math.ceil(total / pageSize);
}

/**
 * pageSize 变化后重新计算 currentPage：保持"当前显示的第一条数据仍然
 * 可见"（而非简单保留页码数字）。
 */
export function computeCurrentPageAfterPageSizeChange(currentPage: number, oldPageSize: number, newPageSize: number): number {
  const currentPageFirstItemIndex = (currentPage - 1) * oldPageSize + 1;
  return Math.ceil(currentPageFirstItemIndex / newPageSize);
}

/** currentPage clamp 到 [1, totalPageNum]（totalPageNum=0 时退化为 1，避免除零页场景无法交互）。 */
export function clampCurrentPage(currentPage: number, totalPageNum: number): number {
  const max = Math.max(totalPageNum, 1);
  return Math.min(Math.max(currentPage, 1), max);
}
