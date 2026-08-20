import { describe, it, expect } from 'vitest';
import { foldTags } from './tag-fold.js';

describe('foldTags', () => {
  it('maxTagCount 未定义时全部展示', () => {
    const result = foldTags([1, 2, 3], undefined);
    expect(result).toEqual({ visible: [1, 2, 3], restCount: 0, rest: [] });
  });

  it('数量未超出时全部展示', () => {
    const result = foldTags([1, 2, 3], 5);
    expect(result).toEqual({ visible: [1, 2, 3], restCount: 0, rest: [] });
  });

  it('数量恰好等于 maxTagCount 时不折叠', () => {
    const result = foldTags([1, 2, 3], 3);
    expect(result).toEqual({ visible: [1, 2, 3], restCount: 0, rest: [] });
  });

  it('超出 maxTagCount 时折叠，visible 取前 N 个', () => {
    const result = foldTags([1, 2, 3, 4, 5], 2);
    expect(result.visible).toEqual([1, 2]);
    expect(result.restCount).toBe(3);
    expect(result.rest).toEqual([3, 4, 5]);
  });

  it('maxTagCount=0 时全部折叠', () => {
    const result = foldTags([1, 2, 3], 0);
    expect(result.visible).toEqual([]);
    expect(result.restCount).toBe(3);
  });

  it('空数组返回空结果', () => {
    const result = foldTags([], 3);
    expect(result).toEqual({ visible: [], restCount: 0, rest: [] });
  });
});
