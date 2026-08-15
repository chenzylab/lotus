import { describe, it, expect, vi } from 'vitest';
import { SwitchFoundation, type SwitchState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: SwitchState): Adapter<SwitchState> & { _raw: () => SwitchState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<SwitchState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

describe('SwitchFoundation.handleToggle', () => {
  it('uncontrolled mode: toggles internal state and calls onChange with the new value', () => {
    const adapter = createMockAdapter({ checked: false, disabled: false, loading: false });
    const foundation = new SwitchFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, onChange);

    expect(adapter._raw().checked).toBe(true);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('uncontrolled mode: toggling twice returns to the original state', () => {
    const adapter = createMockAdapter({ checked: false, disabled: false, loading: false });
    const foundation = new SwitchFoundation(adapter);

    foundation.handleToggle(false);
    foundation.handleToggle(false);

    expect(adapter._raw().checked).toBe(false);
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter({ checked: false, disabled: false, loading: false });
    const foundation = new SwitchFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(true, onChange);

    // 受控模式下内部 state 不应被 Foundation 直接改写——真实值来自外部重新传入的 props.checked
    expect(adapter._raw().checked).toBe(false);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('disabled state: does not toggle and does not call onChange', () => {
    const adapter = createMockAdapter({ checked: false, disabled: true, loading: false });
    const foundation = new SwitchFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('loading state: does not toggle and does not call onChange', () => {
    const adapter = createMockAdapter({ checked: false, disabled: false, loading: true });
    const foundation = new SwitchFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('does not throw when onChange is omitted', () => {
    const adapter = createMockAdapter({ checked: false, disabled: false, loading: false });
    const foundation = new SwitchFoundation(adapter);

    expect(() => foundation.handleToggle(false)).not.toThrow();
  });
});
