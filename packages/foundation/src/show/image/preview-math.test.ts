import { describe, it, expect } from 'vitest';
import {
  calcBoundingRectSize,
  clampZoom,
  getExtremeTranslate,
  clampTranslate,
  recalcTranslateOnZoom,
} from './preview-math.js';

describe('calcBoundingRectSize', () => {
  it('rotation=0 时包围盒等于原始宽高', () => {
    expect(calcBoundingRectSize(100, 50, 0)).toEqual({ width: 100, height: 50 });
  });

  it('rotation=90 时宽高互换', () => {
    const result = calcBoundingRectSize(100, 50, 90);
    expect(result.width).toBeCloseTo(50);
    expect(result.height).toBeCloseTo(100);
  });

  it('rotation=180 时包围盒等于原始宽高（旋转半圈不改变占用空间）', () => {
    const result = calcBoundingRectSize(100, 50, 180);
    expect(result.width).toBeCloseTo(100);
    expect(result.height).toBeCloseTo(50);
  });
});

describe('clampZoom', () => {
  it('在范围内的值原样返回', () => {
    expect(clampZoom(2, 0.1, 5)).toBe(2);
  });

  it('超过 max 时钳制为 max', () => {
    expect(clampZoom(10, 0.1, 5)).toBe(5);
  });

  it('小于 min 时钳制为 min', () => {
    expect(clampZoom(0.01, 0.1, 5)).toBe(0.1);
  });

  it('非法输入（NaN）回退到 min', () => {
    expect(clampZoom(NaN, 0.1, 5)).toBe(0.1);
  });
});

describe('getExtremeTranslate', () => {
  it('图片比容器小时极值为负数（理论上不应该被使用，但计算本身仍正确）', () => {
    expect(getExtremeTranslate(50, 50, 100, 100)).toEqual({ x: -25, y: -25 });
  });

  it('图片比容器大时极值为正数', () => {
    expect(getExtremeTranslate(200, 150, 100, 100)).toEqual({ x: 50, y: 25 });
  });
});

describe('clampTranslate', () => {
  it('图片某一轴小于等于容器时，该轴不允许拖拽，强制为 0', () => {
    const result = clampTranslate(50, 200, 100, 100, 999, 999);
    expect(result.x).toBe(0);
  });

  it('图片某一轴大于容器时，钳制在极值范围内', () => {
    const result = clampTranslate(200, 100, 100, 100, 999, 0);
    expect(result.x).toBe(50);
  });

  it('拖拽值在合法范围内时原样返回', () => {
    const result = clampTranslate(200, 100, 100, 100, 30, 0);
    expect(result.x).toBe(30);
  });
});

describe('recalcTranslateOnZoom', () => {
  it('从 zoom=1 放大到 zoom=2 时，平移量按比例放大后再钳制', () => {
    const result = recalcTranslateOnZoom(1, 2, { x: 10, y: 10 }, 100, 100, 0, 100, 100);
    // 放大后包围盒 200x200，容器 100x100，极值为 50；原始 translate*2=20，未超出钳制范围
    expect(result.x).toBe(20);
    expect(result.y).toBe(20);
  });

  it('缩小到 zoom<=1 且图片小于容器时，平移强制归零', () => {
    const result = recalcTranslateOnZoom(2, 0.5, { x: 40, y: 40 }, 100, 100, 0, 100, 100);
    expect(result).toEqual({ x: 0, y: 0 });
  });
});
