import { describe, it, expect, vi } from 'vitest';
import { SpinFoundation, type SpinState, type SpinTimers } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: SpinState): { adapter: Adapter<SpinState>; getState: () => SpinState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch: Partial<SpinState>) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

function createFakeTimers(): SpinTimers & { flush: () => void; pendingCount: () => number } {
  const pending: Array<{ fn: () => void; cancelled: boolean }> = [];
  return {
    setTimeout: (fn) => {
      pending.push({ fn, cancelled: false });
      return pending.length;
    },
    clearTimeout: (handle) => {
      const entry = pending[handle - 1];
      if (entry) entry.cancelled = true;
    },
    flush: () => {
      pending.forEach((entry) => {
        if (!entry.cancelled) entry.fn();
      });
      pending.length = 0;
    },
    pendingCount: () => pending.filter((e) => !e.cancelled).length,
  };
}

describe('SpinFoundation', () => {
  it('delay=0 时 loading 立即跟随 spinning', () => {
    const { adapter, getState } = createMockAdapter({ loading: false });
    const foundation = new SpinFoundation(adapter, createFakeTimers());

    foundation.syncFromProps(true, 0);

    expect(getState().loading).toBe(true);
  });

  it('spinning=false 时无论 delay 是多少都立即隐藏', () => {
    const { adapter, getState } = createMockAdapter({ loading: true });
    const foundation = new SpinFoundation(adapter, createFakeTimers());

    foundation.syncFromProps(false, 500);

    expect(getState().loading).toBe(false);
  });

  it('delay>0 且 spinning=true 时不立即显示，计时器触发后才显示', () => {
    const { adapter, getState } = createMockAdapter({ loading: false });
    const timers = createFakeTimers();
    const foundation = new SpinFoundation(adapter, timers);

    foundation.syncFromProps(true, 300);
    expect(getState().loading).toBe(false);

    timers.flush();
    expect(getState().loading).toBe(true);
  });

  it('延迟计时器触发前 spinning 又变回 false：应取消挂起的计时器，不再显示', () => {
    const { adapter, getState } = createMockAdapter({ loading: false });
    const timers = createFakeTimers();
    const foundation = new SpinFoundation(adapter, timers);

    foundation.syncFromProps(true, 300);
    expect(timers.pendingCount()).toBe(1);

    foundation.syncFromProps(false, 300);
    expect(timers.pendingCount()).toBe(0);

    timers.flush();
    expect(getState().loading).toBe(false);
  });

  it('destroy() 清理挂起的计时器', () => {
    const { adapter } = createMockAdapter({ loading: false });
    const timers = createFakeTimers();
    const foundation = new SpinFoundation(adapter, timers);

    foundation.syncFromProps(true, 300);
    expect(timers.pendingCount()).toBe(1);

    foundation.destroy();
    expect(timers.pendingCount()).toBe(0);
  });

  it('连续多次 syncFromProps(true, delay) 调用只保留最后一个计时器（不重叠触发）', () => {
    const { adapter, getState } = createMockAdapter({ loading: false });
    const timers = createFakeTimers();
    const foundation = new SpinFoundation(adapter, timers);

    foundation.syncFromProps(true, 300);
    foundation.syncFromProps(true, 300);
    expect(timers.pendingCount()).toBe(1);

    timers.flush();
    expect(getState().loading).toBe(true);
  });
});
