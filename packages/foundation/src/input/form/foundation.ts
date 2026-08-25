import { Foundation, type Adapter } from '../../base/adapter.js';

export type FieldValue = unknown;

export interface FormValues {
  [field: string]: FieldValue;
}

export interface FormErrors {
  [field: string]: string | undefined;
}

export interface FormTouched {
  [field: string]: boolean | undefined;
}

export interface FormValidating {
  [field: string]: boolean | undefined;
}

export interface FormState {
  values: FormValues;
  errors: FormErrors;
  touched: FormTouched;
  /** 字段是否正在异步校验中（对齐 rules 里含 `validator` 的场景）。Semi 自身没有
   * 暴露这个状态给 UI 层——这是 lotus 主动新增的能力，让消费方能在异步校验期间
   * 给输入框展示 loading 态，同步规则（required/pattern/min/max）校验是瞬时完成的
   * 纯函数调用，不会产生用户能感知到的"进行中"时间窗口，因此不标记 validating。 */
  validating: FormValidating;
}

/** 单条校验规则，风格对齐 Semi 的 rules（async-validator 的极简子集，不引入外部依赖）。 */
export interface FormRule {
  required?: boolean;
  pattern?: RegExp;
  min?: number;
  max?: number;
  message?: string;
  validator?: (value: FieldValue, values: FormValues) => string | undefined | Promise<string | undefined>;
}

interface FieldConfig {
  rules?: FormRule[];
}

/**
 * 规则不满足、且没有传自定义 rule.message 时用到的兜底文案。Foundation 层
 * 不依赖任何渲染框架或 UI 包（含 @lotus/locale——那是面向 UI 层的横切包，
 * Foundation 只应该依赖自己声明的最小契约类型），文案由 Adapter（.tsrx）侧
 * 从 LocaleContext 读取后注入进来，Foundation 本身不关心文案从哪来、是否
 * 会随 locale 切换而变化。
 */
export interface FormMessages {
  requiredError: string;
  patternError: string;
  minError: (min: number) => string;
  maxError: (max: number) => string;
}

/** 未从 Adapter 侧注入 messages 时的默认值（中文，对齐项目历史行为）。 */
const DEFAULT_MESSAGES: FormMessages = {
  requiredError: '该字段不能为空',
  patternError: '格式不正确',
  minError: (min) => `不能小于 ${min}`,
  maxError: (max) => `不能大于 ${max}`,
};

/**
 * 校验单个字段的所有规则，按数组顺序执行，第一条不通过的规则决定错误信息。
 * 只有 validator 规则支持异步（返回 Promise），其余规则都是同步的纯函数校验。
 */
async function validateRules(value: FieldValue, values: FormValues, rules: FormRule[], messages: FormMessages): Promise<string | undefined> {
  for (const rule of rules) {
    if (rule.required && (value === undefined || value === null || value === '')) {
      return rule.message ?? messages.requiredError;
    }
    if (rule.pattern && typeof value === 'string' && !rule.pattern.test(value)) {
      return rule.message ?? messages.patternError;
    }
    if (rule.min !== undefined && typeof value === 'number' && value < rule.min) {
      return rule.message ?? messages.minError(rule.min);
    }
    if (rule.max !== undefined && typeof value === 'number' && value > rule.max) {
      return rule.message ?? messages.maxError(rule.max);
    }
    if (rule.validator) {
      const result = await rule.validator(value, values);
      if (result) {
        return result;
      }
    }
  }
  return undefined;
}

/**
 * Form 管理的是多字段的 values/errors/touched 三张 map，而非单一 value——
 * 与其余组件的 Foundation<单值 State> 模式不同，但仍复用同一个 Adapter<S>
 * 接口，只是 S 的形状换成了 FormState。
 *
 * 字段的 rules 由 Field 侧在 registerField 时登记（Foundation 不持有任何
 * DOM/框架引用，只持有普通对象），setValue/validateField 都通过 field 名
 * 从这份登记表里取回 rules 使用。
 */
export class FormFoundation extends Foundation<FormState> {
  private fields = new Map<string, FieldConfig>();
  // Form 挂载那一刻的 values 快照（含 Form.initValues 里所有字段，不局限于
  // 已注册 Field 声明了 initValue 的那部分）——reset 要恢复到这份完整快照，
  // 而不是只恢复"曾经通过 registerField 传了 initValue"的字段，否则没有单独
  // 声明 initValue、只吃 Form 级 initValues 的字段（例如本例中的 age/
  // businessLine）reset 时不会被清空。
  private readonly initValues: FormValues;

  constructor(adapter: Adapter<FormState>) {
    super(adapter);
    this.initValues = { ...this.getState().values };
  }

  registerField(field: string, config: FieldConfig, initValue?: FieldValue): void {
    this.fields.set(field, config);
    const { values } = this.getState();
    if (initValue !== undefined && values[field] === undefined) {
      this.initValues[field] = initValue;
      this.setState({ values: { ...values, [field]: initValue } });
    }
  }

  unregisterField(field: string): void {
    this.fields.delete(field);
  }

  setValue(field: string, value: FieldValue, onValueChange?: (values: FormValues, changed: FormValues) => void): void {
    const { values } = this.getState();
    const nextValues = { ...values, [field]: value };
    this.setState({ values: nextValues });
    onValueChange?.(nextValues, { [field]: value });
  }

  setTouched(field: string, isTouched: boolean): void {
    const { touched } = this.getState();
    this.setState({ touched: { ...touched, [field]: isTouched } });
  }

  async validateField(field: string, messages: FormMessages = DEFAULT_MESSAGES): Promise<string | undefined> {
    const config = this.fields.get(field);
    const rules = config?.rules;
    const hasAsyncValidator = rules?.some((rule) => rule.validator) ?? false;
    if (hasAsyncValidator) {
      const { validating } = this.getState();
      this.setState({ validating: { ...validating, [field]: true } });
    }
    const { values } = this.getState();
    const error = rules ? await validateRules(values[field], values, rules, messages) : undefined;
    // 并发校验多个字段时（validateAll 用 Promise.all），每个字段的规则校验都
    // 可能经过至少一次微任务让出（validateRules 对 validator 规则用了
    // await）。写回时必须重新读取当前最新的 errors/validating 再 merge，而不是
    // 复用函数开始时的旧快照——否则后完成的字段会用旧快照覆盖掉先完成字段刚写入的
    // error，最终只有最后一个完成的字段错误被保留（并发写竞态）。
    const { errors, validating } = this.getState();
    this.setState({
      errors: { ...errors, [field]: error },
      validating: hasAsyncValidator ? { ...validating, [field]: false } : validating,
    });
    return error;
  }

  async validateAll(messages: FormMessages = DEFAULT_MESSAGES): Promise<FormErrors> {
    const results = await Promise.all(
      Array.from(this.fields.keys()).map(async (field) => [field, await this.validateField(field, messages)] as const),
    );
    const errors: FormErrors = {};
    for (const [field, error] of results) {
      if (error) {
        errors[field] = error;
      }
    }
    return errors;
  }

  async submit(
    onSubmit?: (values: FormValues) => void,
    onSubmitFail?: (errors: FormErrors, values: FormValues) => void,
    messages: FormMessages = DEFAULT_MESSAGES,
  ): Promise<void> {
    const errors = await this.validateAll(messages);
    const { values } = this.getState();
    if (Object.keys(errors).length > 0) {
      onSubmitFail?.(errors, values);
      return;
    }
    onSubmit?.(values);
  }

  reset(onReset?: () => void): void {
    this.setState({ values: { ...this.initValues }, errors: {}, touched: {}, validating: {} });
    onReset?.();
  }
}

export type { Adapter };
