import { describe, it, expect } from 'vitest';
import { RatingFoundation, type RatingState, type RatingFoundationOptions } from './foundation.js';

function makeFoundation(
  stateOverrides: Partial<RatingState> = {},
  optsOverrides: Partial<RatingFoundationOptions> = {},
) {
  let state: RatingState = { value: 0, hoverValue: undefined, clearedValue: null, ...stateOverrides };
  const opts: RatingFoundationOptions = { count: 5, allowHalf: false, allowClear: true, ...optsOverrides };
  const foundation = new RatingFoundation(
    { getState: () => state, setState: (patch) => { state = { ...state, ...patch }; } },
    opts,
  );
  return { foundation, getState: () => state };
}

describe('getStarValue', () => {
  it('allowHalf=false 时恒返回整数分', () => {
    const { foundation } = makeFoundation({}, { allowHalf: false });
    expect(foundation.getStarValue(2, 0.1)).toBe(3);
    expect(foundation.getStarValue(2, 0.9)).toBe(3);
  });

  it('allowHalf=true 时按 fraction<0.5 判半星', () => {
    const { foundation } = makeFoundation({}, { allowHalf: true });
    expect(foundation.getStarValue(2, 0.3)).toBe(2.5);
    expect(foundation.getStarValue(2, 0.7)).toBe(3);
  });

  it('fraction 恰好 0.5 时算整星', () => {
    const { foundation } = makeFoundation({}, { allowHalf: true });
    expect(foundation.getStarValue(2, 0.5)).toBe(3);
  });
});

describe('displayValue', () => {
  it('无 hover 时展示 value', () => {
    const { foundation } = makeFoundation({ value: 3 });
    expect(foundation.displayValue()).toBe(3);
  });

  it('有 hover 时 hover 值优先覆盖', () => {
    const { foundation } = makeFoundation({ value: 3, hoverValue: 4.5 });
    expect(foundation.displayValue()).toBe(4.5);
  });
});

describe('handleHover', () => {
  it('新 hover 值与当前不同时更新并返回 true', () => {
    const { foundation, getState } = makeFoundation({ value: 1 });
    const changed = foundation.handleHover(3, 0.9);
    expect(changed).toBe(true);
    expect(getState().hoverValue).toBe(4);
  });

  it('hover 到同一个值不重复触发', () => {
    const { foundation } = makeFoundation({ value: 1, hoverValue: 4 });
    expect(foundation.handleHover(3, 0.9)).toBe(false);
  });

  it('clearedValue 守卫：hover 到刚清零的值时不触发（防止清零后视觉复原）', () => {
    const { foundation } = makeFoundation({ value: 0, hoverValue: undefined, clearedValue: 3 });
    expect(foundation.handleHover(2, 0.9)).toBe(false);
  });
});

describe('handleLeave', () => {
  it('清空 hoverValue', () => {
    const { foundation, getState } = makeFoundation({ hoverValue: 3 });
    foundation.handleLeave();
    expect(getState().hoverValue).toBeUndefined();
  });
});

describe('handleClick', () => {
  it('点击新值时提交并清空 clearedValue', () => {
    const { foundation, getState } = makeFoundation({ value: 2, clearedValue: 1 });
    const result = foundation.handleClick(3, 0.9, false);
    expect(result).toEqual({ value: 4, changed: true });
    expect(getState().value).toBe(4);
    expect(getState().clearedValue).toBeNull();
  });

  it('allowClear=true 时点击当前已选值清零', () => {
    const { foundation, getState } = makeFoundation({ value: 3 }, { allowClear: true });
    const result = foundation.handleClick(2, 0.9, false);
    expect(result).toEqual({ value: 0, changed: true });
    expect(getState().clearedValue).toBe(3);
  });

  it('allowClear=false 时点击当前已选值不清零，重复设为同值', () => {
    const { foundation, getState } = makeFoundation({ value: 3 }, { allowClear: false });
    const result = foundation.handleClick(2, 0.9, false);
    expect(result).toEqual({ value: 3, changed: false });
    expect(getState().value).toBe(3);
  });

  it('点击后清空 hoverValue', () => {
    const { foundation, getState } = makeFoundation({ value: 1, hoverValue: 4 });
    foundation.handleClick(3, 0.9, false);
    expect(getState().hoverValue).toBeUndefined();
  });

  it('受控模式（isControlled=true）：不写 value，只清空 hoverValue/clearedValue（回归防护：真机验证过父组件拒绝更新时 UI 曾永久停留在点击产生的中间态，踩坑记录）', () => {
    const { foundation, getState } = makeFoundation({ value: 2, hoverValue: 4, clearedValue: null });
    const result = foundation.handleClick(3, 0.9, true);
    expect(result).toEqual({ value: 4, changed: true });
    expect(getState().value).toBe(2);
    expect(getState().hoverValue).toBeUndefined();
  });

  it('受控模式下 allowClear 触发清零：不写 value，但仍记录 clearedValue 供 hover 守卫使用', () => {
    const { foundation, getState } = makeFoundation({ value: 3 }, { allowClear: true });
    const result = foundation.handleClick(2, 0.9, true);
    expect(result).toEqual({ value: 0, changed: true });
    expect(getState().value).toBe(3);
    expect(getState().clearedValue).toBe(3);
  });
});

describe('handleKeyDown', () => {
  it('ArrowRight/ArrowUp 按 step 递增', () => {
    const { foundation, getState } = makeFoundation({ value: 2 }, { allowHalf: false });
    foundation.handleKeyDown('ArrowRight', false);
    expect(getState().value).toBe(3);
  });

  it('ArrowLeft/ArrowDown 按 step 递减', () => {
    const { foundation, getState } = makeFoundation({ value: 2 }, { allowHalf: false });
    foundation.handleKeyDown('ArrowLeft', false);
    expect(getState().value).toBe(1);
  });

  it('allowHalf=true 时 step 为 0.5', () => {
    const { foundation, getState } = makeFoundation({ value: 2 }, { allowHalf: true });
    foundation.handleKeyDown('ArrowRight', false);
    expect(getState().value).toBe(2.5);
  });

  it('超过 count 时环绕归零（不是钳制在 count）', () => {
    const { foundation, getState } = makeFoundation({ value: 5 }, { count: 5, allowHalf: false });
    foundation.handleKeyDown('ArrowRight', false);
    expect(getState().value).toBe(0);
  });

  it('低于 0 时环绕跳到 count（不是钳制在 0）', () => {
    const { foundation, getState } = makeFoundation({ value: 0 }, { count: 5, allowHalf: false });
    foundation.handleKeyDown('ArrowLeft', false);
    expect(getState().value).toBe(5);
  });

  it('非方向键返回 null', () => {
    const { foundation } = makeFoundation({ value: 2 });
    expect(foundation.handleKeyDown('Enter', false)).toBeNull();
  });

  it('按键后清空 hoverValue 和 clearedValue', () => {
    const { foundation, getState } = makeFoundation({ value: 2, hoverValue: 3, clearedValue: 1 });
    foundation.handleKeyDown('ArrowRight', false);
    expect(getState().hoverValue).toBeUndefined();
    expect(getState().clearedValue).toBeNull();
  });

  it('受控模式（isControlled=true）：不写 value，只清空 hoverValue/clearedValue', () => {
    const { foundation, getState } = makeFoundation({ value: 2, hoverValue: 3, clearedValue: 1 });
    const result = foundation.handleKeyDown('ArrowRight', true);
    expect(result).toEqual({ value: 3, changed: true });
    expect(getState().value).toBe(2);
    expect(getState().hoverValue).toBeUndefined();
    expect(getState().clearedValue).toBeNull();
  });

  it('isRtl=true 时 ArrowRight/ArrowUp 变为递减（对齐 Semi RTL 下"往右操作应减小值"的语义）', () => {
    const { foundation, getState } = makeFoundation({ value: 2 }, { allowHalf: false, isRtl: true });
    foundation.handleKeyDown('ArrowRight', false);
    expect(getState().value).toBe(1);
  });

  it('isRtl=true 时 ArrowLeft/ArrowDown 变为递增', () => {
    const { foundation, getState } = makeFoundation({ value: 2 }, { allowHalf: false, isRtl: true });
    foundation.handleKeyDown('ArrowLeft', false);
    expect(getState().value).toBe(3);
  });

  it('isRtl=true 时环绕逻辑不受影响（超过 count 归零、低于 0 跳到 count）', () => {
    const { foundation: f1, getState: s1 } = makeFoundation({ value: 0 }, { count: 5, allowHalf: false, isRtl: true });
    f1.handleKeyDown('ArrowRight', false);
    expect(s1().value).toBe(5);

    const { foundation: f2, getState: s2 } = makeFoundation({ value: 5 }, { count: 5, allowHalf: false, isRtl: true });
    f2.handleKeyDown('ArrowLeft', false);
    expect(s2().value).toBe(0);
  });
});

describe('getStarFillState', () => {
  it('display >= starValue 时 full', () => {
    const { foundation } = makeFoundation({ value: 3 });
    expect(foundation.getStarFillState(0)).toBe('full');
    expect(foundation.getStarFillState(2)).toBe('full');
  });

  it('display < starValue 时 empty', () => {
    const { foundation } = makeFoundation({ value: 3 });
    expect(foundation.getStarFillState(3)).toBe('empty');
  });

  it('allowHalf 且 display 落在 [starValue-0.5, starValue) 时 half', () => {
    const { foundation } = makeFoundation({ value: 2.5 }, { allowHalf: true });
    expect(foundation.getStarFillState(2)).toBe('half');
    expect(foundation.getStarFillState(1)).toBe('full');
    expect(foundation.getStarFillState(3)).toBe('empty');
  });

  it('allowHalf=false 时不产生 half 态', () => {
    const { foundation } = makeFoundation({ value: 2.5 }, { allowHalf: false });
    expect(foundation.getStarFillState(2)).toBe('empty');
  });

  it('hover 中时按 hoverValue 计算填充态', () => {
    const { foundation } = makeFoundation({ value: 1, hoverValue: 4 });
    expect(foundation.getStarFillState(3)).toBe('full');
    expect(foundation.getStarFillState(0)).toBe('full');
  });
});
