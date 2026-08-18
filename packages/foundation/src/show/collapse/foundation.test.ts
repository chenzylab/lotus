import { describe, it, expect } from 'vitest';
import { initActiveKeys, toggleActiveKey, CollapseFoundation } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

describe('initActiveKeys', () => {
  it('未传值时返回空集合', () => {
    expect(initActiveKeys(undefined, false)).toEqual(new Set());
  });

  it('非 accordion 模式下，字符串转成单元素集合', () => {
    expect(initActiveKeys('a', false)).toEqual(new Set(['a']));
  });

  it('非 accordion 模式下，数组转成对应集合（可多展开）', () => {
    expect(initActiveKeys(['a', 'b'], false)).toEqual(new Set(['a', 'b']));
  });

  it('accordion 模式下，数组只取第一个 key', () => {
    expect(initActiveKeys(['a', 'b'], true)).toEqual(new Set(['a']));
  });

  it('accordion 模式下，字符串正常生效', () => {
    expect(initActiveKeys('a', true)).toEqual(new Set(['a']));
  });

  it('空数组返回空集合', () => {
    expect(initActiveKeys([], true)).toEqual(new Set());
  });
});

describe('toggleActiveKey', () => {
  it('点击已展开的 key 会收起它（非 accordion）', () => {
    const result = toggleActiveKey(new Set(['a', 'b']), 'a', false);
    expect(result).toEqual(new Set(['b']));
  });

  it('点击已展开的 key 会收起它（accordion）', () => {
    const result = toggleActiveKey(new Set(['a']), 'a', true);
    expect(result).toEqual(new Set());
  });

  it('非 accordion 模式下点击未展开的 key 会追加进集合', () => {
    const result = toggleActiveKey(new Set(['a']), 'b', false);
    expect(result).toEqual(new Set(['a', 'b']));
  });

  it('accordion 模式下点击未展开的 key 会替换整个集合（自动收起其他 panel）', () => {
    const result = toggleActiveKey(new Set(['a']), 'b', true);
    expect(result).toEqual(new Set(['b']));
  });

  it('不修改传入的原始集合（返回新对象）', () => {
    const original = new Set(['a']);
    const result = toggleActiveKey(original, 'b', false);
    expect(original).toEqual(new Set(['a']));
    expect(result).not.toBe(original);
  });
});

function createMockAdapter(initial: { activeKeys: Set<string> }) {
  let state = initial;
  const adapter: Adapter<{ activeKeys: Set<string> }> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  return { adapter, getState: () => state };
}

describe('CollapseFoundation', () => {
  it('handleToggle 展开一个未展开的 panel', () => {
    const { adapter, getState } = createMockAdapter({ activeKeys: new Set() });
    const foundation = new CollapseFoundation(adapter);

    foundation.handleToggle('a', false);

    expect(getState().activeKeys.has('a')).toBe(true);
  });

  it('handleToggle 在 accordion 模式下切换面板会自动收起原展开项', () => {
    const { adapter, getState } = createMockAdapter({ activeKeys: new Set(['a']) });
    const foundation = new CollapseFoundation(adapter);

    foundation.handleToggle('b', true);

    expect(getState().activeKeys).toEqual(new Set(['b']));
  });
});
