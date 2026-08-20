import { describe, it, expect } from 'vitest';
import {
  formatFullDate,
  getMonthTable,
  getDayOfWeek,
  isAfter,
  isBefore,
  isSameDay,
  isBetween,
  isValidDate,
  getFullDateOffset,
  getYears,
  getYearAndMonth,
  compatibleParse,
  localeFormat,
  getInsetInputFormatToken,
  getInsetInputValueFromInsetInputStr,
} from './utils.js';

describe('formatFullDate', () => {
  it('补零到 yyyy-MM-dd', () => {
    expect(formatFullDate(2024, 3, 5)).toBe('2024-03-05');
    expect(formatFullDate(2024, 12, 25)).toBe('2024-12-25');
  });
});

describe('getMonthTable', () => {
  it('2024-02（闰年）weekStartsOn=0 生成正确周数', () => {
    const table = getMonthTable(new Date(2024, 1, 1), 0);
    expect(table.monthText).toBe('2024-02');
    expect(table.weeks.flat().filter((d) => d.fullDate).length).toBe(29);
  });

  it('首行前补空日格使 1 号落到正确星期列', () => {
    const table = getMonthTable(new Date(2024, 1, 1), 0);
    const firstWeek = table.weeks[0]!;
    const firstRealDayIndex = firstWeek.findIndex((d) => d.fullDate === '2024-02-01');
    expect(firstRealDayIndex).toBeGreaterThanOrEqual(0);
    for (let i = 0; i < firstRealDayIndex; i++) {
      expect(firstWeek[i]!.fullDate).toBe('');
    }
  });

  it('weekStartsOn=1 时首日列位置变化', () => {
    const table0 = getMonthTable(new Date(2024, 1, 1), 0);
    const table1 = getMonthTable(new Date(2024, 1, 1), 1);
    const idx0 = table0.weeks[0]!.findIndex((d) => d.fullDate === '2024-02-01');
    const idx1 = table1.weeks[0]!.findIndex((d) => d.fullDate === '2024-02-01');
    expect(idx0).not.toBe(idx1);
  });
});

describe('getDayOfWeek', () => {
  it('默认周日开始', () => {
    expect(getDayOfWeek(0)).toEqual(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);
  });

  it('weekStartsOn=1 轮转到周一开始', () => {
    expect(getDayOfWeek(1)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
  });
});

describe('isAfter / isBefore / isSameDay', () => {
  it('字符串和 Date 混用比较', () => {
    expect(isAfter('2024-03-05', new Date(2024, 2, 1))).toBe(true);
    expect(isBefore('2024-03-01', '2024-03-05')).toBe(true);
    expect(isSameDay('2024-03-05', new Date(2024, 2, 5, 23, 0))).toBe(true);
  });
});

describe('isBetween', () => {
  it('day 严格在开区间内返回 true', () => {
    expect(isBetween('2024-03-05', { start: '2024-03-01', end: '2024-03-10' })).toBe(true);
  });

  it('day 等于端点返回 false（不含端点）', () => {
    expect(isBetween('2024-03-01', { start: '2024-03-01', end: '2024-03-10' })).toBe(false);
    expect(isBetween('2024-03-10', { start: '2024-03-01', end: '2024-03-10' })).toBe(false);
  });

  it('start > end 时返回 false', () => {
    expect(isBetween('2024-03-05', { start: '2024-03-10', end: '2024-03-01' })).toBe(false);
  });
});

describe('isValidDate', () => {
  it('合法 Date 返回 true', () => {
    expect(isValidDate(new Date())).toBe(true);
  });

  it('非法 Date / 非 Date 值返回 false', () => {
    expect(isValidDate(new Date('invalid'))).toBe(false);
    expect(isValidDate('2024-01-01')).toBe(false);
    expect(isValidDate(null)).toBe(false);
  });
});

describe('getFullDateOffset', () => {
  it('无 fn 时原样格式化', () => {
    expect(getFullDateOffset(undefined, '2024-03-05')).toBe('2024-03-05');
  });

  it('有 fn 时套用 offset', () => {
    const startOfWeekMon = (d: Date) => {
      const day = d.getDay();
      const diff = (day + 6) % 7;
      const r = new Date(d);
      r.setDate(d.getDate() - diff);
      return r;
    };
    // 2024-03-05 是周二，周一是 2024-03-04。
    expect(getFullDateOffset(startOfWeekMon, '2024-03-05')).toBe('2024-03-04');
  });

  it('空 date 返回空串', () => {
    expect(getFullDateOffset(undefined, '')).toBe('');
  });
});

describe('getYears', () => {
  it('默认 [今年-100, 今年+100]', () => {
    const years = getYears();
    const now = new Date().getFullYear();
    expect(years[0]).toBe(now - 100);
    expect(years[years.length - 1]).toBe(now + 100);
  });

  it('显式区间', () => {
    expect(getYears(2020, 2022)).toEqual([2020, 2021, 2022]);
  });

  it('start > end 时自动交换', () => {
    expect(getYears(2022, 2020)).toEqual([2020, 2021, 2022]);
  });
});

describe('getYearAndMonth', () => {
  it('缺省值按当前年月推导（right 默认 left+1 月）', () => {
    const now = new Date();
    const result = getYearAndMonth({ left: 0, right: 0 }, { left: 0, right: 0 });
    expect(result.month.left).toBe(now.getMonth() + 1);
  });

  it('显式值原样保留', () => {
    const result = getYearAndMonth({ left: 2020, right: 2021 }, { left: 3, right: 4 });
    expect(result).toEqual({ year: { left: 2020, right: 2021 }, month: { left: 3, right: 4 } });
  });
});

describe('compatibleParse', () => {
  it('按 formatToken 严格解析成功', () => {
    const d = compatibleParse('2024-03-05', 'yyyy-MM-dd');
    expect(d?.getFullYear()).toBe(2024);
    expect(d?.getMonth()).toBe(2);
    expect(d?.getDate()).toBe(5);
  });

  it('formatToken 解析失败时降级 ISO 解析', () => {
    const d = compatibleParse('2024-03-05T00:00:00.000Z', 'yyyy/MM/dd');
    expect(d).not.toBeNull();
  });

  it('年份超 4 位视为非法', () => {
    const d = compatibleParse('20240-03-05', 'yyyy-MM-dd');
    expect(d).toBeNull();
  });

  it('空串返回 null', () => {
    expect(compatibleParse('')).toBeNull();
  });
});

describe('localeFormat', () => {
  it('按 token 序列化', () => {
    expect(localeFormat(new Date(2024, 2, 5), 'yyyy-MM-dd')).toBe('2024-03-05');
  });
});

describe('getInsetInputFormatToken', () => {
  it('date 类型拆出日期段', () => {
    expect(getInsetInputFormatToken({ type: 'date', format: 'yyyy-MM-dd' })).toBe('yyyy-MM-dd');
  });

  it('dateTime 类型拆出日期段+时间段', () => {
    expect(getInsetInputFormatToken({ type: 'dateTime', format: 'yyyy-MM-dd HH:mm:ss' })).toBe('yyyy-MM-dd HH:mm:ss');
  });

  it('未传 format 时回退默认 token', () => {
    expect(getInsetInputFormatToken({ type: 'date' })).toBe('yyyy-MM-dd');
  });
});

describe('getInsetInputValueFromInsetInputStr', () => {
  it('date 类型整串放 monthLeft.dateInput', () => {
    const result = getInsetInputValueFromInsetInputStr({ inputValue: '2024-03-05', rangeSeparator: ' ~ ', type: 'date' });
    expect(result.monthLeft.dateInput).toBe('2024-03-05');
  });

  it('dateRange 按 rangeSeparator 拆两端', () => {
    const result = getInsetInputValueFromInsetInputStr({ inputValue: '2024-03-05 ~ 2024-03-10', rangeSeparator: ' ~ ', type: 'dateRange' });
    expect(result.monthLeft.dateInput).toBe('2024-03-05');
    expect(result.monthRight.dateInput).toBe('2024-03-10');
  });

  it('dateTime 按空格拆日期/时间', () => {
    const result = getInsetInputValueFromInsetInputStr({ inputValue: '2024-03-05 12:00:00', rangeSeparator: ' ~ ', type: 'dateTime' });
    expect(result.monthLeft.dateInput).toBe('2024-03-05');
    expect(result.monthLeft.timeInput).toBe('12:00:00');
  });

  it('dateTimeRange 拆两端各自的日期+时间', () => {
    const result = getInsetInputValueFromInsetInputStr({
      inputValue: '2024-03-05 12:00:00 ~ 2024-03-10 18:00:00',
      rangeSeparator: ' ~ ',
      type: 'dateTimeRange',
    });
    expect(result.monthLeft).toEqual({ dateInput: '2024-03-05', timeInput: '12:00:00' });
    expect(result.monthRight).toEqual({ dateInput: '2024-03-10', timeInput: '18:00:00' });
  });
});
