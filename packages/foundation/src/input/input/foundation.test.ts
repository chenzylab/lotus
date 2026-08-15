import { describe, it, expect, vi } from 'vitest';
import { InputFoundation, type InputState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: InputState): Adapter<InputState> & { _raw: () => InputState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<InputState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

const baseState: InputState = { value: '', isFocus: false, isHovering: false, eyeOpen: false };

describe('InputFoundation.handleInput', () => {
  it('非受控模式：更新内部 value 并触发 onChange', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();
    const event = new Event('input');

    foundation.handleInput('hello', event, false, false, onChange);

    expect(adapter._raw().value).toBe('hello');
    expect(onChange).toHaveBeenCalledWith('hello', event);
  });

  it('受控模式：不改内部 state，只触发 onChange', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleInput('hello', new Event('input'), true, false, onChange);

    expect(adapter._raw().value).toBe('');
    expect(onChange).toHaveBeenCalledWith('hello', expect.any(Event));
  });

  it('composition=true 且正在组合输入时：只更新展示值，不触发 onChange', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleCompositionStart(new Event('compositionstart') as CompositionEvent);
    foundation.handleInput('ni', new Event('input'), false, true, onChange);

    expect(adapter._raw().value).toBe('ni');
    expect(onChange).not.toHaveBeenCalled();
  });

  it('composition=false 时：即使有 compositionEnter 标志也照常触发 onChange', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleCompositionStart(new Event('compositionstart') as CompositionEvent);
    foundation.handleInput('a', new Event('input'), false, false, onChange);

    expect(onChange).toHaveBeenCalledWith('a', expect.any(Event));
  });
});

describe('InputFoundation composition 生命周期', () => {
  it('handleCompositionEnd + composition=true：触发一次 onChange 并更新内部值', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();
    const onCompositionEnd = vi.fn();

    foundation.handleCompositionStart(new Event('compositionstart') as CompositionEvent);
    foundation.handleCompositionEnd('你好', new Event('compositionend') as CompositionEvent, false, true, onChange, onCompositionEnd);

    expect(adapter._raw().value).toBe('你好');
    expect(onChange).toHaveBeenCalledWith('你好', expect.any(Event));
    expect(onCompositionEnd).toHaveBeenCalled();
  });

  it('handleCompositionEnd + composition=false：不重复触发 onChange（默认模式下 handleInput 已经触发过）', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleCompositionStart(new Event('compositionstart') as CompositionEvent);
    foundation.handleCompositionEnd('你好', new Event('compositionend') as CompositionEvent, false, false, onChange);

    expect(onChange).not.toHaveBeenCalled();
  });
});

describe('InputFoundation.handleClear', () => {
  it('非受控模式：清空内部 value，触发 onChange(\'\') 与 onClear', () => {
    const adapter = createMockAdapter({ ...baseState, value: 'hello' });
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();
    const onClear = vi.fn();

    foundation.handleClear(new Event('click') as MouseEvent, false, onChange, onClear);

    expect(adapter._raw().value).toBe('');
    expect(onChange).toHaveBeenCalledWith('', expect.any(Event));
    expect(onClear).toHaveBeenCalled();
  });

  it('受控模式：不改内部 value，仍触发 onChange 与 onClear', () => {
    const adapter = createMockAdapter({ ...baseState, value: 'hello' });
    const foundation = new InputFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleClear(new Event('click') as MouseEvent, true, onChange);

    expect(adapter._raw().value).toBe('hello');
    expect(onChange).toHaveBeenCalledWith('', expect.any(Event));
  });
});

describe('InputFoundation focus/blur/hover', () => {
  it('handleFocus 设置 isFocus=true 并触发 onFocus', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);
    const onFocus = vi.fn();

    foundation.handleFocus(new Event('focus') as FocusEvent, onFocus);

    expect(adapter._raw().isFocus).toBe(true);
    expect(onFocus).toHaveBeenCalled();
  });

  it('handleBlur 设置 isFocus=false 并触发 onBlur', () => {
    const adapter = createMockAdapter({ ...baseState, isFocus: true });
    const foundation = new InputFoundation(adapter);
    const onBlur = vi.fn();

    foundation.handleBlur(new Event('blur') as FocusEvent, onBlur);

    expect(adapter._raw().isFocus).toBe(false);
    expect(onBlur).toHaveBeenCalled();
  });

  it('handleMouseEnter/handleMouseLeave 切换 isHovering', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);

    foundation.handleMouseEnter();
    expect(adapter._raw().isHovering).toBe(true);

    foundation.handleMouseLeave();
    expect(adapter._raw().isHovering).toBe(false);
  });
});

describe('InputFoundation.toggleEye', () => {
  it('切换密码可见性', () => {
    const adapter = createMockAdapter(baseState);
    const foundation = new InputFoundation(adapter);

    foundation.toggleEye();
    expect(adapter._raw().eyeOpen).toBe(true);

    foundation.toggleEye();
    expect(adapter._raw().eyeOpen).toBe(false);
  });
});

describe('InputFoundation.isAllowClear', () => {
  it('有内容 + showClear + focus 时允许清除', () => {
    expect(InputFoundation.isAllowClear('hello', true, false, true, false)).toBe(true);
  });

  it('有内容 + showClear + hovering 时允许清除', () => {
    expect(InputFoundation.isAllowClear('hello', true, false, false, true)).toBe(true);
  });

  it('无内容时不允许清除', () => {
    expect(InputFoundation.isAllowClear('', true, false, true, false)).toBe(false);
  });

  it('showClear=false 时不允许清除', () => {
    expect(InputFoundation.isAllowClear('hello', false, false, true, false)).toBe(false);
  });

  it('disabled 时不允许清除', () => {
    expect(InputFoundation.isAllowClear('hello', true, true, true, false)).toBe(false);
  });

  it('既不 focus 也不 hovering 时不允许清除', () => {
    expect(InputFoundation.isAllowClear('hello', true, false, false, false)).toBe(false);
  });
});
