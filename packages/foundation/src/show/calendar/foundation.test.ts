import { describe, it, expect } from 'vitest';
import {
  amendEvent,
  splitEventByDay,
  layoutTimedEventsForDay,
  layoutRangeEvents,
  getWeekRange,
  getWeekDays,
  getDateRangeDays,
  getMonthWeeks,
  groupTimedEventsByDay,
  extractAllDayEvents,
  calcMonthItemLimit,
  filterEventsByItemLimit,
  calcRemainingCount,
  getDayPos,
  type CalendarEvent,
  type PositionedRangeEvent,
} from './foundation.js';

function d(y: number, m: number, day: number, h = 0, min = 0): Date {
  return new Date(y, m - 1, day, h, min);
}

describe('amendEvent', () => {
  it('start/end 都有时原样返回', () => {
    const event: CalendarEvent = { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) };
    expect(amendEvent(event)).toBe(event);
  });

  it('缺 end 时补 start+1h', () => {
    const event: CalendarEvent = { key: 'a', start: d(2026, 1, 1, 9) };
    const result = amendEvent(event);
    expect(result.end).toEqual(d(2026, 1, 1, 10));
  });

  it('缺 start 时补 end-1h', () => {
    const event: CalendarEvent = { key: 'a', end: d(2026, 1, 1, 10) };
    const result = amendEvent(event);
    expect(result.start).toEqual(d(2026, 1, 1, 9));
  });
});

describe('splitEventByDay', () => {
  it('不跨天的普通事件原样返回单条', () => {
    const event: CalendarEvent = { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) };
    const result = splitEventByDay(event);
    expect(result).toHaveLength(1);
    expect(result[0].allDay).toBeFalsy();
  });

  it('跨天但 <24h 的事件拆成两条分钟级事件（当天+次日）', () => {
    const event: CalendarEvent = { key: 'a', start: d(2026, 1, 1, 23), end: d(2026, 1, 2, 1) };
    const result = splitEventByDay(event);
    expect(result).toHaveLength(2);
    expect(result[0].allDay).toBeFalsy();
    expect(result[0].start).toEqual(d(2026, 1, 1, 23));
    expect(result[1].start).toEqual(d(2026, 1, 2, 0, 0));
  });

  it('allDay 事件按天数拆成多条全天副本', () => {
    const event: CalendarEvent = { key: 'a', allDay: true, start: d(2026, 1, 1), end: d(2026, 1, 3) };
    const result = splitEventByDay(event);
    expect(result).toHaveLength(3);
    expect(result.every((e) => e.allDay)).toBe(true);
  });

  it('跨度 >=24h 的非 allDay 事件也按全天事件处理', () => {
    const event: CalendarEvent = { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 2, 9) };
    const result = splitEventByDay(event);
    expect(result.length).toBeGreaterThanOrEqual(2);
    expect(result.every((e) => e.allDay)).toBe(true);
  });
});

describe('layoutTimedEventsForDay', () => {
  it('单个事件占满宽度', () => {
    const events: CalendarEvent[] = [{ key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) }];
    const result = layoutTimedEventsForDay(events);
    expect(result).toHaveLength(1);
    expect(result[0].left).toBe(0);
    expect(result[0].width).toBe(1);
    expect(result[0].top).toBeCloseTo(9 / 24, 5);
    expect(result[0].height).toBeCloseTo(1 / 24, 5);
  });

  it('起止时间完全相同的事件并排（对齐 Semi 简化算法）', () => {
    const events: CalendarEvent[] = [
      { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) },
      { key: 'b', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) },
    ];
    const result = layoutTimedEventsForDay(events);
    expect(result).toHaveLength(2);
    const lefts = result.map((r) => r.left).sort((a, b) => a - b);
    expect(lefts).toEqual([0, 0.5]);
    expect(result.every((r) => r.width === 0.5)).toBe(true);
  });

  it('起止时间不同（即使有交叉重叠）不会并排，各自占满宽度', () => {
    const events: CalendarEvent[] = [
      { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) },
      { key: 'b', start: d(2026, 1, 1, 9, 30), end: d(2026, 1, 1, 10, 30) },
    ];
    const result = layoutTimedEventsForDay(events);
    expect(result.every((r) => r.width === 1 && r.left === 0)).toBe(true);
  });
});

describe('layoutRangeEvents', () => {
  it('单个跨天事件正确计算 leftPos/width', () => {
    const rangeStart = d(2026, 1, 1);
    const events: CalendarEvent[] = [{ key: 'a', start: d(2026, 1, 2), end: d(2026, 1, 4) }];
    const result = layoutRangeEvents(events, rangeStart, 7);
    expect(result).toHaveLength(1);
    expect(result[0].leftPos).toBeCloseTo(1 / 7, 5);
    expect(result[0].width).toBeCloseTo(3 / 7, 5);
    expect(result[0].topInd).toBe(0);
  });

  it('时间重叠的事件分配到不同行（贪心找空闲行）', () => {
    const rangeStart = d(2026, 1, 1);
    const events: CalendarEvent[] = [
      { key: 'a', start: d(2026, 1, 1), end: d(2026, 1, 3) },
      { key: 'b', start: d(2026, 1, 2), end: d(2026, 1, 4) },
    ];
    const result = layoutRangeEvents(events, rangeStart, 7);
    expect(result[0].topInd).toBe(0);
    expect(result[1].topInd).toBe(1);
  });

  it('时间不重叠的事件可以复用同一行', () => {
    const rangeStart = d(2026, 1, 1);
    const events: CalendarEvent[] = [
      { key: 'a', start: d(2026, 1, 1), end: d(2026, 1, 2) },
      { key: 'b', start: d(2026, 1, 3), end: d(2026, 1, 4) },
    ];
    const result = layoutRangeEvents(events, rangeStart, 7);
    expect(result[0].topInd).toBe(0);
    expect(result[1].topInd).toBe(0);
  });

  it('超出 range 范围的事件被裁剪到边界内', () => {
    const rangeStart = d(2026, 1, 1);
    const events: CalendarEvent[] = [{ key: 'a', start: d(2025, 12, 30), end: d(2026, 1, 2) }];
    const result = layoutRangeEvents(events, rangeStart, 7);
    expect(result[0].leftPos).toBe(0);
  });
});

describe('getWeekRange', () => {
  it('默认 weekStartsOn=0（周日），返回周日到周六', () => {
    // 2026-01-01 是周四，所在周从 2025-12-28（周日）到 2026-01-03（周六）
    const { start, end } = getWeekRange(d(2026, 1, 1));
    expect(start.getDay()).toBe(0);
    expect(end.getDay()).toBe(6);
    expect(start).toEqual(d(2025, 12, 28));
    expect(end.getDate()).toBe(3);
  });

  it('weekStartsOn=1（周一），返回周一到周日', () => {
    const { start, end } = getWeekRange(d(2026, 1, 1), 1);
    expect(start.getDay()).toBe(1);
    expect(end.getDay()).toBe(0);
  });
});

describe('getWeekDays', () => {
  it('返回 7 天，today 标记正确', () => {
    const today = d(2026, 1, 1);
    const days = getWeekDays(today, 0, today);
    expect(days).toHaveLength(7);
    expect(days.filter((day) => day.isToday)).toHaveLength(1);
  });

  it('周末标记正确（周日/周六）', () => {
    const days = getWeekDays(d(2026, 1, 1), 0);
    const weekend = days.filter((day) => day.isWeekend);
    expect(weekend).toHaveLength(2);
  });
});

describe('getDateRangeDays', () => {
  it('dayCount=1：单日视图（day 模式），只返回起点当天', () => {
    const day = d(2026, 1, 5);
    const days = getDateRangeDays(day, 1, day);
    expect(days).toHaveLength(1);
    expect(days[0]!.date.getTime()).toBe(day.getTime());
    expect(days[0]!.isToday).toBe(true);
  });

  it('dayCount=7：等价于从任意起点（不要求是自然周首日）连续 7 天', () => {
    const start = d(2026, 1, 3); // 周六，非自然周首日
    const days = getDateRangeDays(start, 7);
    expect(days).toHaveLength(7);
    expect(days[0]!.date.getDate()).toBe(3);
    expect(days[6]!.date.getDate()).toBe(9);
  });

  it('任意天数（range 模式，如 3 天）：连续 dayCount 天，跨月正确进位', () => {
    const start = d(2026, 1, 30);
    const days = getDateRangeDays(start, 3);
    expect(days.map((day) => day.date.getDate())).toEqual([30, 31, 1]);
    expect(days[2]!.date.getMonth()).toBe(1); // 2 月（0-indexed）
  });

  it('getWeekDays(weekStartsOn=0) 与 getDateRangeDays 从对应周首日起算的结果一致', () => {
    const anchor = d(2026, 1, 15);
    const weekDays = getWeekDays(anchor, 0);
    const rangeDays = getDateRangeDays(weekDays[0]!.date, 7);
    expect(rangeDays.map((day) => day.date.getTime())).toEqual(weekDays.map((day) => day.date.getTime()));
  });
});

describe('getMonthWeeks', () => {
  it('返回的每一周都是 7 天', () => {
    const weeks = getMonthWeeks(d(2026, 1, 15));
    expect(weeks.every((week) => week.length === 7)).toBe(true);
  });

  it('覆盖当月所有日期', () => {
    const weeks = getMonthWeeks(d(2026, 2, 15));
    const allDays = weeks.flat();
    const febDays = allDays.filter((day) => day.date.getMonth() === 1);
    expect(febDays).toHaveLength(28); // 2026 年 2 月非闰年
  });
});

describe('groupTimedEventsByDay', () => {
  it('全天事件不出现在分组结果中', () => {
    const events: CalendarEvent[] = [{ key: 'a', allDay: true, start: d(2026, 1, 1), end: d(2026, 1, 1) }];
    const map = groupTimedEventsByDay(events);
    expect(map.size).toBe(0);
  });

  it('按天正确分组普通事件', () => {
    const events: CalendarEvent[] = [
      { key: 'a', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) },
      { key: 'b', start: d(2026, 1, 2, 9), end: d(2026, 1, 2, 10) },
    ];
    const map = groupTimedEventsByDay(events);
    expect(map.size).toBe(2);
  });
});

describe('extractAllDayEvents', () => {
  it('提取全天事件，忽略普通事件', () => {
    const events: CalendarEvent[] = [
      { key: 'a', allDay: true, start: d(2026, 1, 1), end: d(2026, 1, 1) },
      { key: 'b', start: d(2026, 1, 1, 9), end: d(2026, 1, 1, 10) },
    ];
    const result = extractAllDayEvents(events);
    expect(result).toHaveLength(1);
    expect(result[0].key).toBe('a');
  });
});

describe('calcMonthItemLimit', () => {
  it('按 (cellHeight - 60) / 24 向上取整换算可见行数', () => {
    // (132 - 60) / 24 = 3 -> ceil(3) = 3
    expect(calcMonthItemLimit(132)).toBe(3);
    // (140 - 60) / 24 = 3.33... -> ceil = 4
    expect(calcMonthItemLimit(140)).toBe(4);
  });

  it('格子高度不足以容纳 padding 时返回 0，不出现负数', () => {
    expect(calcMonthItemLimit(30)).toBe(0);
    expect(calcMonthItemLimit(0)).toBe(0);
  });
});

describe('filterEventsByItemLimit', () => {
  const event = (topInd: number): PositionedRangeEvent => ({
    event: { key: String(topInd), start: d(2026, 1, 1), end: d(2026, 1, 1) },
    leftPos: 0,
    width: 1,
    topInd,
  });

  it('只保留 topInd < itemLimit 的事件', () => {
    const events = [event(0), event(1), event(2), event(3)];
    const result = filterEventsByItemLimit(events, 2);
    expect(result.map((e) => e.topInd)).toEqual([0, 1]);
  });

  it('itemLimit=0 时全部过滤掉', () => {
    const events = [event(0), event(1)];
    expect(filterEventsByItemLimit(events, 0)).toHaveLength(0);
  });

  it('itemLimit 足够大时全部保留', () => {
    const events = [event(0), event(1)];
    expect(filterEventsByItemLimit(events, 100)).toHaveLength(2);
  });
});

describe('calcRemainingCount', () => {
  it('事件数超过 itemLimit 时返回差值', () => {
    expect(calcRemainingCount(5, 2)).toBe(3);
  });

  it('事件数不超过 itemLimit 时返回 0（不出现负数）', () => {
    expect(calcRemainingCount(2, 5)).toBe(0);
    expect(calcRemainingCount(2, 2)).toBe(0);
  });
});

describe('getDayPos', () => {
  it('午夜返回 0', () => {
    expect(getDayPos(d(2026, 1, 1, 0, 0))).toBe(0);
  });

  it('正午返回 0.5', () => {
    expect(getDayPos(d(2026, 1, 1, 12, 0))).toBe(0.5);
  });

  it('23:59 接近但小于 1', () => {
    const pos = getDayPos(new Date(2026, 0, 1, 23, 59, 59));
    expect(pos).toBeLessThan(1);
    expect(pos).toBeGreaterThan(0.99);
  });
});
