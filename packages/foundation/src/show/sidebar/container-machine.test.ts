import { describe, it, expect } from 'vitest';
import { ContainerFoundation, initialContainerState, type ContainerState } from './container-machine.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: ContainerState): { adapter: Adapter<ContainerState>; getState: () => ContainerState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('initialContainerState', () => {
  it('visible=true 时 displayNone 为 false', () => {
    expect(initialContainerState(true).displayNone).toBe(false);
  });

  it('visible=false 时 displayNone 为 true', () => {
    expect(initialContainerState(false).displayNone).toBe(true);
  });
});

describe('ContainerFoundation 显隐动画状态机', () => {
  it('handleShow 把 displayNone 置为 false', () => {
    const { adapter, getState } = createMockAdapter(initialContainerState(false));
    const foundation = new ContainerFoundation(adapter);

    foundation.handleShow();

    expect(getState().displayNone).toBe(false);
  });

  it('handleAnimationEnd(visible=false) 把 displayNone 置为 true（关闭动画播完才真正隐藏）', () => {
    const { adapter, getState } = createMockAdapter(initialContainerState(true));
    const foundation = new ContainerFoundation(adapter);

    foundation.handleAnimationEnd(false);

    expect(getState().displayNone).toBe(true);
  });

  it('handleAnimationEnd(visible=true) 不影响 displayNone（正在显示不该被隐藏）', () => {
    const { adapter, getState } = createMockAdapter(initialContainerState(true));
    const foundation = new ContainerFoundation(adapter);

    foundation.handleAnimationEnd(true);

    expect(getState().displayNone).toBe(false);
  });
});
