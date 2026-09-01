import { track, untrack, effect } from 'ripple';
import { FormFoundation, type FormState, type FormValues, type FormErrors, type FormMessages } from '@lotus/foundation/input/form';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { FormContext, type LabelPosition, type FormLayout } from './form-context.js';

export type { FormRule, FormMessages } from '@lotus/foundation/input/form';
export type { FormValues, FormErrors } from '@lotus/foundation/input/form';
export { Field } from './field.tsrx';
export type { FieldProps, FieldRenderProps, FieldValidateStatus } from './field.tsrx';
export type { FormLayout } from './form-context.js';
export { Slot } from './slot.tsrx';
export type { SlotProps } from './slot.tsrx';
export { ArrayField } from './array-field.tsrx';
export type { ArrayFieldProps, ArrayFieldRenderProps } from './array-field.tsrx';

export interface FormApi {
  getValues: () => FormValues;
  getValue: (field: string) => unknown;
  setValue: (field: string, value: unknown) => void;
  setValues: (values: FormValues) => void;
  validate: (fields?: string[]) => Promise<FormErrors>;
  submitForm: () => Promise<void>;
  reset: () => void;
  /** Form 挂载时刻的完整初始值快照（对齐 Semi formApi.getInitValues）。 */
  getInitValues: () => FormValues;
  getInitValue: (field: string) => unknown;
  getFormState: () => FormState;
  getTouched: (field: string) => boolean;
  getError: (field: string) => string | undefined;
  getFieldExist: (field: string) => boolean;
  /** 滚动到指定字段（对齐 Semi formApi.scrollToField）。 */
  scrollToField: (field: string, options?: ScrollIntoViewOptions) => void;
  /** 滚动到第一个当前有错误的字段（对齐 Semi formApi.scrollToError）。 */
  scrollToError: (options?: ScrollIntoViewOptions) => void;
}

export interface FormProps {
  /** 表单初始值（仅在 Form 挂载时消费一次），例如 `{ username: 'semi' }`。
   * 各 Field 的 `initValue` 优先级高于此处对应字段的值。 */
  initValues?: FormValues;
  disabled?: boolean;
  /** 统一配置 Field 中 label 的位置，可选 'top'/'left'。 */
  labelPosition?: LabelPosition;
  labelWidth?: string | number;
  /** Form 整体布局方向（对齐 Semi layout），影响字段间距节奏；不同于
   * labelPosition（后者控制单个字段内部 label 与控件的排列）。 */
  layout?: FormLayout;
  /** 校验失败（onSubmitFail 触发）后是否自动滚动到第一个错误字段（对齐
   * Semi autoScrollToError）。 */
  autoScrollToError?: boolean;
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
    layout = 'vertical',
    autoScrollToError = false,
    getFormApi,
    onValueChange,
    onSubmit,
    onSubmitFail,
    onReset,
    children,
    style,
    class: className,
}: FormProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    let &[messages] = track<FormMessages>(() => locale.Form);

    let &[state] = track<FormState>({ values: { ...initValues }, errors: {}, touched: {}, validating: {} });

    const foundation = new FormFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<FormState>) => { state = { ...state, ...patch }; },
    });

    let rootNode: HTMLElement | null = null;

    function scrollToField(field: string, options?: ScrollIntoViewOptions) {
        const target = rootNode?.querySelector(`[data-field="${field}"]`);
        target?.scrollIntoView(options ?? { block: 'center', behavior: 'smooth' });
    }

    function scrollToError(options?: ScrollIntoViewOptions) {
        const errors = untrack(() => state).errors;
        const firstErrorField = Object.keys(errors).find((field) => errors[field]);
        if (firstErrorField) scrollToField(firstErrorField, options);
    }

    const formApi: FormApi = {
        getValues: () => untrack(() => state).values,
        getValue: (field: string) => foundation.getValue(field),
        setValue: (field: string, value: unknown) => foundation.setValue(field, value, onValueChange),
        setValues: (values: FormValues) => {
            Object.entries(values).forEach(([field, value]) => foundation.setValue(field, value, onValueChange));
        },
        validate: (fields?: string[]) => {
            const currentMessages = untrack(() => messages);
            if (!fields) return foundation.validateAll(currentMessages);
            return Promise.all(fields.map((field) => foundation.validateField(field, currentMessages))).then(() => {
                const errors: FormErrors = {};
                fields.forEach((field) => {
                    const error = untrack(() => state).errors[field];
                    if (error) errors[field] = error;
                });
                return errors;
            });
        },
        submitForm: () => foundation.submit(onSubmit, (errors, values) => {
            onSubmitFail?.(errors, values);
            if (autoScrollToError) scrollToError();
        }, untrack(() => messages)),
        reset: () => foundation.reset(onReset),
        getInitValues: () => foundation.getInitValues(),
        getInitValue: (field: string) => foundation.getInitValue(field),
        getFormState: () => foundation.getFormState(),
        getTouched: (field: string) => foundation.getTouched(field),
        getError: (field: string) => foundation.getError(field),
        getFieldExist: (field: string) => foundation.getFieldExist(field),
        scrollToField,
        scrollToError,
    };
    getFormApi?.(formApi);

    // locale 切换后，已经显示在页面上的校验错误信息要跟着重新翻译，不能等
    // 用户下次触发 blur/submit 才用上新文案（spec 明确要求"实时更新，不需要
    // 重新挂载组件"）。用 effect 监听 messages 的变化，对当前所有已经有
    // error 的字段重新跑一次校验——只有已存在错误的字段才需要重算，避免
    // 每次切换 locale 都对全部字段做一次不必要的重复校验。
    effect(() => {
        const currentMessages = messages;
        const fieldsWithError = Object.keys(untrack(() => state).errors).filter((field) => untrack(() => state).errors[field]);
        fieldsWithError.forEach((field) => {
            foundation.validateField(field, currentMessages);
        });
    });

    let &[, contextTracked] = track(() => ({
        state,
        foundation,
        disabled,
        labelPosition,
        labelWidth,
        messages,
        onValueChange,
    }));
    FormContext.set(contextTracked);

    const handleSubmit = (event: SubmitEvent) => {
        event.preventDefault();
        foundation.submit(onSubmit, (errors, values) => {
            onSubmitFail?.(errors, values);
            if (autoScrollToError) scrollToError();
        }, untrack(() => messages));
    };

    const handleReset = (event: Event) => {
        event.preventDefault();
        foundation.reset(onReset);
    };

    let &[classes] = track<string>(() =>
        ['lotus-form', `lotus-form-${layout}`, className ?? ''].filter(Boolean).join(' '),
    );

    <>
    <form
        class={classes}
        style={style}
        onSubmit={handleSubmit}
        onReset={handleReset}
        ref={(node: HTMLElement) => { rootNode = node; }}
    >
        {children}
    </form>

    <style>
        .lotus-form {
            display: flex;
            flex-direction: column;
            gap: var(--lotus-spacing-default);
        }

        .lotus-form-horizontal {
            gap: var(--lotus-spacing-tight);
        }
    </style>
    </>
}
