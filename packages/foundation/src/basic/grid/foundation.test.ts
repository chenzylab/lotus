import { describe, it, expect, vi } from 'vitest';
import { RowFoundation, type RowState, type Breakpoint } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: RowState): Adapter<RowState> {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  } as Adapter<RowState> & { _raw: () => RowState };
}

describe('RowFoundation.resolveResponsiveValue', () => {
  it('returns the value for the largest matched breakpoint that has a configured value', () => {
    const screens: Partial<Record<Breakpoint, boolean>> = { xs: true, sm: true, md: true, lg: true };
    const config = { xs: 24, md: 12, xl: 6 };
    // 视口命中到 lg，但 lg/xl 均未配置值，应向下找到 md=12（最近的已配置且已命中档位）
    expect(RowFoundation.resolveResponsiveValue(screens, config)).toBe(12);
  });

  it('falls back to xs when no larger matched breakpoint has a configured value', () => {
    const screens: Partial<Record<Breakpoint, boolean>> = { xs: true, sm: true, md: true };
    const config = { xs: 24 };
    expect(RowFoundation.resolveResponsiveValue(screens, config)).toBe(24);
  });

  it('returns undefined when no matched breakpoint has any configured value', () => {
    const screens: Partial<Record<Breakpoint, boolean>> = { xs: true };
    const config = { md: 12, lg: 6 };
    expect(RowFoundation.resolveResponsiveValue(screens, config)).toBeUndefined();
  });

  it('ignores configured values for breakpoints that are not currently matched', () => {
    // 视口只到 sm（未命中 lg），即使 config 里有 lg 的值也不应使用
    const screens: Partial<Record<Breakpoint, boolean>> = { xs: true, sm: true };
    const config = { xs: 24, lg: 6 };
    expect(RowFoundation.resolveResponsiveValue(screens, config)).toBe(24);
  });
});

describe('RowFoundation lifecycle', () => {
  it('init() marks xs as always matched', () => {
    const adapter = createMockAdapter({ screens: {} });
    const foundation = new RowFoundation(adapter);
    const cleanup = foundation.init();
    expect((adapter as any)._raw().screens.xs).toBe(true);
    cleanup();
  });

  it('destroy() (via init cleanup) unsubscribes without throwing', () => {
    const adapter = createMockAdapter({ screens: {} });
    const foundation = new RowFoundation(adapter);
    const cleanup = foundation.init();
    expect(() => cleanup()).not.toThrow();
  });
});
