import { describe, it, expect, vi } from 'vitest';
import { SelectFoundation, type SelectState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: SelectState): Adapter<SelectState> & { _raw: () => SelectState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<SelectState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

describe('SelectFoundation.selectSingle', () => {
  it('uncontrolled mode: replaces value and calls onChange', () => {
    const adapter = createMockAdapter({ value: 'a' });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectSingle('b', false, onChange);

    expect(adapter._raw().value).toBe('b');
    expect(onChange).toHaveBeenCalledWith('b');
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter({ value: 'a' });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectSingle('b', true, onChange);

    expect(adapter._raw().value).toBe('a');
    expect(onChange).toHaveBeenCalledWith('b');
  });
});

describe('SelectFoundation.selectMultiple', () => {
  it('uncontrolled mode: adds value when not present', () => {
    const adapter = createMockAdapter({ value: ['a'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectMultiple('b', false, onChange);

    expect(adapter._raw().value).toEqual(['a', 'b']);
    expect(onChange).toHaveBeenCalledWith(['a', 'b']);
  });

  it('uncontrolled mode: removes value when already present (toggle semantics)', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectMultiple('a', false, onChange);

    expect(adapter._raw().value).toEqual(['b']);
    expect(onChange).toHaveBeenCalledWith(['b']);
  });

  it('treats non-array current value as empty (defensive)', () => {
    const adapter = createMockAdapter({ value: undefined });
    const foundation = new SelectFoundation(adapter);

    foundation.selectMultiple('a', false);

    expect(adapter._raw().value).toEqual(['a']);
  });

  it('controlled mode: does not mutate internal state, only calls onChange', () => {
    const adapter = createMockAdapter({ value: ['a'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.selectMultiple('b', true, onChange);

    expect(adapter._raw().value).toEqual(['a']);
    expect(onChange).toHaveBeenCalledWith(['a', 'b']);
  });
});

describe('SelectFoundation.removeMultipleValue', () => {
  it('uncontrolled mode: removes the given value', () => {
    const adapter = createMockAdapter({ value: ['a', 'b', 'c'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.removeMultipleValue('b', false, onChange);

    expect(adapter._raw().value).toEqual(['a', 'c']);
    expect(onChange).toHaveBeenCalledWith(['a', 'c']);
  });

  it('controlled mode: does not mutate internal state', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.removeMultipleValue('a', true, onChange);

    expect(adapter._raw().value).toEqual(['a', 'b']);
    expect(onChange).toHaveBeenCalledWith(['b']);
  });
});

describe('SelectFoundation.clear', () => {
  it('single mode: clears to undefined', () => {
    const adapter = createMockAdapter({ value: 'a' });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.clear(false, false, onChange);

    expect(adapter._raw().value).toBeUndefined();
    expect(onChange).toHaveBeenCalledWith(undefined);
  });

  it('multiple mode: clears to empty array', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.clear(true, false, onChange);

    expect(adapter._raw().value).toEqual([]);
    expect(onChange).toHaveBeenCalledWith([]);
  });

  it('controlled mode: does not mutate internal state', () => {
    const adapter = createMockAdapter({ value: 'a' });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();

    foundation.clear(false, true, onChange);

    expect(adapter._raw().value).toBe('a');
    expect(onChange).toHaveBeenCalledWith(undefined);
  });
});

describe('SelectFoundation.isSingleChecked (static)', () => {
  it('returns true when value equals itemValue (non-array)', () => {
    expect(SelectFoundation.isSingleChecked('a', 'a')).toBe(true);
  });

  it('returns false when value differs', () => {
    expect(SelectFoundation.isSingleChecked('a', 'b')).toBe(false);
  });

  it('returns false when value is an array (multiple mode)', () => {
    expect(SelectFoundation.isSingleChecked(['a'], 'a')).toBe(false);
  });
});

describe('SelectFoundation.isMultipleChecked (static)', () => {
  it('returns true when array includes itemValue', () => {
    expect(SelectFoundation.isMultipleChecked(['a', 'b'], 'a')).toBe(true);
  });

  it('returns false when array does not include itemValue', () => {
    expect(SelectFoundation.isMultipleChecked(['a'], 'b')).toBe(false);
  });

  it('returns false when value is not an array (single mode)', () => {
    expect(SelectFoundation.isMultipleChecked('a', 'a')).toBe(false);
  });
});
