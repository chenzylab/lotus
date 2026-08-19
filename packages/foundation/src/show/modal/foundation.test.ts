import { describe, it, expect, vi } from 'vitest';
import { ModalFoundation, initialModalState, type ModalState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: ModalState): { adapter: Adapter<ModalState>; getState: () => ModalState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('initialModalState', () => {
  it('visible=true 时 displayNone 为 false', () => {
    expect(initialModalState(true).displayNone).toBe(false);
  });

  it('visible=false 时 displayNone 为 true', () => {
    expect(initialModalState(false).displayNone).toBe(true);
  });
});

describe('ModalFoundation 显隐动画状态机', () => {
  it('handleShow 把 displayNone 置为 false', () => {
    const { adapter, getState } = createMockAdapter(initialModalState(false));
    const foundation = new ModalFoundation(adapter);

    foundation.handleShow();

    expect(getState().displayNone).toBe(false);
  });

  it('handleAnimationEnd(visible=false) 把 displayNone 置为 true（关闭动画播完才真正隐藏）', () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    foundation.handleAnimationEnd(false);

    expect(getState().displayNone).toBe(true);
  });

  it('handleAnimationEnd(visible=true) 不改变 displayNone（打开动画结束不需要额外处理）', () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    foundation.handleAnimationEnd(true);

    expect(getState().displayNone).toBe(false);
  });
});

describe('ModalFoundation invokeOk/invokeCancel', () => {
  it('onOk 返回非 Promise（undefined）时不改变 onOkStatus', () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    foundation.invokeOk(undefined);

    expect(getState().onOkStatus).toBe('idle');
  });

  it('onOk 返回 Promise 时立即置为 pending，resolve 后置为 fulfilled', async () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    let resolvePromise: () => void = () => {};
    const promise = new Promise<void>((resolve) => { resolvePromise = resolve; });
    foundation.invokeOk(promise);

    expect(getState().onOkStatus).toBe('pending');

    resolvePromise();
    await promise;
    await Promise.resolve();

    expect(getState().onOkStatus).toBe('fulfilled');
  });

  it('onOk 返回的 Promise reject 时置为 rejected，且不吞异常（继续抛出）', async () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    const error = new Error('boom');
    let rejectPromise: (err: Error) => void = () => {};
    const promise = new Promise<void>((_, reject) => { rejectPromise = reject; });

    const onUnhandledRejection = vi.fn();
    const originalHandler = process.listeners('unhandledRejection');
    process.removeAllListeners('unhandledRejection');
    process.on('unhandledRejection', onUnhandledRejection);

    foundation.invokeOk(promise);
    rejectPromise(error);
    await promise.catch(() => {});
    await new Promise((r) => setTimeout(r, 0));

    expect(getState().onOkStatus).toBe('rejected');

    process.removeAllListeners('unhandledRejection');
    originalHandler.forEach((handler) => process.on('unhandledRejection', handler as any));
  });

  it('invokeCancel 同样支持 Promise-aware loading', async () => {
    const { adapter, getState } = createMockAdapter(initialModalState(true));
    const foundation = new ModalFoundation(adapter);

    let resolvePromise: () => void = () => {};
    const promise = new Promise<void>((resolve) => { resolvePromise = resolve; });
    foundation.invokeCancel(promise);

    expect(getState().onCancelStatus).toBe('pending');

    resolvePromise();
    await promise;
    await Promise.resolve();

    expect(getState().onCancelStatus).toBe('fulfilled');
  });
});
