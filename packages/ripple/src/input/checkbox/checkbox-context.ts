import { Context, type Tracked } from 'ripple';

/**
 * CheckboxGroup 下发给所有子 Checkbox 的共享状态。单独使用的 Checkbox 不消费
 * 这个 Context（`CheckboxContext.get()` 返回 undefined），此时 Checkbox 完全
 * 依赖自身的 checked/defaultChecked props；在 Group 内使用时，选中态改由
 * `value` 数组是否包含自身 `value` 决定，Checkbox 自身的 checked/defaultChecked
 * 被忽略（对齐 Semi："在 Group 中使用时无效"）。
 */
export interface CheckboxContextValue {
  value: Array<string | number>;
  disabled: boolean;
  onItemToggle: (itemValue: string | number) => void;
}

export const CheckboxContext = new Context<Tracked<CheckboxContextValue>>();
