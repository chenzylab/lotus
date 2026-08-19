import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { CarouselFoundation, getValidIndex, type CarouselState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: CarouselState): { adapter: Adapter<CarouselState>; getState: () => CarouselState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

function initialState(): CarouselState {
  return { activeIndex: 0, isReverse: false };
}

describe('getValidIndex', () => {
  it('索引在范围内时原样返回', () => {
    expect(getValidIndex(2, 5)).toBe(2);
  });

  it('负数索引环形回绕到末尾', () => {
    expect(getValidIndex(-1, 5)).toBe(4);
  });

  it('超出范围的索引环形回绕到开头', () => {
    expect(getValidIndex(5, 5)).toBe(0);
  });

  it('length=0 时返回 0（不做除零运算）', () => {
    expect(getValidIndex(3, 0)).toBe(0);
  });
});

describe('CarouselFoundation', () => {
  it('next 切换到下一个索引，isReverse 为 false', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.next(3);

    expect(getState().activeIndex).toBe(1);
    expect(getState().isReverse).toBe(false);
  });

  it('next 在最后一张时循环回到第一张', () => {
    const { adapter, getState } = createMockAdapter({ ...initialState(), activeIndex: 2 });
    const foundation = new CarouselFoundation(adapter);

    foundation.next(3);

    expect(getState().activeIndex).toBe(0);
  });

  it('prev 切换到上一个索引，isReverse 为 true', () => {
    const { adapter, getState } = createMockAdapter({ ...initialState(), activeIndex: 1 });
    const foundation = new CarouselFoundation(adapter);

    foundation.prev(3);

    expect(getState().activeIndex).toBe(0);
    expect(getState().isReverse).toBe(true);
  });

  it('prev 在第一张时循环回到最后一张', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.prev(3);

    expect(getState().activeIndex).toBe(2);
  });

  it('goTo 跳到比当前索引大的目标时 isReverse 为 false', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.goTo(2, 3);

    expect(getState().activeIndex).toBe(2);
    expect(getState().isReverse).toBe(false);
  });

  it('goTo 跳到比当前索引小的目标时 isReverse 为 true', () => {
    const { adapter, getState } = createMockAdapter({ ...initialState(), activeIndex: 2 });
    const foundation = new CarouselFoundation(adapter);

    foundation.goTo(0, 3);

    expect(getState().isReverse).toBe(true);
  });
});

describe('CarouselFoundation 自动播放', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('play 后每隔 intervalMs 自动调用 next', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.play(3, 1000);
    expect(getState().activeIndex).toBe(0);

    vi.advanceTimersByTime(1000);
    expect(getState().activeIndex).toBe(1);

    vi.advanceTimersByTime(1000);
    expect(getState().activeIndex).toBe(2);
  });

  it('length<=1 时 play 不启动定时器', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.play(1, 1000);
    vi.advanceTimersByTime(5000);

    expect(getState().activeIndex).toBe(0);
  });

  it('stop 后定时器不再触发', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.play(3, 1000);
    vi.advanceTimersByTime(1000);
    expect(getState().activeIndex).toBe(1);

    foundation.stop();
    vi.advanceTimersByTime(5000);
    expect(getState().activeIndex).toBe(1);
  });

  it('重复调用 play 会先清理旧定时器，不会产生多个并发定时器', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.play(3, 1000);
    foundation.play(3, 1000);
    vi.advanceTimersByTime(1000);

    // 如果旧定时器没清理，这里 activeIndex 会因为两个定时器同时触发 next 而变成 2 而非 1
    expect(getState().activeIndex).toBe(1);
  });

  it('destroy 清理定时器', () => {
    const { adapter, getState } = createMockAdapter(initialState());
    const foundation = new CarouselFoundation(adapter);

    foundation.play(3, 1000);
    foundation.destroy();
    vi.advanceTimersByTime(5000);

    expect(getState().activeIndex).toBe(0);
  });
});
