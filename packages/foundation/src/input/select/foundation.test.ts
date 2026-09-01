import { describe, it, expect, vi } from 'vitest';
import { SelectFoundation, filterSelectOptions, flattenSelectOptions, isSelectOptionGroup, type SelectState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: Omit<SelectState, 'searchInput'> & { searchInput?: string }): Adapter<SelectState> & { _raw: () => SelectState } {
  let state: SelectState = { searchInput: '', ...initial };
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

describe('SelectFoundation.handleSearch / resetSearch', () => {
  it('handleSearch 写入 searchInput 并回调 onSearch', () => {
    const adapter = createMockAdapter({ value: undefined });
    const foundation = new SelectFoundation(adapter);
    const onSearch = vi.fn();

    foundation.handleSearch('抖音', onSearch);

    expect(adapter._raw().searchInput).toBe('抖音');
    expect(onSearch).toHaveBeenCalledWith('抖音');
  });

  it('resetSearch 清空 searchInput', () => {
    const adapter = createMockAdapter({ value: undefined, searchInput: '抖音' });
    const foundation = new SelectFoundation(adapter);

    foundation.resetSearch();

    expect(adapter._raw().searchInput).toBe('');
  });
});

describe('filterSelectOptions', () => {
  const options = [
    { value: 'douyin', label: '抖音' },
    { value: 'ulikecam', label: '轻颜相机' },
    { value: 'jianying', label: '剪映' },
  ];

  it('filter 为 false/undefined 时不过滤，原样返回', () => {
    expect(filterSelectOptions(options, '抖', false)).toEqual(options);
    expect(filterSelectOptions(options, '抖', undefined)).toEqual(options);
  });

  it('filter 为 true 时按 label 做大小写不敏感包含匹配', () => {
    expect(filterSelectOptions(options, '音', true).map((o) => o.value)).toEqual(['douyin']);
    expect(filterSelectOptions([{ value: 'a', label: 'Douyin' }], 'DOUYIN', true).map((o) => o.value)).toEqual(['a']);
  });

  it('filter 为 true 时无匹配返回空数组', () => {
    expect(filterSelectOptions(options, '不存在', true)).toEqual([]);
  });

  it('filter 为函数时完全交给自定义逻辑判断', () => {
    const result = filterSelectOptions(options, 'x', (input, option) => option.value === 'jianying');
    expect(result.map((o) => o.value)).toEqual(['jianying']);
  });

  it('label 缺失时回退用 value 做字符串匹配', () => {
    const noLabel = [{ value: 'plain-text' }];
    expect(filterSelectOptions(noLabel, 'plain', true).map((o) => o.value)).toEqual(['plain-text']);
  });
});

describe('SelectFoundation.selectMultiple with max', () => {
  it('未达上限时正常新增并触发 onSelect', () => {
    const adapter = createMockAdapter({ value: ['a'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();
    const onSelect = vi.fn();

    foundation.selectMultiple('b', false, onChange, { max: 2, onSelect });

    expect(adapter._raw().value).toEqual(['a', 'b']);
    expect(onChange).toHaveBeenCalledWith(['a', 'b']);
    expect(onSelect).toHaveBeenCalledWith('b');
  });

  it('已达上限时新增被拦截，触发 onExceed，不调用 onChange', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();
    const onExceed = vi.fn();

    foundation.selectMultiple('c', false, onChange, { max: 2, onExceed });

    expect(adapter._raw().value).toEqual(['a', 'b']);
    expect(onChange).not.toHaveBeenCalled();
    expect(onExceed).toHaveBeenCalled();
  });

  it('已达上限时取消选中仍然允许，触发 onDeselect', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();
    const onDeselect = vi.fn();

    foundation.selectMultiple('a', false, onChange, { max: 2, onDeselect });

    expect(adapter._raw().value).toEqual(['b']);
    expect(onDeselect).toHaveBeenCalledWith('a');
  });
});

describe('SelectFoundation.removeMultipleValue triggers onDeselect', () => {
  it('移除时触发 onDeselect 回调', () => {
    const adapter = createMockAdapter({ value: ['a', 'b'] });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();
    const onDeselect = vi.fn();

    foundation.removeMultipleValue('a', false, onChange, onDeselect);

    expect(onDeselect).toHaveBeenCalledWith('a');
  });
});

describe('SelectFoundation.selectSingle triggers onSelect', () => {
  it('选中时同时触发 onChange 和 onSelect', () => {
    const adapter = createMockAdapter({ value: 'a' });
    const foundation = new SelectFoundation(adapter);
    const onChange = vi.fn();
    const onSelect = vi.fn();

    foundation.selectSingle('b', false, onChange, onSelect);

    expect(onChange).toHaveBeenCalledWith('b');
    expect(onSelect).toHaveBeenCalledWith('b');
  });
});

describe('SelectFoundation.resolveVisibleTags', () => {
  const items = [{ value: 'a' }, { value: 'b' }, { value: 'c' }, { value: 'd' }];

  it('maxTagCount 未设置时不折叠，返回全部', () => {
    const result = SelectFoundation.resolveVisibleTags(items, undefined);
    expect(result.visible).toEqual(items);
    expect(result.restCount).toBe(0);
  });

  it('maxTagCount 为 0 时不折叠', () => {
    const result = SelectFoundation.resolveVisibleTags(items, 0);
    expect(result.visible).toEqual(items);
    expect(result.restCount).toBe(0);
  });

  it('已选数量未超出 maxTagCount 时不折叠', () => {
    const result = SelectFoundation.resolveVisibleTags(items.slice(0, 2), 3);
    expect(result.visible).toEqual(items.slice(0, 2));
    expect(result.restCount).toBe(0);
  });

  it('超出 maxTagCount 时截断，返回剩余数量与剩余项', () => {
    const result = SelectFoundation.resolveVisibleTags(items, 2);
    expect(result.visible).toEqual(items.slice(0, 2));
    expect(result.restCount).toBe(2);
    expect(result.rest).toEqual(items.slice(2));
  });
});

describe('isSelectOptionGroup / flattenSelectOptions', () => {
  const flatOption = { value: 'a', label: 'A' };
  const group = { label: '分组一', options: [{ value: 'b', label: 'B' }, { value: 'c', label: 'C' }] };

  it('isSelectOptionGroup 正确区分扁平项和分组项', () => {
    expect(isSelectOptionGroup(flatOption)).toBe(false);
    expect(isSelectOptionGroup(group)).toBe(true);
  });

  it('flattenSelectOptions 展平混合的扁平项与分组项', () => {
    const result = flattenSelectOptions([flatOption, group]);
    expect(result.map((o) => o.value)).toEqual(['a', 'b', 'c']);
  });

  it('flattenSelectOptions 对全扁平数组保持原样', () => {
    const result = flattenSelectOptions([flatOption, { value: 'x', label: 'X' }]);
    expect(result.map((o) => o.value)).toEqual(['a', 'x']);
  });
});
