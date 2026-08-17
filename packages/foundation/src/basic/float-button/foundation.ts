import { Foundation, type Adapter } from '../../base/adapter.js';

export interface FloatButtonState {
  disabled: boolean;
}

export class FloatButtonFoundation extends Foundation<FloatButtonState> {
  constructor(adapter: Adapter<FloatButtonState>) {
    super(adapter);
  }

  /**
   * 点击拦截逻辑：disabled 时不触发外部回调、不跳转。
   * `href` 跳转的具体执行（`window.open`/`window.location.href`）依赖 DOM 全局对象，
   * 留给 Adapter 层处理——Foundation 只负责判断"是否应该继续走点击流程"这一步，
   * 保持框架无关、可脱离 DOM 单测。
   */
  handleClick(onClick?: () => void): void {
    const { disabled } = this.getState();
    if (disabled) return;
    onClick?.();
  }
}
