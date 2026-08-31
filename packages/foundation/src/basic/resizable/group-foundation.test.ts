import { describe, it, expect } from 'vitest';
import {
  getPixelSize,
  initializeItemPercents,
  violatesConstraint,
  clampToConstraint,
  resizeAdjacentItems,
} from './group-foundation.js';

describe('getPixelSize', () => {
  it('px 字符串直接取数值', () => {
    expect(getPixelSize('100px', 1000)).toBe(100);
  });

  it('% 字符串按父尺寸换算', () => {
    expect(getPixelSize('20%', 1000)).toBe(200);
  });

  it('纯数字字符串按 Number 解析', () => {
    expect(getPixelSize('50', 1000)).toBe(50);
  });
});

describe('initializeItemPercents', () => {
  it('全部 flex 比例项：按权重均分 100%', () => {
    const percents = initializeItemPercents([{ defaultSize: 1 }, { defaultSize: 1 }], 1000);
    expect(percents).toEqual([50, 50]);
  });

  it('固定 px + 固定 % + flex 比例混合：flex 项分剩余空间', () => {
    // 400px = 40%，20% 固定，剩余 40% 按 0.5:1 比例分配给两个 flex 项（对齐 Semi 组合组件 demo 数值）。
    const percents = initializeItemPercents(
      [{ defaultSize: '400px' }, { defaultSize: '20%' }, { defaultSize: '0.5' }, { defaultSize: 1 }],
      1000,
    );
    expect(percents[0]).toBeCloseTo(40, 5);
    expect(percents[1]).toBeCloseTo(20, 5);
    expect(percents[2]).toBeCloseTo((0.5 / 1.5) * 40, 5);
    expect(percents[3]).toBeCloseTo((1 / 1.5) * 40, 5);
  });

  it('未指定 defaultSize 的项按权重 1 计入 flex 分配', () => {
    const percents = initializeItemPercents([{ defaultSize: '50%' }, {}], 1000);
    expect(percents[0]).toBeCloseTo(50, 5);
    expect(percents[1]).toBeCloseTo(50, 5);
  });

  it('固定项总和超过 100% 时，flex 项兜底分配 10%（对齐 Semi 越界告警场景的容错策略）', () => {
    const percents = initializeItemPercents([{ defaultSize: '70%' }, { defaultSize: '60%' }, { defaultSize: 1 }], 1000);
    expect(percents[0]).toBeCloseTo(70, 5);
    expect(percents[1]).toBeCloseTo(60, 5);
    expect(percents[2]).toBeCloseTo(10, 5);
  });
});

describe('violatesConstraint / clampToConstraint', () => {
  it('未设置 min/max 时默认范围是 0%~100%，不越界', () => {
    expect(violatesConstraint(500, undefined, undefined, 1000)).toBe(false);
  });

  it('小于 min 时判定越界，clamp 后回到 min+offset', () => {
    expect(violatesConstraint(50, '10%', undefined, 1000)).toBe(true);
    expect(clampToConstraint(50, '10%', undefined, 1000)).toBe(100);
  });

  it('大于 max 时判定越界，clamp 后回到 max', () => {
    expect(violatesConstraint(900, undefined, '80%', 1000)).toBe(true);
    expect(clampToConstraint(900, undefined, '80%', 1000)).toBe(800);
  });

  it('offset（相邻 handler 占用空间）计入 min 判断', () => {
    expect(violatesConstraint(105, '10%', undefined, 1000, 10)).toBe(true);
    expect(violatesConstraint(115, '10%', undefined, 1000, 10)).toBe(false);
  });
});

describe('resizeAdjacentItems', () => {
  it('正常范围内：一个变大对应另一个等量变小', () => {
    const result = resizeAdjacentItems(400, 400, 50, {}, {}, 1000);
    expect(result.lastPercent).toBeCloseTo(45, 5);
    expect(result.nextPercent).toBeCloseTo(35, 5);
  });

  it('last 越界时，delta 让给 next 侧承担', () => {
    // last 的 min 是 40%（400px），尝试把 last 从 400 缩到 300（越界），应 clamp 回 400，
    // 总和 800px 不变，多让出去的 100px 全部由 next 侧吸收（400 -> 400，即维持不变）。
    const result = resizeAdjacentItems(400, 400, -100, { min: '40%' }, {}, 1000);
    expect(result.lastPercent).toBeCloseTo(40, 5);
    expect(result.nextPercent).toBeCloseTo(40, 5);
  });

  it('next 越界时，delta 让给 last 侧承担', () => {
    const result = resizeAdjacentItems(400, 400, 100, {}, { min: '40%' }, 1000);
    expect(result.nextPercent).toBeCloseTo(40, 5);
    expect(result.lastPercent).toBeCloseTo(40, 5);
  });
});
