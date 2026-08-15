import { describe, it, expect, vi } from 'vitest';
import { AvatarFoundation, type AvatarState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: AvatarState): Adapter<AvatarState> & { _raw: () => AvatarState } {
  let state = initial;
  return {
    getState: () => state,
    setState: (patch: Partial<AvatarState>) => {
      state = { ...state, ...patch };
    },
    _raw: () => state,
  };
}

describe('AvatarFoundation.handleImgError', () => {
  it('无 onError 时降级为文字/占位内容', () => {
    const adapter = createMockAdapter({ imgLoaded: true });
    const foundation = new AvatarFoundation(adapter);

    foundation.handleImgError();

    expect(adapter._raw().imgLoaded).toBe(false);
  });

  it('onError 返回非 false 时仍降级', () => {
    const adapter = createMockAdapter({ imgLoaded: true });
    const foundation = new AvatarFoundation(adapter);
    const onError = vi.fn(() => true);

    foundation.handleImgError(onError);

    expect(onError).toHaveBeenCalled();
    expect(adapter._raw().imgLoaded).toBe(false);
  });

  it('onError 显式返回 false 时保留原状态，不降级', () => {
    const adapter = createMockAdapter({ imgLoaded: true });
    const foundation = new AvatarFoundation(adapter);
    const onError = vi.fn(() => false);

    foundation.handleImgError(onError);

    expect(adapter._raw().imgLoaded).toBe(true);
  });
});

describe('AvatarFoundation.computeTextScale', () => {
  it('文字宽度小于可用宽度时不缩放', () => {
    expect(AvatarFoundation.computeTextScale(40, 20, 3)).toBe(1);
  });

  it('文字宽度超出可用宽度时按比例缩小', () => {
    const scale = AvatarFoundation.computeTextScale(40, 68, 3);
    // available = 40 - 3*2 = 34; scale = 34 / 68 = 0.5
    expect(scale).toBeCloseTo(0.5);
  });

  it('容器宽度为 0 时返回 1（避免除零）', () => {
    expect(AvatarFoundation.computeTextScale(0, 20, 3)).toBe(1);
  });

  it('文字宽度为 0 时返回 1', () => {
    expect(AvatarFoundation.computeTextScale(40, 0, 3)).toBe(1);
  });

  it('gap 过大导致可用宽度非正时返回 1', () => {
    expect(AvatarFoundation.computeTextScale(10, 20, 10)).toBe(1);
  });
});
