import { track, untrack } from 'ripple';
import { FormFoundation, type FormState, type FormValues, type FormErrors } from '@lotus/foundation/input/form';
import { FormContext, type LabelPosition } from './form-context.js';

export type { FormRule } from '@lotus/foundation/input/form';
export type { FormValues, FormErrors } from '@lotus/foundation/input/form';
export { Field } from './field.tsrx';
export type { FieldProps, FieldRenderProps } from './field.tsrx';

export interface FormApi {
  getValues: () => FormValues;
  getValue: (field: string) => unknown;
  setValue: (field: string, value: unknown) => void;
  setValues: (values: FormValues) => void;
  validate: (fields?: string[]) => Promise<FormErrors>;
  submitForm: () => Promise<void>;
  reset: () => void;
}

export interface FormProps {
  /** 表单初始值（仅在 Form 挂载时消费一次），例如 `{ username: 'semi' }`。
   * 各 Field 的 `initValue` 优先级高于此处对应字段的值。 */
  initValues?: FormValues;
  disabled?: boolean;
  /** 统一配置 Field 中 label 的位置，可选 'top'/'left'。 */
  labelPosition?: LabelPosition;
  labelWidth?: string | number;
  /** Form 挂载时回调，将 formApi 作为参数传入，可用于在外部保存引用以便后续调用
   * `formApi.setValue`/`formApi.validate`/`formApi.reset` 等（对齐 Semi 的
   * `getFormApi`；Ripple 没有 `Form.useForm()` 这类脱离组件树创建实例的机制，
   * 只能在挂载后通过回调拿到，这是诚实的设计取舍）。 */
  getFormApi?: (formApi: FormApi) => void;
  onValueChange?: (values: FormValues, changed: FormValues) => void;
  onSubmit?: (values: FormValues) => void;
  onSubmitFail?: (errors: FormErrors, values: FormValues) => void;
  onReset?: () => void;
  children?: any;
  style?: Record<string, any>;
  class?: string;
}

export function Form(&{
    initValues = {},
    disabled = false,
    labelPosition = 'top',
    labelWidth,
    getFormApi,
    onValueChange,
    onSubmit,
    onSubmitFail,
    onReset,
    children,
    style,
    class: className,
}: FormProps) @{
    let &[state] = track<FormState>({ values: { ...initValues }, errors: {}, touched: {} });

    const foundation = new FormFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<FormState>) => { state = { ...state, ...patch }; },
    });

    const formApi: FormApi = {
        getValues: () => untrack(() => state).values,
        getValue: (field: string) => untrack(() => state).values[field],
        setValue: (field: string, value: unknown) => foundation.setValue(field, value, onValueChange),
        setValues: (values: FormValues) => {
            Object.entries(values).forEach(([field, value]) => foundation.setValue(field, value, onValueChange));
        },
        validate: (fields?: string[]) => {
            if (!fields) return foundation.validateAll();
            return Promise.all(fields.map((field) => foundation.validateField(field))).then(() => {
                const errors: FormErrors = {};
                fields.forEach((field) => {
                    const error = untrack(() => state).errors[field];
                    if (error) errors[field] = error;
                });
                return errors;
            });
        },
        submitForm: () => foundation.submit(onSubmit, onSubmitFail),
        reset: () => foundation.reset(onReset),
    };
    getFormApi?.(formApi);

    let &[, contextTracked] = track(() => ({
        state,
        foundation,
        disabled,
        labelPosition,
        labelWidth,
        onValueChange,
    }));
    FormContext.set(contextTracked);

    const handleSubmit = (event: SubmitEvent) => {
        event.preventDefault();
        foundation.submit(onSubmit, onSubmitFail);
    };

    const handleReset = (event: Event) => {
        event.preventDefault();
        foundation.reset(onReset);
    };

    <>
    <form
        class={['lotus-form', className ?? ''].filter(Boolean).join(' ')}
        style={style}
        onSubmit={handleSubmit}
        onReset={handleReset}
    >
        {children}
    </form>

    <style>
        .lotus-form {
            display: flex;
            flex-direction: column;
            gap: var(--lotus-spacing-default);
        }
    </style>
    </>
}
