import { describe, it, expect } from 'vitest';
import {
  getDragOffset,
  calcTargetIndex,
  arrayMove,
  computeTargetIndexWrap,
  computeItemTransformsWrap,
  type ItemRect,
  type SortableDragState,
  type WrapRect,
} from './sortable-drag.js';

describe('sortable-drag', () => {
  describe('getDragOffset', () => {
    it('未拖拽：返回 0', () => {
      const state: SortableDragState = { draggingIndex: null, startPos: 0, currentPos: 100 };
      expect(getDragOffset(state)).toBe(0);
    });

    it('拖拽中：返回当前位置与起点的差值', () => {
      const state: SortableDragState = { draggingIndex: 1, startPos: 50, currentPos: 120 };
      expect(getDragOffset(state)).toBe(70);
    });
  });

  describe('calcTargetIndex', () => {
    // 4 项列表，每项高 40，中心分别在 20/60/100/140
    const rects: ItemRect[] = [
      { index: 0, center: 20 },
      { index: 1, center: 60 },
      { index: 2, center: 100 },
      { index: 3, center: 140 },
    ];

    it('未越过任何中心线：目标索引不变', () => {
      expect(calcTargetIndex(1, 60, rects)).toBe(1);
    });

    it('向下拖拽越过后一项中心线：目标索引前移到该项位置', () => {
      expect(calcTargetIndex(1, 110, rects)).toBe(2);
    });

    it('向下拖拽越过后两项中心线：目标索引跳两位', () => {
      expect(calcTargetIndex(0, 150, rects)).toBe(3);
    });

    it('向上拖拽越过前一项中心线：目标索引后移到该项位置', () => {
      expect(calcTargetIndex(2, 10, rects)).toBe(0);
    });

    it('只有自身一项：目标索引恒为自身', () => {
      expect(calcTargetIndex(0, 999, [{ index: 0, center: 20 }])).toBe(0);
    });
  });

  describe('arrayMove', () => {
    it('把元素从 oldIndex 移到 newIndex（向后移动）', () => {
      expect(arrayMove(['a', 'b', 'c', 'd'], 0, 2)).toEqual(['b', 'c', 'a', 'd']);
    });

    it('把元素从 oldIndex 移到 newIndex（向前移动）', () => {
      expect(arrayMove(['a', 'b', 'c', 'd'], 3, 1)).toEqual(['a', 'd', 'b', 'c']);
    });

    it('不修改原数组', () => {
      const arr = ['a', 'b', 'c'];
      arrayMove(arr, 0, 2);
      expect(arr).toEqual(['a', 'b', 'c']);
    });

    it('oldIndex === newIndex：数组内容不变', () => {
      expect(arrayMove(['a', 'b', 'c'], 1, 1)).toEqual(['a', 'b', 'c']);
    });
  });

  describe('computeTargetIndexWrap', () => {
    // 两行标签布局：第一行 3 个（宽度不等），第二行 2 个
    // row1: [0,0,60,20] [60,0,50,20] [110,0,70,20]
    // row2: [0,20,80,20] [80,20,60,20]
    const rects: WrapRect[] = [
      { left: 0, top: 0, width: 60, height: 20 },
      { left: 60, top: 0, width: 50, height: 20 },
      { left: 110, top: 0, width: 70, height: 20 },
      { left: 0, top: 20, width: 80, height: 20 },
      { left: 80, top: 20, width: 60, height: 20 },
    ];

    it('同一行内最近中心点判定', () => {
      // 指针落在第一项中心附近
      expect(computeTargetIndexWrap(30, 10, rects)).toBe(0);
      // 指针落在第二项中心附近
      expect(computeTargetIndexWrap(85, 10, rects)).toBe(1);
    });

    it('跨行移动：指针落在第二行时正确命中该行项', () => {
      expect(computeTargetIndexWrap(40, 30, rects)).toBe(3);
      expect(computeTargetIndexWrap(110, 30, rects)).toBe(4);
    });

    it('不等宽列：命中判定仍按几何中心而非索引顺序', () => {
      // 第三项（index 2）中心在 (145, 10)
      expect(computeTargetIndexWrap(145, 10, rects)).toBe(2);
    });

    it('空数组：返回 0', () => {
      expect(computeTargetIndexWrap(0, 0, [])).toBe(0);
    });
  });

  describe('computeItemTransformsWrap', () => {
    const rects: WrapRect[] = [
      { left: 0, top: 0, width: 60, height: 20 },
      { left: 60, top: 0, width: 50, height: 20 },
      { left: 110, top: 0, width: 70, height: 20 },
    ];

    it('targetIndex === activeIndex：被拖拽项跟随指针，其余不动', () => {
      const result = computeItemTransformsWrap(1, 1, 15, 5, rects);
      expect(result[1]).toEqual({ x: 15, y: 5 });
      expect(result[0]).toEqual({ x: 0, y: 0 });
      expect(result[2]).toEqual({ x: 0, y: 0 });
    });

    it('向后移动（activeIndex < targetIndex）：中间项精确滑动到邻居矩形位置', () => {
      const result = computeItemTransformsWrap(0, 2, 100, 0, rects);
      expect(result[0]).toEqual({ x: 100, y: 0 });
      // index1 滑到 activeRect（原 index0）位置：0 - 60 = -60
      expect(result[1]).toEqual({ x: -60, y: 0 });
      // index2 滑到 index1 原位置：60 - 110 = -50
      expect(result[2]).toEqual({ x: -50, y: 0 });
    });

    it('向前移动（activeIndex > targetIndex）：中间项精确滑动到邻居矩形位置', () => {
      const result = computeItemTransformsWrap(2, 0, -100, 0, rects);
      expect(result[2]).toEqual({ x: -100, y: 0 });
      // index1 滑到 activeRect（原 index2）位置：110 - 60 = 50
      expect(result[1]).toEqual({ x: 50, y: 0 });
      // index0 滑到 index1 原位置：60 - 0 = 60
      expect(result[0]).toEqual({ x: 60, y: 0 });
    });

    it('跨行移动：x/y 同时产生位移', () => {
      const wrapRects: WrapRect[] = [
        { left: 0, top: 0, width: 60, height: 20 },
        { left: 60, top: 0, width: 50, height: 20 },
        { left: 0, top: 20, width: 80, height: 20 },
      ];
      const result = computeItemTransformsWrap(0, 2, 10, 25, wrapRects);
      expect(result[0]).toEqual({ x: 10, y: 25 });
      expect(result[1]).toEqual({ x: -60, y: 0 });
      expect(result[2]).toEqual({ x: 60, y: -20 });
    });

    it('activeIndex 越界：返回全零位移不抛错', () => {
      const result = computeItemTransformsWrap(-1, 0, 10, 10, rects);
      expect(result).toEqual([{ x: 0, y: 0 }, { x: 0, y: 0 }, { x: 0, y: 0 }]);
    });
  });
});
