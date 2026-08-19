import { describe, it, expect } from 'vitest';
import { ImageFoundation, type ImageState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: ImageState): { adapter: Adapter<ImageState>; getState: () => ImageState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('ImageFoundation', () => {
  it('handleLoad 把状态置为 success', () => {
    const { adapter, getState } = createMockAdapter({ loadStatus: 'loading' });
    const foundation = new ImageFoundation(adapter);

    foundation.handleLoad();

    expect(getState().loadStatus).toBe('success');
  });

  it('handleError 把状态置为 error', () => {
    const { adapter, getState } = createMockAdapter({ loadStatus: 'loading' });
    const foundation = new ImageFoundation(adapter);

    foundation.handleError();

    expect(getState().loadStatus).toBe('error');
  });

  it('resetForNewSrc 把状态重置为 loading（即使之前是 success/error）', () => {
    const { adapter, getState } = createMockAdapter({ loadStatus: 'error' });
    const foundation = new ImageFoundation(adapter);

    foundation.resetForNewSrc();

    expect(getState().loadStatus).toBe('loading');
  });
});
