import { describe, it, expect, vi } from 'vitest';
import { ButtonFoundation, type ButtonState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: ButtonState): Adapter<ButtonState> {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<ButtonState>) => {
      state = { ...state, ...patch };
    },
  };
}

describe('ButtonFoundation', () => {
  it('正常状态下点击触发回调', () => {
    const adapter = createMockAdapter({ disabled: false, loading: false });
    const foundation = new ButtonFoundation(adapter);
    const onClick = vi.fn();

    foundation.handleClick(onClick);

    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('disabled 状态下点击不触发回调', () => {
    const adapter = createMockAdapter({ disabled: true, loading: false });
    const foundation = new ButtonFoundation(adapter);
    const onClick = vi.fn();

    foundation.handleClick(onClick);

    expect(onClick).not.toHaveBeenCalled();
  });

  it('loading 状态下点击不触发回调', () => {
    const adapter = createMockAdapter({ disabled: false, loading: true });
    const foundation = new ButtonFoundation(adapter);
    const onClick = vi.fn();

    foundation.handleClick(onClick);

    expect(onClick).not.toHaveBeenCalled();
  });

  it('未传入 onClick 时不抛出异常', () => {
    const adapter = createMockAdapter({ disabled: false, loading: false });
    const foundation = new ButtonFoundation(adapter);

    expect(() => foundation.handleClick()).not.toThrow();
  });
});
