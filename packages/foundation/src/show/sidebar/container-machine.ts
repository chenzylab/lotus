import { Foundation, type Adapter } from '../../base/adapter.js';

/**
 * Sidebar.Container 的显隐/动画时序状态机：与 Modal 同构（displayNone 与
 * visible 分离，播放完关闭动画才真正卸载 DOM），对齐 Semi ContainerFoundation
 * 的量级——真实的 resize 拖拽几何完全委托给 lotus 已有的 Resizable 组件
 * （`enable: ['left']` 单方向），这里不重复实现。
 */
export interface ContainerState {
  displayNone: boolean;
}

export function initialContainerState(visible: boolean): ContainerState {
  return { displayNone: !visible };
}

export class ContainerFoundation extends Foundation<ContainerState> {
  constructor(adapter: Adapter<ContainerState>) {
    super(adapter);
  }

  /** visible 变为 true 时同步显示 DOM（展开动画本身用 CSS 处理）。 */
  handleShow(): void {
    this.setState({ displayNone: false });
  }

  /** 关闭动画播放完毕后调用，真正隐藏/卸载 DOM。 */
  handleAnimationEnd(visible: boolean): void {
    if (!visible) this.setState({ displayNone: true });
  }
}
