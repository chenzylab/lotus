import { describe, it, expect } from 'vitest';
import { PinCodeFoundation, type PinCodeState, type PinCodeFoundationOptions } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createFoundation(opts: Partial<PinCodeFoundationOptions> = {}, initial: string[] = ['', '', '', '']) {
  let state: PinCodeState = { valueList: initial };
  const adapter: Adapter<PinCodeState> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new PinCodeFoundation(adapter, { count: 4, format: 'number', ...opts });
  return { foundation, getState: () => state };
}

describe('PinCodeFoundation', () => {
  describe('writeChar', () => {
    it('合法字符：写入并推进焦点到下一格', () => {
      const { foundation, getState } = createFoundation();
      const result = foundation.writeChar(0, '5', false);
      expect(result?.valueList).toEqual(['5', '', '', '']);
      expect(result?.focusIndex).toBe(1);
      expect(result?.completed).toBe(false);
      expect(getState().valueList).toEqual(['5', '', '', '']);
    });

    it('写入末格：completed=true，focusIndex=null（不再推进）', () => {
      const { foundation } = createFoundation({}, ['1', '2', '3', '']);
      const result = foundation.writeChar(3, '4', false);
      expect(result?.completed).toBe(true);
      expect(result?.focusIndex).toBeNull();
    });

    it('非法字符：返回 null，不做任何变更', () => {
      const { foundation, getState } = createFoundation();
      const before = getState().valueList;
      expect(foundation.writeChar(0, 'a', false)).toBeNull();
      expect(getState().valueList).toBe(before);
    });

    it('受控模式：不更新内部 state', () => {
      const { foundation, getState } = createFoundation();
      foundation.writeChar(0, '5', true);
      expect(getState().valueList).toEqual(['', '', '', '']);
    });
  });

  describe('handleFocusMoveKey', () => {
    it('Backspace：无条件清空当前格并回退焦点（对齐 Semi，不判断当前格是否已空）', () => {
      const { foundation, getState } = createFoundation({}, ['1', '2', '', '']);
      const result = foundation.handleFocusMoveKey('Backspace', 1, false);
      expect(result?.valueList).toEqual(['1', '', '', '']);
      expect(result?.focusIndex).toBe(0);
      expect(getState().valueList).toEqual(['1', '', '', '']);
    });

    it('Backspace 在首格：焦点钳制在 0', () => {
      const { foundation } = createFoundation({}, ['1', '', '', '']);
      const result = foundation.handleFocusMoveKey('Backspace', 0, false);
      expect(result?.focusIndex).toBe(0);
    });

    it('Delete：清空当前格并前进焦点', () => {
      const { foundation, getState } = createFoundation({}, ['1', '2', '3', '']);
      const result = foundation.handleFocusMoveKey('Delete', 1, false);
      expect(result?.valueList).toEqual(['1', '', '3', '']);
      expect(result?.focusIndex).toBe(2);
      expect(getState().valueList).toEqual(['1', '', '3', '']);
    });

    it('Delete 在末格：焦点钳制在 count-1', () => {
      const { foundation } = createFoundation({}, ['1', '2', '3', '4']);
      const result = foundation.handleFocusMoveKey('Delete', 3, false);
      expect(result?.focusIndex).toBe(3);
    });

    it('ArrowLeft：只移动焦点，不改变 valueList', () => {
      const { foundation, getState } = createFoundation({}, ['1', '2', '3', '4']);
      const before = getState().valueList;
      const result = foundation.handleFocusMoveKey('ArrowLeft', 2, false);
      expect(result?.focusIndex).toBe(1);
      expect(result?.valueList).toBe(before);
    });

    it('ArrowRight：只移动焦点，钳制在 count-1', () => {
      const { foundation } = createFoundation({}, ['1', '2', '3', '4']);
      const result = foundation.handleFocusMoveKey('ArrowRight', 3, false);
      expect(result?.focusIndex).toBe(3);
    });

    it('受控模式下 Backspace：不更新内部 state', () => {
      const { foundation, getState } = createFoundation({}, ['1', '2', '', '']);
      foundation.handleFocusMoveKey('Backspace', 1, true);
      expect(getState().valueList).toEqual(['1', '2', '', '']);
    });
  });

  describe('handlePaste', () => {
    it('非受控：写入 state 并返回聚焦索引', () => {
      const { foundation, getState } = createFoundation();
      const result = foundation.handlePaste(0, '123', false);
      expect(result.valueList).toEqual(['1', '2', '3', '']);
      expect(result.focusIndex).toBe(3);
      expect(getState().valueList).toEqual(['1', '2', '3', '']);
    });

    it('受控：不更新内部 state，仍返回计算结果', () => {
      const { foundation, getState } = createFoundation();
      foundation.handlePaste(0, '123', true);
      expect(getState().valueList).toEqual(['', '', '', '']);
    });

    it('粘贴写满全部格：completed=true', () => {
      const { foundation } = createFoundation();
      const result = foundation.handlePaste(0, '1234', false);
      expect(result.completed).toBe(true);
    });
  });

  describe('syncValueList', () => {
    it('归一化到 count 长度', () => {
      const { foundation, getState } = createFoundation();
      foundation.syncValueList('12');
      expect(getState().valueList).toEqual(['1', '2', '', '']);
    });

    it('超长截断', () => {
      const { foundation, getState } = createFoundation();
      foundation.syncValueList('123456');
      expect(getState().valueList).toEqual(['1', '2', '3', '4']);
    });
  });
});
