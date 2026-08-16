import { describe, it, expect, vi } from 'vitest';
import { RadioFoundation, RadioGroupFoundation, type RadioState, type RadioGroupState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter<S extends object>(initial: S): Adapter<S> & { _raw: () => S } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<S>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

describe('RadioFoundation.handleToggle', () => {
  it('uncontrolled mode: selecting an unchecked radio checks it and calls onChange', () => {
    const adapter = createMockAdapter<RadioState>({ checked: false, disabled: false });
    const foundation = new RadioFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, false, onChange);

    expect(adapter._raw().checked).toBe(true);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('default mode: clicking an already-checked radio does nothing (no onChange)', () => {
    const adapter = createMockAdapter<RadioState>({ checked: true, disabled: false });
    const foundation = new RadioFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, false, onChange);

    expect(adapter._raw().checked).toBe(true);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('advanced mode: clicking an already-checked radio toggles it back to unchecked', () => {
    const adapter = createMockAdapter<RadioState>({ checked: true, disabled: false });
    const foundation = new RadioFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, true, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).toHaveBeenCalledWith(false);
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter<RadioState>({ checked: false, disabled: false });
    const foundation = new RadioFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(true, false, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('disabled state: does not toggle and does not call onChange', () => {
    const adapter = createMockAdapter<RadioState>({ checked: false, disabled: true });
    const foundation = new RadioFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, false, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('does not throw when onChange is omitted', () => {
    const adapter = createMockAdapter<RadioState>({ checked: false, disabled: false });
    const foundation = new RadioFoundation(adapter);

    expect(() => foundation.handleToggle(false, false)).not.toThrow();
  });
});

describe('RadioGroupFoundation.selectValue', () => {
  it('uncontrolled mode: sets the new value and calls onChange', () => {
    const adapter = createMockAdapter<RadioGroupState>({ value: 'a' });
    const foundation = new RadioGroupFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectValue('b', false, onChange);

    expect(adapter._raw().value).toBe('b');
    expect(onChange).toHaveBeenCalledWith('b');
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter<RadioGroupState>({ value: 'a' });
    const foundation = new RadioGroupFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectValue('b', true, onChange);

    expect(adapter._raw().value).toBe('a');
    expect(onChange).toHaveBeenCalledWith('b');
  });

  it('does not throw when onChange is omitted', () => {
    const adapter = createMockAdapter<RadioGroupState>({ value: undefined });
    const foundation = new RadioGroupFoundation(adapter);

    expect(() => foundation.selectValue('a', false)).not.toThrow();
  });
});

describe('RadioGroupFoundation.isChecked (static)', () => {
  it('returns true when value equals the item value', () => {
    expect(RadioGroupFoundation.isChecked('a', 'a')).toBe(true);
  });

  it('returns false when value differs from the item value', () => {
    expect(RadioGroupFoundation.isChecked('a', 'b')).toBe(false);
  });

  it('returns false when either value or itemValue is undefined', () => {
    expect(RadioGroupFoundation.isChecked(undefined, 'a')).toBe(false);
    expect(RadioGroupFoundation.isChecked('a', undefined)).toBe(false);
  });
});
