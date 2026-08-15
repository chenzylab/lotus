import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TooltipFoundation, type TooltipState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: TooltipState): Adapter<TooltipState> & { _raw: () => TooltipState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<TooltipState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.useRealTimers();
});

describe('TooltipFoundation: show/hide 立即执行', () => {
  it('非受控模式下 show 立即置 visible=true 并通知', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);
    const onVisibleChange = vi.fn();

    foundation.show(false, onVisibleChange);

    expect(adapter._raw().visible).toBe(true);
    expect(onVisibleChange).toHaveBeenCalledWith(true);
  });

  it('受控模式下 show 只通知，不改内部 state', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);
    const onVisibleChange = vi.fn();

    foundation.show(true, onVisibleChange);

    expect(adapter._raw().visible).toBe(false);
    expect(onVisibleChange).toHaveBeenCalledWith(true);
  });

  it('hide 立即置 visible=false', () => {
    const adapter = createMockAdapter({ visible: true });
    const foundation = new TooltipFoundation(adapter);

    foundation.hide(false);

    expect(adapter._raw().visible).toBe(false);
  });
});

describe('TooltipFoundation: scheduleShow/scheduleHide 延迟触发', () => {
  it('scheduleShow 在延迟时间后才置为 visible', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);

    foundation.scheduleShow(50, false);
    expect(adapter._raw().visible).toBe(false);

    vi.advanceTimersByTime(49);
    expect(adapter._raw().visible).toBe(false);

    vi.advanceTimersByTime(1);
    expect(adapter._raw().visible).toBe(true);
  });

  it('delay<=0 时 scheduleShow 立即生效', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);

    foundation.scheduleShow(0, false);

    expect(adapter._raw().visible).toBe(true);
  });

  it('scheduleShow 期间再次调用 scheduleHide 会打断显示计时器', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);

    foundation.scheduleShow(50, false);
    vi.advanceTimersByTime(30);
    foundation.scheduleHide(0, false);

    vi.advanceTimersByTime(50);
    expect(adapter._raw().visible).toBe(false);
  });

  it('scheduleHide 在延迟时间后才置为不可见', () => {
    const adapter = createMockAdapter({ visible: true });
    const foundation = new TooltipFoundation(adapter);

    foundation.scheduleHide(50, false);
    expect(adapter._raw().visible).toBe(true);

    vi.advanceTimersByTime(50);
    expect(adapter._raw().visible).toBe(false);
  });
});

describe('TooltipFoundation.toggle', () => {
  it('从隐藏切换为显示', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);

    foundation.toggle(false);

    expect(adapter._raw().visible).toBe(true);
  });

  it('从显示切换为隐藏', () => {
    const adapter = createMockAdapter({ visible: true });
    const foundation = new TooltipFoundation(adapter);

    foundation.toggle(false);

    expect(adapter._raw().visible).toBe(false);
  });
});

describe('TooltipFoundation.destroy', () => {
  it('destroy 后挂起的延迟显示不再触发', () => {
    const adapter = createMockAdapter({ visible: false });
    const foundation = new TooltipFoundation(adapter);

    foundation.scheduleShow(50, false);
    foundation.destroy();
    vi.advanceTimersByTime(100);

    expect(adapter._raw().visible).toBe(false);
  });
});
