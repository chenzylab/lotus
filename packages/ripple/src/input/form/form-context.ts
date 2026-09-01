import { Context, type Tracked } from 'ripple';
import type { FormFoundation, FormState, FormRule, FormMessages } from '@lotus/foundation/input/form';

export type LabelPosition = 'top' | 'left';
export type FormLayout = 'vertical' | 'horizontal';

/**
 * Form 下发给所有 Field 的共享上下文。`state` 是响应式的 FormState 快照
 * （values/errors/touched），Field 从中读取自己 field 名对应的值；`foundation`
 * 是同一个 FormFoundation 实例的直接引用，Field 调用其方法驱动状态变化
 * （单一实例、单一数据源，避免 Form/Field 各自持有一份状态造成不同步）。
 * `messages` 是从当前 LocaleContext 派生出的 Foundation 校验兜底文案，
 * Field 调用 `foundation.validateField(field, messages)` 时传入——放进
 * Context 而不是让 Field 各自读取 LocaleContext，是因为 Form 已经统一读了
 * 一次，避免重复解析。
 */
export interface FormContextValue {
  state: FormState;
  foundation: FormFoundation;
  disabled: boolean;
  labelPosition: LabelPosition;
  labelWidth?: string | number;
  messages: FormMessages;
  onValueChange?: (values: FormState['values'], changed: FormState['values']) => void;
}

export const FormContext = new Context<Tracked<FormContextValue>>();

export type { FormRule };
