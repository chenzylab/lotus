import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { watchSiderBreakpoints } from './foundation.js';

interface MockMql {
  matches: boolean;
  listeners: Array<(e: { matches: boolean }) => void>;
  addEventListener: (type: string, handler: (e: { matches: boolean }) => void) => void;
  removeEventListener: (type: string, handler: (e: { matches: boolean }) => void) => void;
}

describe('watchSiderBreakpoints', () => {
  let mqlByQuery: Map<string, MockMql>;

  beforeEach(() => {
    mqlByQuery = new Map();
    vi.stubGlobal('window', {
      matchMedia: (query: string) => {
        if (!mqlByQuery.has(query)) {
          const listeners: Array<(e: { matches: boolean }) => void> = [];
          mqlByQuery.set(query, {
            matches: false,
            listeners,
            addEventListener: (_type, handler) => listeners.push(handler),
            removeEventListener: (_type, handler) => {
              const idx = listeners.indexOf(handler);
              if (idx !== -1) listeners.splice(idx, 1);
            },
          });
        }
        return mqlByQuery.get(query)!;
      },
    });
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('为每个声明的断点注册一次监听，并以初始匹配状态（默认 false）立即回调 unmatch', () => {
    const onBreakpoint = vi.fn();
    watchSiderBreakpoints(['md', 'lg'], onBreakpoint);

    expect(onBreakpoint).toHaveBeenCalledWith('md', false);
    expect(onBreakpoint).toHaveBeenCalledWith('lg', false);
    expect(onBreakpoint).toHaveBeenCalledTimes(2);
  });

  it('xs 断点使用 max-width 查询语义，而非其余断点的 min-width', () => {
    watchSiderBreakpoints(['xs'], vi.fn());
    expect([...mqlByQuery.keys()]).toContain('(max-width: 575px)');
  });

  it('断点命中变化时触发对应的 match/unmatch 回调', () => {
    const onBreakpoint = vi.fn();
    watchSiderBreakpoints(['md'], onBreakpoint);
    onBreakpoint.mockClear();

    const mql = mqlByQuery.get('(min-width: 768px)')!;
    mql.listeners.forEach((l) => l({ matches: true }));
    expect(onBreakpoint).toHaveBeenCalledWith('md', true);

    mql.listeners.forEach((l) => l({ matches: false }));
    expect(onBreakpoint).toHaveBeenCalledWith('md', false);
  });

  it('返回的清理函数会移除所有断点的监听', () => {
    const onBreakpoint = vi.fn();
    const cleanup = watchSiderBreakpoints(['sm', 'xl'], onBreakpoint);

    cleanup();

    expect(mqlByQuery.get('(min-width: 576px)')!.listeners).toHaveLength(0);
    expect(mqlByQuery.get('(min-width: 1200px)')!.listeners).toHaveLength(0);
  });

  it('空断点数组不注册任何监听，返回的清理函数可安全调用', () => {
    const onBreakpoint = vi.fn();
    const cleanup = watchSiderBreakpoints([], onBreakpoint);

    expect(onBreakpoint).not.toHaveBeenCalled();
    expect(() => cleanup()).not.toThrow();
  });
});
