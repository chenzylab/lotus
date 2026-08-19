import { describe, it, expect } from 'vitest';
import { layoutOverflowList, estimateMaxRenderCount, MINIMUM_ITEM_WIDTH } from './foundation.js';

describe('layoutOverflowList', () => {
  it('空数组返回空结果', () => {
    expect(layoutOverflowList([], [], 100)).toEqual({ visible: [], overflow: [] });
  });

  it('全部能放下时不折叠', () => {
    const items = ['a', 'b', 'c'];
    const sizes = [30, 30, 30];
    const result = layoutOverflowList(items, sizes, 100);
    expect(result.visible).toEqual(['a', 'b', 'c']);
    expect(result.overflow).toEqual([]);
  });

  it('超出容器宽度时按 collapseFrom=end（默认）折叠尾部', () => {
    const items = ['a', 'b', 'c', 'd'];
    const sizes = [30, 30, 30, 30];
    const result = layoutOverflowList(items, sizes, 70);
    expect(result.visible).toEqual(['a', 'b']);
    expect(result.overflow).toEqual(['c', 'd']);
  });

  it('collapseFrom=start 时折叠头部、保留尾部', () => {
    const items = ['a', 'b', 'c', 'd'];
    const sizes = [30, 30, 30, 30];
    const result = layoutOverflowList(items, sizes, 70, 'start');
    expect(result.visible).toEqual(['c', 'd']);
    expect(result.overflow).toEqual(['a', 'b']);
  });

  it('minVisibleItems 强制保留至少 N 项，即使超出容器宽度', () => {
    const items = ['a', 'b', 'c', 'd'];
    const sizes = [50, 50, 50, 50];
    const result = layoutOverflowList(items, sizes, 60, 'end', 2);
    expect(result.visible).toEqual(['a', 'b']);
    expect(result.overflow).toEqual(['c', 'd']);
  });

  it('minVisibleItems 超过 items 总数时不会越界', () => {
    const items = ['a', 'b'];
    const sizes = [50, 50];
    const result = layoutOverflowList(items, sizes, 10, 'end', 10);
    expect(result.visible).toEqual(['a', 'b']);
    expect(result.overflow).toEqual([]);
  });

  it('单项超出容器宽度但 minVisibleItems=0 时仍不折叠掉全部（至少保留第一项判定逻辑）', () => {
    const items = ['a'];
    const sizes = [200];
    const result = layoutOverflowList(items, sizes, 100);
    expect(result.visible).toEqual([]);
    expect(result.overflow).toEqual(['a']);
  });

  it('缺失尺寸的项按 0 宽度处理，不影响后续累加', () => {
    const items = ['a', 'b'];
    const sizes = [50];
    const result = layoutOverflowList(items, sizes, 60);
    expect(result.visible).toEqual(['a', 'b']);
  });

  it('恰好等于容器宽度时不算超出', () => {
    const items = ['a', 'b'];
    const sizes = [50, 50];
    const result = layoutOverflowList(items, sizes, 100);
    expect(result.visible).toEqual(['a', 'b']);
    expect(result.overflow).toEqual([]);
  });
});

describe('estimateMaxRenderCount', () => {
  it('容器宽度为 0 时返回 0（对齐 SSR 首屏不渲染任何 item）', () => {
    expect(estimateMaxRenderCount(0, 10)).toBe(0);
  });

  it('按 MINIMUM_ITEM_WIDTH 估算上限，不超过 items 总数', () => {
    expect(estimateMaxRenderCount(40, 100)).toBe(40 / MINIMUM_ITEM_WIDTH);
  });

  it('估算上限超过 items 总数时取 items 总数', () => {
    expect(estimateMaxRenderCount(1000, 5)).toBe(5);
  });
});
