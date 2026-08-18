import { describe, it, expect, vi } from 'vitest';
import { BackTopFoundation, type BackTopState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: BackTopState): { adapter: Adapter<BackTopState>; getState: () => BackTopState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch: Partial<BackTopState>) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('BackTopFoundation', () => {
  describe('handleScroll', () => {
    it('scrollTop 超过 visibilityHeight 时 visible=true', () => {
      const { adapter, getState } = createMockAdapter({ visible: false });
      const foundation = new BackTopFoundation(adapter);

      foundation.handleScroll(500, 400);

      expect(getState().visible).toBe(true);
    });

    it('scrollTop 未超过 visibilityHeight 时 visible=false', () => {
      const { adapter, getState } = createMockAdapter({ visible: true });
      const foundation = new BackTopFoundation(adapter);

      foundation.handleScroll(100, 400);

      expect(getState().visible).toBe(false);
    });

    it('scrollTop 恰好等于 visibilityHeight 时 visible=false（严格大于才显示）', () => {
      const { adapter, getState } = createMockAdapter({ visible: false });
      const foundation = new BackTopFoundation(adapter);

      foundation.handleScroll(400, 400);

      expect(getState().visible).toBe(false);
    });
  });

  describe('handleClick', () => {
    it('触发传入的回调', () => {
      const { adapter } = createMockAdapter({ visible: true });
      const foundation = new BackTopFoundation(adapter);
      const onClick = vi.fn();

      foundation.handleClick(onClick);

      expect(onClick).toHaveBeenCalledTimes(1);
    });

    it('未传入回调时不抛出异常', () => {
      const { adapter } = createMockAdapter({ visible: true });
      const foundation = new BackTopFoundation(adapter);

      expect(() => foundation.handleClick()).not.toThrow();
    });
  });
});
