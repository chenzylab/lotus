import { Foundation, type Adapter } from '../../base/adapter.js';

export type FieldValue = unknown;

export interface FormValues {
  [field: string]: FieldValue;
}

/** 把 `a.b[0].c` 形式的路径字符串拆成 `['a', 'b', 0, 'c']` 段（数字段转为
 * number，用于数组索引），对齐 Semi/lodash 的路径记法——供 ArrayField 场景
 * 的字段名（如 `contacts[0]`）读写嵌套在 values 里的数组/对象值。纯路径
 * 解析，不引入 lodash 作为运行时依赖（对齐项目"基础能力自研"约定，参照
 * lodash get/set 的路径语义自行实现，只覆盖 Form 场景实际用到的
 * `.`/`[index]` 两种记法，不做完整的 lodash path 语法兼容）。 */
function toPathSegments(path: string): Array<string | number> {
  const segments: Array<string | number> = [];
  const regex = /[^.[\]]+/g;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(path)) !== null) {
    const token = match[0];
    segments.push(/^\d+$/.test(token) ? Number(token) : token);
  }
  return segments;
}

/** 路径不存在时返回 undefined，不抛错（对齐 lodash get 的容错行为）。 */
function getByPath(obj: FormValues, path: string): FieldValue {
  const segments = toPathSegments(path);
  let current: any = obj;
  for (const segment of segments) {
    if (current == null) return undefined;
    current = current[segment];
  }
  return current;
}

/** 沿路径逐层浅拷贝容器（对象/数组）后设置目标值，不改变原始 obj 引用
 * （Ripple 的响应式依赖收集要求新旧引用不同才会触发重算，同 Form 现有
 * setValue 对顶层 values 的浅拷贝写法一致，这里把浅拷贝延伸到路径经过的
 * 每一层容器）。中间层不存在时按下一段是否为数字新建数组/对象。 */
function setByPath(obj: FormValues, path: string, value: FieldValue): FormValues {
  const segments = toPathSegments(path);
  if (segments.length === 0) return obj;
  function recur(current: any, index: number): any {
    const segment = segments[index]!;
    const isLast = index === segments.length - 1;
    const container: any = Array.isArray(current) ? current.slice() : { ...(current ?? {}) };
    if (isLast) {
      container[segment] = value;
      return container;
    }
    const nextSegmentIsIndex = typeof segments[index + 1] === 'number';
    const existingChild = container[segment];
    const child = existingChild != null ? existingChild : (nextSegmentIsIndex ? [] : {});
    container[segment] = recur(child, index + 1);
    return container;
  }
  return recur(obj, 0) as FormValues;
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
  /** 字段卸载后是否保留其值/校验态（对齐 Semi keepState），默认 false——
   * 卸载即从 values/errors/touched/validating 里清除，同 Semi 默认行为。 */
  keepState?: boolean;
  /** 值写入 formState 前的转换函数（对齐 Semi convert），如字符串转大写。
   * 只影响写入 formState 的值，不影响传给具体输入控件展示的原始输入。 */
  convert?: (value: FieldValue) => FieldValue;
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
  // 不再是 readonly——ArrayField 场景下 registerField 用 setByPath 沿路径
  // 重新生成整个 initValues 对象（setByPath 不做原地修改），不是简单的
  // 顶层 key 赋值，因此需要能重新绑定这个引用本身。
  private initValues: FormValues;

  constructor(adapter: Adapter<FormState>) {
    super(adapter);
    this.initValues = { ...this.getState().values };
  }

  registerField(field: string, config: FieldConfig, initValue?: FieldValue): void {
    this.fields.set(field, config);
    const { values } = this.getState();
    if (initValue !== undefined && getByPath(values, field) === undefined) {
      this.initValues = setByPath(this.initValues, field, initValue);
      this.setState({ values: setByPath(values, field, initValue) });
    }
  }

  /** 卸载时按 keepState 决定是否清除该字段的 values/errors/touched（对齐 Semi
   * unRegister：默认卸载即清除，keepState=true 时保留供重新挂载复用）。
   * values 走路径写 undefined（field 可能是 `contacts[0]` 这种 ArrayField
   * 行内路径，指向数组元素/嵌套对象字段，不能直接 delete 顶层 key）；
   * errors/touched 仍按完整路径字符串本身当扁平 key（这两个 map 不需要真的
   * 是嵌套结构，只要求同一个 field 名读写一致）。不动 validating——这是
   * lotus 独有于 Semi 的新增状态，其生命周期完全由 validateField 自己管理
   * （写回前检查 this.fields.has(field) 已经保证卸载后过期的异步结果不会
   * 误写，不需要在这里额外清理，也不应该清理：清理会影响"卸载时刻
   * validating 状态原样保留"这一行为，与卸载后是否触发新校验是两回事）。
   *
   * ArrayField 行内路径字段（`xxx[数字]` 形如 `contacts[1]`）默认也不清
   * values——真机验证发现的真实 bug：ArrayField.remove(index) 删除非尾部
   * 行时，Ripple 按 key 复用后续行的 Field 组件实例，该实例的 field prop
   * 从 `contacts[2]` 变为 `contacts[1]`，同时刚好有另一个 `contacts[1]`
   * 旧实例（原本渲染"被删除那一行的下一行"之前的内容）触发卸载——两者
   * 操作的是同一个路径字符串，卸载清值会把复用实例刚写入的新值冲掉。
   * ArrayField 的行内字段名本身只是"当前位置"而非稳定标识，数组内容的
   * 增删已经由 ArrayField 通过 setValue 整体维护，行内 Field 卸载不代表
   * 这个位置的数据真的要被删除，语义上等价于 Semi `inArrayField` 时忽略
   * keepState 语义的反面：直接豁免清值，而不需要 Field 显式声明
   * keepState（ArrayField 调用方不需要为行内 Field 手动加 keepState）。 */
  unregisterField(field: string): void {
    const config = this.fields.get(field);
    this.fields.delete(field);
    if (config?.keepState) return;
    const isArrayFieldRowPath = /\[\d+\]/.test(field);
    const { values, errors, touched } = this.getState();
    const nextErrors = { ...errors };
    const nextTouched = { ...touched };
    delete nextErrors[field];
    delete nextTouched[field];
    if (isArrayFieldRowPath) {
      this.setState({ errors: nextErrors, touched: nextTouched });
      return;
    }
    this.setState({ values: setByPath(values, field, undefined), errors: nextErrors, touched: nextTouched });
  }

  setValue(field: string, value: FieldValue, onValueChange?: (values: FormValues, changed: FormValues) => void): void {
    const config = this.fields.get(field);
    const converted = config?.convert ? config.convert(value) : value;
    const { values } = this.getState();
    const nextValues = setByPath(values, field, converted);
    this.setState({ values: nextValues });
    onValueChange?.(nextValues, { [field]: converted });
  }

  /** 按路径读取字段当前值（对齐 Semi formApi.getValue，支持 ArrayField 场景
   * 的 `contacts[0]` 路径记法）。Adapter 层（Field/ArrayField/formApi）应
   * 统一通过这个方法读值，不直接访问 state.values[field]。 */
  getValue(field: string): FieldValue {
    return getByPath(this.getState().values, field);
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
    const error = rules ? await validateRules(getByPath(values, field), values, rules, messages) : undefined;
    // 字段在异步校验（validator 规则的 await）挂起期间可能已经卸载
    // （Field 组件的清理 effect 调用 unregisterField 从 this.fields 里删除）。
    // 若不判断直接写回，一个过期的 Promise 会在字段早已不存在时把 error/
    // validating 写进共享的 errors/validating map；若同一个 field 名后续被
    // 重新挂载复用（表单向导切换步骤、动态字段数组复用 key），新挂载的字段
    // 会在用户尚未产生任何交互前就"继承"这个过期的校验结果。
    if (!this.fields.has(field)) return error;
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

  /** Form 挂载时刻的完整初始值快照（含所有字段，不局限于已注册字段），
   * reset() 恢复的正是这份快照（对齐 Semi formApi.getInitValues）。 */
  getInitValues(): FormValues {
    return { ...this.initValues };
  }

  getInitValue(field: string): FieldValue {
    return getByPath(this.initValues, field);
  }

  getFormState(): FormState {
    return this.getState();
  }

  getTouched(field: string): boolean {
    return this.getState().touched[field] ?? false;
  }

  getError(field: string): string | undefined {
    return this.getState().errors[field];
  }

  /** 字段是否已通过 registerField 注册（对齐 Semi formApi.getFieldExist），
   * 用于动态字段数组等场景判断某个 field key 当前是否真实挂载。 */
  getFieldExist(field: string): boolean {
    return this.fields.has(field);
  }
}

export type { Adapter };
