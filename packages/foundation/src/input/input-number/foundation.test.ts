import { describe, it, expect, vi } from 'vitest';
import { InputNumberFoundation, type InputNumberState, type InputNumberBounds } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: InputNumberState): Adapter<InputNumberState> & { _raw: () => InputNumberState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<InputNumberState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

const bounds: InputNumberBounds = { min: -Infinity, max: Infinity, step: 1 };
const bounded: InputNumberBounds = { min: 1, max: 10, step: 1 };

describe('InputNumberFoundation.clamp (static)', () => {
  it('returns the value unchanged when within bounds', () => {
    expect(InputNumberFoundation.clamp(5, bounded)).toBe(5);
  });

  it('clamps to max when value exceeds it', () => {
    expect(InputNumberFoundation.clamp(20, bounded)).toBe(10);
  });

  it('clamps to min when value is below it', () => {
    expect(InputNumberFoundation.clamp(-5, bounded)).toBe(1);
  });
});

describe('InputNumberFoundation.parse (static)', () => {
  it('parses a valid numeric string', () => {
    expect(InputNumberFoundation.parse('42')).toBe(42);
  });

  it('returns undefined for an empty string', () => {
    expect(InputNumberFoundation.parse('')).toBeUndefined();
    expect(InputNumberFoundation.parse('   ')).toBeUndefined();
  });

  it('returns undefined for a non-numeric intermediate string', () => {
    expect(InputNumberFoundation.parse('-')).toBeUndefined();
    expect(InputNumberFoundation.parse('abc')).toBeUndefined();
  });

  it('parses negative and decimal numbers', () => {
    expect(InputNumberFoundation.parse('-3.5')).toBe(-3.5);
  });
});

describe('InputNumberFoundation.handleInput', () => {
  it('uncontrolled mode: updates inputValue and value, calls onChange with the parsed number', () => {
    const adapter = createMockAdapter({ inputValue: '', value: undefined, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleInput('42', false, onChange);

    expect(adapter._raw().inputValue).toBe('42');
    expect(adapter._raw().value).toBe(42);
    expect(onChange).toHaveBeenCalledWith(42);
  });

  it('uncontrolled mode: intermediate non-numeric input updates inputValue but not onChange', () => {
    const adapter = createMockAdapter({ inputValue: '', value: undefined, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleInput('-', false, onChange);

    expect(adapter._raw().inputValue).toBe('-');
    expect(adapter._raw().value).toBeUndefined();
    expect(onChange).not.toHaveBeenCalled();
  });

  it('controlled mode: does not mutate internal value, only inputValue for display', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleInput('7', true, onChange);

    expect(adapter._raw().value).toBe(5);
    expect(onChange).toHaveBeenCalledWith(7);
  });
});

describe('InputNumberFoundation.handleBlur', () => {
  it('clamps out-of-range value on blur and reports the clamped value', () => {
    const adapter = createMockAdapter({ inputValue: '20', value: 20, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleBlur(bounded, false, onChange);

    expect(adapter._raw().value).toBe(10);
    expect(adapter._raw().inputValue).toBe('10');
    expect(adapter._raw().isFocus).toBe(false);
    expect(onChange).toHaveBeenCalledWith(10);
  });

  it('does not call onChange when the value is already within bounds', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleBlur(bounded, false, onChange);

    expect(onChange).not.toHaveBeenCalled();
  });

  it('resets inputValue to empty when the value cannot be parsed (e.g. trailing "-")', () => {
    const adapter = createMockAdapter({ inputValue: '-', value: undefined, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);

    foundation.handleBlur(bounds, false);

    expect(adapter._raw().inputValue).toBe('');
    expect(adapter._raw().value).toBeUndefined();
  });

  it('controlled mode: does not mutate internal value', () => {
    const adapter = createMockAdapter({ inputValue: '20', value: 20, isFocus: true });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleBlur(bounded, true, onChange);

    expect(adapter._raw().value).toBe(20);
    expect(onChange).toHaveBeenCalledWith(10);
  });
});

describe('InputNumberFoundation.handleStep', () => {
  it('uncontrolled mode: increments by step and calls onChange', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleStep(1, bounds, false, false, onChange);

    expect(adapter._raw().value).toBe(6);
    expect(onChange).toHaveBeenCalledWith(6);
  });

  it('uncontrolled mode: decrements by step', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);

    foundation.handleStep(-1, bounds, false, false);

    expect(adapter._raw().value).toBe(4);
  });

  it('defaults to 0 as the base when value is undefined', () => {
    const adapter = createMockAdapter({ inputValue: '', value: undefined, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);

    foundation.handleStep(1, bounds, false, false);

    expect(adapter._raw().value).toBe(1);
  });

  it('clamps the stepped value to bounds', () => {
    const adapter = createMockAdapter({ inputValue: '10', value: 10, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);

    foundation.handleStep(1, bounded, false, false);

    expect(adapter._raw().value).toBe(10);
  });

  it('disabled: does nothing', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleStep(1, bounds, false, true, onChange);

    expect(adapter._raw().value).toBe(5);
    expect(onChange).not.toHaveBeenCalled();
  });

  it('controlled mode: does not mutate internal value', () => {
    const adapter = createMockAdapter({ inputValue: '5', value: 5, isFocus: false });
    const foundation = new InputNumberFoundation(adapter);
    const onChange = vi.fn();

    foundation.handleStep(1, bounds, true, false, onChange);

    expect(adapter._raw().value).toBe(5);
    expect(onChange).toHaveBeenCalledWith(6);
  });
});

describe('InputNumberFoundation.isStepDisabled (static)', () => {
  it('increment disabled at max', () => {
    expect(InputNumberFoundation.isStepDisabled(1, 10, bounded, false)).toBe(true);
  });

  it('decrement disabled at min', () => {
    expect(InputNumberFoundation.isStepDisabled(-1, 1, bounded, false)).toBe(true);
  });

  it('not disabled within range', () => {
    expect(InputNumberFoundation.isStepDisabled(1, 5, bounded, false)).toBe(false);
    expect(InputNumberFoundation.isStepDisabled(-1, 5, bounded, false)).toBe(false);
  });

  it('always disabled when the component itself is disabled', () => {
    expect(InputNumberFoundation.isStepDisabled(1, 5, bounded, true)).toBe(true);
  });

  it('not disabled when value is undefined (no value entered yet)', () => {
    expect(InputNumberFoundation.isStepDisabled(1, undefined, bounded, false)).toBe(false);
  });
});
