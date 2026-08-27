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
    it('同步回调（非 Promise）直接调用 onClose', () => {
      const { adapter } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onConfirm = vi.fn();
      const onClose = vi.fn();

      foundation.handleConfirm(onConfirm, onClose);

      expect(onConfirm).toHaveBeenCalledTimes(1);
      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it('返回 Promise 时先进入 confirmLoading，resolve 后调用 onClose 并退出 loading', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onClose = vi.fn();
      let resolvePromise: () => void;
      const onConfirm = vi.fn(() => new Promise<void>((resolve) => { resolvePromise = resolve; }));

      foundation.handleConfirm(onConfirm, onClose);

      expect(getState().confirmLoading).toBe(true);
      expect(onClose).not.toHaveBeenCalled();

      resolvePromise!();
      await Promise.resolve();
      await Promise.resolve();

      expect(getState().confirmLoading).toBe(false);
      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it('Promise reject 时退出 loading 但不调用 onClose（浮层保持打开）', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onClose = vi.fn();
      let rejectPromise: () => void;
      const onConfirm = vi.fn(() => new Promise<void>((_, reject) => { rejectPromise = reject; }));

      foundation.handleConfirm(onConfirm, onClose);
      rejectPromise!();
      await Promise.resolve().catch(() => {});
      await Promise.resolve().catch(() => {});

      expect(getState().confirmLoading).toBe(false);
      expect(onClose).not.toHaveBeenCalled();
    });

    it('未传入 onConfirm 时不抛出异常，直接调用 onClose', () => {
      const { adapter } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onClose = vi.fn();

      expect(() => foundation.handleConfirm(undefined, onClose)).not.toThrow();
      expect(onClose).toHaveBeenCalledTimes(1);
    });
  });

  describe('handleCancel', () => {
    it('同步回调直接调用 onClose', () => {
      const { adapter } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onCancel = vi.fn();
      const onClose = vi.fn();

      foundation.handleCancel(onCancel, onClose);

      expect(onCancel).toHaveBeenCalledTimes(1);
      expect(onClose).toHaveBeenCalledTimes(1);
    });

    it('返回 Promise 时先进入 cancelLoading，resolve 后调用 onClose', async () => {
      const { adapter, getState } = createMockAdapter({ visible: true, confirmLoading: false, cancelLoading: false });
      const foundation = new PopconfirmFoundation(adapter);
      const onClose = vi.fn();
      let resolvePromise: () => void;
      const onCancel = vi.fn(() => new Promise<void>((resolve) => { resolvePromise = resolve; }));

      foundation.handleCancel(onCancel, onClose);
      expect(getState().cancelLoading).toBe(true);

      resolvePromise!();
      await Promise.resolve();
      await Promise.resolve();

      expect(getState().cancelLoading).toBe(false);
      expect(onClose).toHaveBeenCalledTimes(1);
    });
  });
});
