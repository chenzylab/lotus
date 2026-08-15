import { describe, it, expect, vi } from 'vitest';
import { TextAreaFoundation, type TextAreaState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: TextAreaState): Adapter<TextAreaState> & { _raw: () => TextAreaState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<TextAreaState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

const baseState: TextAreaState = { value: '', isFocus: false, isHovering: false };

describe('TextAreaFoundation.handleInput', () => {
  it('非受控模式：更新内部 value 并触发 onChange', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new TextAreaFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleInput('多行\n文本', new Event('input'), false, false, onChange);

    expect(adapter._raw().value).toBe('多行\n文本');
    expect(onChange).toHaveBeenCalledWith('多行\n文本', expect.any(Event));
  });

  it('受控模式：不改内部 state', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new TextAreaFoundation(adapter);

    foundation.handleInput('x', new Event('input'), true, false);

    expect(adapter._raw().value).toBe('');
  });
});

describe('TextAreaFoundation composition 生命周期', () => {
  it('组合期间只更新展示值不触发 onChange，确认后触发一次', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new TextAreaFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleCompositionStart(new Event('compositionstart') as CompositionEvent);
    foundation.handleInput('ni', new Event('input'), false, true, onChange);
    expect(onChange).not.toHaveBeenCalled();

    foundation.handleCompositionEnd('你', new Event('compositionend') as CompositionEvent, false, true, onChange);
    expect(onChange).toHaveBeenCalledWith('你', expect.any(Event));
  });
});

describe('TextAreaFoundation.handleClear', () => {
  it('清空内部 value 并触发 onChange/onClear', () => {
    const adapter = createMockAdapter({ ...baseState, value: 'text' });
    const foundation = new TextAreaFoundation(adapter);
    const onChange = vi.fn();
    const onClear = vi.fn();

    foundation.handleClear(new Event('click') as MouseEvent, false, onChange, onClear);

    expect(adapter._raw().value).toBe('');
    expect(onChange).toHaveBeenCalledWith('', expect.any(Event));
    expect(onClear).toHaveBeenCalled();
  });
});

describe('TextAreaFoundation.isAllowClear', () => {
  it('readonly 时不允许清除（Input 没有这个约束，TextArea 独有）', () => {
    expect(TextAreaFoundation.isAllowClear('text', true, false, true, true, false)).toBe(false);
  });

  it('非 readonly 且满足其他条件时允许清除', () => {
    expect(TextAreaFoundation.isAllowClear('text', true, false, false, true, false)).toBe(true);
  });
});
