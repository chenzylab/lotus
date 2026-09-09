import { Foundation, type Adapter } from '../../base/adapter.js';

export interface CollapsibleState {
  /** 首次挂载后真实测得的内容高度（scrollHeight），驱动展开态的目标高度。 */
  domHeight: number;
  /** 收起动画结束前仍要渲染 children（避免 isOpen 一变 false 就立刻卸载
   * 内容，导致收起动画看到的是空壳）。 */
  visible: boolean;
  isTransitioning: boolean;
  /** lazyRender 场景下，内容是否已经被渲染过至少一次——渲染过后即使收起
   * 也不会因为 lazyRender 再次跳过（对齐 Semi hasBeenRendered）。 */
  hasBeenRendered: boolean;
}

/**
 * Collapsible：单个裸的展开/收起动画壳子，移植自 Semi
 * semi-foundation/collapsible/foundation.ts 的状态机思路，但把「什么时候
 * 该渲染 children／目标高度是多少／要不要淡出」这几个原本散落在 Semi
 * React 组件 render() 里的计算收纳成纯函数——这几处判断不碰 DOM，只是
 * 布尔/数值运算，抽出来才能脱离渲染框架单测（Semi 自己的 Foundation 反而
 * 很薄，只做 setState 转发，是因为 React class 组件的 render() 本身就是
 * 纯函数，不需要额外抽象层；lotus 用响应式 track()，同样的计算若不抽成
 * 独立纯函数就只能写在 .tsrx 里，没法脱离编译产物单测）。
 *
 * 真实高度测量（ResizeObserver 读 scrollHeight）取代旧版 CSS `max-height:
 * 2000px` 的做法：max-height 动画的时长是按声明的常量差值（2000 - 0）算
 * 过渡进度，不是按内容真实高度，短内容展开时动画绝大部分时间在过渡
 * "看不见的空白"、后段才突然出现，是已知的视觉缺陷；内容一旦超过 2000px
 * 还会被直接截断，是真实功能性 bug，不是可以接受的近似。
 */
export class CollapsibleFoundation extends Foundation<CollapsibleState> {
  constructor(adapter: Adapter<CollapsibleState>) {
    super(adapter);
  }

  updateDOMHeight(domHeight: number): void {
    if (this.getState().domHeight === domHeight) return;
    this.setState({ domHeight });
  }

  updateVisible(visible: boolean): void {
    if (this.getState().visible === visible) return;
    this.setState({ visible });
  }

  updateIsTransitioning(isTransitioning: boolean): void {
    if (this.getState().isTransitioning === isTransitioning) return;
    this.setState({ isTransitioning });
  }

  markRendered(): void {
    if (this.getState().hasBeenRendered) return;
    this.setState({ hasBeenRendered: true });
  }

  /** isOpen 翻转时的状态转移：对齐 Semi getDerivedStateFromProps——
   * 展开时或无动画时立即置 visible；收起且有动画时保持 visible=true 直到
   * 过渡结束（handleTransitionEnd 里才收）；有动画则进入 isTransitioning。 */
  handleOpenChange(nextIsOpen: boolean, motion: boolean): void {
    if (nextIsOpen || !motion) {
      this.updateVisible(nextIsOpen);
    }
    if (motion) {
      this.updateIsTransitioning(true);
    }
  }

  /** 过渡动画结束（transitionend）：收起态才需要把 visible 收掉；
   * isTransitioning 无论展开/收起都要复位。 */
  handleTransitionEnd(isOpen: boolean): void {
    if (!isOpen) {
      this.updateVisible(false);
    }
    this.updateIsTransitioning(false);
  }
}

/** children 是否应该渲染：keepDOM 场景下常驻（lazyRender 时要求已渲染过一次）；
 * collapseHeight 非 0（收起态也露出一截内容）或当前可见态或展开态都要渲染。 */
export function shouldRenderCollapsibleChildren(options: {
  isOpen: boolean;
  visible: boolean;
  keepDOM: boolean;
  lazyRender: boolean;
  hasBeenRendered: boolean;
  collapseHeight: number;
}): boolean {
  const { isOpen, visible, keepDOM, lazyRender, hasBeenRendered, collapseHeight } = options;
  const keepDOMRender = keepDOM && (lazyRender ? hasBeenRendered : true);
  return keepDOMRender || collapseHeight !== 0 || visible || isOpen;
}

/** 收起态的目标高度：collapseHeightAdaptive 时不超过内容真实高度（避免
 * collapseHeight 声明值比内容还高时露馅——内容比声明的"收起高度"还矮，
 * adaptive 模式下收起态直接用内容真实高度，不硬撑一个不存在的高度）。 */
export function calcCollapsedHeight(options: {
  collapseHeight: number;
  collapseHeightAdaptive: boolean;
  domHeight: number;
}): number {
  const { collapseHeight, collapseHeightAdaptive, domHeight } = options;
  return collapseHeightAdaptive ? Math.min(domHeight, collapseHeight) : collapseHeight;
}

/** 展开态目标高度用真实测得的 domHeight，收起态用 calcCollapsedHeight。 */
export function calcTargetHeight(options: {
  isOpen: boolean;
  domHeight: number;
  collapseHeight: number;
  collapseHeightAdaptive: boolean;
}): number {
  const { isOpen, domHeight, collapseHeight, collapseHeightAdaptive } = options;
  if (isOpen) return domHeight;
  return calcCollapsedHeight({ collapseHeight, collapseHeightAdaptive, domHeight });
}

/** fade 场景下是否要把 opacity 压到 0：只有「收起态 + 声明了 fade +
 * collapseHeight 为 0（完全收起，没有露出内容）」才淡出——collapseHeight
 * 非 0 时收起态仍露出一截内容，不应该让它透明不可见。 */
export function shouldFadeOut(options: { isOpen: boolean; fade: boolean; collapseHeight: number }): boolean {
  const { isOpen, fade, collapseHeight } = options;
  return !isOpen && fade && collapseHeight === 0;
}
