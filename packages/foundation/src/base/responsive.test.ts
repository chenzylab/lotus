import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import {
  watchMediaQuery,
  BREAKPOINTS,
  breakpointMinWidthQuery,
  DEFAULT_RESPONSIVE_MAP,
  createEmptyBreakpointScreens,
  readBreakpointScreens,
  watchAllBreakpoints,
} from './responsive.js';

describe('watchMediaQuery', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('returns a no-op unsubscribe when window.matchMedia is unavailable (SSR safety)', () => {
    vi.stubGlobal('window', undefined);
    const unsubscribe = watchMediaQuery('(min-width: 768px)', {});
    expect(() => unsubscribe()).not.toThrow();
  });

  it('calls match handler immediately on init when the query currently matches', () => {
    const listeners: Array<(e: any) => void> = [];
    const mql = {
      matches: true,
      addEventListener: (_: string, cb: (e: any) => void) => listeners.push(cb),
      removeEventListener: vi.fn(),
    };
    vi.stubGlobal('window', { matchMedia: vi.fn(() => mql) });

    const match = vi.fn();
    const unmatch = vi.fn();
    watchMediaQuery('(min-width: 768px)', { match, unmatch });

    expect(match).toHaveBeenCalledTimes(1);
    expect(unmatch).not.toHaveBeenCalled();
  });

  it('does not call match/unmatch on init when callOnInit is false', () => {
    const mql = {
      matches: true,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    };
    vi.stubGlobal('window', { matchMedia: vi.fn(() => mql) });

    const match = vi.fn();
    watchMediaQuery('(min-width: 768px)', { match, callOnInit: false });

    expect(match).not.toHaveBeenCalled();
  });

  it('the returned unsubscribe function removes the change listener', () => {
    const removeEventListener = vi.fn();
    const mql = {
      matches: false,
      addEventListener: vi.fn(),
      removeEventListener,
    };
    vi.stubGlobal('window', { matchMedia: vi.fn(() => mql) });

    const unsubscribe = watchMediaQuery('(min-width: 768px)', {});
    unsubscribe();

    expect(removeEventListener).toHaveBeenCalledWith('change', expect.any(Function));
  });

  it('reacts to a simulated change event by invoking match/unmatch based on e.matches', () => {
    let changeHandler: ((e: any) => void) | undefined;
    const mql = {
      matches: false,
      addEventListener: (_: string, cb: (e: any) => void) => {
        changeHandler = cb;
      },
      removeEventListener: vi.fn(),
    };
    vi.stubGlobal('window', { matchMedia: vi.fn(() => mql) });

    const match = vi.fn();
    const unmatch = vi.fn();
    watchMediaQuery('(min-width: 768px)', { match, unmatch, callOnInit: false });

    changeHandler?.({ matches: true });
    expect(match).toHaveBeenCalledTimes(1);

    changeHandler?.({ matches: false });
    expect(unmatch).toHaveBeenCalledTimes(1);
  });
});

describe('breakpointMinWidthQuery', () => {
  it('produces a valid min-width media query string for each breakpoint', () => {
    for (const key of Object.keys(BREAKPOINTS) as (keyof typeof BREAKPOINTS)[]) {
      expect(breakpointMinWidthQuery(key)).toBe(`(min-width: ${BREAKPOINTS[key]}px)`);
    }
  });
});

describe('createEmptyBreakpointScreens', () => {
  it('返回全部断点均为 false 的对象', () => {
    expect(createEmptyBreakpointScreens()).toEqual({
      xs: false, sm: false, md: false, lg: false, xl: false, xxl: false,
    });
  });
});

describe('readBreakpointScreens', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('SSR/无 window 环境下全部为 false', () => {
    vi.stubGlobal('window', undefined);
    expect(readBreakpointScreens(DEFAULT_RESPONSIVE_MAP)).toEqual(createEmptyBreakpointScreens());
  });

  it('按 responsiveMap 同步读取每个断点的当前匹配状态', () => {
    vi.stubGlobal('window', {
      matchMedia: vi.fn((query: string) => ({ matches: query === DEFAULT_RESPONSIVE_MAP.md })),
    });
    const screens = readBreakpointScreens(DEFAULT_RESPONSIVE_MAP);
    expect(screens.md).toBe(true);
    expect(screens.sm).toBe(false);
  });
});

describe('watchAllBreakpoints', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('为 responsiveMap 里每个断点注册监听，变化时回调 (screen, matches)', () => {
    const handlers: Record<string, { match: () => void; unmatch: () => void }> = {};
    vi.stubGlobal('window', {
      matchMedia: vi.fn((query: string) => ({
        matches: false,
        addEventListener: (_: string, cb: any) => {
          const key = (Object.keys(DEFAULT_RESPONSIVE_MAP) as (keyof typeof DEFAULT_RESPONSIVE_MAP)[])
            .find((k) => DEFAULT_RESPONSIVE_MAP[k] === query);
          if (key) handlers[key] = { match: () => cb({ matches: true }), unmatch: () => cb({ matches: false }) };
        },
        removeEventListener: vi.fn(),
      })),
    });

    const onChange = vi.fn();
    const unsubscribe = watchAllBreakpoints(DEFAULT_RESPONSIVE_MAP, onChange);

    handlers.md.match();
    expect(onChange).toHaveBeenCalledWith('md', true);

    handlers.lg.unmatch();
    expect(onChange).toHaveBeenCalledWith('lg', false);

    expect(() => unsubscribe()).not.toThrow();
  });
});
