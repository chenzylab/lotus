import { track, effect } from 'ripple';
import type { FormRule } from '@lotus/foundation/input/form';
import { FormContext, type LabelPosition } from './form-context.js';

export type FieldValidateStatus = 'default' | 'warning' | 'error';

export interface FieldRenderProps {
    /** 与 Field 渲染的 `<label for={field}>` 对应，桥接函数需要把它透传给具体控件的
     * 原生 id（如 Input/TextArea/InputNumber 已支持的 `id` prop）才能建立真正的语义关联；
     * 若具体控件没有可设置 id 的原生元素（如浮层触发型组件），可以不使用这个值。 */
    id: string;
    value: any;
    disabled: boolean;
    /** 该字段的异步 validator 规则是否正在校验中（Semi 自身没有这个状态，
     * lotus 主动新增），桥接函数可选择性地用它给具体控件传 loading 态。
     * 只有 rules 里含 `validator` 时才会变 true，同步规则不会产生这个状态。 */
    validating: boolean;
    onChange: (value: any) => void;
    onBlur: () => void;
    'aria-label': string;
    'aria-labelledby'?: string;
    'aria-describedby'?: string;
    'aria-errormessage'?: string;
    'aria-invalid'?: boolean;
    'aria-required'?: boolean;
}

export interface FieldProps {
    /** 该字段在 formState.values 中的 key，必填。 */
    field: string;
    /** 不传时默认与 field 同名。 */
    label?: string;
    /** 仅在 Field 挂载时消费一次，优先级高于 Form 的 initValues 中对应字段的值。 */
    initValue?: any;
    rules?: FormRule[];
    /** 触发校验的时机，可组合传入，另支持 'mount'（挂载时立即校验一次）。
     * 默认 'blur'（对齐大多数表单的常见交互，change 时机会导致用户还没
     * 输完就报错，体验更差）。传 'custom' 或空数组表示完全不自动触发，
     * 只能通过 formApi.validate() 手动触发。 */
    trigger?: Array<'blur' | 'change' | 'mount' | 'custom'>;
    /** 字段卸载后是否保留其值/校验态（对齐 Semi keepState），默认 false。 */
    keepState?: boolean;
    /** 值写入 formState 前的转换函数（对齐 Semi convert）。 */
    convert?: (value: any) => any;
    /** 手动指定字段校验态，优先级高于 rules 校验产出的错误态（对齐 Semi
     * Field 级 validateStatus 覆盖）。 */
    validateStatus?: FieldValidateStatus;
    noLabel?: boolean;
    noErrorMessage?: boolean;
    helpText?: any;
    /** 字段说明文字，区别于 helpText（对齐 Semi extraText），可配合
     * extraTextPosition 摆在控件下方或 label 旁边。 */
    extraText?: any;
    extraTextPosition?: 'middle' | 'bottom';
    labelPosition?: LabelPosition;
    labelWidth?: string | number;
    /** 实际渲染的输入组件，以“组件作为显式 prop”的方式传入（Ripple 没有
     * render-prop/函数调用 children 的机制——组件只能作为 prop 传递并用
     * `<Comp {...} />` 渲染，不能当函数调用，见 components.md "Passing
     * Components as Props"）。该组件会收到 { value, disabled, onChange,
     * onBlur, 'aria-label' }，需要自行桥接到具体控件的 props 形状——lotus
     * 不做 Semi 的 withField HOC 那种 onChange 签名归一化（Input 是
     * (value, event)，Select 是 (value)，Checkbox 是 (checked)），调用方
     * 显式桥接，写法多一层但语义透明，是诚实的设计取舍。 */
    Comp: (props: FieldRenderProps) => any;
    class?: string;
    style?: Record<string, any>;
}

export function Field(&{
    field,
    label,
    initValue,
    rules,
    trigger = ['blur'],
    keepState = false,
    convert,
    validateStatus,
    noLabel = false,
    noErrorMessage = false,
    helpText,
    extraText,
    extraTextPosition = 'bottom',
    labelPosition,
    labelWidth,
    Comp,
    class: className,
    style,
}: FieldProps) @{
    const contextTracked = FormContext.get();
    const foundation = contextTracked?.value.foundation;

    foundation?.registerField(field, { rules, keepState, convert }, initValue);

    // unregisterField 推迟到微任务执行，不能在 effect 的 cleanup 回调里
    // 直接同步调用——真机验证 + 阅读 Ripple 运行时源码证实：只要一个组件
    // 树里存在任何 `effect(() => cleanup)`，Ripple 会给这条 block 链路
    // （沿父级一路向上）打上 CONTAINS_TEARDOWN 标记，使得链路上所有track
    // 变量的写入都会在 old_values 里额外记一份"变化前快照"；而 cleanup
    // 回调执行期间全局 teardown=true，此时对这些 track 变量的读取一律返回
    // old_values 里锁定的快照而非真实当前值（框架设计意图是让 cleanup 逻辑
    // 看到组件销毁前一刻的稳定状态，不被"未来"的批处理更新污染）。
    // ArrayField 场景下这与我们的需求正面冲突：remove(index) 调用
    // foundation.setValue 让 Form 的 state 提交了新值，紧接着触发被删除
    // 那一行 Field 的 cleanup、同步调用 unregisterField——它在 teardown
    // 上下文里执行，`this.getState()` 读到的却是 setValue 之前的旧
    // state，导致 unregisterField 内 `{...values}` 合并出的补丁把刚写入
    // 的新数组值整个覆盖回旧值（真机复现：delete 数组中间行后，其余行
    // 的值被冲掉变成空字符串）。推迟到微任务，让 unregisterField 在
    // teardown 上下文结束、state 真正提交之后再执行，就能读到最新值。
    effect(() => {
        return () => queueMicrotask(() => foundation?.unregisterField(field));
    });

    // trigger 含 'mount' 时挂载后立即校验一次（对齐 Semi trigger='mount'）；
    // 只应在挂载时跑一次，用 effect + 空依赖等价的方式——这里 trigger 是
    // props、不会变化，直接在组件体顶层同步调用即可，不需要包进 effect。
    if (trigger.includes('mount')) {
        foundation?.validateField(field, contextTracked?.value.messages);
    }

    let &[value] = track(() => (contextTracked?.value.state ? foundation?.getValue(field) : undefined));
    let &[ruleError] = track(() => contextTracked?.value.state.errors[field]);
    let &[validating] = track<boolean>(() => contextTracked?.value.state.validating[field] ?? false);
    let &[disabled] = track(() => contextTracked?.value.disabled ?? false);
    let &[resolvedLabelPosition] = track(() => labelPosition ?? contextTracked?.value.labelPosition ?? 'top');
    let &[resolvedLabelWidth] = track(() => labelWidth ?? contextTracked?.value.labelWidth);
    const resolvedLabel = label ?? field;
    const onValueChange = contextTracked?.value.onValueChange;

    // validateStatus 手动覆盖优先级最高：显式传 'error' 即使 rules 未产出
    // 错误也视为出错态（不影响 rules 校验本身是否运行），显式传其它值则
    // 完全屏蔽 rules 产出的错误展示（对齐 Semi withField 的 blockStatus 优先级）。
    let &[effectiveValidateStatus] = track<FieldValidateStatus>(() => validateStatus ?? (ruleError ? 'error' : 'default'));
    let &[displayError] = track<string | undefined>(() => (validateStatus !== undefined ? (validateStatus === 'error' ? (ruleError ?? '') : undefined) : ruleError));

    const errorId = `${field}-error`;
    const helpId = `${field}-help`;
    const extraId = `${field}-extra`;
    let &[describedByIds] = track<string | undefined>(() => {
        const ids: string[] = [];
        if (extraText) ids.push(extraId);
        if (!noErrorMessage && !displayError && helpText) ids.push(helpId);
        return ids.length > 0 ? ids.join(' ') : undefined;
    });
    let &[errorMessageId] = track<string | undefined>(() => (!noErrorMessage && displayError ? errorId : undefined));

    const handleChange = (nextValue: any) => {
        foundation?.setValue(field, nextValue, onValueChange);
        if (trigger.includes('change')) {
            foundation?.validateField(field, contextTracked?.value.messages);
        }
    };

    const handleBlur = () => {
        foundation?.setTouched(field, true);
        if (trigger.includes('blur')) {
            foundation?.validateField(field, contextTracked?.value.messages);
        }
    };

    let &[classes] = track(() =>
        [
            'lotus-form-field',
            `lotus-form-field-label-${resolvedLabelPosition}`,
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[labelStyle] = track(() => (resolvedLabelWidth !== undefined ? { width: typeof resolvedLabelWidth === 'number' ? `${resolvedLabelWidth}px` : resolvedLabelWidth } : undefined));

    <>
    <div class={classes} style={style} data-field={field}>
        @if (!noLabel) {
            <label id={`${field}-label`} class="lotus-form-field-label" style={labelStyle} for={field}>{resolvedLabel}</label>
        }
        <div class="lotus-form-field-control">
            <Comp
                id={field}
                value={value}
                disabled={disabled}
                validating={validating}
                onChange={handleChange}
                onBlur={handleBlur}
                aria-label={resolvedLabel}
                aria-labelledby={!noLabel ? `${field}-label` : undefined}
                aria-describedby={describedByIds}
                aria-errormessage={errorMessageId}
                aria-invalid={effectiveValidateStatus === 'error'}
                aria-required={rules?.some((rule) => rule.required)}
            />
            @if (extraText && extraTextPosition === 'middle') {
                <div id={extraId} class="lotus-form-field-extra">{extraText}</div>
            }
            @if (!noErrorMessage) {
                @if (displayError) {
                    <div id={errorId} class="lotus-form-field-error" role="alert">{displayError}</div>
                } @else if (helpText) {
                    <div id={helpId} class="lotus-form-field-help">{helpText}</div>
                }
            }
            @if (extraText && extraTextPosition === 'bottom') {
                <div id={extraId} class="lotus-form-field-extra">{extraText}</div>
            }
        </div>
    </div>

    <style>
        .lotus-form-field {
            display: flex;
            gap: var(--lotus-spacing-tight);
        }

        .lotus-form-field-label-top {
            flex-direction: column;
            align-items: flex-start;
        }

        .lotus-form-field-label-left {
            flex-direction: row;
            align-items: flex-start;
        }

        .lotus-form-field-label {
            flex-shrink: 0;
            color: var(--lotus-color-text-1);
            font-size: var(--lotus-font-label-size);
        }

        .lotus-form-field-label-left .lotus-form-field-label {
            padding-top: 6px;
        }

        .lotus-form-field-control {
            display: flex;
            flex-direction: column;
            gap: 4px;
            flex: 1;
            min-width: 0;
        }

        .lotus-form-field-error {
            color: var(--lotus-color-danger);
            font-size: var(--lotus-font-label-size);
        }

        .lotus-form-field-help {
            color: var(--lotus-color-text-2);
            font-size: var(--lotus-font-label-size);
        }

        .lotus-form-field-extra {
            color: var(--lotus-color-text-2);
            font-size: var(--lotus-font-label-size);
        }
    </style>
    </>
}
