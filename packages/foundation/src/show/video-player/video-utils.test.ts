import { describe, expect, it } from 'vitest';
import { clampVolume, clampTime, formatVideoTime, DEFAULT_PLAYBACK_RATE_LIST } from './video-utils.js';

describe('clampVolume / clampTime 复用自 AudioPlayer', () => {
  it('clampVolume 钳制到 [0,100]', () => {
    expect(clampVolume(-10)).toBe(0);
    expect(clampVolume(150)).toBe(100);
  });

  it('clampTime 钳制到 [0,total]', () => {
    expect(clampTime(150, 100)).toBe(100);
    expect(clampTime(-5, 100)).toBe(0);
  });
});

describe('formatVideoTime', () => {
  it('小于一小时格式化为 m:ss', () => {
    expect(formatVideoTime(0)).toBe('0:00');
    expect(formatVideoTime(65)).toBe('1:05');
    expect(formatVideoTime(3599)).toBe('59:59');
  });

  it('大于等于一小时格式化为 h:mm:ss', () => {
    expect(formatVideoTime(3600)).toBe('1:00:00');
    expect(formatVideoTime(3661)).toBe('1:01:01');
    expect(formatVideoTime(7325)).toBe('2:02:05');
  });

  it('NaN/负数视为 0', () => {
    expect(formatVideoTime(NaN)).toBe('0:00');
    expect(formatVideoTime(-5)).toBe('0:00');
  });
});

describe('DEFAULT_PLAYBACK_RATE_LIST', () => {
  it('5 档降序，含 1.25x（与 AudioPlayer 的升序档位不同）', () => {
    expect(DEFAULT_PLAYBACK_RATE_LIST.map((r) => r.value)).toEqual([2, 1.5, 1.25, 1, 0.75]);
  });
});
