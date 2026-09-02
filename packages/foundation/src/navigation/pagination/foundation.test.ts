import { describe, it, expect } from 'vitest';
import {
  computePageList,
  getTotalPageNumber,
  computeCurrentPageAfterPageSizeChange,
  clampCurrentPage,
  computeRestPageLists,
} from './foundation.js';

describe('computePageList', () => {
  it('总页数 <= 7 时不截断，展示全部页码', () => {
    expect(computePageList(1, 7).pageList).toEqual([1, 2, 3, 4, 5, 6, 7]);
    expect(computePageList(3, 5).pageList).toEqual([1, 2, 3, 4, 5]);
  });

  it('总页数 > 7 且 current < 4 时，第 5 项为省略号，末尾展示最后两页', () => {
    expect(computePageList(1, 20).pageList).toEqual([1, 2, 3, 4, '...', 19, 20]);
    expect(computePageList(3, 20).pageList).toEqual([1, 2, 3, 4, '...', 19, 20]);
  });

  it('current === 4 时，第 6 项为省略号', () => {
    expect(computePageList(4, 20).pageList).toEqual([1, 2, 3, 4, 5, '...', 20]);
  });

  it('4 < current < total-3 时，前后各一个省略号，中间是 current-1/current/current+1', () => {
    expect(computePageList(10, 20).pageList).toEqual([1, '...', 9, 10, 11, '...', 20]);
  });

  it('current 落在末尾 4 页（total-3 <= current <= total）时，展示最后 5 页', () => {
    expect(computePageList(20, 20).pageList).toEqual([1, '...', 16, 17, 18, 19, 20]);
    expect(computePageList(17, 20).pageList).toEqual([1, '...', 16, 17, 18, 19, 20]);
  });

  it('边界：total=8（刚好超过 PAGE_SHOW_MAX）时正确截断', () => {
    expect(computePageList(1, 8).pageList).toEqual([1, 2, 3, 4, '...', 7, 8]);
  });

  it('current=1 时始终包含第 1 页且不重复', () => {
    const result = computePageList(1, 100).pageList;
    expect(result[0]).toBe(1);
  });
});

describe('getTotalPageNumber', () => {
  it('向上取整计算总页数', () => {
    expect(getTotalPageNumber(95, 10)).toBe(10);
    expect(getTotalPageNumber(100, 10)).toBe(10);
    expect(getTotalPageNumber(101, 10)).toBe(11);
  });

  it('pageSize<=0 时返回 0，避免除零', () => {
    expect(getTotalPageNumber(100, 0)).toBe(0);
  });
});

describe('computeCurrentPageAfterPageSizeChange', () => {
  it('pageSize 从 10 变为 20，保持第一条可见数据所在页正确换算', () => {
    // currentPage=3, pageSize=10 时第一条数据是第 21 条；pageSize 变为 20 后应落在第 2 页
    expect(computeCurrentPageAfterPageSizeChange(3, 10, 20)).toBe(2);
  });

  it('pageSize 变小时页码相应增大', () => {
    // currentPage=2, pageSize=20 时第一条数据是第 21 条；pageSize 变为 10 后应落在第 3 页
    expect(computeCurrentPageAfterPageSizeChange(2, 20, 10)).toBe(3);
  });
});

describe('clampCurrentPage', () => {
  it('currentPage 超过总页数时夹到总页数', () => {
    expect(clampCurrentPage(999, 10)).toBe(10);
  });

  it('currentPage 小于 1 时夹到 1', () => {
    expect(clampCurrentPage(-5, 10)).toBe(1);
  });

  it('totalPageNum=0 时仍返回 1，避免无可用页码', () => {
    expect(clampCurrentPage(5, 0)).toBe(1);
  });

  it('正常区间内的值原样返回', () => {
    expect(clampCurrentPage(5, 10)).toBe(5);
  });
});

describe('computeRestPageLists', () => {
  it('总页数 <= 7 时两个列表均为空（不截断，无省略号）', () => {
    expect(computeRestPageLists(3, 5)).toEqual({ restLeftPageList: [], restRightPageList: [] });
  });

  it('current < 4 时只有右侧省略号覆盖 5..totalPageNum-2', () => {
    expect(computeRestPageLists(1, 20)).toEqual({ restLeftPageList: [], restRightPageList: [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18] });
  });

  it('current === 4 时只有右侧省略号覆盖 6..totalPageNum-1', () => {
    expect(computeRestPageLists(4, 20)).toEqual({ restLeftPageList: [], restRightPageList: [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19] });
  });

  it('4 < current < total-3 时左右两侧省略号各覆盖对应区间', () => {
    const result = computeRestPageLists(10, 20);
    expect(result.restLeftPageList).toEqual([2, 3, 4, 5, 6, 7, 8]);
    expect(result.restRightPageList).toEqual([12, 13, 14, 15, 16, 17, 18, 19]);
  });

  it('current 落在末尾 4 页时只有左侧省略号覆盖 2..totalPageNum-5', () => {
    expect(computeRestPageLists(20, 20)).toEqual({ restLeftPageList: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], restRightPageList: [] });
  });

  it('与 computePageList 的省略号位置一致：左侧列表最大值 < currentPage，右侧列表最小值 > currentPage', () => {
    const currentPage = 15;
    const totalPageNum = 30;
    const { restLeftPageList, restRightPageList } = computeRestPageLists(currentPage, totalPageNum);
    expect(Math.max(...restLeftPageList)).toBeLessThan(currentPage);
    expect(Math.min(...restRightPageList)).toBeGreaterThan(currentPage);
  });
});
