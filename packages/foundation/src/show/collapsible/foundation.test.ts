import { describe, it, expect } from 'vitest';
import {
  CollapsibleFoundation,
  shouldRenderCollapsibleChildren,
  calcCollapsedHeight,
  calcTargetHeight,
  shouldFadeOut,
  type CollapsibleState,
} from './foundation.js';

function createFoundation(initial: CollapsibleState) {
  let state = initial;
  const foundation = new CollapsibleFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('CollapsibleFoundation.handleOpenChange', () => {
  it('展开（isOpen=true）：立即置 visible=true', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: false, isTransitioning: false, hasBeenRendered: false });
    foundation.handleOpenChange(true, true);
    expect(getState().visible).toBe(true);
  });

  it('收起（isOpen=false）+ 无动画：立即置 visible=false', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: true, isTransitioning: false, hasBeenRendered: false });
    foundation.handleOpenChange(false, false);
    expect(getState().visible).toBe(false);
  });

  it('收起（isOpen=false）+ 有动画：暂不收 visible，等待过渡结束', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: true, isTransitioning: false, hasBeenRendered: false });
    foundation.handleOpenChange(false, true);
    expect(getState().visible).toBe(true);
    expect(getState().isTransitioning).toBe(true);
  });

  it('有动画时无论展开/收起都置 isTransitioning=true', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: false, isTransitioning: false, hasBeenRendered: false });
    foundation.handleOpenChange(true, true);
    expect(getState().isTransitioning).toBe(true);
  });

  it('无动画时不设置 isTransitioning', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: false, isTransitioning: false, hasBeenRendered: false });
    foundation.handleOpenChange(true, false);
    expect(getState().isTransitioning).toBe(false);
  });
});

describe('CollapsibleFoundation.handleTransitionEnd', () => {
  it('收起态过渡结束：visible 收为 false，isTransitioning 复位', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: true, isTransitioning: true, hasBeenRendered: false });
    foundation.handleTransitionEnd(false);
    expect(getState().visible).toBe(false);
    expect(getState().isTransitioning).toBe(false);
  });

  it('展开态过渡结束：visible 保持 true，只复位 isTransitioning', () => {
    const { foundation, getState } = createFoundation({ domHeight: 0, visible: true, isTransitioning: true, hasBeenRendered: false });
    foundation.handleTransitionEnd(true);
    expect(getState().visible).toBe(true);
    expect(getState().isTransitioning).toBe(false);
  });
});

describe('CollapsibleFoundation setter 去重', () => {
  it('updateDOMHeight 值相同时不触发 setState（避免无谓响应式更新）', () => {
    let setStateCalls = 0;
    const foundation = new CollapsibleFoundation({
      getState: () => ({ domHeight: 100, visible: false, isTransitioning: false, hasBeenRendered: false }),
      setState: () => { setStateCalls++; },
    });
    foundation.updateDOMHeight(100);
    expect(setStateCalls).toBe(0);
  });

  it('markRendered 已经是 true 时不重复 setState', () => {
    let setStateCalls = 0;
    const foundation = new CollapsibleFoundation({
      getState: () => ({ domHeight: 0, visible: false, isTransitioning: false, hasBeenRendered: true }),
      setState: () => { setStateCalls++; },
    });
    foundation.markRendered();
    expect(setStateCalls).toBe(0);
  });
});

describe('shouldRenderCollapsibleChildren', () => {
  const base = { isOpen: false, visible: false, keepDOM: false, lazyRender: false, hasBeenRendered: false, collapseHeight: 0 };

  it('全部为 false：不渲染', () => {
    expect(shouldRenderCollapsibleChildren(base)).toBe(false);
  });

  it('isOpen=true：渲染', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, isOpen: true })).toBe(true);
  });

  it('visible=true（收起动画进行中）：渲染', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, visible: true })).toBe(true);
  });

  it('collapseHeight 非 0（收起态露出一截内容）：渲染', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, collapseHeight: 40 })).toBe(true);
  });

  it('keepDOM=true 且非 lazyRender：始终渲染', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, keepDOM: true })).toBe(true);
  });

  it('keepDOM=true 且 lazyRender=true 且未渲染过：不渲染', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, keepDOM: true, lazyRender: true, hasBeenRendered: false })).toBe(false);
  });

  it('keepDOM=true 且 lazyRender=true 且已渲染过：渲染（即使收起）', () => {
    expect(shouldRenderCollapsibleChildren({ ...base, keepDOM: true, lazyRender: true, hasBeenRendered: true })).toBe(true);
  });
});

describe('calcCollapsedHeight', () => {
  it('非 adaptive：直接用声明的 collapseHeight', () => {
    expect(calcCollapsedHeight({ collapseHeight: 40, collapseHeightAdaptive: false, domHeight: 20 })).toBe(40);
  });

  it('adaptive 且内容高度小于声明值：用内容真实高度', () => {
    expect(calcCollapsedHeight({ collapseHeight: 40, collapseHeightAdaptive: true, domHeight: 20 })).toBe(20);
  });

  it('adaptive 且内容高度大于声明值：用声明值', () => {
    expect(calcCollapsedHeight({ collapseHeight: 40, collapseHeightAdaptive: true, domHeight: 100 })).toBe(40);
  });
});

describe('calcTargetHeight', () => {
  it('展开态：用真实测得的 domHeight，不管 collapseHeight', () => {
    expect(calcTargetHeight({ isOpen: true, domHeight: 300, collapseHeight: 40, collapseHeightAdaptive: false })).toBe(300);
  });

  it('收起态：走 calcCollapsedHeight 逻辑', () => {
    expect(calcTargetHeight({ isOpen: false, domHeight: 300, collapseHeight: 40, collapseHeightAdaptive: false })).toBe(40);
    expect(calcTargetHeight({ isOpen: false, domHeight: 20, collapseHeight: 40, collapseHeightAdaptive: true })).toBe(20);
  });
});

describe('shouldFadeOut', () => {
  it('展开态：不淡出', () => {
    expect(shouldFadeOut({ isOpen: true, fade: true, collapseHeight: 0 })).toBe(false);
  });

  it('收起态 + 未声明 fade：不淡出', () => {
    expect(shouldFadeOut({ isOpen: false, fade: false, collapseHeight: 0 })).toBe(false);
  });

  it('收起态 + fade + collapseHeight=0（完全收起）：淡出', () => {
    expect(shouldFadeOut({ isOpen: false, fade: true, collapseHeight: 0 })).toBe(true);
  });

  it('收起态 + fade + collapseHeight 非 0（露出一截内容）：不淡出', () => {
    expect(shouldFadeOut({ isOpen: false, fade: true, collapseHeight: 40 })).toBe(false);
  });
});
