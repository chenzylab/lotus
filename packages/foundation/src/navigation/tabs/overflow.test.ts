import { describe, it, expect } from 'vitest';
import { computeOverflowScrollState, resolveScrollToStart, resolveScrollToEnd, type TabItemRect } from './overflow.js';

const ITEMS: TabItemRect[] = [
  { itemKey: 'a', offsetLeft: 0, width: 100 },
  { itemKey: 'b', offsetLeft: 100, width: 100 },
  { itemKey: 'c', offsetLeft: 200, width: 100 },
  { itemKey: 'd', offsetLeft: 300, width: 100 },
  { itemKey: 'e', offsetLeft: 400, width: 100 },
];

describe('computeOverflowScrollState', () => {
  it('全部可见时两侧都为空', () => {
    expect(computeOverflowScrollState(ITEMS, 0, 500)).toEqual({ hiddenStart: [], hiddenEnd: [] });
  });

  it('滚动到中间时，左侧完全滚出的项在 hiddenStart，右侧完全看不到的项在 hiddenEnd', () => {
    const result = computeOverflowScrollState(ITEMS, 150, 200);
    expect(result.hiddenStart).toEqual(['a']);
    expect(result.hiddenEnd).toEqual(['e']);
  });

  it('scrollLeft 恰好等于某项右边缘时该项视为完全滚出（不是部分可见）', () => {
    const result = computeOverflowScrollState(ITEMS, 100, 400);
    expect(result.hiddenStart).toEqual(['a']);
  });

  it('hiddenStart 按从最靠左到最靠右的顺序排列', () => {
    const result = computeOverflowScrollState(ITEMS, 250, 100);
    expect(result.hiddenStart).toEqual(['a', 'b']);
  });
});

describe('resolveScrollToStart', () => {
  it('hiddenStart 为空时返回 null（没有可滚的内容）', () => {
    expect(resolveScrollToStart(ITEMS, [])).toBeNull();
  });

  it('返回最靠近可视区左边缘的隐藏项（hiddenStart 数组最后一个）的 offsetLeft', () => {
    expect(resolveScrollToStart(ITEMS, ['a', 'b'])).toBe(100);
  });
});

describe('resolveScrollToEnd', () => {
  it('hiddenEnd 为空时返回 null', () => {
    expect(resolveScrollToEnd(ITEMS, [], 200)).toBeNull();
  });

  it('返回让最靠近可视区右边缘的隐藏项完全进入视口右边缘所需的滚动位置', () => {
    // 'd' 在 300-400，视口宽 200：让 'd' 右边缘（400）贴视口右边缘 -> scrollLeft = 400 - 200 = 200
    expect(resolveScrollToEnd(ITEMS, ['d', 'e'], 200)).toBe(200);
  });
});
