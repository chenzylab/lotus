import { describe, it, expect, vi } from 'vitest';
import { ToastListFoundation, type ToastItem, type ToastTimers } from './foundation.js';

function createFakeTimers(): ToastTimers & { flush: () => void; pendingCount: () => number } {
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

function makeToast(overrides: Partial<ToastItem> = {}): ToastItem {
  return { id: 't1', content: 'hello', type: 'info', duration: 3, showClose: false, stack: false, ...overrides };
}

describe('ToastListFoundation', () => {
  it('add() 把新通知追加到队列并通知 onChange', () => {
    const onChange = vi.fn();
    const foundation = new ToastListFoundation(onChange, createFakeTimers());

    foundation.add(makeToast());

    expect(foundation.getList()).toHaveLength(1);
    expect(onChange).toHaveBeenCalledWith([makeToast()]);
  });

  it('add() 使用已存在的 id 时更新该条内容而非追加新条目', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ content: '第一次' }));
    foundation.add(makeToast({ content: '第二次' }));

    expect(foundation.getList()).toHaveLength(1);
    expect(foundation.getList()[0]!.content).toBe('第二次');
  });

  it('duration 秒后自动移除对应通知', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ duration: 3 }));
    expect(foundation.getList()).toHaveLength(1);

    timers.flush();
    expect(foundation.getList()).toHaveLength(0);
  });

  it('duration=0 时不设置自动关闭计时器', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ duration: 0 }));
    expect(timers.pendingCount()).toBe(0);
  });

  it('update 同一 id 会重启计时器（不会残留旧计时器重叠触发）', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ duration: 3 }));
    expect(timers.pendingCount()).toBe(1);

    foundation.add(makeToast({ duration: 3, content: '更新后' }));
    expect(timers.pendingCount()).toBe(1);
  });

  it('remove() 主动移除指定 id 并清理对应计时器', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ id: 't1' }));
    foundation.add(makeToast({ id: 't2' }));
    foundation.remove('t1');

    expect(foundation.getList().map((t) => t.id)).toEqual(['t2']);
    expect(timers.pendingCount()).toBe(1);
  });

  it('destroyAll() 清空队列并清理全部计时器', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ id: 't1' }));
    foundation.add(makeToast({ id: 't2' }));
    foundation.destroyAll();

    expect(foundation.getList()).toHaveLength(0);
    expect(timers.pendingCount()).toBe(0);
  });

  it('多条通知各自独立计时，互不影响', () => {
    const timers = createFakeTimers();
    const foundation = new ToastListFoundation(() => {}, timers);

    foundation.add(makeToast({ id: 't1' }));
    foundation.add(makeToast({ id: 't2' }));
    foundation.remove('t1');

    timers.flush();
    expect(foundation.getList()).toHaveLength(0);
  });
});
