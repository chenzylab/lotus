import { Context, type Tracked } from 'ripple';

/**
 * RadioGroup 下发给所有子 Radio 的共享状态。单独使用的 Radio 不消费这个 Context
 * （`RadioContext.get()` 返回 undefined），此时 Radio 完全依赖自身的
 * checked/defaultChecked props；在 Group 内使用时，选中态改由 `value` 是否等于
 * 自身 `value` 决定，Radio 自身的 checked/defaultChecked 被忽略（对齐 Semi 语义）。
 */
export type RadioGroupType = 'default' | 'button' | 'card' | 'pureCard';
export type RadioGroupButtonSize = 'small' | 'middle' | 'large';

export interface RadioContextValue {
  value: string | number | undefined;
  disabled: boolean;
  name?: string;
  type: RadioGroupType;
  buttonSize: RadioGroupButtonSize;
  onItemSelect: (itemValue: string | number) => void;
}

export const RadioContext = new Context<Tracked<RadioContextValue>>();
