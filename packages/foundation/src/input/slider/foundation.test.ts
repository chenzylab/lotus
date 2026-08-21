import { describe, it, expect } from 'vitest';
import { SliderFoundation, type SliderState, type SliderFoundationOptions, type SliderValue } from './foundation.js';

function makeFoundation(
  value: SliderValue,
  optsOverrides: Partial<SliderFoundationOptions> = {},
) {
  let state: SliderState = { value, dragging: false, focusPos: false };
  const opts: SliderFoundationOptions = {
    min: 0,
    max: 100,
    step: 1,
    range: Array.isArray(value),
    vertical: false,
    verticalReverse: false,
    ...optsOverrides,
  };
  const foundation = new SliderFoundation(
    { getState: () => state, setState: (patch) => { state = { ...state, ...patch }; } },
    opts,
  );
  return { foundation, getState: () => state };
}

const RECT = { left: 0, top: 0, width: 200, height: 20 };

describe('snapToStep', () => {
  it('对齐 step 网格', () => {
    const { foundation } = makeFoundation(0, { step: 10 });
    expect(foundation.snapToStep(23)).toBe(20);
    expect(foundation.snapToStep(27)).toBe(30);
  });

  it('钳制在 [min,max] 区间', () => {
    const { foundation } = makeFoundation(0, { min: 0, max: 100 });
    expect(foundation.snapToStep(-10)).toBe(0);
    expect(foundation.snapToStep(150)).toBe(100);
  });

  it('小数 step 时修正浮点误差', () => {
    const { foundation } = makeFoundation(0, { min: 0, max: 1, step: 0.1 });
    expect(foundation.snapToStep(0.3)).toBe(0.3);
    expect(foundation.snapToStep(0.1 + 0.2)).toBeCloseTo(0.3, 10);
  });
});

describe('posToRawValue', () => {
  it('水平方向：按 x 偏移比例线性插值', () => {
    const { foundation } = makeFoundation(0);
    expect(foundation.posToRawValue(0, 0, RECT)).toBe(0);
    expect(foundation.posToRawValue(200, 0, RECT)).toBe(100);
    expect(foundation.posToRawValue(100, 0, RECT)).toBe(50);
  });

  it('超出轨道范围时钳制到端点', () => {
    const { foundation } = makeFoundation(0);
    expect(foundation.posToRawValue(-50, 0, RECT)).toBe(0);
    expect(foundation.posToRawValue(300, 0, RECT)).toBe(100);
  });

  it('vertical 默认底部为 min（percent 反转）', () => {
    const { foundation } = makeFoundation(0, { vertical: true });
    const vRect = { left: 0, top: 0, width: 20, height: 200 };
    expect(foundation.posToRawValue(0, 200, vRect)).toBe(0);
    expect(foundation.posToRawValue(0, 0, vRect)).toBe(100);
  });

  it('verticalReverse 时顶部为 min', () => {
    const { foundation } = makeFoundation(0, { vertical: true, verticalReverse: true });
    const vRect = { left: 0, top: 0, width: 20, height: 200 };
    expect(foundation.posToRawValue(0, 0, vRect)).toBe(0);
    expect(foundation.posToRawValue(0, 200, vRect)).toBe(100);
  });
});

describe('valueToPercent', () => {
  it('按 min/max 归一化到 0-100', () => {
    const { foundation } = makeFoundation(0, { min: 0, max: 200 });
    expect(foundation.valueToPercent(100)).toBe(50);
    expect(foundation.valueToPercent(0)).toBe(0);
    expect(foundation.valueToPercent(200)).toBe(100);
  });
});

describe('单值拖拽状态机', () => {
  it('onHandleDown 设置 dragging/focusPos', () => {
    const { foundation, getState } = makeFoundation(0);
    foundation.onHandleDown('min');
    expect(getState().dragging).toBe('min');
    expect(getState().focusPos).toBe('min');
  });

  it('onHandleMove 未拖拽时返回 null', () => {
    const { foundation } = makeFoundation(0);
    expect(foundation.onHandleMove(100, 0, RECT)).toBeNull();
  });

  it('onHandleMove 拖拽中按位置更新值', () => {
    const { foundation, getState } = makeFoundation(0);
    foundation.onHandleDown('min');
    const result = foundation.onHandleMove(100, 0, RECT);
    expect(result?.value).toBe(50);
    expect(result?.changed).toBe(true);
    expect(getState().value).toBe(50);
  });

  it('值未变化时 changed=false', () => {
    const { foundation } = makeFoundation(50);
    foundation.onHandleDown('min');
    const result = foundation.onHandleMove(100, 0, RECT);
    expect(result?.changed).toBe(false);
  });

  it('onHandleUp 复位 dragging', () => {
    const { foundation, getState } = makeFoundation(0);
    foundation.onHandleDown('min');
    foundation.onHandleUp();
    expect(getState().dragging).toBe(false);
  });
});

describe('range 拖拽状态机', () => {
  it('分别拖拽 min/max 手柄', () => {
    const { foundation, getState } = makeFoundation([20, 80]);
    foundation.onHandleDown('min');
    foundation.onHandleMove(60, 0, RECT);
    expect(getState().value).toEqual([30, 80]);

    foundation.onHandleUp();
    foundation.onHandleDown('max');
    foundation.onHandleMove(180, 0, RECT);
    expect(getState().value).toEqual([30, 90]);
  });

  it('min 手柄拖过 max 手柄时收缩贴住（不允许交叉穿越）', () => {
    const { foundation, getState } = makeFoundation([20, 80]);
    foundation.onHandleDown('min');
    foundation.onHandleMove(200, 0, RECT); // 尝试拖到 100，超过 max=80
    expect(getState().value).toEqual([80, 80]);
  });

  it('max 手柄拖过 min 手柄时收缩贴住', () => {
    const { foundation, getState } = makeFoundation([20, 80]);
    foundation.onHandleDown('max');
    foundation.onHandleMove(0, 0, RECT); // 尝试拖到 0，低于 min=20
    expect(getState().value).toEqual([20, 20]);
  });
});

describe('onRailClick', () => {
  it('单值模式：点击轨道任意位置直接跳转', () => {
    const { foundation } = makeFoundation(0);
    const result = foundation.onRailClick(150, 0, RECT);
    expect(result?.value).toBe(75);
    expect(result?.handler).toBe('min');
  });

  it('range 模式：点击位置离 min 手柄更近则操作 min', () => {
    const { foundation, getState } = makeFoundation([10, 90]);
    const result = foundation.onRailClick(30, 0, RECT); // value=15，离 10 更近
    expect(result?.handler).toBe('min');
    expect(getState().value).toEqual([15, 90]);
  });

  it('range 模式：点击位置离 max 手柄更近则操作 max', () => {
    const { foundation, getState } = makeFoundation([10, 90]);
    const result = foundation.onRailClick(170, 0, RECT); // value=85，离 90 更近
    expect(result?.handler).toBe('max');
    expect(getState().value).toEqual([10, 85]);
  });

  it('点击后设置 focusPos', () => {
    const { foundation, getState } = makeFoundation(0);
    foundation.onRailClick(100, 0, RECT);
    expect(getState().focusPos).toBe('min');
  });
});

describe('handleKeyDown：单值模式', () => {
  it('ArrowRight/ArrowUp 递增 step', () => {
    const { foundation, getState } = makeFoundation(50, { step: 5 });
    foundation.handleKeyDown('ArrowRight', 'min');
    expect(getState().value).toBe(55);
  });

  it('ArrowLeft/ArrowDown 递减 step', () => {
    const { foundation, getState } = makeFoundation(50, { step: 5 });
    foundation.handleKeyDown('ArrowLeft', 'min');
    expect(getState().value).toBe(45);
  });

  it('PageUp/PageDown 步进 ×10', () => {
    const { foundation, getState } = makeFoundation(50, { step: 1 });
    foundation.handleKeyDown('PageUp', 'min');
    expect(getState().value).toBe(60);
    foundation.handleKeyDown('PageDown', 'min');
    expect(getState().value).toBe(50);
  });

  it('Home 跳到 min，End 跳到 max', () => {
    const { foundation, getState } = makeFoundation(50, { min: 0, max: 100 });
    foundation.handleKeyDown('Home', 'min');
    expect(getState().value).toBe(0);
    foundation.handleKeyDown('End', 'min');
    expect(getState().value).toBe(100);
  });

  it('未知按键返回 null', () => {
    const { foundation } = makeFoundation(50);
    expect(foundation.handleKeyDown('Escape', 'min')).toBeNull();
  });

  it('边界处值不再变化时 changed=false', () => {
    const { foundation } = makeFoundation(100, { max: 100 });
    const result = foundation.handleKeyDown('ArrowRight', 'min');
    expect(result?.changed).toBe(false);
  });
});

describe('handleKeyDown：range 模式硬钳制', () => {
  it('min 手柄不能通过键盘超过 max 手柄', () => {
    const { foundation, getState } = makeFoundation([20, 25], { step: 10 });
    foundation.handleKeyDown('ArrowRight', 'min');
    expect((getState().value as [number, number])[0]).toBeLessThanOrEqual(25);
  });

  it('max 手柄不能通过键盘低于 min 手柄', () => {
    const { foundation, getState } = makeFoundation([20, 25], { step: 10 });
    foundation.handleKeyDown('ArrowLeft', 'max');
    expect((getState().value as [number, number])[1]).toBeGreaterThanOrEqual(20);
  });

  it('Home：min 手柄跳到全局 min，max 手柄贴住 min 手柄的当前值', () => {
    const { foundation, getState } = makeFoundation([30, 70]);
    foundation.handleKeyDown('Home', 'max');
    expect(getState().value).toEqual([30, 30]);
  });

  it('End：max 手柄跳到全局 max，min 手柄贴住 max 手柄的当前值', () => {
    const { foundation, getState } = makeFoundation([30, 70]);
    foundation.handleKeyDown('End', 'min');
    expect(getState().value).toEqual([70, 70]);
  });
});

describe('isMarkActive', () => {
  it('单值模式：mark <= value 时 active', () => {
    const { foundation } = makeFoundation(50);
    expect(foundation.isMarkActive(30)).toBe(true);
    expect(foundation.isMarkActive(70)).toBe(false);
  });

  it('range 模式：mark 落在 [min,max] 区间内时 active', () => {
    const { foundation } = makeFoundation([20, 80]);
    expect(foundation.isMarkActive(50)).toBe(true);
    expect(foundation.isMarkActive(10)).toBe(false);
    expect(foundation.isMarkActive(90)).toBe(false);
  });
});

describe('onBlur', () => {
  it('清空 focusPos', () => {
    const { foundation, getState } = makeFoundation(0);
    foundation.onHandleDown('min');
    foundation.onBlur();
    expect(getState().focusPos).toBe(false);
  });
});
