import { describe, it, expect } from 'vitest';
import { ResizableFoundation, type ResizableState, type ResizableConstraints } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: ResizableState): Adapter<ResizableState> {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<ResizableState>) => {
      state = { ...state, ...patch };
    },
  };
}

const NO_LIMIT: ResizableConstraints = {
  minWidth: 0,
  minHeight: 0,
  maxWidth: Infinity,
  maxHeight: Infinity,
  lockAspectRatio: false,
};

function createFoundation(width = 200, height = 100) {
  const adapter = createMockAdapter({ width, height, isResizing: false, direction: null });
  return { foundation: new ResizableFoundation(adapter), adapter };
}

describe('ResizableFoundation', () => {
  it('onResizeStart 进入 resizing 态并记录方向', () => {
    const { foundation, adapter } = createFoundation();
    foundation.onResizeStart('right', 0, 0);

    expect(adapter.getState().isResizing).toBe(true);
    expect(adapter.getState().direction).toBe('right');
  });

  it('right 方向拖拽：宽度随水平位移增加，高度不变', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('right', 100, 100);

    const size = foundation.onResize(150, 100, NO_LIMIT);

    expect(size).toEqual({ width: 250, height: 100 });
  });

  it('left 方向拖拽：向左移动指针（负向）会增加宽度', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('left', 100, 100);

    const size = foundation.onResize(60, 100, NO_LIMIT);

    expect(size).toEqual({ width: 240, height: 100 });
  });

  it('bottom 方向拖拽：高度随垂直位移增加，宽度不变', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('bottom', 100, 100);

    const size = foundation.onResize(100, 130, NO_LIMIT);

    expect(size).toEqual({ width: 200, height: 130 });
  });

  it('top 方向拖拽：向上移动指针（负向）会增加高度', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('top', 100, 100);

    const size = foundation.onResize(100, 70, NO_LIMIT);

    expect(size).toEqual({ width: 200, height: 130 });
  });

  it('bottomRight 方向拖拽：宽高同时增加', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('bottomRight', 100, 100);

    const size = foundation.onResize(150, 130, NO_LIMIT);

    expect(size).toEqual({ width: 250, height: 130 });
  });

  it('topLeft 方向拖拽：宽高同时增加（指针左上移动）', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('topLeft', 100, 100);

    const size = foundation.onResize(60, 70, NO_LIMIT);

    expect(size).toEqual({ width: 240, height: 130 });
  });

  it('拖拽结果受 minWidth/minHeight 约束，不会小于下限', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('right', 100, 100);

    const size = foundation.onResize(-500, 100, { ...NO_LIMIT, minWidth: 50 });

    expect(size!.width).toBe(50);
  });

  it('拖拽结果受 maxWidth/maxHeight 约束，不会超过上限', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('right', 100, 100);

    const size = foundation.onResize(1000, 100, { ...NO_LIMIT, maxWidth: 300 });

    expect(size!.width).toBe(300);
  });

  it('lockAspectRatio=true 时，水平方向拖拽会按比例联动改变高度', () => {
    const { foundation } = createFoundation(200, 100);
    foundation.onResizeStart('right', 100, 100);

    const size = foundation.onResize(300, 100, { ...NO_LIMIT, lockAspectRatio: true });

    // 起始比例 200:100 = 2:1，宽度变为 400 时高度应联动为 200
    expect(size).toEqual({ width: 400, height: 200 });
  });

  it('未调用 onResizeStart 时 onResize 返回 null，不抛出异常', () => {
    const { foundation } = createFoundation();

    expect(() => foundation.onResize(100, 100, NO_LIMIT)).not.toThrow();
    expect(foundation.onResize(100, 100, NO_LIMIT)).toBeNull();
  });

  it('onResizeEnd 退出 resizing 态并清空方向', () => {
    const { foundation, adapter } = createFoundation();
    foundation.onResizeStart('right', 100, 100);
    foundation.onResize(150, 100, NO_LIMIT);
    foundation.onResizeEnd();

    expect(adapter.getState().isResizing).toBe(false);
    expect(adapter.getState().direction).toBeNull();
  });

  it('onResizeEnd 后再次 onResize（未重新 start）返回 null', () => {
    const { foundation } = createFoundation();
    foundation.onResizeStart('right', 100, 100);
    foundation.onResizeEnd();

    expect(foundation.onResize(150, 100, NO_LIMIT)).toBeNull();
  });

  it('连续两次独立的拖拽周期，第二次以第一次的结果为新起点', () => {
    const { foundation, adapter } = createFoundation(200, 100);

    foundation.onResizeStart('right', 100, 100);
    foundation.onResize(150, 100, NO_LIMIT);
    foundation.onResizeEnd();

    expect(adapter.getState().width).toBe(250);

    foundation.onResizeStart('right', 100, 100);
    const size = foundation.onResize(120, 100, NO_LIMIT);

    expect(size).toEqual({ width: 270, height: 100 });
  });
});
