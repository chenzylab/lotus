import { describe, it, expect } from 'vitest';
import { SideSheetFoundation, initialSideSheetState, type SideSheetState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: SideSheetState): { adapter: Adapter<SideSheetState>; getState: () => SideSheetState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

describe('initialSideSheetState', () => {
  it('visible=true 时 displayNone 为 false', () => {
    expect(initialSideSheetState(true).displayNone).toBe(false);
  });

  it('visible=false 时 displayNone 为 true', () => {
    expect(initialSideSheetState(false).displayNone).toBe(true);
  });
});

describe('SideSheetFoundation 显隐动画状态机', () => {
  it('handleShow 把 displayNone 置为 false', () => {
    const { adapter, getState } = createMockAdapter(initialSideSheetState(false));
    const foundation = new SideSheetFoundation(adapter);

    foundation.handleShow();

    expect(getState().displayNone).toBe(false);
  });

  it('handleAnimationEnd(visible=false) 把 displayNone 置为 true（关闭动画播完才真正隐藏）', () => {
    const { adapter, getState } = createMockAdapter(initialSideSheetState(true));
    const foundation = new SideSheetFoundation(adapter);

    foundation.handleAnimationEnd(false);

    expect(getState().displayNone).toBe(true);
  });

  it('handleAnimationEnd(visible=true) 不改变 displayNone（打开动画结束不需要额外处理）', () => {
    const { adapter, getState } = createMockAdapter(initialSideSheetState(true));
    const foundation = new SideSheetFoundation(adapter);

    foundation.handleAnimationEnd(true);

    expect(getState().displayNone).toBe(false);
  });

  it('handleAnimationEnd(visible=false) 重复调用是幂等的（对齐 Semi 双层动画各自兜底一次的设计）', () => {
    const { adapter, getState } = createMockAdapter(initialSideSheetState(true));
    const foundation = new SideSheetFoundation(adapter);

    foundation.handleAnimationEnd(false);
    foundation.handleAnimationEnd(false);

    expect(getState().displayNone).toBe(true);
  });
});
