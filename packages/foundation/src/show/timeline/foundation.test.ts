import { describe, it, expect } from 'vitest';
import { resolvePosition } from './foundation.js';

describe('resolvePosition', () => {
  it('mode=left 时始终返回 left，忽略节点自己的 position', () => {
    expect(resolvePosition('left', 0, 'right')).toBe('left');
    expect(resolvePosition('left', 1, 'right')).toBe('left');
  });

  it('mode=right 时始终返回 right，忽略节点自己的 position', () => {
    expect(resolvePosition('right', 0, 'left')).toBe('right');
    expect(resolvePosition('right', 3, 'left')).toBe('right');
  });

  it('mode=alternate 时按 index 奇偶交替，偶数在左', () => {
    expect(resolvePosition('alternate', 0, undefined)).toBe('left');
    expect(resolvePosition('alternate', 1, undefined)).toBe('right');
    expect(resolvePosition('alternate', 2, undefined)).toBe('left');
    expect(resolvePosition('alternate', 3, undefined)).toBe('right');
  });

  it('mode=alternate 时节点显式 position 优先于交替规则', () => {
    expect(resolvePosition('alternate', 0, 'right')).toBe('right');
    expect(resolvePosition('alternate', 1, 'left')).toBe('left');
  });

  it('mode=center 时未显式 position 统一返回 left', () => {
    expect(resolvePosition('center', 0, undefined)).toBe('left');
    expect(resolvePosition('center', 1, undefined)).toBe('left');
  });

  it('mode=center 时节点显式 position 优先于默认值', () => {
    expect(resolvePosition('center', 0, 'right')).toBe('right');
  });
});
