import { describe, it, expect, vi } from 'vitest';
import { NotificationListFoundation, groupByPosition, type NotificationItem } from './foundation.js';

function createFakeTimers() {
  const pending: Array<{ fn: () => void; cancelled: boolean }> = [];
  return {
    setTimeout: (fn: () => void) => {
      pending.push({ fn, cancelled: false });
      return pending.length;
    },
    clearTimeout: (handle: number) => {
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

function makeNotice(overrides: Partial<NotificationItem> = {}): NotificationItem {
  return {
    id: 'n1',
    content: 'hello',
    type: 'info',
    position: 'topRight',
    duration: 3,
    showClose: false,
    ...overrides,
  };
}

describe('NotificationListFoundation', () => {
  it('add() 把新通知插入队列头部（unshift，最新的在最前面）', () => {
    const onChange = vi.fn();
    const foundation = new NotificationListFoundation(onChange, createFakeTimers());

    foundation.add(makeNotice({ id: 'n1' }));
    foundation.add(makeNotice({ id: 'n2' }));

    expect(foundation.getList().map((n) => n.id)).toEqual(['n2', 'n1']);
  });

  it('add() 使用已存在的 id 时原地更新，不改变顺序', () => {
    const foundation = new NotificationListFoundation(() => {}, createFakeTimers());

    foundation.add(makeNotice({ id: 'n1', content: '第一次' }));
    foundation.add(makeNotice({ id: 'n2' }));
    foundation.add(makeNotice({ id: 'n1', content: '更新后' }));

    expect(foundation.getList().map((n) => n.id)).toEqual(['n2', 'n1']);
    expect(foundation.getList().find((n) => n.id === 'n1')!.content).toBe('更新后');
  });

  it('duration 秒后自动移除', () => {
    const timers = createFakeTimers();
    const foundation = new NotificationListFoundation(() => {}, timers);

    foundation.add(makeNotice());
    timers.flush();

    expect(foundation.getList()).toHaveLength(0);
  });

  it('remove() 主动移除并清理计时器', () => {
    const timers = createFakeTimers();
    const foundation = new NotificationListFoundation(() => {}, timers);

    foundation.add(makeNotice({ id: 'n1' }));
    foundation.remove('n1');

    expect(foundation.getList()).toHaveLength(0);
    expect(timers.pendingCount()).toBe(0);
  });

  it('destroyAll() 清空队列并清理全部计时器', () => {
    const timers = createFakeTimers();
    const foundation = new NotificationListFoundation(() => {}, timers);

    foundation.add(makeNotice({ id: 'n1' }));
    foundation.add(makeNotice({ id: 'n2' }));
    foundation.destroyAll();

    expect(foundation.getList()).toHaveLength(0);
    expect(timers.pendingCount()).toBe(0);
  });
});

describe('groupByPosition', () => {
  it('按 position 字段正确分组，且返回全部 6 个 position 键（即使为空）', () => {
    const list: NotificationItem[] = [
      makeNotice({ id: 'n1', position: 'topRight' }),
      makeNotice({ id: 'n2', position: 'topRight' }),
      makeNotice({ id: 'n3', position: 'bottomLeft' }),
    ];
    const groups = groupByPosition(list);

    expect(groups.topRight.map((n) => n.id)).toEqual(['n1', 'n2']);
    expect(groups.bottomLeft.map((n) => n.id)).toEqual(['n3']);
    expect(groups.top).toEqual([]);
    expect(groups.bottom).toEqual([]);
    expect(groups.topLeft).toEqual([]);
    expect(groups.bottomRight).toEqual([]);
  });

  it('空队列返回全部为空数组的分组', () => {
    const groups = groupByPosition([]);
    expect(Object.values(groups).every((g) => g.length === 0)).toBe(true);
  });
});
