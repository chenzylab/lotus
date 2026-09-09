import { describe, expect, it } from 'vitest';
import { isValidTimeZone, normalizeTimeZone, utcToZonedTime, zonedTimeToUtc } from './timezone.js';

describe('isValidTimeZone', () => {
  it('接受非空字符串与数值', () => {
    expect(isValidTimeZone('Asia/Shanghai')).toBe(true);
    expect(isValidTimeZone('GMT+08:00')).toBe(true);
    expect(isValidTimeZone(8)).toBe(true);
    expect(isValidTimeZone(-5.5)).toBe(true);
  });

  it('拒绝空字符串、undefined、其他类型', () => {
    expect(isValidTimeZone('')).toBe(false);
    expect(isValidTimeZone(undefined)).toBe(false);
    expect(isValidTimeZone(null)).toBe(false);
    expect(isValidTimeZone(true)).toBe(false);
  });
});

describe('normalizeTimeZone', () => {
  it('数值偏移转换为 ±HH:MM 格式', () => {
    expect(normalizeTimeZone(8)).toBe('+08:00');
    expect(normalizeTimeZone(-5)).toBe('-05:00');
    expect(normalizeTimeZone(5.5)).toBe('+05:30');
    expect(normalizeTimeZone(0)).toBe('+00:00');
  });

  it('GMT±HH:MM 写法转换为 date-fns-tz 认识的 ±HH:MM 格式', () => {
    expect(normalizeTimeZone('GMT+08:00')).toBe('+08:00');
    expect(normalizeTimeZone('GMT-05:00')).toBe('-05:00');
  });

  it('IANA 时区名与已是 ±HH:MM 格式的字符串原样返回', () => {
    expect(normalizeTimeZone('Asia/Shanghai')).toBe('Asia/Shanghai');
    expect(normalizeTimeZone('+08:00')).toBe('+08:00');
  });
});

describe('utcToZonedTime / zonedTimeToUtc', () => {
  it('UTC 转目标时区挂钟时间：Asia/Shanghai 为 UTC+8', () => {
    const utc = new Date('2026-09-08T12:00:00.000Z');
    const zoned = utcToZonedTime(utc, 'Asia/Shanghai');
    expect(zoned.getHours()).toBe(20);
    expect(zoned.getMinutes()).toBe(0);
  });

  it('UTC 转目标时区挂钟时间：GMT+08:00 与 Asia/Shanghai 等价', () => {
    const utc = new Date('2026-09-08T12:00:00.000Z');
    const zoned = utcToZonedTime(utc, 'GMT+08:00');
    expect(zoned.getHours()).toBe(20);
  });

  it('数值时区支持半小时偏移', () => {
    const utc = new Date('2026-09-08T12:00:00.000Z');
    const zoned = utcToZonedTime(utc, 5.5);
    expect(zoned.getHours()).toBe(17);
    expect(zoned.getMinutes()).toBe(30);
  });

  it('zonedTimeToUtc 与 utcToZonedTime 互为逆运算', () => {
    const utc = new Date('2026-09-08T12:00:00.000Z');
    const zoned = utcToZonedTime(utc, 'Asia/Shanghai');
    const backToUtc = zonedTimeToUtc(zoned, 'Asia/Shanghai');
    expect(backToUtc.getTime()).toBe(utc.getTime());
  });
});
