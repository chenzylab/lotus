import { Foundation, type Adapter } from '../../base/adapter.js';

export interface RadioState {
  checked: boolean;
  disabled: boolean;
}

/**
 * Radio 的受控/非受控状态机，与 CheckboxFoundation 同构，但没有 indeterminate 概念。
 * `mode: 'advanced'` 允许 checked 时点击变回 unchecked（Semi 语义），默认模式下已选中
 * 的 Radio 再次点击不产生变化（原生 radio 语义——同组内必须始终有且只有一个选中）。
 *
 * 单独使用时 isControlled 由 `props.checked !== undefined` 判定；在 RadioGroup 内
 * 使用时，选中态由外部（RadioGroupFoundation）通过 value 是否等于自身 value 计算得出，
 * Radio 自身完全不持有状态，这种场景下 Adapter 会始终把 isControlled 传 true。
 */
export class RadioFoundation extends Foundation<RadioState> {
  handleToggle(isControlled: boolean, advanced: boolean, onChange?: (checked: boolean) => void): void {
    const { checked, disabled } = this.getState();
    if (disabled) return;
    if (checked && !advanced) return;

    const next = advanced ? !checked : true;
    if (!isControlled) {
      this.setState({ checked: next });
    }
    onChange?.(next);
  }
}

export interface RadioGroupState {
  value: string | number | undefined;
}

/**
 * RadioGroup 的受控/非受控当前选中值管理：value 是单个选中项的 value（不是集合），
 * selectValue 处理某个 Radio 被点击后组内值的切换。
 */
export class RadioGroupFoundation extends Foundation<RadioGroupState> {
  selectValue(itemValue: string | number, isControlled: boolean, onChange?: (value: string | number) => void): void {
    if (!isControlled) {
      this.setState({ value: itemValue });
    }
    onChange?.(itemValue);
  }

  static isChecked(value: string | number | undefined, itemValue: string | number | undefined): boolean {
    if (itemValue === undefined || value === undefined) return false;
    return value === itemValue;
  }
}
