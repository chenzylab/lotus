import { describe, it, expect } from 'vitest';
import {
  buildRange,
  to12Hour,
  meridiemOf,
  from12Hour,
  buildHourOptions,
  buildMinuteOptions,
  buildSecondOptions,
  applyHideDisabled,
  isTimeDisabled,
  parseFormatSpec,
  formatTime,
  parseTimeString,
} from './time-utils.js';

describe('buildRange', () => {
  it('按 step 生成 [0, max)', () => {
    expect(buildRange(5, 1)).toEqual([0, 1, 2, 3, 4]);
    expect(buildRange(10, 3)).toEqual([0, 3, 6, 9]);
  });

  it('step<=0 视为 1', () => {
    expect(buildRange(3, 0)).toEqual([0, 1, 2]);
  });
});

describe('to12Hour / meridiemOf / from12Hour', () => {
  it('0 点 -> 12（凌晨12点）', () => {
    expect(to12Hour(0)).toBe(12);
    expect(meridiemOf(0)).toBe('am');
  });

  it('12 点 -> 12（中午12点）', () => {
    expect(to12Hour(12)).toBe(12);
    expect(meridiemOf(12)).toBe('pm');
  });

  it('13 点 -> 1（下午1点）', () => {
    expect(to12Hour(13)).toBe(1);
    expect(meridiemOf(13)).toBe('pm');
  });

  it('from12Hour 往返一致', () => {
    expect(from12Hour(12, 'am')).toBe(0);
    expect(from12Hour(12, 'pm')).toBe(12);
    expect(from12Hour(1, 'pm')).toBe(13);
    expect(from12Hour(11, 'am')).toBe(11);
  });
});

describe('buildHourOptions', () => {
  it('24 小时制生成 0-23', () => {
    const result = buildHourOptions(1, false, 'am');
    expect(result.length).toBe(24);
    expect(result[0]).toEqual({ value: 0, disabled: false });
  });

  it('12 小时制 AM 生成 1-12（映射到 0-11 判 disabled）', () => {
    const result = buildHourOptions(1, true, 'am', () => [0]);
    expect(result.map((r) => r.value)).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    expect(result.find((r) => r.value === 12)?.disabled).toBe(true);
  });

  it('disabledHours 按 24 小时数值过滤', () => {
    const result = buildHourOptions(1, false, 'am', () => [5, 10]);
    expect(result.find((r) => r.value === 5)?.disabled).toBe(true);
    expect(result.find((r) => r.value === 10)?.disabled).toBe(true);
    expect(result.find((r) => r.value === 6)?.disabled).toBe(false);
  });
});

describe('buildMinuteOptions / buildSecondOptions', () => {
  it('60 个值，按 disabledMinutes(hour) 过滤', () => {
    const result = buildMinuteOptions(1, 10, (h) => (h === 10 ? [0, 30] : []));
    expect(result.length).toBe(60);
    expect(result.find((r) => r.value === 0)?.disabled).toBe(true);
    expect(result.find((r) => r.value === 1)?.disabled).toBe(false);
  });

  it('buildSecondOptions 按 (hour, minute) 过滤', () => {
    const result = buildSecondOptions(1, 10, 5, (h, m) => (h === 10 && m === 5 ? [59] : []));
    expect(result.find((r) => r.value === 59)?.disabled).toBe(true);
  });
});

describe('applyHideDisabled', () => {
  it('hideDisabledOptions=false 时原样返回', () => {
    const opts = [{ value: 0, disabled: true }, { value: 1, disabled: false }];
    expect(applyHideDisabled(opts, false)).toEqual(opts);
  });

  it('hideDisabledOptions=true 时剔除 disabled 项', () => {
    const opts = [{ value: 0, disabled: true }, { value: 1, disabled: false }];
    expect(applyHideDisabled(opts, true)).toEqual([{ value: 1, disabled: false }]);
  });
});

describe('isTimeDisabled', () => {
  it('命中任一维度即视为禁用', () => {
    expect(isTimeDisabled(10, 0, 0, { disabledHours: () => [10] })).toBe(true);
    expect(isTimeDisabled(10, 30, 0, { disabledMinutes: (h) => (h === 10 ? [30] : []) })).toBe(true);
    expect(isTimeDisabled(10, 30, 45, { disabledSeconds: (h, m) => (h === 10 && m === 30 ? [45] : []) })).toBe(true);
  });

  it('都不命中则不禁用', () => {
    expect(isTimeDisabled(1, 2, 3, {})).toBe(false);
  });
});

describe('parseFormatSpec', () => {
  it('HH:mm:ss 显示时分秒，24 小时制', () => {
    expect(parseFormatSpec('HH:mm:ss')).toEqual({ showHour: true, showMinute: true, showSecond: true, use12Hours: false });
  });

  it('HH:mm 不显示秒', () => {
    expect(parseFormatSpec('HH:mm')).toEqual({ showHour: true, showMinute: true, showSecond: false, use12Hours: false });
  });

  it('a h:mm:ss 含 12 小时制标记', () => {
    expect(parseFormatSpec('a h:mm:ss')).toEqual({ showHour: true, showMinute: true, showSecond: true, use12Hours: true });
  });

  it('小写 h 隐含 12 小时制', () => {
    expect(parseFormatSpec('h:mm')).toEqual({ showHour: true, showMinute: true, showSecond: false, use12Hours: true });
  });
});

describe('formatTime', () => {
  it('24 小时制补零', () => {
    expect(formatTime({ hour: 9, minute: 5, second: 3 }, 'HH:mm:ss')).toBe('09:05:03');
  });

  it('12 小时制 + AM/PM', () => {
    expect(formatTime({ hour: 13, minute: 30, second: 0 }, 'a h:mm:ss')).toBe('pm 1:30:00');
    expect(formatTime({ hour: 0, minute: 0, second: 0 }, 'A h:mm:ss')).toBe('AM 12:00:00');
  });

  it('不含 padding 的单字符 token 不补零', () => {
    expect(formatTime({ hour: 9, minute: 5, second: 3 }, 'H:m:s')).toBe('9:5:3');
  });
});

describe('parseTimeString', () => {
  it('解析 HH:mm:ss', () => {
    expect(parseTimeString('09:05:03')).toEqual({ hour: 9, minute: 5, second: 3 });
  });

  it('解析 HH:mm（秒缺省 0）', () => {
    expect(parseTimeString('9:5')).toEqual({ hour: 9, minute: 5, second: 0 });
  });

  it('解析带 AM/PM 后缀', () => {
    expect(parseTimeString('12:30 pm')).toEqual({ hour: 12, minute: 30, second: 0 });
    expect(parseTimeString('12:30am')).toEqual({ hour: 0, minute: 30, second: 0 });
  });

  it('非法输入返回 null', () => {
    expect(parseTimeString('')).toBeNull();
    expect(parseTimeString('abc')).toBeNull();
    expect(parseTimeString('25:00')).toBeNull();
    expect(parseTimeString('10:60')).toBeNull();
    expect(parseTimeString('13:00 pm')).toBeNull();
  });
});
