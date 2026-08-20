/**
 * 单日格状态计算：给定 fullDate + 全局选中/hover/offset 状态 → 一组布尔标志，
 * 直接映射渲染层 CSS class。移植自参考实现（对齐 Semi month.tsx 的
 * getSingleDayStatus/getDateRangeStatus/getOffsetDateStatus 三段合成）。
 */
import { isAfter, isBefore, isBetween, isSameDay } from './utils.js';

export type RangeInputFocus = 'rangeStart' | 'rangeEnd' | false;

export interface DayStatusOptions {
  fullDate: string;
  todayText: string;
  selected: Set<string>;
  disabledDate?: (day: Date, options?: { rangeStart: string; rangeEnd: string; rangeInputFocus: RangeInputFocus }) => boolean;
  rangeStart: string;
  rangeEnd: string;
  hoverDay: string;
  offsetRangeStart: string;
  offsetRangeEnd: string;
  rangeInputFocus: RangeInputFocus;
}

export interface DayStatus {
  isToday?: boolean;
  isSelected?: boolean;
  isDisabled?: boolean;
  isHoverDay?: boolean;
  isSelectedStart?: boolean;
  isSelectedEnd?: boolean;
  isInRange?: boolean;
  isHover?: boolean;
  isSelectedStartAfterHover?: boolean;
  isSelectedEndBeforeHover?: boolean;
  isHoverDayInRange?: boolean;
  isHoverDayInStartSelection?: boolean;
  isHoverDayInEndSelection?: boolean;
  isHoverDayAroundOneSelected?: boolean;
  isOffsetRangeStart?: boolean;
  isOffsetRangeEnd?: boolean;
  isHoverInOffsetRange?: boolean;
  isHoverDayOffset?: boolean;
  isInOffsetRange?: boolean;
}

function getSingleDayStatus(o: DayStatusOptions): Pick<DayStatus, 'isToday' | 'isSelected' | 'isDisabled'> {
  const { fullDate, todayText, selected, disabledDate, rangeStart, rangeEnd, rangeInputFocus } = o;
  const disabledOptions = { rangeStart, rangeEnd, rangeInputFocus };
  const isToday = fullDate === todayText;
  const isSelected = selected.has(fullDate);
  const isDisabled = disabledDate ? disabledDate(new Date(fullDate), disabledOptions) : false;
  return { isToday, isSelected, isDisabled };
}

function getDateRangeStatus(o: DayStatusOptions): Partial<DayStatus> {
  const { rangeStart, rangeEnd, fullDate, hoverDay, offsetRangeStart, offsetRangeEnd, rangeInputFocus } = o;

  const isDateRangeAnySelected = Boolean(rangeStart || rangeEnd);
  const isDateRangeSelected = Boolean(rangeStart && rangeEnd);
  const isOffsetDateRangeAnyExist = Boolean(offsetRangeStart || offsetRangeEnd);
  if (!isDateRangeAnySelected) return {};

  const isHoverDay = isSameDay(hoverDay, fullDate);

  let isHoverAfterStart: boolean | undefined;
  let isHoverBeforeEnd: boolean | undefined;
  let isSelectedStart: boolean | undefined;
  let isSelectedEnd: boolean | undefined;
  let isHoverDayAroundOneSelected: boolean | undefined;
  if (rangeStart) {
    isSelectedStart = isSameDay(fullDate, rangeStart);
    if (rangeInputFocus === 'rangeEnd') isHoverAfterStart = isBetween(fullDate, { start: rangeStart, end: hoverDay });
  }
  if (rangeEnd) {
    isSelectedEnd = isSameDay(fullDate, rangeEnd);
    if (rangeInputFocus === 'rangeStart') isHoverBeforeEnd = isBetween(fullDate, { start: hoverDay, end: rangeEnd });
  }
  if (!isDateRangeSelected && isDateRangeAnySelected) isHoverDayAroundOneSelected = isHoverDay;

  let isHover: boolean | undefined;
  if (!isOffsetDateRangeAnyExist) isHover = isHoverAfterStart || isHoverBeforeEnd || isHoverDay;

  let isInRange: boolean | undefined;
  let isSelectedStartAfterHover: boolean | undefined;
  let isSelectedEndBeforeHover: boolean | undefined;
  let isHoverDayInStartSelection: boolean | undefined;
  let isHoverDayInEndSelection: boolean | undefined;
  let isHoverDayInRange: boolean | undefined;
  if (isDateRangeSelected) {
    isInRange = isBetween(fullDate, { start: rangeStart, end: rangeEnd });
    if (!isOffsetDateRangeAnyExist) {
      isSelectedStartAfterHover = Boolean(isSelectedStart && isAfter(rangeStart, hoverDay));
      isSelectedEndBeforeHover = Boolean(isSelectedEnd && isBefore(rangeEnd, hoverDay));
      isHoverDayInStartSelection = isHoverDay && rangeInputFocus === 'rangeStart';
      isHoverDayInEndSelection = isHoverDay && rangeInputFocus === 'rangeEnd';
      isHoverDayInRange = isHoverDay && isBetween(hoverDay, { start: rangeStart, end: rangeEnd });
    }
  }

  return {
    isHoverDay,
    isSelectedStart,
    isSelectedEnd,
    isInRange,
    isHover,
    isSelectedStartAfterHover,
    isSelectedEndBeforeHover,
    isHoverDayInRange,
    isHoverDayInStartSelection,
    isHoverDayInEndSelection,
    isHoverDayAroundOneSelected,
  };
}

function getOffsetDateStatus(o: DayStatusOptions): Partial<DayStatus> {
  const { offsetRangeStart, offsetRangeEnd, rangeStart, rangeEnd, fullDate, hoverDay } = o;
  const isOffsetDateRangeNull = !(offsetRangeStart || offsetRangeEnd);
  if (isOffsetDateRangeNull) return {};

  const isInRange = isBetween(fullDate, { start: rangeStart, end: rangeEnd });
  const isHoverDay = isSameDay(hoverDay, fullDate);
  const isSelectedStart = Boolean(rangeStart && isSameDay(fullDate, rangeStart));
  const isSelectedEnd = Boolean(rangeEnd && isSameDay(fullDate, rangeEnd));
  const isDateRangeSelected = Boolean(rangeStart && rangeEnd);

  const isOffsetRangeStart = isSameDay(fullDate, offsetRangeStart);
  const isOffsetRangeEnd = isSameDay(fullDate, offsetRangeEnd);
  const isHoverDayOffset = isHoverDay;

  let isHoverInOffsetRange: boolean | undefined;
  let isInOffsetRange: boolean | undefined;
  if (isDateRangeSelected) isHoverInOffsetRange = isInRange && isHoverDay;

  const isOffsetDateRangeSelected = Boolean(offsetRangeStart && offsetRangeEnd);
  if (isOffsetDateRangeSelected) {
    isInOffsetRange = isSelectedStart || isBetween(fullDate, { start: offsetRangeStart, end: offsetRangeEnd }) || isSelectedEnd;
  }

  return { isOffsetRangeStart, isOffsetRangeEnd, isHoverInOffsetRange, isHoverDayOffset, isInOffsetRange };
}

/** 合成三段状态：单日基础态 + range 态 + offset(周选择) 态。 */
export function getDayStatus(o: DayStatusOptions): DayStatus {
  const single = getSingleDayStatus(o);
  const range = getDateRangeStatus({ ...o, ...single });
  const offset = getOffsetDateStatus({ ...o, ...single, ...range });
  return { ...single, ...range, ...offset };
}

export function getTodayText(): string {
  const now = new Date();
  const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`);
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}
