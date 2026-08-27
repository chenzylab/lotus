import { Foundation, type Adapter } from '../../base/adapter.js';

export interface PopconfirmState {
  visible: boolean;
  confirmLoading: boolean;
  cancelLoading: boolean;
}

function isPromise(value: unknown): value is Promise<any> {
  return !!value && typeof (value as any).then === 'function';
}

/**
 * Popconfirm 的确认/取消回调支持返回 Promise：Promise 未 resolve 前对应
 * 按钮进入 loading 态、浮层不关闭；resolve 后关闭浮层；reject 后仅退出
 * loading，浮层保持打开（对齐 Semi 的语义——异步校验失败时不应静默关闭）。
 * 同步回调（非 Promise）直接关闭浮层。
 *
 * 关闭动作不由 Foundation 自己 `setState({visible:false})`——这条路径曾经
 * 绕开组件层统一的 `setVisible()` 函数，导致 `onVisibleChange` 在确认/取消
 * 关闭这条路径上完全不会被调用（只有点击外部/Esc 走 Popover 自身转发才会
 * 通知外部）。改为 `onClose` 回调通知调用方"现在应该关闭"，由 `.tsrx` 渲染层
 * 统一走 `setVisible(false)`，这样非受控模式下写内部 state、受控模式下也能
 * 正确转发 `onVisibleChange` 给父组件，且不需要 Foundation 关心受控/非受控
 * 这个渲染层概念。
 */
export class PopconfirmFoundation extends Foundation<PopconfirmState> {
  constructor(adapter: Adapter<PopconfirmState>) {
    super(adapter);
  }

  handleConfirm(onConfirm: (() => Promise<any> | void) | undefined, onClose: () => void): void {
    const maybePromise = onConfirm?.();
    if (isPromise(maybePromise)) {
      this.setState({ confirmLoading: true });
      maybePromise.then(
        () => {
          this.setState({ confirmLoading: false });
          onClose();
        },
        () => {
          this.setState({ confirmLoading: false });
        },
      );
    } else {
      onClose();
    }
  }

  handleCancel(onCancel: (() => Promise<any> | void) | undefined, onClose: () => void): void {
    const maybePromise = onCancel?.();
    if (isPromise(maybePromise)) {
      this.setState({ cancelLoading: true });
      maybePromise.then(
        () => {
          this.setState({ cancelLoading: false });
          onClose();
        },
        () => {
          this.setState({ cancelLoading: false });
        },
      );
    } else {
      onClose();
    }
  }
}
