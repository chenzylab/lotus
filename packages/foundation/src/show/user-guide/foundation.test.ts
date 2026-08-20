import { describe, it, expect } from 'vitest';
import {
  resolveStepTarget,
  resolveSpotlightPadding,
  computeSpotlightRect,
  isRectInViewport,
  computeUserGuideFloatingStyle,
  computeNext,
  computePrev,
  UserGuideFoundation,
  type UserGuideStepData,
  type UserGuideState,
} from './foundation.js';
import type { FloatingRect } from '../../base/floating-position.js';

function rect(partial: Partial<FloatingRect>): FloatingRect {
  return { top: 0, left: 0, right: 0, bottom: 0, width: 0, height: 0, ...partial };
}

describe('resolveStepTarget', () => {
  it('target 为 Element 时原样返回', () => {
    const el = {} as Element;
    expect(resolveStepTarget({ target: el })).toBe(el);
  });

  it('target 为函数时每次调用求值', () => {
    let calls = 0;
    const el = {} as Element;
    const step: UserGuideStepData = { target: () => { calls++; return el; } };
    expect(resolveStepTarget(step)).toBe(el);
    expect(resolveStepTarget(step)).toBe(el);
    expect(calls).toBe(2);
  });

  it('target 缺失时返回 null', () => {
    expect(resolveStepTarget(undefined)).toBeNull();
    expect(resolveStepTarget({})).toBeNull();
  });

  it('target 函数返回 null/undefined 时归一化为 null', () => {
    expect(resolveStepTarget({ target: () => null })).toBeNull();
    expect(resolveStepTarget({ target: () => undefined })).toBeNull();
  });
});

describe('resolveSpotlightPadding', () => {
  it('step 级优先于全局 prop', () => {
    expect(resolveSpotlightPadding({ spotlightPadding: 10 }, 20)).toBe(10);
  });

  it('无 step 级时回退全局 prop', () => {
    expect(resolveSpotlightPadding({}, 20)).toBe(20);
  });

  it('都没有时回退默认值 5', () => {
    expect(resolveSpotlightPadding({}, undefined)).toBe(5);
    expect(resolveSpotlightPadding(undefined, undefined)).toBe(5);
  });

  it('修正 Semi 的 || 吞掉 0 的 bug：step 级显式传 0 时必须生效为 0，不回退', () => {
    expect(resolveSpotlightPadding({ spotlightPadding: 0 }, 20)).toBe(0);
  });

  it('全局 prop 显式传 0 时同样生效，不回退默认值', () => {
    expect(resolveSpotlightPadding({}, 0)).toBe(0);
  });
});

describe('computeSpotlightRect', () => {
  it('按 padding 向四周扩展', () => {
    const target = rect({ left: 100, top: 100, right: 200, bottom: 150, width: 100, height: 50 });
    const spotlight = computeSpotlightRect(target, 5);
    expect(spotlight).toEqual({ left: 95, top: 95, right: 205, bottom: 155, width: 110, height: 60 });
  });

  it('padding=0 时等于原矩形', () => {
    const target = rect({ left: 10, top: 10, right: 50, bottom: 40, width: 40, height: 30 });
    expect(computeSpotlightRect(target, 0)).toEqual(target);
  });
});

describe('isRectInViewport', () => {
  it('完全在视口内返回 true', () => {
    expect(isRectInViewport(rect({ top: 10, left: 10, bottom: 100, right: 100 }), 1920, 1080)).toBe(true);
  });

  it('任意一边越界返回 false（top 越界）', () => {
    expect(isRectInViewport(rect({ top: -5, left: 10, bottom: 100, right: 100 }), 1920, 1080)).toBe(false);
  });

  it('任意一边越界返回 false（right 超出视口宽度）', () => {
    expect(isRectInViewport(rect({ top: 10, left: 10, bottom: 100, right: 2000 }), 1920, 1080)).toBe(false);
  });

  it('恰好贴边（等于边界值）仍算在视口内', () => {
    expect(isRectInViewport(rect({ top: 0, left: 0, bottom: 1080, right: 1920 }), 1920, 1080)).toBe(true);
  });
});

describe('computeUserGuideFloatingStyle', () => {
  it('以高亮框（非目标元素）作为虚拟锚点计算浮层位置', () => {
    const spotlightRect = rect({ left: 100, top: 100, right: 200, bottom: 150, width: 100, height: 50 });
    const style = computeUserGuideFloatingStyle({
      spotlightRect,
      position: 'bottom',
      floatingSize: { width: 200, height: 80 },
    });
    expect(style.position).toBe('bottom');
    expect(style.left).toBe(150);
    expect(style.top).toBe(158);
  });
});

describe('computeNext / computePrev（状态机边界钳制）', () => {
  it('非最后一步：current + 1，finished=false', () => {
    expect(computeNext(0, 3)).toEqual({ current: 1, finished: false });
    expect(computeNext(1, 3)).toEqual({ current: 2, finished: false });
  });

  it('最后一步：current 不变，finished=true（对齐 Semi「onFinish 与 onNext 互斥」语义）', () => {
    expect(computeNext(2, 3)).toEqual({ current: 2, finished: true });
  });

  it('只有一步时，第 0 步即最后一步', () => {
    expect(computeNext(0, 1)).toEqual({ current: 0, finished: true });
  });

  it('current > 0 时正常回退', () => {
    expect(computePrev(2)).toEqual({ current: 1, finished: false });
  });

  it('修正 Semi 的边界 bug：current=0 时继续 prev 钳制在 0，不产生 -1', () => {
    expect(computePrev(0)).toEqual({ current: 0, finished: false });
  });
});

describe('UserGuideFoundation', () => {
  function makeFoundation(initial: UserGuideState) {
    let state = { ...initial };
    const foundation = new UserGuideFoundation({
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    });
    return { foundation, getState: () => state };
  }

  it('非受控模式下 next() 写回内部 state', () => {
    const { foundation, getState } = makeFoundation({ current: 0 });
    const result = foundation.next(3, false);
    expect(result).toEqual({ current: 1, finished: false });
    expect(getState().current).toBe(1);
  });

  it('受控模式下 next() 不写回内部 state，只返回计算结果', () => {
    const { foundation, getState } = makeFoundation({ current: 0 });
    const result = foundation.next(3, true);
    expect(result).toEqual({ current: 1, finished: false });
    expect(getState().current).toBe(0);
  });

  it('最后一步 next() 无论受控与否都不改变 state', () => {
    const { foundation, getState } = makeFoundation({ current: 2 });
    const result = foundation.next(3, false);
    expect(result.finished).toBe(true);
    expect(getState().current).toBe(2);
  });

  it('非受控模式下 prev() 写回内部 state', () => {
    const { foundation, getState } = makeFoundation({ current: 2 });
    const next = foundation.prev(false);
    expect(next).toBe(1);
    expect(getState().current).toBe(1);
  });

  it('受控模式下 prev() 不写回内部 state', () => {
    const { foundation, getState } = makeFoundation({ current: 2 });
    const next = foundation.prev(true);
    expect(next).toBe(1);
    expect(getState().current).toBe(2);
  });

  it('reset() 强制回到第一步（对齐 visible false->true 重新打开引导的行为）', () => {
    const { foundation, getState } = makeFoundation({ current: 2 });
    foundation.reset();
    expect(getState().current).toBe(0);
  });
});
