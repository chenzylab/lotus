import { describe, it, expect } from 'vitest';
import { getDragOffset, calcTargetIndex, arrayMove, type ItemRect, type SortableDragState } from './sortable-drag.js';

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
});
