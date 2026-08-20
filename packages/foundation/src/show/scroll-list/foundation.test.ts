import { describe, it, expect } from 'vitest';
import {
  findNearestIndex,
  getScrollTopForIndex,
  calcCycledListLayout,
  normalizeIndex,
  type ScrollListItemData,
} from './foundation.js';

function makeItems(count: number, disabledIndexes: number[] = []): ScrollListItemData<number>[] {
  return Array.from({ length: count }, (_, i) => ({
    value: i,
    text: String(i),
    disabled: disabledIndexes.includes(i),
  }));
}

describe('findNearestIndex', () => {
  it('空数组返回 -1', () => {
    expect(findNearestIndex([], 36, 0, 200)).toBe(-1);
  });

  it('scrollTop=0 时容器中心对齐到第 2-3 项之间，命中较近的一项', () => {
    // itemHeight=36, containerHeight=200 -> center=100
    // item i 的中心 = i*36+18；i=2: 90, i=3: 126, 距离 100 更近的是 i=2 (10 vs 26)
    const items = makeItems(10);
    const index = findNearestIndex(items, 36, 0, 200);
    expect(index).toBe(2);
  });

  it('滚动到精确对齐某一项时命中该项', () => {
    const items = makeItems(10);
    const itemHeight = 36;
    const containerHeight = 200;
    const target = 5;
    const scrollTop = getScrollTopForIndex(target, itemHeight, containerHeight);
    const index = findNearestIndex(items, itemHeight, scrollTop, containerHeight);
    expect(index).toBe(target);
  });

  it('跳过 disabled 项，命中次近的可用项', () => {
    const items = makeItems(10, [2]);
    const index = findNearestIndex(items, 36, 0, 200);
    expect(index).not.toBe(2);
    expect(items[index]?.disabled).toBeFalsy();
  });

  it('全部项都 disabled 时返回 -1', () => {
    const items = makeItems(3, [0, 1, 2]);
    const index = findNearestIndex(items, 36, 0, 200);
    expect(index).toBe(-1);
  });
});

describe('getScrollTopForIndex', () => {
  it('往返一致：算出的 scrollTop 再喂给 findNearestIndex 能精确命中同一项', () => {
    const items = makeItems(20);
    const itemHeight = 40;
    const containerHeight = 240;
    for (let target = 0; target < 20; target++) {
      const scrollTop = getScrollTopForIndex(target, itemHeight, containerHeight);
      expect(findNearestIndex(items, itemHeight, scrollTop, containerHeight)).toBe(target);
    }
  });
});

describe('calcCycledListLayout', () => {
  it('空列表返回 0 副本', () => {
    expect(calcCycledListLayout(0, 36, 200)).toEqual({ prependCount: 0, appendCount: 0 });
  });

  it('数据总高度小于可视区域倍数时至少补 1 组副本', () => {
    const result = calcCycledListLayout(3, 36, 200, 2);
    expect(result.prependCount).toBeGreaterThanOrEqual(1);
    expect(result.appendCount).toBeGreaterThanOrEqual(1);
  });

  it('数据总高度足够大时不需要过多副本', () => {
    const result = calcCycledListLayout(100, 36, 200, 2);
    expect(result.prependCount).toBe(1);
    expect(result.appendCount).toBe(1);
  });
});

describe('normalizeIndex', () => {
  it('原始范围内的索引原样返回', () => {
    expect(normalizeIndex(3, 10)).toBe(3);
  });

  it('超出范围的正索引正确取模', () => {
    expect(normalizeIndex(13, 10)).toBe(3);
    expect(normalizeIndex(23, 10)).toBe(3);
  });

  it('负数索引正确归一化（JS % 对负数不直接可用，需要额外处理）', () => {
    expect(normalizeIndex(-1, 10)).toBe(9);
    expect(normalizeIndex(-11, 10)).toBe(9);
  });

  it('itemCount=0 时返回 -1', () => {
    expect(normalizeIndex(5, 0)).toBe(-1);
  });
});
