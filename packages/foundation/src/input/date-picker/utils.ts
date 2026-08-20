/**
 * DatePicker 纯函数工具集，移植自参考实现（date-fns 版），逻辑对齐 Semi
 * semi-foundation/datePicker/_utils/*。
 */
import {
  startOfMonth,
  lastDayOfMonth,
  getDaysInMonth,
  format as dateFnsFormat,
  parse as dateFnsParse,
  parseISO as dateFnsParseISO,
  isValid as dateFnsIsValid,
  isAfter as dateFnsIsAfter,
  isBefore as dateFnsIsBefore,
  isSameDay as dateFnsIsSameDay,
  isWithinInterval,
  isEqual as dateFnsIsEqual,
  type Locale,
} from 'date-fns';
import { formatToken } from './constants.js';

export type WeekStartNumber = 0 | 1 | 2 | 3 | 4 | 5 | 6;

export interface MonthDayInfo {
  dayNumber: number | string;
  dayNumberFull?: string;
  fullDate: string;
}

export interface MonthInfo {
  weeks: MonthDayInfo[][];
  monthText: string;
  month?: Date;
}

export function formatFullDate(
  year: number | string = '',
  month: number | string = '',
  day: number | string = '',
): string {
  const monthFull = typeof month === 'number' && month < 10 ? `0${month}` : month.toString();
  const dayNumberFull = typeof day === 'number' && day < 10 ? `0${day}` : day.toString();
  return `${String(year)}-${monthFull}-${dayNumberFull}`;
}

function getWeeks(date: Date, weekStartsOn: WeekStartNumber = 0): MonthDayInfo[][] {
  const weekDayNotInMonth: MonthDayInfo = { dayNumber: '', dayNumberFull: '', fullDate: '' };
  const daysInMonth = getDaysInMonth(date);
  const year = dateFnsFormat(date, 'yyyy');
  const month = dateFnsFormat(date, 'MM');
  const lastday = lastDayOfMonth(date);
  const firstDay = startOfMonth(date);
  const firstDayInWeek = Number(dateFnsFormat(firstDay, 'e', { weekStartsOn }));

  const weeks: MonthDayInfo[][] = [];
  let week: MonthDayInfo[] = [];
  for (let s = 1; s < firstDayInWeek; s++) {
    week.push(weekDayNotInMonth);
  }

  for (let d = 0; d < daysInMonth; d++) {
    const dayNumber = d + 1;
    const dayNumberFull = dayNumber < 10 ? `0${dayNumber}` : dayNumber.toString();
    const fullDate = formatFullDate(year, month, dayNumber);
    week.push({ dayNumber, dayNumberFull, fullDate });

    if (week.length === 7) {
      weeks.push(week);
      week = [];
    } else if (fullDate === dateFnsFormat(lastday, 'yyyy-MM-dd')) {
      weeks.push(week);
      week = [];
    }
  }
  return weeks;
}

/** 生成某月的周表格（含首尾空日格补位），供日历网格渲染。 */
export function getMonthTable(month: Date, weekStartsOn: WeekStartNumber): MonthInfo {
  const weeks = getWeeks(month, weekStartsOn);
  const monthText = dateFnsFormat(month, 'yyyy-MM');
  return { monthText, weeks, month };
}

/** 按一周首日索引轮转出星期缩写 key 数组（'Sun'..'Sat' 起点可调）。 */
export function getDayOfWeek(weekStartsOn: WeekStartNumber = 0): string[] {
  const weekDay = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  for (let index = 0; index < weekStartsOn; index++) {
    weekDay.push(weekDay.shift() as string);
  }
  return weekDay;
}

function toDate(d: string | Date): Date {
  return typeof d === 'string' ? dateFnsParseISO(d) : d;
}

export function isAfter(date: string | Date, dateToCompare: string | Date): boolean {
  return dateFnsIsAfter(toDate(date), toDate(dateToCompare));
}

export function isBefore(date: string | Date, dateToCompare: string | Date): boolean {
  return dateFnsIsBefore(toDate(date), toDate(dateToCompare));
}

export function isSameDay(date: string | Date, dateToCompare: string | Date): boolean {
  return dateFnsIsSameDay(toDate(date), toDate(dateToCompare));
}

/** day 是否严格在 (start, end) 开区间内（不含端点）；start > end 时返回 false。 */
export function isBetween(day: string | Date, range: { start: string | Date; end: string | Date }): boolean {
  const d = toDate(day);
  const s = toDate(range.start);
  const e = toDate(range.end);
  return dateFnsIsBefore(s, e) && isWithinInterval(d, { start: s, end: e }) && !dateFnsIsEqual(d, s) && !dateFnsIsEqual(d, e);
}

export function isValidDate(date: unknown): date is Date {
  return (
    !!date &&
    Object.prototype.toString.call(date) === '[object Date]' &&
    !Number.isNaN((date as Date).getTime())
  );
}

/** 周选择等 offset 场景：对给定日期套用 offset 函数，输出 yyyy-MM-dd 字符串。 */
export function getFullDateOffset(fn: ((d: Date) => Date) | undefined, date: string | Date): string {
  if (!date) return '';
  const getDate = new Date(date);
  const offsetDate = typeof fn === 'function' ? fn(getDate) : getDate;
  return dateFnsFormat(new Date(offsetDate), formatToken.FORMAT_FULL_DATE);
}

/** 年/月滚轮列表默认 [今年-100, 今年+100]。 */
export function getYears(startYear?: number, endYear?: number): number[] {
  const currentYear = new Date().getFullYear();
  let start = typeof startYear === 'number' ? startYear : currentYear - 100;
  let end = typeof endYear === 'number' ? endYear : currentYear + 100;
  if (end < start) [start, end] = [end, start];
  return Array.from({ length: end - start + 1 }, (_v, i) => start + i);
}

/** left/right 缺省时用当前年月推导（monthRange 双面板初始定位）。 */
export function getYearAndMonth(
  year: { left: number; right: number },
  month: { left: number; right: number },
): { year: { left: number; right: number }; month: { left: number; right: number } } {
  const nowYear = new Date().getFullYear();
  const nowMonth = new Date().getMonth();
  const rightMonth = month.right || nowMonth + 2;
  const rightYear = year.right || (rightMonth <= 12 ? nowYear : nowYear + 1);
  return {
    year: { left: year.left || nowYear, right: rightYear },
    month: { left: month.left || nowMonth + 1, right: rightMonth <= 12 ? rightMonth : 1 },
  };
}

/**
 * 三级降级解析：严格按 formatToken → ISO 8601 → 原生宽松解析；年份超 4 位视为非法兜底。
 */
export function compatibleParse(value: string, formatTok?: string, baseDate?: Date, locale?: Locale): Date | null {
  let result: Date | null = null;
  if (value) {
    if (formatTok) {
      const base = baseDate ?? new Date();
      result = dateFnsParse(value, formatTok, base, locale ? { locale } : undefined);
    }
    if (!result || !dateFnsIsValid(result)) {
      result = dateFnsParseISO(value);
    }
    if (!dateFnsIsValid(result)) {
      result = new Date(Date.parse(value));
    }
    const yearInvalid = dateFnsIsValid(result) && String(result.getFullYear()).length > 4;
    if (!dateFnsIsValid(result) || yearInvalid) result = null;
  }
  return result;
}

/** date-fns format 按 token 序列化 Date（本地字段），可选 locale 本地化月份/星期名。 */
export function localeFormat(date: Date, token: string, locale?: Locale): string {
  return dateFnsFormat(date, token, locale ? { locale } : undefined);
}

/** 获取 insetInput 输入框的 format（placeholder）：从完整 format 里拆出日期段/日期+时间段。 */
export function getInsetInputFormatToken(options: { format?: string; type: string }): string {
  const { format = '', type } = options;
  const dateReg = /([yMd]{0,4}[^a-z\s]*[yMd]{0,4}[^a-z\s]*[yMd]{0,4})/i;
  const dateTimeReg = /([yMd]{0,4}[^a-z\s]*[yMd]{0,4}[^a-z\s]*[yMd]{0,4}) (H{0,2}[^a-z\s]*m{0,2}[^a-z\s]*s{0,2})/i;
  const defaultToken = getDefaultFormatTokenByTypeSafe(type) ?? 'yyyy-MM-dd';
  let insetInputFormat: string;
  switch (type) {
    case 'dateTime':
    case 'dateTimeRange': {
      const dateTimeResult = dateTimeReg.exec(format);
      insetInputFormat =
        dateTimeResult && dateTimeResult[1] && dateTimeResult[2] ? `${dateTimeResult[1]} ${dateTimeResult[2]}` : defaultToken;
      break;
    }
    case 'date':
    case 'month':
    case 'monthRange':
    case 'dateRange':
    default: {
      const dateResult = dateReg.exec(format);
      insetInputFormat = (dateResult && dateResult[1]) || defaultToken;
      break;
    }
  }
  return insetInputFormat;
}

function getDefaultFormatTokenByTypeSafe(type: string): string | undefined {
  const map: Record<string, string> = {
    date: formatToken.FORMAT_FULL_DATE,
    dateTime: formatToken.FORMAT_DATE_TIME,
    dateRange: formatToken.FORMAT_FULL_DATE,
    dateTimeRange: formatToken.FORMAT_DATE_TIME,
    month: formatToken.FORMAT_YEAR_MONTH,
    monthRange: formatToken.FORMAT_YEAR_MONTH,
  };
  return map[type];
}

export interface InsetInputValue {
  monthLeft: { dateInput: string; timeInput: string };
  monthRight: { dateInput: string; timeInput: string };
}

/** 从 insetInputStr 字符串解析出 insetInputValue 对象。 */
export function getInsetInputValueFromInsetInputStr(options: {
  inputValue: string;
  rangeSeparator: string;
  type: string;
}): InsetInputValue {
  const timeSeparator = ' ';
  const { inputValue = '', rangeSeparator, type } = options;
  let leftDateInput = '';
  let leftTimeInput = '';
  let rightDateInput = '';
  let rightTimeInput = '';
  const insetInputValue: InsetInputValue = {
    monthLeft: { dateInput: '', timeInput: '' },
    monthRight: { dateInput: '', timeInput: '' },
  };

  switch (type) {
    case 'date':
    case 'month':
    case 'monthRange':
      insetInputValue.monthLeft.dateInput = inputValue;
      break;
    case 'dateRange':
      [leftDateInput = '', rightDateInput = ''] = inputValue.split(rangeSeparator);
      insetInputValue.monthLeft.dateInput = leftDateInput;
      insetInputValue.monthRight.dateInput = rightDateInput;
      break;
    case 'dateTime':
      [leftDateInput = '', leftTimeInput = ''] = inputValue.split(timeSeparator);
      insetInputValue.monthLeft.dateInput = leftDateInput;
      insetInputValue.monthLeft.timeInput = leftTimeInput;
      break;
    case 'dateTimeRange': {
      const [leftInput = '', rightInput = ''] = inputValue.split(rangeSeparator);
      [leftDateInput = '', leftTimeInput = ''] = leftInput.split(timeSeparator);
      [rightDateInput = '', rightTimeInput = ''] = rightInput.split(timeSeparator);
      insetInputValue.monthLeft.dateInput = leftDateInput;
      insetInputValue.monthLeft.timeInput = leftTimeInput;
      insetInputValue.monthRight.dateInput = rightDateInput;
      insetInputValue.monthRight.timeInput = rightTimeInput;
      break;
    }
    default:
      break;
  }
  return insetInputValue;
}
