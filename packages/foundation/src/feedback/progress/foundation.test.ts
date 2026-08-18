import { describe, it, expect } from 'vitest';
import { clampPercent, calcCircleGeometry, resolveGradientStroke } from './foundation.js';

describe('clampPercent', () => {
  it('超过 100 的值被夹到 100', () => {
    expect(clampPercent(150)).toBe(100);
  });

  it('小于 0 的值被夹到 0', () => {
    expect(clampPercent(-20)).toBe(0);
  });

  it('NaN 归一化为 0', () => {
    expect(clampPercent(NaN)).toBe(0);
  });

  it('正常区间内的值原样返回', () => {
    expect(clampPercent(42)).toBe(42);
  });
});

describe('calcCircleGeometry', () => {
  it('半径 = (width - strokeWidth) / 2', () => {
    const geo = calcCircleGeometry(72, 4, 50);
    expect(geo.radius).toBe(34);
  });

  it('周长 = 2πr', () => {
    const geo = calcCircleGeometry(72, 4, 50);
    expect(geo.circumference).toBeCloseTo(2 * Math.PI * 34, 5);
  });

  it('percent=0 时 strokeDashoffset 等于完整周长（未填充）', () => {
    const geo = calcCircleGeometry(72, 4, 0);
    expect(geo.strokeDashoffset).toBeCloseTo(geo.circumference, 5);
  });

  it('percent=100 时 strokeDashoffset 为 0（完全填充）', () => {
    const geo = calcCircleGeometry(72, 4, 100);
    expect(geo.strokeDashoffset).toBeCloseTo(0, 5);
  });

  it('percent=50 时 strokeDashoffset 为周长一半', () => {
    const geo = calcCircleGeometry(72, 4, 50);
    expect(geo.strokeDashoffset).toBeCloseTo(geo.circumference / 2, 5);
  });
});

describe('resolveGradientStroke', () => {
  it('空数组返回 undefined', () => {
    expect(resolveGradientStroke([], 50, false)).toBeUndefined();
  });

  it('percent 小于最小断点时取第一个断点颜色', () => {
    const result = resolveGradientStroke([{ percent: 30, color: '#ff0000' }, { percent: 70, color: '#00ff00' }], 10, false);
    expect(result).toBe('#ff0000');
  });

  it('percent 大于最大断点时取最后一个断点颜色', () => {
    const result = resolveGradientStroke([{ percent: 30, color: '#ff0000' }, { percent: 70, color: '#00ff00' }], 90, false);
    expect(result).toBe('#00ff00');
  });

  it('percent 精确命中某个断点时直接返回该断点颜色', () => {
    const result = resolveGradientStroke([{ percent: 30, color: '#ff0000' }, { percent: 70, color: '#00ff00' }], 30, false);
    expect(result).toBe('#ff0000');
  });

  it('gradient=false 时区间内取区间下界颜色（硬切换，不插值）', () => {
    const result = resolveGradientStroke([{ percent: 0, color: '#ff0000' }, { percent: 100, color: '#00ff00' }], 50, false);
    expect(result).toBe('#ff0000');
  });

  it('gradient=true 时区间中点插值出两色的中间色', () => {
    const result = resolveGradientStroke([{ percent: 0, color: '#000000' }, { percent: 100, color: '#ffffff' }], 50, true);
    expect(result).toBe('rgb(128, 128, 128)');
  });

  it('gradient=true 时支持 rgb() 格式颜色插值', () => {
    const result = resolveGradientStroke(
      [{ percent: 0, color: 'rgb(0, 0, 0)' }, { percent: 100, color: 'rgb(200, 100, 50)' }],
      50,
      true,
    );
    expect(result).toBe('rgb(100, 50, 25)');
  });

  it('未排序的断点数组会先按 percent 排序再计算', () => {
    const result = resolveGradientStroke(
      [{ percent: 100, color: '#00ff00' }, { percent: 0, color: '#ff0000' }],
      0,
      false,
    );
    expect(result).toBe('#ff0000');
  });

  it('传入单个断点时始终返回该颜色', () => {
    const result = resolveGradientStroke([{ percent: 50, color: '#123456' }], 80, true);
    expect(result).toBe('#123456');
  });
});
