import { describe, it, expect } from 'vitest';
import { getDayStatus, getTodayText, type DayStatusOptions } from './day-status.js';

function makeOptions(overrides: Partial<DayStatusOptions> = {}): DayStatusOptions {
  return {
    fullDate: '2024-03-05',
    todayText: '2024-03-05',
    selected: new Set(),
    rangeStart: '',
    rangeEnd: '',
    hoverDay: '',
    offsetRangeStart: '',
    offsetRangeEnd: '',
    rangeInputFocus: false,
    ...overrides,
  };
}

describe('getTodayText', () => {
  it('返回 yyyy-MM-dd 格式的今天', () => {
    const text = getTodayText();
    expect(text).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });
});

describe('getDayStatus：单日基础态', () => {
  it('isToday：fullDate 等于 todayText', () => {
    expect(getDayStatus(makeOptions()).isToday).toBe(true);
    expect(getDayStatus(makeOptions({ fullDate: '2024-03-06' })).isToday).toBe(false);
  });

  it('isSelected：命中 selected 集合', () => {
    const status = getDayStatus(makeOptions({ selected: new Set(['2024-03-05']) }));
    expect(status.isSelected).toBe(true);
  });

  it('isDisabled：调用 disabledDate 回调', () => {
    const status = getDayStatus(makeOptions({ disabledDate: (d) => d.getDate() === 5 }));
    expect(status.isDisabled).toBe(true);
  });
});

describe('getDayStatus：range 态', () => {
  it('两端都未选时不产生 range 相关字段', () => {
    const status = getDayStatus(makeOptions());
    expect(status.isSelectedStart).toBeUndefined();
    expect(status.isInRange).toBeUndefined();
  });

  it('isSelectedStart/isSelectedEnd 命中对应端点', () => {
    const s1 = getDayStatus(makeOptions({ fullDate: '2024-03-01', rangeStart: '2024-03-01', rangeEnd: '2024-03-10' }));
    expect(s1.isSelectedStart).toBe(true);
    expect(s1.isSelectedEnd).toBe(false);

    const s2 = getDayStatus(makeOptions({ fullDate: '2024-03-10', rangeStart: '2024-03-01', rangeEnd: '2024-03-10' }));
    expect(s2.isSelectedEnd).toBe(true);
  });

  it('isInRange：两端都选中时严格开区间内为 true，不含端点', () => {
    const middle = getDayStatus(makeOptions({ fullDate: '2024-03-05', rangeStart: '2024-03-01', rangeEnd: '2024-03-10' }));
    expect(middle.isInRange).toBe(true);

    const startPoint = getDayStatus(makeOptions({ fullDate: '2024-03-01', rangeStart: '2024-03-01', rangeEnd: '2024-03-10' }));
    expect(startPoint.isInRange).toBe(false);
  });

  it('只选了一端时 isHoverDayAroundOneSelected 标记 hover 落在该端', () => {
    const status = getDayStatus(makeOptions({ fullDate: '2024-03-01', rangeStart: '2024-03-01', rangeEnd: '', hoverDay: '2024-03-01' }));
    expect(status.isHoverDayAroundOneSelected).toBe(true);
  });

  it('rangeInputFocus=rangeEnd 时 hover 预览态计算 isHover（start~hover 之间）', () => {
    const status = getDayStatus(makeOptions({ fullDate: '2024-03-05', rangeStart: '2024-03-01', rangeEnd: '', hoverDay: '2024-03-10', rangeInputFocus: 'rangeEnd' }));
    expect(status.isHover).toBe(true);
  });
});

describe('getDayStatus：offset（周选择）态', () => {
  it('无 offset 数据时不产生 offset 字段', () => {
    const status = getDayStatus(makeOptions());
    expect(status.isOffsetRangeStart).toBeUndefined();
  });

  it('isOffsetRangeStart/End 命中 offset 端点', () => {
    const status = getDayStatus(makeOptions({ fullDate: '2024-03-04', offsetRangeStart: '2024-03-04', offsetRangeEnd: '2024-03-10' }));
    expect(status.isOffsetRangeStart).toBe(true);
  });

  it('isInOffsetRange：两端都有时开区间+端点都算 in range', () => {
    const status = getDayStatus(makeOptions({ fullDate: '2024-03-07', offsetRangeStart: '2024-03-04', offsetRangeEnd: '2024-03-10' }));
    expect(status.isInOffsetRange).toBe(true);
  });
});
