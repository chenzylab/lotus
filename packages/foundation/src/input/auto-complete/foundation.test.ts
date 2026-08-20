import { describe, it, expect } from 'vitest';
import {
  normalizeOptions,
  findMatchedOptionIndex,
  computeInitialFocusIndex,
  moveFocusIndex,
  AutoCompleteFoundation,
  type AutoCompleteState,
  type AutoCompleteOptionItem,
} from './foundation.js';

describe('normalizeOptions', () => {
  it('字符串数组：value/label 都等于自身，非 disabled', () => {
    const result = normalizeOptions(['a', 'b']);
    expect(result).toEqual([
      { value: 'a', label: 'a', disabled: false, raw: 'a' },
      { value: 'b', label: 'b', disabled: false, raw: 'b' },
    ]);
  });

  it('数字数组：同样归一化', () => {
    const result = normalizeOptions([1, 2]);
    expect(result[0]).toEqual({ value: 1, label: 1, disabled: false, raw: 1 });
  });

  it('对象数组：label 缺失时 fallback 到 value', () => {
    const result = normalizeOptions([{ value: 'a' }]);
    expect(result[0]).toEqual({ value: 'a', label: 'a', disabled: false, raw: { value: 'a' } });
  });

  it('对象数组：完整字段透传，disabled 正确读取', () => {
    const item = { value: 'a', label: 'A标签', disabled: true };
    const result = normalizeOptions([item]);
    expect(result[0]).toEqual({ value: 'a', label: 'A标签', disabled: true, raw: item });
  });

  it('不做任何过滤——原样转换全部传入项', () => {
    const result = normalizeOptions(['x', 'y', 'z']);
    expect(result.length).toBe(3);
  });
});

describe('findMatchedOptionIndex', () => {
  const options = normalizeOptions(['apple', 'banana', 'cherry']);

  it('精确匹配返回索引', () => {
    expect(findMatchedOptionIndex(options, 'banana')).toBe(1);
  });

  it('无匹配返回 -1', () => {
    expect(findMatchedOptionIndex(options, 'grape')).toBe(-1);
  });

  it('inputValue 为 undefined 时返回 -1', () => {
    expect(findMatchedOptionIndex(options, undefined)).toBe(-1);
  });

  it('数字/字符串宽松比较（String() 转换）', () => {
    const numOptions = normalizeOptions([1, 2, 3]);
    expect(findMatchedOptionIndex(numOptions, '2')).toBe(1);
  });
});

describe('computeInitialFocusIndex', () => {
  const options = normalizeOptions(['apple', 'banana', 'cherry']);

  it('精确匹配当前 inputValue 时优先高亮该项', () => {
    expect(computeInitialFocusIndex(options, 'banana', false)).toBe(1);
  });

  it('无匹配且 defaultActiveFirstOption=false 时不高亮任何项', () => {
    expect(computeInitialFocusIndex(options, 'grape', false)).toBe(-1);
  });

  it('无匹配且 defaultActiveFirstOption=true 时高亮第一个非 disabled 项', () => {
    expect(computeInitialFocusIndex(options, 'grape', true)).toBe(0);
  });

  it('第一项 disabled 时跳过，高亮下一个非 disabled 项', () => {
    const withDisabled = normalizeOptions([{ value: 'apple', disabled: true }, 'banana']);
    expect(computeInitialFocusIndex(withDisabled, undefined, true)).toBe(1);
  });

  it('匹配到的项恰好是 disabled 时不高亮它，走 defaultActiveFirstOption 逻辑', () => {
    const withDisabled = normalizeOptions([{ value: 'apple', disabled: true }, 'banana']);
    expect(computeInitialFocusIndex(withDisabled, 'apple', true)).toBe(1);
  });
});

describe('moveFocusIndex', () => {
  const options = normalizeOptions(['a', 'b', 'c']);

  it('向下移动到下一项', () => {
    expect(moveFocusIndex(options, 0, 1)).toBe(1);
  });

  it('向上移动到上一项', () => {
    expect(moveFocusIndex(options, 1, -1)).toBe(0);
  });

  it('向下越界时循环回绕到第一项', () => {
    expect(moveFocusIndex(options, 2, 1)).toBe(0);
  });

  it('向上越界时循环回绕到最后一项', () => {
    expect(moveFocusIndex(options, 0, -1)).toBe(2);
  });

  it('从 -1（未高亮）开始向下移动到第一项', () => {
    expect(moveFocusIndex(options, -1, 1)).toBe(0);
  });

  it('跳过 disabled 项', () => {
    const withDisabled = normalizeOptions(['a', { value: 'b', disabled: true }, 'c']);
    expect(moveFocusIndex(withDisabled, 0, 1)).toBe(2);
  });

  it('全部 disabled 时返回 -1', () => {
    const allDisabled = normalizeOptions([{ value: 'a', disabled: true }, { value: 'b', disabled: true }]);
    expect(moveFocusIndex(allDisabled, 0, 1)).toBe(-1);
  });

  it('空候选列表返回 -1', () => {
    expect(moveFocusIndex([], 0, 1)).toBe(-1);
  });
});

function makeFoundation(initial: Partial<AutoCompleteState> = {}) {
  let state: AutoCompleteState = { inputValue: '', visible: false, focusIndex: -1, ...initial };
  const foundation = new AutoCompleteFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('open / close / toggle', () => {
  const options = normalizeOptions(['apple', 'banana']);

  it('open 时设置 visible=true 并计算 focusIndex', () => {
    const { foundation, getState } = makeFoundation({ inputValue: 'banana' });
    foundation.open(options, false);
    expect(getState().visible).toBe(true);
    expect(getState().focusIndex).toBe(1);
  });

  it('已经打开时 open 不重复计算（幂等）', () => {
    const { foundation, getState } = makeFoundation({ visible: true, focusIndex: 5 });
    foundation.open(options, false);
    expect(getState().focusIndex).toBe(5);
  });

  it('close 重置 visible 和 focusIndex', () => {
    const { foundation, getState } = makeFoundation({ visible: true, focusIndex: 1 });
    foundation.close();
    expect(getState().visible).toBe(false);
    expect(getState().focusIndex).toBe(-1);
  });

  it('toggle 在关闭时打开，打开时关闭', () => {
    const { foundation, getState } = makeFoundation();
    foundation.toggle(options, false);
    expect(getState().visible).toBe(true);
    foundation.toggle(options, false);
    expect(getState().visible).toBe(false);
  });
});

describe('openOnTriggerClick', () => {
  const options = normalizeOptions(['apple', 'banana']);

  it('关闭时点击触发器打开面板并计算高亮', () => {
    const { foundation, getState } = makeFoundation({ inputValue: 'banana' });
    foundation.openOnTriggerClick(options, false);
    expect(getState().visible).toBe(true);
    expect(getState().focusIndex).toBe(1);
  });

  it('已打开时点击触发器不做任何事（不关闭，不重算 focusIndex）', () => {
    const { foundation, getState } = makeFoundation({ visible: true, focusIndex: 5 });
    foundation.openOnTriggerClick(options, false);
    expect(getState().visible).toBe(true);
    expect(getState().focusIndex).toBe(5);
  });
});

describe('handleSearch', () => {
  const options = normalizeOptions(['apple', 'banana']);

  it('非受控模式下更新 inputValue', () => {
    const { foundation, getState } = makeFoundation();
    foundation.handleSearch('app', options, false, false);
    expect(getState().inputValue).toBe('app');
  });

  it('受控模式下不写 inputValue（交给外部通过 value prop 驱动）', () => {
    const { foundation, getState } = makeFoundation({ inputValue: 'original' });
    foundation.handleSearch('app', options, false, true);
    expect(getState().inputValue).toBe('original');
  });

  it('未打开时自动打开面板', () => {
    const { foundation, getState } = makeFoundation({ visible: false });
    foundation.handleSearch('a', options, false, false);
    expect(getState().visible).toBe(true);
  });

  it('已打开时保持打开，仅更新 focusIndex', () => {
    const { foundation, getState } = makeFoundation({ visible: true });
    foundation.handleSearch('banana', options, false, false);
    expect(getState().visible).toBe(true);
    expect(getState().focusIndex).toBe(1);
  });
});

describe('handleSelect', () => {
  const option: AutoCompleteOptionItem = { value: 'banana', label: 'banana', disabled: false, raw: 'banana' };

  it('非受控模式：回填 inputValue，关闭浮层', () => {
    const { foundation, getState } = makeFoundation({ visible: true });
    const result = foundation.handleSelect(option, 1, false);
    expect(result).toBe('banana');
    expect(getState().inputValue).toBe('banana');
    expect(getState().visible).toBe(false);
    expect(getState().focusIndex).toBe(1);
  });

  it('受控模式：不回填 inputValue，但仍关闭浮层', () => {
    const { foundation, getState } = makeFoundation({ visible: true, inputValue: 'original' });
    const result = foundation.handleSelect(option, 1, true);
    expect(result).toBe('banana');
    expect(getState().inputValue).toBe('original');
    expect(getState().visible).toBe(false);
  });
});

describe('handleArrowKey', () => {
  const options = normalizeOptions(['apple', 'banana', 'cherry']);

  it('未打开时先打开面板，不移动焦点', () => {
    const { foundation, getState } = makeFoundation({ visible: false });
    foundation.handleArrowKey(options, 1, false);
    expect(getState().visible).toBe(true);
  });

  it('已打开时按方向移动焦点', () => {
    const { foundation, getState } = makeFoundation({ visible: true, focusIndex: 0 });
    foundation.handleArrowKey(options, 1, false);
    expect(getState().focusIndex).toBe(1);
  });

  it('向上移动焦点', () => {
    const { foundation, getState } = makeFoundation({ visible: true, focusIndex: 1 });
    foundation.handleArrowKey(options, -1, false);
    expect(getState().focusIndex).toBe(0);
  });
});
