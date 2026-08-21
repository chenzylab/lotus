import { describe, it, expect } from 'vitest';
import { calcVirtualRange } from './virtual-list.js';

describe('calcVirtualRange', () => {
  it('itemCount=0：空区间', () => {
    const range = calcVirtualRange({ itemCount: 0, itemHeight: 40, containerHeight: 200, scrollTop: 0 });
    expect(range).toEqual({ startIndex: 0, endIndex: -1, totalHeight: 0, offsetY: 0 });
  });

  it('scrollTop=0：从头开始渲染，overscan 不越界', () => {
    // 100 项，每项 40px，容器 200px（可见5项），overscan 默认 3
    const range = calcVirtualRange({ itemCount: 100, itemHeight: 40, containerHeight: 200, scrollTop: 0 });
    expect(range.startIndex).toBe(0); // rawStart=0, overscan前移clamp到0
    expect(range.endIndex).toBe(0 + 5 + 3); // rawStart + visibleCount + overscan
    expect(range.totalHeight).toBe(4000);
    expect(range.offsetY).toBe(0);
  });

  it('滚动到中间：startIndex/endIndex 按 overscan 前后扩展', () => {
    const range = calcVirtualRange({ itemCount: 100, itemHeight: 40, containerHeight: 200, scrollTop: 400 });
    // rawStart = 400/40 = 10, visibleCount = ceil(200/40) = 5
    expect(range.startIndex).toBe(10 - 3);
    expect(range.endIndex).toBe(10 + 5 + 3);
    expect(range.offsetY).toBe((10 - 3) * 40);
  });

  it('滚动到底部附近：endIndex 不超过 itemCount-1', () => {
    const range = calcVirtualRange({ itemCount: 20, itemHeight: 40, containerHeight: 200, scrollTop: 800 - 200 });
    expect(range.endIndex).toBe(19);
  });

  it('overscan 自定义值生效', () => {
    const range = calcVirtualRange({ itemCount: 100, itemHeight: 40, containerHeight: 200, scrollTop: 400, overscan: 0 });
    expect(range.startIndex).toBe(10);
    expect(range.endIndex).toBe(10 + 5);
  });

  it('itemHeight<=0：返回空区间，不产生除零错误', () => {
    const range = calcVirtualRange({ itemCount: 10, itemHeight: 0, containerHeight: 200, scrollTop: 0 });
    expect(range).toEqual({ startIndex: 0, endIndex: -1, totalHeight: 0, offsetY: 0 });
  });
});
