import { describe, it, expect, vi } from 'vitest';
import { CheckboxFoundation, CheckboxGroupFoundation, type CheckboxState, type CheckboxGroupState } from './foundation.js';
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

describe('CheckboxFoundation.handleToggle', () => {
  it('uncontrolled mode: toggles internal state and calls onChange with the new value', () => {
    const adapter = createMockAdapter<CheckboxState>({ checked: false, disabled: false });
    const foundation = new CheckboxFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, onChange);

    expect(adapter._raw().checked).toBe(true);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('uncontrolled mode: toggling twice returns to the original state', () => {
    const adapter = createMockAdapter<CheckboxState>({ checked: false, disabled: false });
    const foundation = new CheckboxFoundation(adapter);

    foundation.handleToggle(false);
    foundation.handleToggle(false);

    expect(adapter._raw().checked).toBe(false);
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter<CheckboxState>({ checked: false, disabled: false });
    const foundation = new CheckboxFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(true, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).toHaveBeenCalledWith(true);
  });

  it('disabled state: does not toggle and does not call onChange', () => {
    const adapter = createMockAdapter<CheckboxState>({ checked: false, disabled: true });
    const foundation = new CheckboxFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleToggle(false, onChange);

    expect(adapter._raw().checked).toBe(false);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('does not throw when onChange is omitted', () => {
    const adapter = createMockAdapter<CheckboxState>({ checked: false, disabled: false });
    const foundation = new CheckboxFoundation(adapter);

    expect(() => foundation.handleToggle(false)).not.toThrow();
  });
});

describe('CheckboxGroupFoundation.toggleValue', () => {
  it('uncontrolled mode: adds value when not present', () => {
    const adapter = createMockAdapter<CheckboxGroupState>({ value: ['a'] });
    const foundation = new CheckboxGroupFoundation(adapter);
    const onChange = vi.fn();

    foundation.toggleValue('b', false, onChange);

    expect(adapter._raw().value).toEqual(['a', 'b']);
    expect(onChange).toHaveBeenCalledWith(['a', 'b']);
  });

  it('uncontrolled mode: removes value when already present', () => {
    const adapter = createMockAdapter<CheckboxGroupState>({ value: ['a', 'b'] });
    const foundation = new CheckboxGroupFoundation(adapter);
    const onChange = vi.fn();

    foundation.toggleValue('a', false, onChange);

    expect(adapter._raw().value).toEqual(['b']);
    expect(onChange).toHaveBeenCalledWith(['b']);
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter<CheckboxGroupState>({ value: ['a'] });
    const foundation = new CheckboxGroupFoundation(adapter);
    const onChange = vi.fn();

    foundation.toggleValue('b', true, onChange);

    expect(adapter._raw().value).toEqual(['a']);
    expect(onChange).toHaveBeenCalledWith(['a', 'b']);
  });

  it('does not throw when onChange is omitted', () => {
    const adapter = createMockAdapter<CheckboxGroupState>({ value: [] });
    const foundation = new CheckboxGroupFoundation(adapter);

    expect(() => foundation.toggleValue('a', false)).not.toThrow();
  });
});

describe('CheckboxGroupFoundation.isChecked (static)', () => {
  it('returns true when value array includes the item value', () => {
    expect(CheckboxGroupFoundation.isChecked(['a', 'b'], 'a')).toBe(true);
  });

  it('returns false when value array does not include the item value', () => {
    expect(CheckboxGroupFoundation.isChecked(['a', 'b'], 'c')).toBe(false);
  });

  it('returns false when item value is undefined (standalone Checkbox not in a group)', () => {
    expect(CheckboxGroupFoundation.isChecked(['a'], undefined)).toBe(false);
  });
});
