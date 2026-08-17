import { describe, it, expect, vi } from 'vitest';
import { FloatButtonFoundation, type FloatButtonState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: FloatButtonState): Adapter<FloatButtonState> {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<FloatButtonState>) => {
      state = { ...state, ...patch };
    },
  };
}

describe('FloatButtonFoundation', () => {
  it('正常状态下点击触发回调', () => {
    const adapter = createMockAdapter({ disabled: false });
    const foundation = new FloatButtonFoundation(adapter);
    const onClick = vi.fn();

    foundation.handleClick(onClick);

    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('disabled 状态下点击不触发回调', () => {
    const adapter = createMockAdapter({ disabled: true });
    const foundation = new FloatButtonFoundation(adapter);
    const onClick = vi.fn();

    foundation.handleClick(onClick);

    expect(onClick).not.toHaveBeenCalled();
  });

  it('未传入 onClick 时不抛出异常', () => {
    const adapter = createMockAdapter({ disabled: false });
    const foundation = new FloatButtonFoundation(adapter);

    expect(() => foundation.handleClick()).not.toThrow();
  });
});
