import { describe, it, expect } from 'vitest';
import { resolveTabWrapTarget } from './focus-trap.js';

function el(name: string): HTMLElement {
  return { toString: () => name } as unknown as HTMLElement;
}

describe('resolveTabWrapTarget', () => {
  const first = el('first');
  const middle = el('middle');
  const last = el('last');
  const list = [first, middle, last];

  it('焦点在最后一个元素上按 Tab（非 Shift）：环绕到第一个元素', () => {
    expect(resolveTabWrapTarget(list, last, false)).toBe(first);
  });

  it('焦点在第一个元素上按 Shift+Tab：环绕到最后一个元素', () => {
    expect(resolveTabWrapTarget(list, first, true)).toBe(last);
  });

  it('焦点在中间元素上按 Tab：不拦截，返回 null', () => {
    expect(resolveTabWrapTarget(list, middle, false)).toBeNull();
  });

  it('焦点在中间元素上按 Shift+Tab：不拦截，返回 null', () => {
    expect(resolveTabWrapTarget(list, middle, true)).toBeNull();
  });

  it('焦点在第一个元素上按 Tab（非 Shift）：不拦截（正常前进到下一个）', () => {
    expect(resolveTabWrapTarget(list, first, false)).toBeNull();
  });

  it('焦点在最后一个元素上按 Shift+Tab：不拦截（正常后退到上一个）', () => {
    expect(resolveTabWrapTarget(list, last, true)).toBeNull();
  });

  it('可聚焦元素列表只有一个：Tab 和 Shift+Tab 都环绕到自身', () => {
    const single = [first];
    expect(resolveTabWrapTarget(single, first, false)).toBe(first);
    expect(resolveTabWrapTarget(single, first, true)).toBe(first);
  });

  it('空列表：始终返回 null（无可聚焦元素时不拦截）', () => {
    expect(resolveTabWrapTarget([], null, false)).toBeNull();
    expect(resolveTabWrapTarget([], null, true)).toBeNull();
  });

  it('当前聚焦元素不在列表内（如焦点在容器外部）：不拦截', () => {
    const outsideElement = el('outside');
    expect(resolveTabWrapTarget(list, outsideElement, false)).toBeNull();
  });
});
