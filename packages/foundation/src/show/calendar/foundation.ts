export interface CalendarEvent {
  key: string;
  allDay?: boolean;
  start?: Date;
  end?: Date;
  [x: string]: any;
}

export interface DayInfo {
  date: Date;
  isToday: boolean;
  isWeekend: boolean;
  weekday: number;
}

/** 补全缺失的 start/end：缺 start 则 end-1h，缺 end 则 start+1h。 */
export function amendEvent(event: CalendarEvent): CalendarEvent {
  if (event.start && event.end) return event;
  if (event.start && !event.end) {
    return { ...event, end: new Date(event.start.getTime() + 60 * 60 * 1000) };
  }
  if (!event.start && event.end) {
    return { ...event, start: new Date(event.end.getTime() - 60 * 60 * 1000) };
  }
  const now = new Date();
  return { ...event, start: now, end: new Date(now.getTime() + 60 * 60 * 1000) };
}

function startOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
}

function endOfDay(date: Date): Date {
  const d = new Date(date);
  d.setHours(23, 59, 59, 999);
  return d;
}

function isSameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

function differenceInCalendarDays(a: Date, b: Date): number {
  const utcA = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate());
  const utcB = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate());
  return Math.round((utcA - utcB) / (24 * 60 * 60 * 1000));
}

function addDays(date: Date, amount: number): Date {
  const d = new Date(date);
  d.setDate(d.getDate() + amount);
  return d;
}

/** 一天内秒数占比，[0, 1)。 */
export function getDayPos(date: Date): number {
  return ((date.getHours() * 60 + date.getMinutes()) * 60 + date.getSeconds()) / 86400;
}

/**
 * 把一个可能跨天/多天的 event 拆分为多条"单天"副本：
 * - allDay 或跨度 >=24h：按天数差拆成多条全天副本，交给分层布局算法处理。
 * - 非 allDay 但跨天（如 23:00-01:00）：拆成两条普通分钟级事件。
 * - 不跨天：原样返回单条。
 */
export function splitEventByDay(rawEvent: CalendarEvent): CalendarEvent[] {
  const event = amendEvent(rawEvent);
  const start = event.start as Date;
  const end = event.end as Date;

  const isMultiDay = end.getTime() - start.getTime() >= 24 * 60 * 60 * 1000 || !isSameDay(start, end);

  if (event.allDay || (isMultiDay && end.getTime() - start.getTime() >= 24 * 60 * 60 * 1000)) {
    const dayCount = differenceInCalendarDays(end, start) + 1;
    return Array.from({ length: dayCount }, (_, i) => ({
      ...event,
      allDay: true,
      start: addDays(startOfDay(start), i),
      end: addDays(startOfDay(start), i),
    }));
  }

  if (isMultiDay) {
    return [
      { ...event, start, end: endOfDay(start) },
      { ...event, start: startOfDay(end), end },
    ];
  }

  return [event];
}

export interface PositionedTimedEvent {
  event: CalendarEvent;
  /** 顶部位置，[0, 1) 相对当天总高度的比例。 */
  top: number;
  /** 高度，(0, 1] 相对当天总高度的比例。 */
  height: number;
  /** 左侧位置，[0, 1) 相对列宽的比例（同起止时间重叠时并排）。 */
  left: number;
  /** 宽度，(0, 1] 相对列宽的比例。 */
  width: number;
}

/**
 * 计算一天内分钟级事件的 top/height/left/width（相对比例，渲染时再乘容器尺寸）。
 * 重叠处理对齐 Semi 的简化算法：只有"起止时间完全相同"的事件才会并排，
 * 不做通用区间重叠检测（这是 Semi 自身已知局限，此处对齐而非改进）。
 */
export function layoutTimedEventsForDay(events: CalendarEvent[]): PositionedTimedEvent[] {
  const groups = new Map<string, CalendarEvent[]>();
  for (const event of events) {
    const start = event.start as Date;
    const end = event.end as Date;
    const key = `${getDayPos(start)}-${getDayPos(end)}`;
    const group = groups.get(key);
    if (group) group.push(event);
    else groups.set(key, [event]);
  }

  const result: PositionedTimedEvent[] = [];
  for (const group of groups.values()) {
    const groupSize = group.length;
    group.forEach((event, index) => {
      const start = event.start as Date;
      const end = event.end as Date;
      const top = getDayPos(start);
      const height = Math.max(getDayPos(end) - top, 0);
      result.push({
        event,
        top,
        height,
        left: index / groupSize,
        width: 1 / groupSize,
      });
    });
  }
  return result;
}

export interface PositionedRangeEvent {
  event: CalendarEvent;
  /** 起始列在 range 内的索引位置比例，[0, 1)。 */
  leftPos: number;
  /** 覆盖宽度比例，(0, 1]。 */
  width: number;
  /** 纵向层级（第几行），用于堆叠多个全天事件互不遮挡。 */
  topInd: number;
}

/**
 * 全天事件/月视图事件的横条布局：贪心从上往下找第一个空闲行放置每个事件，
 * 跨天事件占满对应列区间，同一行内不重叠。对齐 Semi 的 parseRangeAllDayEvent。
 */
export function layoutRangeEvents(events: CalendarEvent[], rangeStart: Date, rangeLength: number): PositionedRangeEvent[] {
  const sorted = [...events].sort((a, b) => (a.start as Date).getTime() - (b.start as Date).getTime());
  const occupied: boolean[][] = [];
  const result: PositionedRangeEvent[] = [];

  for (const event of sorted) {
    const start = event.start as Date;
    const end = event.end as Date;
    const startCol = Math.max(differenceInCalendarDays(start, rangeStart), 0);
    const endCol = Math.min(differenceInCalendarDays(end, rangeStart), rangeLength - 1);
    if (startCol > rangeLength - 1 || endCol < 0) continue;

    let row = 0;
    while (isRowRangeOccupied(occupied, row, startCol, endCol)) row++;

    let rowArr = occupied[row];
    if (!rowArr) {
      rowArr = [];
      occupied[row] = rowArr;
    }
    for (let col = startCol; col <= endCol; col++) rowArr[col] = true;

    result.push({
      event,
      leftPos: startCol / rangeLength,
      width: (endCol - startCol + 1) / rangeLength,
      topInd: row,
    });
  }

  return result;
}

function isRowRangeOccupied(occupied: boolean[][], row: number, startCol: number, endCol: number): boolean {
  const rowArr = occupied[row];
  if (!rowArr) return false;
  for (let col = startCol; col <= endCol; col++) {
    if (rowArr[col]) return true;
  }
  return false;
}

/** 月视图单个格子的内边距/单行事件高度（像素），对齐 Semi monthCalendar.tsx
 * 的 contentPadding=60 / contentHeight=24 常量——两者共同决定"给定格子实测
 * 高度，能完整容纳几行事件"，这是纯几何换算，不依赖任何渲染框架。 */
const MONTH_CELL_CONTENT_PADDING = 60;
const MONTH_CELL_CONTENT_ROW_HEIGHT = 24;

/** 根据月视图单元格实测高度换算能完整显示的事件行数（itemLimit）。
 * 超出这个行数的事件应被隐藏、改用"+N 更多"聚合展示（calcRemainingCount）。 */
export function calcMonthItemLimit(cellHeight: number): number {
  return Math.max(0, Math.ceil((cellHeight - MONTH_CELL_CONTENT_PADDING) / MONTH_CELL_CONTENT_ROW_HEIGHT));
}

/** 按 itemLimit 过滤掉超出可见行数的跨天/全天事件（topInd >= itemLimit 的
 * 直接丢弃，不渲染）。 */
export function filterEventsByItemLimit(events: PositionedRangeEvent[], itemLimit: number): PositionedRangeEvent[] {
  return events.filter((item) => item.topInd < itemLimit);
}

/** 某一天里超出 itemLimit 的事件数量（用于"+N 更多"文案），dayEventCount 是
 * 该天全部事件条数（含被截断的），itemLimit 之内的不算超出。 */
export function calcRemainingCount(dayEventCount: number, itemLimit: number): number {
  return Math.max(0, dayEventCount - itemLimit);
}

/** 某天所属的一周起止日期（周日为一周起始，对齐 Semi 默认 weekStartsOn=0）。 */
export function getWeekRange(date: Date, weekStartsOn: number = 0): { start: Date; end: Date } {
  const day = date.getDay();
  const diff = (day - weekStartsOn + 7) % 7;
  const start = startOfDay(addDays(date, -diff));
  const end = endOfDay(addDays(start, 6));
  return { start, end };
}

/** 一周 7 天的 DayInfo 数组。 */
export function getWeekDays(date: Date, weekStartsOn: number = 0, today: Date = new Date()): DayInfo[] {
  const { start } = getWeekRange(date, weekStartsOn);
  return getDateRangeDays(start, 7, today);
}

/** 从 startDate 起连续 dayCount 天的 DayInfo[]，是 week（7 天，从自然周首日起）/
 * day（1 天）/ range（任意天数，从任意起点）三种视图共用的通用打平函数——
 * 对齐 Semi rangeCalendar 用 differenceInCalendarDays(range[1], range[0]) 算
 * 天数、逐天铺开渲染跟 week 视图相同 DayCol 结构的思路，三种模式本质是
 * "同一套逐日列渲染，只是天数和起点不同"，不需要三份独立实现。
 */
export function getDateRangeDays(startDate: Date, dayCount: number, today: Date = new Date()): DayInfo[] {
  return Array.from({ length: dayCount }, (_, i) => {
    const d = addDays(startDate, i);
    return {
      date: d,
      isToday: isSameDay(d, today),
      isWeekend: d.getDay() === 0 || d.getDay() === 6,
      weekday: d.getDay(),
    };
  });
}

/** 当月按周分组的 DayInfo[][]（含首尾补齐的相邻月天数，保证每周 7 天）。 */
export function getMonthWeeks(date: Date, weekStartsOn: number = 0, today: Date = new Date()): DayInfo[][] {
  const firstOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);
  const lastOfMonth = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  const gridStart = getWeekRange(firstOfMonth, weekStartsOn).start;
  const gridEnd = getWeekRange(lastOfMonth, weekStartsOn).end;

  const totalDays = differenceInCalendarDays(gridEnd, gridStart) + 1;
  const days: DayInfo[] = Array.from({ length: totalDays }, (_, i) => {
    const d = addDays(gridStart, i);
    return {
      date: d,
      isToday: isSameDay(d, today),
      isWeekend: d.getDay() === 0 || d.getDay() === 6,
      weekday: d.getDay(),
    };
  });

  const weeks: DayInfo[][] = [];
  for (let i = 0; i < days.length; i += 7) {
    weeks.push(days.slice(i, i + 7));
  }
  return weeks;
}

/** 把事件按其覆盖的每一天分组（同一天内可能有多条，用于 day/week 分钟级渲染）。 */
export function groupTimedEventsByDay(events: CalendarEvent[]): Map<string, CalendarEvent[]> {
  const map = new Map<string, CalendarEvent[]>();
  for (const raw of events) {
    if (raw.allDay) continue;
    for (const event of splitEventByDay(raw)) {
      if (event.allDay) continue;
      const start = event.start as Date;
      const key = startOfDay(start).toISOString();
      const group = map.get(key);
      if (group) group.push(event);
      else map.set(key, [event]);
    }
  }
  return map;
}

/** 提取一组事件里的全部全天事件（含跨天/多天事件拆分后的全天副本）。 */
export function extractAllDayEvents(events: CalendarEvent[]): CalendarEvent[] {
  const result: CalendarEvent[] = [];
  for (const raw of events) {
    for (const event of splitEventByDay(raw)) {
      if (event.allDay) result.push(event);
    }
  }
  return result;
}
