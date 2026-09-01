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

### ArrayField

动态增删的字段数组，常见于"批量添加联系人"一类场景。`Comp` 收到 `{ arrayFields, add, addWithInitValue }`，`arrayFields` 每一项带 `key`/`field`/`remove`，行内字段名形如 `contacts[0]`，可直接传给 `Field` 的 `field`。

```tsrx demo
../../src/demos/input/form/array-field.tsrx
```

## API 参考

### Form

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| autoScrollToError | 校验失败（onSubmitFail 触发）后自动滚动到第一个错误字段 | boolean | false |
| class | 类名 | string | - |
| disabled | 统一禁用所有 Field | boolean | false |
| getFormApi | 挂载时回调，传入 formApi 引用 | `(formApi: FormApi) => void` | - |
| initValues | 表单初始值，仅挂载时消费一次 | `FormValues` | {} |
| labelPosition | 统一配置 Field 中 label 的位置，可选 top、left | string | "top" |
| labelWidth | 统一配置 label 宽度 | string \| number | - |
| layout | 表单整体布局方向，可选 vertical、horizontal（影响字段间距节奏，区别于控制单个字段内部排列的 labelPosition） | string | "vertical" |
| style | 内联样式 | object | - |
| onReset | 重置时的回调 | `() => void` | - |
| onSubmit | 校验全部通过后的提交回调 | `(values: FormValues) => void` | - |
| onSubmitFail | 校验未通过时的回调 | `(errors: FormErrors, values: FormValues) => void` | - |
| onValueChange | 任意字段值变化时的回调 | `(values: FormValues, changed: FormValues) => void` | - |

### Field

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| Comp | 实际渲染的输入组件，接收 `{ id, value, disabled, validating, onChange, onBlur, 'aria-label', 'aria-labelledby', 'aria-describedby', 'aria-errormessage', 'aria-invalid', 'aria-required' }` | `(props: FieldRenderProps) => any` | 必填 |
| class | 类名 | string | - |
| convert | 值写入 formState 前的转换函数 | `(value: any) => any` | - |
| extraText | 字段说明文字，区别于 helpText，可配合 extraTextPosition 摆在控件下方或 label 旁边 | any | - |
| extraTextPosition | extraText 的展示位置 | `'middle' \| 'bottom'` | "bottom" |
| field | 字段名，对应 `formState.values` 中的 key，支持 `contacts[0]` 这类路径记法（配合 ArrayField） | string | 必填 |
| helpText | 无错误信息时展示的提示内容 | any | - |
| initValue | 字段初始值，仅挂载时消费一次，优先级高于 Form 的 initValues | any | - |
| keepState | 字段卸载后是否保留其值/校验态，供重新挂载时复用 | boolean | false |
| label | label 文案，不传时默认与 field 同名 | string | - |
| labelPosition | 覆盖 Form 级配置 | string | - |
| labelWidth | 覆盖 Form 级配置 | string \| number | - |
| noErrorMessage | 不自动展示错误信息 | boolean | false |
| noLabel | 不展示 label | boolean | false |
| rules | 校验规则数组 | `FormRule[]` | - |
| style | 内联样式 | object | - |
| trigger | 触发校验的时机，可组合 blur、change、mount（挂载后立即校验一次），传 custom 或空数组表示完全不自动触发 | `Array<'blur' \| 'change' \| 'mount' \| 'custom'>` | ['blur'] |
| validateStatus | 手动指定字段校验态，优先级高于 rules 校验产出的错误态 | `'default' \| 'warning' \| 'error'` | - |

`FormRule` 结构：`{ required?: boolean; pattern?: RegExp; min?: number; max?: number; message?: string; validator?: (value, values) => string | undefined | Promise<string | undefined> }`。

`FieldRenderProps.validating` 是异步 `validator` 规则执行期间的 loading 态，Semi 自身没有这个状态，lotus 主动新增；只有 rules 里含 `validator` 时才会变 true，同步规则不会产生这个状态。

### ArrayField

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| Comp | 实际渲染内容，接收 `{ arrayFields, add, addWithInitValue }` | `(props: ArrayFieldRenderProps) => any` | 必填 |
| field | 该数组字段在 `formState.values` 中的 key | string | 必填 |
| initValue | 非受控模式下的初始数组值，仅挂载时消费一次 | `unknown[]` | - |

`ArrayFieldRenderProps` 结构：

| 字段 | 说明 |
| --- | --- |
| arrayFields | 当前行数组，每项为 `{ key, field, remove }`，`field` 形如 `contacts[0]`，可直接传给 `Field` 的 `field` |
| add(index?) | 在指定位置插入一个空行，不传 index 时追加到末尾 |
| addWithInitValue(rowValue, index?) | 同 add，但插入指定初始值而非空值 |

### Slot

不绑定字段名的纯布局占位，复用 Field 的 label/控件两栏布局展示任意内容，不参与表单的值/校验/提交。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 展示内容 | any | - |
| label | label 文案 | string | - |
| labelPosition | 覆盖 Form 级配置 | string | - |
| labelWidth | 覆盖 Form 级配置 | string \| number | - |

### FormApi

| 方法 | 说明 |
| --- | --- |
| getError(field) | 获取字段的当前错误信息 |
| getFieldExist(field) | 字段当前是否已注册 |
| getFormState() | 获取完整当前状态（values/errors/touched/validating） |
| getInitValue(field) | 获取单个字段挂载时的初始值 |
| getInitValues() | 获取 Form 挂载时刻的完整初始值快照 |
| getTouched(field) | 获取字段的 touched 状态，未设置时为 false |
| getValue(field) | 获取单个字段的值 |
| getValues() | 获取所有字段的值 |
| reset() | 重置表单到挂载时的初始快照 |
| scrollToError(options?) | 滚动到第一个当前有错误的字段 |
| scrollToField(field, options?) | 滚动到指定字段 |
| setValue(field, value) | 设置单个字段的值 |
| setValues(values) | 批量设置字段值 |
| submitForm() | 手动触发提交（含全量校验） |
| validate(fields?) | 手动触发校验，不传参数时校验全部字段 |

> 注意事项：lotus 不做 Semi 的 `withField` HOC 那种 `Form.Input`/`Form.Select` 挂载写法（Ripple 无 children 反射能力，无法运行时挂载子组件），改用 `Field` + `Comp` 显式桥接。onChange 签名不做归一化（Input 是 `(value, event)`，Select 是 `(value)`），调用方显式桥接。尚未实现 `Form.Section`/`Form.InputGroup` 布局组件、异步远程校验去重、静默校验。

## Accessibility

### ARIA

- Field 的错误信息容器携带 `role="alert"`，屏幕阅读器会在错误出现时自动播报。
- label 与输入控件通过 `<label for>` 真正关联到原生 id（`Comp` 需要把 `id` prop 透传给具体控件），同时补充 `aria-label`/`aria-labelledby` 兜底。
- `aria-describedby` 关联 extraText/helpText 容器，`aria-errormessage` 关联错误信息容器，`aria-invalid` 反映当前是否处于错误态，`aria-required` 由 rules 中是否含 `required` 规则推导。

## 设计变量

- `--lotus-spacing-default` / `--lotus-spacing-tight`（Field 间距）
- `--lotus-color-danger`（错误信息文字色）
- `--lotus-color-text-1` / `--lotus-color-text-2`（label/提示文字色）
