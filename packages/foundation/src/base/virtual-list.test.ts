import { describe, it, expect } from 'vitest';
import { calcVirtualRange, calcScrollToItemTop } from './virtual-list.js';

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

describe('calcScrollToItemTop', () => {
  const base = { itemCount: 100, itemHeight: 40, containerHeight: 200 };

  it('itemCount=0 或 itemHeight<=0：返回 0，不产生除零错误', () => {
    expect(calcScrollToItemTop(5, { ...base, itemCount: 0, scrollTop: 0 })).toBe(0);
    expect(calcScrollToItemTop(5, { ...base, itemHeight: 0, scrollTop: 0 })).toBe(0);
  });

  it('align=start：目标行顶对齐容器顶', () => {
    expect(calcScrollToItemTop(10, { ...base, scrollTop: 0, align: 'start' })).toBe(400);
  });

  it('align=end：目标行底对齐容器底', () => {
    // item 10: top=400, bottom=440；containerHeight=200 => target = 440-200=240
    expect(calcScrollToItemTop(10, { ...base, scrollTop: 0, align: 'end' })).toBe(240);
  });

  it('align=center：目标行居中', () => {
    // item 10: top=400 => target = 400 - 100 + 20 = 320
    expect(calcScrollToItemTop(10, { ...base, scrollTop: 0, align: 'center' })).toBe(320);
  });

  it('align=auto：已在可视区间内，不滚动', () => {
    // scrollTop=200 可视区间 [200,400)，item 5: top=200,bottom=240 完全落在区间内
    expect(calcScrollToItemTop(5, { ...base, scrollTop: 200, align: 'auto' })).toBe(200);
  });

  it('align=auto：目标行在可视区间上方，滚动到其顶部', () => {
    expect(calcScrollToItemTop(2, { ...base, scrollTop: 400, align: 'auto' })).toBe(80);
  });

  it('align=auto：目标行在可视区间下方，滚动到其底部对齐容器底', () => {
    // item 20: top=800, bottom=840; scrollTop=0 可视区间[0,200) => target=840-200=640
    expect(calcScrollToItemTop(20, { ...base, scrollTop: 0, align: 'auto' })).toBe(640);
  });

  it('target 不小于 0，不大于最大可滚动距离', () => {
    expect(calcScrollToItemTop(0, { ...base, scrollTop: 0, align: 'start' })).toBe(0);
    // 最后一项 99: top=3960, 但 maxScrollTop = 100*40-200=3800
    expect(calcScrollToItemTop(99, { ...base, scrollTop: 0, align: 'start' })).toBe(3800);
  });

  it('index 越界会被 clamp 到 [0, itemCount-1]', () => {
    expect(calcScrollToItemTop(-5, { ...base, scrollTop: 0, align: 'start' })).toBe(0);
    expect(calcScrollToItemTop(999, { ...base, scrollTop: 0, align: 'start' })).toBe(3800);
  });
});
