import { describe, it, expect } from 'vitest';
import { shouldShowBadge, isCustomContent, formatCount } from './foundation.js';

describe('shouldShowBadge', () => {
  it('dot 为 true 时始终显示，不论 count', () => {
    expect(shouldShowBadge(undefined, true)).toBe(true);
    expect(shouldShowBadge(null, true)).toBe(true);
  });

  it('count 为 0 时显示（不是 antd 那种自动隐藏语义）', () => {
    expect(shouldShowBadge(0, false)).toBe(true);
  });

  it('count 为 null/undefined 且非 dot 时不显示', () => {
    expect(shouldShowBadge(null, false)).toBe(false);
    expect(shouldShowBadge(undefined, false)).toBe(false);
  });

  it('count 为字符串或自定义内容时显示', () => {
    expect(shouldShowBadge('NEW', false)).toBe(true);
    expect(shouldShowBadge({}, false)).toBe(true);
  });
});

describe('isCustomContent', () => {
  it('number/string 不算自定义内容', () => {
    expect(isCustomContent(5)).toBe(false);
    expect(isCustomContent('NEW')).toBe(false);
  });

  it('null/undefined 不算自定义内容', () => {
    expect(isCustomContent(null)).toBe(false);
    expect(isCustomContent(undefined)).toBe(false);
  });

  it('对象/JSX 节点算自定义内容', () => {
    expect(isCustomContent({ type: 'svg' })).toBe(true);
  });
});

describe('formatCount', () => {
  it('数字未超过 overflowCount 时原样显示', () => {
    expect(formatCount(50, 99)).toBe('50');
  });

  it('数字超过 overflowCount 时显示为 "N+"', () => {
    expect(formatCount(100, 99)).toBe('99+');
  });

  it('数字等于 overflowCount 时不裁剪（严格小于才裁剪）', () => {
    expect(formatCount(99, 99)).toBe('99');
  });

  it('未传 overflowCount 时原样显示完整数字', () => {
    expect(formatCount(12345)).toBe('12345');
  });

  it('字符串原样返回', () => {
    expect(formatCount('VIP')).toBe('VIP');
  });

  it('非 number/string 返回空字符串（自定义内容由组件层单独渲染）', () => {
    expect(formatCount({})).toBe('');
  });
});
