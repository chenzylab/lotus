import { Foundation, type Adapter } from '../../base/adapter.js';

export type PromiseStatus = 'idle' | 'pending' | 'fulfilled' | 'rejected';

export interface ModalState {
  /** 是否真正隐藏/卸载 DOM——与 visible 分离，播放完关闭动画才置 true（对齐 Semi）。 */
  displayNone: boolean;
  onOkStatus: PromiseStatus;
  onCancelStatus: PromiseStatus;
}

export function initialModalState(visible: boolean): ModalState {
  return { displayNone: !visible, onOkStatus: 'idle', onCancelStatus: 'idle' };
}

export class ModalFoundation extends Foundation<ModalState> {
  constructor(adapter: Adapter<ModalState>) {
    super(adapter);
  }

  /** visible 变为 true 时同步显示 DOM（不需要等待，展开动画本身用 CSS 处理）。 */
  handleShow(): void {
    this.setState({ displayNone: false });
  }

  /** 关闭动画播放完毕后调用，真正隐藏/卸载 DOM。 */
  handleAnimationEnd(visible: boolean): void {
    if (!visible) this.setState({ displayNone: true });
  }

  /**
   * 调用 onOk/onCancel，若返回 Promise 则自动管理对应按钮的 loading 态
   * （pending → fulfilled/rejected），不吞异常。返回值供调用方在 rejected
   * 时也能感知（比如打印日志），但 Foundation 本身不做任何异常处理决策。
   */
  invokeOk(result: void | Promise<any>): void {
    if (!isPromiseLike(result)) return;
    this.setState({ onOkStatus: 'pending' });
    result.then(
      () => this.setState({ onOkStatus: 'fulfilled' }),
      (err) => { this.setState({ onOkStatus: 'rejected' }); throw err; },
    );
  }

  invokeCancel(result: void | Promise<any>): void {
    if (!isPromiseLike(result)) return;
    this.setState({ onCancelStatus: 'pending' });
    result.then(
      () => this.setState({ onCancelStatus: 'fulfilled' }),
      (err) => { this.setState({ onCancelStatus: 'rejected' }); throw err; },
    );
  }
}

function isPromiseLike(value: unknown): value is Promise<any> {
  return !!value && typeof (value as any).then === 'function';
}
