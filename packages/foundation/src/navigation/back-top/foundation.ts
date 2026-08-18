import { Foundation, type Adapter } from '../../base/adapter.js';

export interface BackTopState {
  visible: boolean;
}

export interface ScrollTarget {
  getScrollTop(): number;
  scrollTo(top: number): void;
}

/**
 * BackTop 的滚动监听 + 数值动画滚动回顶。目标节点的 scrollTop 读写通过
 * ScrollTarget 接口注入（window 用 pageYOffset/scrollTo，元素用
 * scrollTop/scrollTo），保持 Foundation 框架无关、可脱离浏览器单测。
 */
export class BackTopFoundation extends Foundation<BackTopState> {
  constructor(adapter: Adapter<BackTopState>) {
    super(adapter);
  }

  handleScroll(scrollTop: number, visibilityHeight: number): void {
    this.setState({ visible: scrollTop > visibilityHeight });
  }

  handleClick(onClick?: () => void): void {
    onClick?.();
  }
}
