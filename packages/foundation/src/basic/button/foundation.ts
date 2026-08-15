import { Foundation, type Adapter } from '../../base/adapter.js';

export interface ButtonState {
  disabled: boolean;
  loading: boolean;
}

export class ButtonFoundation extends Foundation<ButtonState> {
  constructor(adapter: Adapter<ButtonState>) {
    super(adapter);
  }

  /**
   * 点击拦截逻辑：disabled 或 loading 时不触发外部回调。
   * 这是 Phase 0 的验证对象——必须能在不依赖任何渲染框架的前提下单测。
   */
  handleClick(onClick?: () => void): void {
    const { disabled, loading } = this.getState();
    if (disabled || loading) return;
    onClick?.();
  }
}
