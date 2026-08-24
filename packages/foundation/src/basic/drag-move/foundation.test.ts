import { describe, expect, it } from 'vitest';
import {
  clampValueInRange,
  calcMoveRangeAbsolute,
  calcMoveRangeRelative,
  computeNextPosition,
  DragMoveFoundation,
  type DragMoveState,
} from './foundation.js';

describe('clampValueInRange', () => {
  it('钳制到 [min, max]', () => {
    expect(clampValueInRange(50, 0, 100)).toBe(50);
    expect(clampValueInRange(-10, 0, 100)).toBe(0);
    expect(clampValueInRange(150, 0, 100)).toBe(100);
  });
});

describe('calcMoveRangeAbsolute', () => {
  it('按 offsetParent 累积偏移 + 容器/元素尺寸差计算范围', () => {
    const range = calcMoveRangeAbsolute({
      offsetParentAccumX: 10,
      offsetParentAccumY: 20,
      constrainerWidth: 500,
      constrainerHeight: 400,
      elementWidth: 100,
      elementHeight: 50,
    });
    expect(range).toEqual({ xMin: 10, xMax: 410, yMin: 20, yMax: 370 });
  });
});

describe('calcMoveRangeRelative', () => {
  it('按元素/约束容器真实矩形差 + 当前 top/left 计算范围', () => {
    const elementRect = { left: 100, top: 100, right: 200, bottom: 150, width: 100, height: 50 };
    const constrainerRect = { left: 0, top: 0, right: 800, bottom: 600, width: 800, height: 600 };
    const range = calcMoveRangeRelative(elementRect, constrainerRect, 0, 0);
    expect(range).toEqual({ xMin: -100, xMax: 600, yMin: -100, yMax: 450 });
  });
});

describe('computeNextPosition', () => {
  it('absolute 策略：新位置 = 鼠标位置 - 起始偏移量', () => {
    const result = computeNextPosition(150, 130, {
      positionStrategy: 'absolute',
      range: null,
      startOffsetX: 50,
      startOffsetY: 30,
      startClientX: 0,
      startClientY: 0,
      startLeft: 0,
      startTop: 0,
    });
    expect(result).toEqual({ top: 100, left: 100 });
  });

  it('relative 策略：新位置 = 起始 top/left + 鼠标位移量', () => {
    const result = computeNextPosition(120, 110, {
      positionStrategy: 'relative',
      range: null,
      startOffsetX: 0,
      startOffsetY: 0,
      startClientX: 100,
      startClientY: 100,
      startLeft: 10,
      startTop: 20,
    });
    expect(result).toEqual({ top: 30, left: 30 });
  });

  it('超出 range 时钳制', () => {
    const result = computeNextPosition(1000, 1000, {
      positionStrategy: 'absolute',
      range: { xMin: 0, xMax: 200, yMin: 0, yMax: 150 },
      startOffsetX: 0,
      startOffsetY: 0,
      startClientX: 0,
      startClientY: 0,
      startLeft: 0,
      startTop: 0,
    });
    expect(result).toEqual({ top: 150, left: 200 });
  });

  it('range 为 null 时不设边界', () => {
    const result = computeNextPosition(9999, 9999, {
      positionStrategy: 'absolute',
      range: null,
      startOffsetX: 0,
      startOffsetY: 0,
      startClientX: 0,
      startClientY: 0,
      startLeft: 0,
      startTop: 0,
    });
    expect(result).toEqual({ top: 9999, left: 9999 });
  });
});

function createFoundation(initial: DragMoveState) {
  let state = initial;
  const foundation = new DragMoveFoundation({
    getState: () => state,
    setState: (patch) => {
      state = { ...state, ...patch };
    },
  });
  return { foundation, getState: () => state };
}

describe('DragMoveFoundation', () => {
  // offsetLeft/offsetTop：元素相对 offsetParent 的坐标（与 style.left/top 同一
  // 坐标系），不是 getBoundingClientRect() 的视口坐标——排查中定位到的真实
  // bug 教训：两者一旦不等（页面滚动/offsetParent 非 body）会产生系统性偏差。
  const OFFSET_LEFT = 100;
  const OFFSET_TOP = 100;

  it('onDragStart 进入拖拽态', () => {
    const { foundation, getState } = createFoundation({ top: 0, left: 0, isDragging: false });
    foundation.onDragStart('absolute', 150, 130, OFFSET_LEFT, OFFSET_TOP, null);
    expect(getState().isDragging).toBe(true);
  });

  it('onDragMove 未先调用 onDragStart 时返回 null', () => {
    const { foundation } = createFoundation({ top: 0, left: 0, isDragging: false });
    expect(foundation.onDragMove(150, 130)).toBeNull();
  });

  it('onDragMove 按 absolute 策略计算新位置并写回 state', () => {
    // startOffsetX = mousedown clientX(150) - offsetLeft(100) = 50
    // startOffsetY = mousedown clientY(130) - offsetTop(100) = 30
    // 移动到 (200,180) 后：left = 200-50 = 150，top = 180-30 = 150
    const { foundation, getState } = createFoundation({ top: 0, left: 0, isDragging: false });
    foundation.onDragStart('absolute', 150, 130, OFFSET_LEFT, OFFSET_TOP, null);
    const result = foundation.onDragMove(200, 180);
    expect(result).toEqual({ top: 150, left: 150 });
    expect(getState()).toMatchObject({ top: 150, left: 150 });
  });

  it('onDragMove 按 relative 策略计算新位置', () => {
    const { foundation, getState } = createFoundation({ top: 20, left: 10, isDragging: false });
    foundation.onDragStart('relative', 100, 100, OFFSET_LEFT, OFFSET_TOP, null);
    const result = foundation.onDragMove(120, 110);
    expect(result).toEqual({ top: 30, left: 30 });
    expect(getState()).toMatchObject({ top: 30, left: 30 });
  });

  it('onDragMove 遵循传入的 range 钳制边界', () => {
    const { foundation, getState } = createFoundation({ top: 0, left: 0, isDragging: false });
    foundation.onDragStart('absolute', 150, 130, OFFSET_LEFT, OFFSET_TOP, { xMin: 0, xMax: 50, yMin: 0, yMax: 40 });
    foundation.onDragMove(9999, 9999);
    expect(getState()).toMatchObject({ top: 40, left: 50 });
  });

  it('onDragEnd 退出拖拽态并清空起点，后续 onDragMove 返回 null', () => {
    const { foundation, getState } = createFoundation({ top: 0, left: 0, isDragging: false });
    foundation.onDragStart('absolute', 150, 130, OFFSET_LEFT, OFFSET_TOP, null);
    foundation.onDragEnd();
    expect(getState().isDragging).toBe(false);
    expect(foundation.onDragMove(200, 180)).toBeNull();
  });
});
