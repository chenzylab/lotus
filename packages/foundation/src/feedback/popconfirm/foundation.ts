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
 */
export class PopconfirmFoundation extends Foundation<PopconfirmState> {
  constructor(adapter: Adapter<PopconfirmState>) {
    super(adapter);
  }

  handleConfirm(onConfirm?: () => Promise<any> | void): void {
    const maybePromise = onConfirm?.();
    if (isPromise(maybePromise)) {
      this.setState({ confirmLoading: true });
      maybePromise.then(
        () => {
          this.setState({ confirmLoading: false });
          this.setState({ visible: false });
        },
        () => {
          this.setState({ confirmLoading: false });
        },
      );
    } else {
      this.setState({ visible: false });
    }
  }

  handleCancel(onCancel?: () => Promise<any> | void): void {
    const maybePromise = onCancel?.();
    if (isPromise(maybePromise)) {
      this.setState({ cancelLoading: true });
      maybePromise.then(
        () => {
          this.setState({ cancelLoading: false });
          this.setState({ visible: false });
        },
        () => {
          this.setState({ cancelLoading: false });
        },
      );
    } else {
      this.setState({ visible: false });
    }
  }
}
