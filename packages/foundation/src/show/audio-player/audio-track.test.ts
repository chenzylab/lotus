import { describe, expect, it } from 'vitest';
import {
  normalizeAudioUrl,
  clampVolume,
  clampTime,
  nextTrackIndex,
  formatTime,
} from './audio-track.js';

describe('normalizeAudioUrl', () => {
  it('null/undefined 返回空数组', () => {
    expect(normalizeAudioUrl(null)).toEqual([]);
    expect(normalizeAudioUrl(undefined)).toEqual([]);
  });

  it('空字符串返回空数组', () => {
    expect(normalizeAudioUrl('')).toEqual([]);
  });

  it('单个字符串归一为单曲', () => {
    expect(normalizeAudioUrl('a.mp3')).toEqual([{ src: 'a.mp3' }]);
  });

  it('单个 AudioInfo 归一为单曲，保留 title/cover', () => {
    expect(normalizeAudioUrl({ src: 'a.mp3', title: 'A', cover: 'c.png' })).toEqual([
      { src: 'a.mp3', title: 'A', cover: 'c.png' },
    ]);
  });

  it('字符串数组逐条归一，丢弃空串', () => {
    expect(normalizeAudioUrl(['a.mp3', '', 'b.mp3'])).toEqual([{ src: 'a.mp3' }, { src: 'b.mp3' }]);
  });

  it('AudioInfo 数组逐条归一，丢弃无 src 项', () => {
    expect(normalizeAudioUrl([{ src: 'a.mp3' }, { title: 'no src' } as any])).toEqual([{ src: 'a.mp3' }]);
  });
});

describe('clampVolume', () => {
  it('NaN 视为 0', () => {
    expect(clampVolume(NaN)).toBe(0);
  });

  it('钳制到 [0, 100]', () => {
    expect(clampVolume(-10)).toBe(0);
    expect(clampVolume(150)).toBe(100);
    expect(clampVolume(50)).toBe(50);
  });
});

describe('clampTime', () => {
  it('NaN/负数视为 0', () => {
    expect(clampTime(NaN, 100)).toBe(0);
    expect(clampTime(-5, 100)).toBe(0);
  });

  it('超过 total 时钳到 total', () => {
    expect(clampTime(150, 100)).toBe(100);
  });

  it('total<=0 时不设上界（媒体尚未加载出 duration 前不误钳成 0）', () => {
    expect(clampTime(50, 0)).toBe(50);
  });

  it('正常范围内原样返回', () => {
    expect(clampTime(50, 100)).toBe(50);
  });
});

describe('nextTrackIndex', () => {
  it('next 方向取模循环，末尾绕回首个', () => {
    expect(nextTrackIndex(0, 3, 'next')).toBe(1);
    expect(nextTrackIndex(2, 3, 'next')).toBe(0);
  });

  it('prev 方向取模循环，首个绕回末尾', () => {
    expect(nextTrackIndex(1, 3, 'prev')).toBe(0);
    expect(nextTrackIndex(0, 3, 'prev')).toBe(2);
  });

  it('length<=0 时返回 0', () => {
    expect(nextTrackIndex(0, 0, 'next')).toBe(0);
  });
});

describe('formatTime', () => {
  it('格式化为 mm:ss', () => {
    expect(formatTime(0)).toBe('0:00');
    expect(formatTime(5)).toBe('0:05');
    expect(formatTime(65)).toBe('1:05');
    expect(formatTime(3661)).toBe('61:01');
  });

  it('NaN/负数视为 0', () => {
    expect(formatTime(NaN)).toBe('0:00');
    expect(formatTime(-5)).toBe('0:00');
  });
});
