import { describe, it, expect, vi } from 'vitest';
import { animateValue, throttle } from './animate-value.js';

/** 构造可手动步进的假时钟 + 假 raf，让动画测试同步、确定性地驱动，不依赖真实等待。 */
function createFakeScheduler() {
  let currentTime = 0;
  const pending: Array<() => void> = [];
  return {
    now: () => currentTime,
    raf: (cb: () => void) => {
      pending.push(cb);
      return pending.length;
    },
    cancelRaf: (handle: number) => {
      pending[handle - 1] = () => {};
    },
    advance(ms: number) {
      currentTime += ms;
      const due = pending.splice(0, pending.length);
      due.forEach((cb) => cb());
    },
  };
}

describe('animateValue', () => {
  it('duration<=0 时立即以终值触发一次 onFrame 和 onRest', () => {
    const onFrame = vi.fn();
    const onRest = vi.fn();
    animateValue({ from: 0, to: 100, duration: 0, onFrame, onRest });

    expect(onFrame).toHaveBeenCalledTimes(1);
    expect(onFrame).toHaveBeenCalledWith(100);
    expect(onRest).toHaveBeenCalledTimes(1);
  });

  it('linear 缓动：中途帧的值按线性比例插值', () => {
    const scheduler = createFakeScheduler();
    const frames: number[] = [];
    animateValue({
      from: 0,
      to: 100,
      duration: 100,
      easing: 'linear',
      onFrame: (v) => frames.push(v),
      now: scheduler.now,
      raf: scheduler.raf,
      cancelRaf: scheduler.cancelRaf,
    });

    scheduler.advance(50);
    expect(frames[frames.length - 1]).toBeCloseTo(50, 5);
  });

  it('动画跑满 duration 后，最终帧收敛到终值并触发 onRest', () => {
    const scheduler = createFakeScheduler();
    const frames: number[] = [];
    const onRest = vi.fn();
    animateValue({
      from: 0,
      to: 100,
      duration: 100,
      easing: 'linear',
      onFrame: (v) => frames.push(v),
      onRest,
      now: scheduler.now,
      raf: scheduler.raf,
      cancelRaf: scheduler.cancelRaf,
    });

    scheduler.advance(100);
    expect(frames[frames.length - 1]).toBe(100);
    expect(onRest).toHaveBeenCalledTimes(1);
  });

  it('destroy() 后不再触发任何后续帧回调', () => {
    const scheduler = createFakeScheduler();
    const onFrame = vi.fn();
    const handle = animateValue({
      from: 0,
      to: 100,
      duration: 100,
      onFrame,
      now: scheduler.now,
      raf: scheduler.raf,
      cancelRaf: scheduler.cancelRaf,
    });

    const callsBeforeDestroy = onFrame.mock.calls.length;
    handle.destroy();
    scheduler.advance(100);

    expect(onFrame.mock.calls.length).toBe(callsBeforeDestroy);
  });

  it('easeInOutCubic 缓动在 t=0.5 时正好等于中点值', () => {
    const scheduler = createFakeScheduler();
    const frames: number[] = [];
    animateValue({
      from: 0,
      to: 100,
      duration: 100,
      easing: 'easeInOutCubic',
      onFrame: (v) => frames.push(v),
      now: scheduler.now,
      raf: scheduler.raf,
      cancelRaf: scheduler.cancelRaf,
    });

    scheduler.advance(50);
    expect(frames[frames.length - 1]).toBeCloseTo(50, 5);
  });
});

describe('throttle', () => {
  it('间隔内的重复调用被忽略，只有首次真正执行', () => {
    let time = 0;
    const fn = vi.fn();
    const throttled = throttle(fn, 100, () => time);

    throttled();
    time += 50;
    throttled();
    expect(fn).toHaveBeenCalledTimes(1);
  });

  it('超过间隔后的调用会重新执行', () => {
    let time = 0;
    const fn = vi.fn();
    const throttled = throttle(fn, 100, () => time);

    throttled();
    time += 150;
    throttled();

    expect(fn).toHaveBeenCalledTimes(2);
  });

  it('透传调用参数给被节流的函数', () => {
    let time = 0;
    const fn = vi.fn();
    const throttled = throttle(fn, 100, () => time);

    throttled('a', 1);
    expect(fn).toHaveBeenCalledWith('a', 1);
  });

  it('窗口内被跳过的最后一次调用会在窗口结束后补偿执行（trailing edge）', () => {
    let time = 0;
    const fn = vi.fn();
    const pendingTimers: Array<{ cb: () => void; delay: number }> = [];
    const fakeSetTimeout = (cb: () => void, delay: number) => {
      pendingTimers.push({ cb, delay });
      return pendingTimers.length;
    };
    const fakeClearTimeout = () => {};
    const throttled = throttle(fn, 100, () => time, fakeSetTimeout, fakeClearTimeout);

    throttled('first');
    time += 30;
    throttled('second'); // 落在窗口内，被跳过但记录为待补偿参数
    time += 30;
    throttled('third'); // 同样落在窗口内，覆盖待补偿参数为 'third'

    expect(fn).toHaveBeenCalledTimes(1);
    expect(fn).toHaveBeenCalledWith('first');

    // 模拟窗口结束后 setTimeout 触发
    time += 40;
    pendingTimers[0]!.cb();

    expect(fn).toHaveBeenCalledTimes(2);
    expect(fn).toHaveBeenLastCalledWith('third');
  });

  it('窗口内只调用一次时不会产生多余的补偿调用', () => {
    let time = 0;
    const fn = vi.fn();
    const pendingTimers: Array<() => void> = [];
    const throttled = throttle(
      fn,
      100,
      () => time,
      (cb) => { pendingTimers.push(cb); return pendingTimers.length; },
      () => {},
    );

    throttled();
    expect(pendingTimers.length).toBe(0);
  });
});
