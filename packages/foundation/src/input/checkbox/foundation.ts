import { Foundation, type Adapter } from '../../base/adapter.js';

export interface CheckboxState {
  checked: boolean;
  disabled: boolean;
}

/**
 * Checkbox 的受控/非受控状态机，与 SwitchFoundation 同构：受控模式下只上报
 * 变化（由外部通过 props.checked 或 CheckboxGroup 的 value 决定下一次渲染的
 * 实际值），非受控模式下由 Foundation 自己更新内部状态。
 *
 * 单独使用时 isControlled 由 `props.checked !== undefined` 判定；在
 * CheckboxGroup 内使用时，选中态由外部（CheckboxGroupFoundation）通过
 * value 数组是否包含自身 value 计算得出，Checkbox 自身完全不持有状态，
 * 这种场景下 Adapter 会始终把 isControlled 传 true，Foundation 只负责拦截
 * disabled 并转发 onChange，不做任何 setState。
 */
export class CheckboxFoundation extends Foundation<CheckboxState> {
  handleToggle(isControlled: boolean, onChange?: (checked: boolean) => void): void {
    const { checked, disabled } = this.getState();
    if (disabled) return;

    const next = !checked;
    if (!isControlled) {
      this.setState({ checked: next });
    }
    onChange?.(next);
  }
}

export interface CheckboxGroupState {
  value: Array<string | number>;
}

/**
 * CheckboxGroup 的受控/非受控值集合管理：value 是选中项 value 的数组，
 * toggleValue 处理某个 Checkbox 被点击后集合的增删。
 */
export class CheckboxGroupFoundation extends Foundation<CheckboxGroupState> {
  toggleValue(
    itemValue: string | number,
    isControlled: boolean,
    onChange?: (value: Array<string | number>) => void,
  ): void {
    const { value } = this.getState();
    const exists = value.includes(itemValue);
    const next = exists ? value.filter((v) => v !== itemValue) : [...value, itemValue];

    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
  }

  static isChecked(value: Array<string | number>, itemValue: string | number | undefined): boolean {
    if (itemValue === undefined) return false;
    return value.includes(itemValue);
  }
}
