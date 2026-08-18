import { describe, it, expect, vi } from 'vitest';
import { BannerFoundation, type BannerState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: BannerState): { adapter: Adapter<BannerState>; getState: () => BannerState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch: Partial<BannerState>) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('BannerFoundation', () => {
  it('close() 将 visible 置为 false', () => {
    const { adapter, getState } = createMockAdapter({ visible: true });
    const foundation = new BannerFoundation(adapter);

    foundation.close();

    expect(getState().visible).toBe(false);
  });

  it('close() 触发 onClose 回调', () => {
    const { adapter } = createMockAdapter({ visible: true });
    const foundation = new BannerFoundation(adapter);
    const onClose = vi.fn();

    foundation.close(onClose);

    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('未传入 onClose 时不抛出异常', () => {
    const { adapter } = createMockAdapter({ visible: true });
    const foundation = new BannerFoundation(adapter);

    expect(() => foundation.close()).not.toThrow();
  });
});
