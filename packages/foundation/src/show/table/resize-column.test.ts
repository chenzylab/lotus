import { describe, it, expect } from 'vitest';
import { calcResizedWidth } from './resize-column.js';

describe('calcResizedWidth', () => {
  it('正常拖拽：起始宽度加位移', () => {
    expect(calcResizedWidth(100, 30)).toBe(130);
  });

  it('拖拽导致小于 minWidth：钳制到 minWidth', () => {
    expect(calcResizedWidth(50, -30, 40)).toBe(40);
  });

  it('拖拽导致大于 maxWidth：钳制到 maxWidth', () => {
    expect(calcResizedWidth(100, 500, 40, 300)).toBe(300);
  });

  it('未设置 maxWidth：不做上限钳制', () => {
    expect(calcResizedWidth(100, 1000)).toBe(1100);
  });
});
