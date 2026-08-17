import { track, effect } from 'ripple';
import type { FormRule } from '@lotus/foundation/input/form';
import { FormContext, type LabelPosition } from './form-context.js';

export interface FieldRenderProps {
    value: any;
    disabled: boolean;
    onChange: (value: any) => void;
    onBlur: () => void;
    'aria-label': string;
}

export interface FieldProps {
    /** 该字段在 formState.values 中的 key，必填。 */
    field: string;
    /** 不传时默认与 field 同名。 */
    label?: string;
    /** 仅在 Field 挂载时消费一次，优先级高于 Form 的 initValues 中对应字段的值。 */
    initValue?: any;
    rules?: FormRule[];
    /** 触发校验的时机，可组合传入。默认 'blur'（对齐大多数表单的常见交互，
     * change 时机会导致用户还没输完就报错，体验更差）。 */
    trigger?: Array<'blur' | 'change'>;
    noLabel?: boolean;
    noErrorMessage?: boolean;
    helpText?: any;
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
    noLabel = false,
    noErrorMessage = false,
    helpText,
    labelPosition,
    labelWidth,
    Comp,
    class: className,
    style,
}: FieldProps) @{
    const contextTracked = FormContext.get();
    const foundation = contextTracked?.value.foundation;

    foundation?.registerField(field, { rules }, initValue);

    effect(() => {
        return () => foundation?.unregisterField(field);
    });

    let &[value] = track(() => contextTracked?.value.state.values[field]);
    let &[error] = track(() => contextTracked?.value.state.errors[field]);
    let &[disabled] = track(() => contextTracked?.value.disabled ?? false);
    let &[resolvedLabelPosition] = track(() => labelPosition ?? contextTracked?.value.labelPosition ?? 'top');
    let &[resolvedLabelWidth] = track(() => labelWidth ?? contextTracked?.value.labelWidth);
    const resolvedLabel = label ?? field;
    const onValueChange = contextTracked?.value.onValueChange;

    const handleChange = (nextValue: any) => {
        foundation?.setValue(field, nextValue, onValueChange);
        if (trigger.includes('change')) {
            foundation?.validateField(field);
        }
    };

    const handleBlur = () => {
        foundation?.setTouched(field, true);
        if (trigger.includes('blur')) {
            foundation?.validateField(field);
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
    <div class={classes} style={style}>
        @if (!noLabel) {
            <label class="lotus-form-field-label" style={labelStyle} for={field}>{resolvedLabel}</label>
        }
        <div class="lotus-form-field-control">
            <Comp
                value={value}
                disabled={disabled}
                onChange={handleChange}
                onBlur={handleBlur}
                aria-label={resolvedLabel}
            />
            @if (!noErrorMessage) {
                @if (error) {
                    <div class="lotus-form-field-error" role="alert">{error}</div>
                } @else if (helpText) {
                    <div class="lotus-form-field-help">{helpText}</div>
                }
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
    </style>
    </>
}
