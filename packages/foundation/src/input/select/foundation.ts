import { Foundation, type Adapter } from '../../base/adapter.js';

export type SelectValue = string | number;

export interface SelectState {
  /** 单选存 SelectValue | undefined；多选存 SelectValue[]。 */
  value: SelectValue | SelectValue[] | undefined;
}

/**
 * Select 的受控/非受控值管理，单选/多选两种模式共用一个 Foundation：
 * - 单选：选中即替换整个 value，并关闭下拉（由 Adapter 侧调用 Popover 的
 *   hide，Foundation 本身不感知显隐，职责单一）。
 * - 多选：value 是数组，selectValue 处理增删（类似 CheckboxGroupFoundation.
 *   toggleValue），选中后不自动关闭下拉（对齐 Semi 多选交互）。
 *
 * 显隐状态完全交给内部包装的 Popover（TooltipFoundation）管理，这里不重复
 * 造轮子——这也是 Select 复用 Popover 浮层定位基础设施的核心体现。
 */
export class SelectFoundation extends Foundation<SelectState> {
  selectSingle(itemValue: SelectValue, isControlled: boolean, onChange?: (value: SelectValue) => void): void {
    if (!isControlled) {
      this.setState({ value: itemValue });
    }
    onChange?.(itemValue);
  }

  selectMultiple(itemValue: SelectValue, isControlled: boolean, onChange?: (value: SelectValue[]) => void): void {
    const { value } = this.getState();
    const current = Array.isArray(value) ? value : [];
    const exists = current.includes(itemValue);
    const next = exists ? current.filter((v) => v !== itemValue) : [...current, itemValue];

    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
  }

  removeMultipleValue(itemValue: SelectValue, isControlled: boolean, onChange?: (value: SelectValue[]) => void): void {
    const { value } = this.getState();
    const current = Array.isArray(value) ? value : [];
    const next = current.filter((v) => v !== itemValue);

    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
  }

  clear(multiple: boolean, isControlled: boolean, onChange?: (value: SelectValue | SelectValue[] | undefined) => void): void {
    const next = multiple ? [] : undefined;
    if (!isControlled) {
      this.setState({ value: next });
    }
    onChange?.(next);
  }

  static isSingleChecked(value: SelectValue | SelectValue[] | undefined, itemValue: SelectValue): boolean {
    return !Array.isArray(value) && value === itemValue;
  }

  static isMultipleChecked(value: SelectValue | SelectValue[] | undefined, itemValue: SelectValue): boolean {
    return Array.isArray(value) && value.includes(itemValue);
  }
}
