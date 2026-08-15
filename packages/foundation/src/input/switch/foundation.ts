import { Foundation, type Adapter } from '../../base/adapter.js';

export interface SwitchState {
  checked: boolean;
  disabled: boolean;
  loading: boolean;
}

/**
 * Switch 的受控/非受控状态机。设计参考 Semi SwitchFoundation 的判定思路
 * （`typeof propChecked !== 'undefined'` 判断是否受控），重新实现，不搬运代码。
 */
export class SwitchFoundation extends Foundation<SwitchState> {
  /**
   * 处理点击/切换：disabled 或 loading 时直接拦截。受控模式下只上报变化（由外部
   * 通过 props.checked 决定下一次渲染的实际值）；非受控模式下由 Foundation 自己
   * 更新内部状态。isControlled 由 Adapter 侧根据 `props.checked !== undefined` 传入，
   * Foundation 本身不感知 props，只依赖 Adapter 传入的判定结果，保持框架无关。
   */
  handleToggle(isControlled: boolean, onChange?: (checked: boolean) => void): void {
    const { checked, disabled, loading } = this.getState();
    if (disabled || loading) return;

    const next = !checked;
    if (!isControlled) {
      this.setState({ checked: next });
    }
    onChange?.(next);
  }
}
