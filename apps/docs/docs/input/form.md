---
title: Form 表单
category: 输入类
---

表单容器，接管字段的值/校验/错误信息展示。

## 代码演示

### 如何引入

```tsrx
import { Form, Field } from '@lotus/ripple';
```

### 基本用法

`Form` 通过 Context 下发数据流，`Field` 接管字段的 value/error/touched。Ripple 没有 React 那种 render-prop 机制，`Field` 的 `Comp` 以"组件作为显式 prop"传入，需要自行桥接到具体输入组件的 props 形状（如 Input 的 `onChange(value, event)`）。

```tsrx demo
../../src/demos/input/form/basic.tsrx
```

### 校验规则

`rules` 支持 `required`/`pattern`/`min`/`max`/自定义 `validator`（同步或异步），默认在 `blur` 时触发校验，可通过 `trigger` 调整时机。

```tsrx demo
../../src/demos/input/form/rules.tsrx
```

### formApi

通过 `getFormApi` 拿到 `formApi` 引用，可在 Form 外部调用 `setValue`/`getValue`/`validate`/`submitForm`/`reset`。

```tsrx demo
../../src/demos/input/form/form-api.tsrx
```

## API 参考

### Form

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | - |
| disabled | 统一禁用所有 Field | boolean | false |
| getFormApi | 挂载时回调，传入 formApi 引用 | `(formApi: FormApi) => void` | - |
| initValues | 表单初始值，仅挂载时消费一次 | `FormValues` | {} |
| labelPosition | 统一配置 Field 中 label 的位置，可选 top、left | string | "top" |
| labelWidth | 统一配置 label 宽度 | string \| number | - |
| style | 内联样式 | object | - |
| onReset | 重置时的回调 | `() => void` | - |
| onSubmit | 校验全部通过后的提交回调 | `(values: FormValues) => void` | - |
| onSubmitFail | 校验未通过时的回调 | `(errors: FormErrors, values: FormValues) => void` | - |
| onValueChange | 任意字段值变化时的回调 | `(values: FormValues, changed: FormValues) => void` | - |

### Field

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| Comp | 实际渲染的输入组件，接收 `{ value, disabled, onChange, onBlur, 'aria-label' }` | `(props: FieldRenderProps) => any` | 必填 |
| class | 类名 | string | - |
| field | 字段名，对应 `formState.values` 中的 key | string | 必填 |
| helpText | 无错误信息时展示的提示内容 | any | - |
| initValue | 字段初始值，仅挂载时消费一次，优先级高于 Form 的 initValues | any | - |
| label | label 文案，不传时默认与 field 同名 | string | - |
| labelPosition | 覆盖 Form 级配置 | string | - |
| labelWidth | 覆盖 Form 级配置 | string \| number | - |
| noErrorMessage | 不自动展示错误信息 | boolean | false |
| noLabel | 不展示 label | boolean | false |
| rules | 校验规则数组 | `FormRule[]` | - |
| style | 内联样式 | object | - |
| trigger | 触发校验的时机，可组合 blur、change | `Array<'blur' \| 'change'>` | ['blur'] |

`FormRule` 结构：`{ required?: boolean; pattern?: RegExp; min?: number; max?: number; message?: string; validator?: (value, values) => string | undefined | Promise<string | undefined> }`。

### FormApi

| 方法 | 说明 |
| --- | --- |
| getValue(field) | 获取单个字段的值 |
| getValues() | 获取所有字段的值 |
| reset() | 重置表单到挂载时的初始快照 |
| setValue(field, value) | 设置单个字段的值 |
| setValues(values) | 批量设置字段值 |
| submitForm() | 手动触发提交（含全量校验） |
| validate(fields?) | 手动触发校验，不传参数时校验全部字段 |

> 注意事项：lotus 不做 Semi 的 `withField` HOC 那种 `Form.Input`/`Form.Select` 挂载写法（Ripple 无 children 反射能力，无法运行时挂载子组件），改用 `Field` + `Comp` 显式桥接。尚未实现 `ArrayField`（动态表单数组）、表单联动、`Form.Slot`/`Form.Section`/`Form.InputGroup` 布局组件、异步远程校验去重、静默校验。

## Accessibility

### ARIA

- Field 的错误信息容器携带 `role="alert"`，屏幕阅读器会在错误出现时自动播报。
- label 与输入控件通过 `aria-label` 关联（Field 会把 `label` 文案透传给 `Comp` 的 `aria-label`）。

## 设计变量

- `--lotus-spacing-default` / `--lotus-spacing-tight`（Field 间距）
- `--lotus-color-danger`（错误信息文字色）
- `--lotus-color-text-1` / `--lotus-color-text-2`（label/提示文字色）
