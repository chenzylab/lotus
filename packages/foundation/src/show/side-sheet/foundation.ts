import { Foundation, type Adapter } from '../../base/adapter.js';

export interface SideSheetState {
  /** 是否真正隐藏/卸载 DOM——与 visible 分离，播放完关闭动画才置 true（对齐 Semi）。 */
  displayNone: boolean;
}

export function initialSideSheetState(visible: boolean): SideSheetState {
  return { displayNone: !visible };
}

export class SideSheetFoundation extends Foundation<SideSheetState> {
  constructor(adapter: Adapter<SideSheetState>) {
    super(adapter);
  }

  /** visible 变为 true 时同步显示 DOM（不需要等待，展开动画本身用 CSS 处理）。 */
  handleShow(): void {
    this.setState({ displayNone: false });
  }

  /**
   * 关闭动画播放完毕后调用，真正隐藏/卸载 DOM。
   * 对齐 Semi：mask 和 content 两层动画各自的 onAnimationEnd 都会调用这个方法，
   * 谁先播完都能正确翻转 displayNone，用户可以自定义 motion duration 导致两层
   * 动画结束时间不同，重复调用是安全的（setState 幂等）。
   */
  handleAnimationEnd(visible: boolean): void {
    if (!visible) this.setState({ displayNone: true });
  }
}
