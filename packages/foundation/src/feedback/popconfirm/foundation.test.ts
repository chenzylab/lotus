import { describe, it, expect, vi } from 'vitest';
import { PopconfirmFoundation, type PopconfirmState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: PopconfirmState): { adapter: Adapter<PopconfirmState>; getState: () => PopconfirmState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch: Partial<PopconfirmState>) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('PopconfirmFoundation', () => {
  describe('handleConfirm', () => {
    it('同步回调（非 Promise）直接关闭浮层', () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onConfirm = vi.fn();

      foundation.handleConfirm(onConfirm);

      expect(onConfirm).toHaveBeenCalledTimes(1);
      expect(getState().visible).toBe(false);
    });

    it('返回 Promise 时先进入 confirmLoading，resolve 后关闭浮层并退出 loading', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      let resolvePromise: () => void;
      const onConfirm = vi.fn(() => new Promise<void>((resolve) => { resolvePromise = resolve; }));

      foundation.handleConfirm(onConfirm);

      expect(getState().confirmLoading).toBe(true);
      expect(getState().visible).toBe(true);

      resolvePromise!();
      await Promise.resolve();
      await Promise.resolve();

      expect(getState().confirmLoading).toBe(false);
      expect(getState().visible).toBe(false);
    });

    it('Promise reject 时退出 loading 但浮层保持打开', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      let rejectPromise: () => void;
      const onConfirm = vi.fn(() => new Promise<void>((_, reject) => { rejectPromise = reject; }));

      foundation.handleConfirm(onConfirm);
      rejectPromise!();
      await Promise.resolve().catch(() => {});
      await Promise.resolve().catch(() => {});

      expect(getState().confirmLoading).toBe(false);
      expect(getState().visible).toBe(true);
    });

    it('未传入 onConfirm 时不抛出异常，直接关闭浮层', () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);

      expect(() => foundation.handleConfirm()).not.toThrow();
      expect(getState().visible).toBe(false);
    });
  });

  describe('handleCancel', () => {
    it('同步回调直接关闭浮层', () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onCancel = vi.fn();

      foundation.handleCancel(onCancel);

      expect(onCancel).toHaveBeenCalledTimes(1);
      expect(getState().visible).toBe(false);
    });

    it('返回 Promise 时先进入 cancelLoading，resolve 后关闭浮层', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      let resolvePromise: () => void;
      const onCancel = vi.fn(() => new Promise<void>((resolve) => { resolvePromise = resolve; }));

      foundation.handleCancel(onCancel);
      expect(getState().cancelLoading).toBe(true);

      resolvePromise!();
      await Promise.resolve();
      await Promise.resolve();

      expect(getState().cancelLoading).toBe(false);
      expect(getState().visible).toBe(false);
    });
  });
});
