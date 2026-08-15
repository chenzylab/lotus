---
title: Input 输入框
category: 输入类
---

用于接收用户输入的文本内容，包含 `Input` 单行输入框和 `TextArea` 多行输入框。

## 代码演示

### 如何引入

```tsrx
import { Input, TextArea } from '@lotus/ripple';
```

### 基本

```tsrx demo
../../src/demos/input/input/basic.tsrx
```

### 三种大小

```tsrx demo
../../src/demos/input/input/size.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/input/disabled.tsrx
```

### 前缀/后缀

`prefix`/`suffix` 接收任意内容，`showClear` 可以配合前后缀一起使用。

```tsrx demo
../../src/demos/input/input/affix.tsrx
```

### 前置/后置标签

```tsrx demo
../../src/demos/input/input/addon.tsrx
```

### 密码模式

设置 `mode="password"`，内置切换可见性的眼睛图标按钮。

```tsrx demo
../../src/demos/input/input/password.tsrx
```

### 校验状态

```tsrx demo
../../src/demos/input/input/validate-status.tsrx
```

### 受控组件

```tsrx demo
../../src/demos/input/input/controlled.tsrx
```

### 多行输入框

`TextArea` 用于多行文本输入，`rows` 控制默认行数。

```tsrx demo
../../src/demos/input/input/textarea-basic.tsrx
```

### 自动扩展的多行输入框

`autosize` 传 `true` 或 `{ minRows, maxRows }` 对象，随内容自动调整高度。

```tsrx demo
../../src/demos/input/input/textarea-autosize.tsrx
```

### 字数统计与清除

`maxCount` 显示字数统计，`showClear` 展示清除按钮。

```tsrx demo
../../src/demos/input/input/textarea-count.tsrx
```

## API 参考

### Input

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| addonAfter | 后置标签 | any | - |
| addonBefore | 前置标签 | any | - |
| aria-label | 设置 aria-label 属性 | string | - |
| borderless | 无边框模式 | boolean | false |
| class | 类名 | string | - |
| composition | 是否开启输入法模式，开启后输入法未确认期间不会触发 onChange，输入法确认后触发一次 onChange | boolean | false |
| defaultValue | 输入框内容默认值 | string | - |
| disabled | 是否禁用 | boolean | false |
| hideSuffix | 清除按钮与后缀标签并存时是否隐藏后缀标签 | boolean | false |
| maxLength | 最大输入长度 | number | - |
| mode | 输入框的模式，可选 password | string | "text" |
| placeholder | 占位提示文字 | string | - |
| prefix | 前缀标签 | any | - |
| showClear | 输入框有内容且 hover 或 focus 时展示清除按钮 | boolean | false |
| size | 输入框大小，可选 large、default、small | string | "default" |
| style | 样式 | object | - |
| suffix | 后缀标签 | any | - |
| type | 声明 input 类型，同原生 input 标签的 type 属性 | string | "text" |
| validateStatus | 校验状态，可选 default、error、warning，仅影响展示样式 | string | "default" |
| value | 输入框内容 | string | - |
| onBlur | 输入框失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 输入框内容变化时的回调 | `(value: string, event: Event) => void` | - |
| onClear | 点击清除按钮时的回调 | `(event: MouseEvent) => void` | - |
| onCompositionEnd | 输入法组合结束回调 | `(event: CompositionEvent) => void` | - |
| onCompositionStart | 输入法组合开始回调 | `(event: CompositionEvent) => void` | - |
| onCompositionUpdate | 输入法组合更新回调 | `(event: CompositionEvent) => void` | - |
| onEnterPress | 按下回车时的回调 | `(event: KeyboardEvent) => void` | - |
| onFocus | 输入框 focus 时的回调 | `(event: FocusEvent) => void` | - |
| onKeyDown | keydown 回调 | `(event: KeyboardEvent) => void` | - |

> 注意事项：lotus 尚未实现 `getValueLength`（自定义计算字符串长度）、`clearIcon`（自定义清除图标节点，可用 `prefix`/`suffix` 的思路间接实现）、`preventScroll`；`maxLength` 直接做字符数截断，未对齐 Semi 的"可插拔长度计算规则"设计。

### TextArea

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autosize | 是否随内容自动调整高度，可传对象配置最小最大行数 | boolean \| `{ minRows?: number; maxRows?: number }` | false |
| borderless | 无边框模式 | boolean | false |
| class | 类名 | string | - |
| composition | 是否开启输入法模式 | boolean | false |
| cols | 默认列数 | number | - |
| defaultValue | 输入框内容默认值 | string | - |
| disabled | 禁用状态 | boolean | false |
| maxCount | 设置字数限制并显示字数统计 | number | - |
| maxLength | 最大输入长度 | number | - |
| placeholder | 占位提示文字 | string | - |
| readonly | 只读 | boolean | false |
| resize | 是否允许用户拖拽调整尺寸，可选 none、both、horizontal、vertical | string | - |
| rows | 默认行数 | number | 4 |
| showClear | 支持清除 | boolean | false |
| style | 外层容器样式 | object | - |
| textareaStyle | textarea 元素自身的样式，可用于设置高度等 | object | - |
| value | 输入框内容 | string | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 内容变化时的回调 | `(value: string, event: Event) => void` | - |
| onClear | 点击清除按钮时的回调 | `(event: MouseEvent) => void` | - |
| onCompositionEnd | 输入法组合结束回调 | `(event: CompositionEvent) => void` | - |
| onCompositionStart | 输入法组合开始回调 | `(event: CompositionEvent) => void` | - |
| onCompositionUpdate | 输入法组合更新回调 | `(event: CompositionEvent) => void` | - |
| onEnterPress | 按下回车的回调（Shift+Enter 不触发） | `(event: KeyboardEvent) => void` | - |
| onFocus | focus 时的回调 | `(event: FocusEvent) => void` | - |
| onKeyDown | keydown 回调 | `(event: KeyboardEvent) => void` | - |
| onResize | autosize 导致高度变化时触发 | `(size: { height: number }) => void` | - |

> 注意事项：lotus 尚未实现 `showLineNumber`（行号显示）、`getValueLength`、`InputGroup` 组合容器。`resize` 仅当显式传入时生效，未传时保留默认的 `vertical` 拖拽调整行为。

## Methods

| 名称 | 描述 |
| --- | --- |
| focus() | 获取焦点，可通过 `ref` 获取原生 DOM 节点后调用 |
| blur() | 移出焦点，同上 |

## Accessibility

### ARIA

- `validateStatus="error"` 时输入框携带 `aria-invalid="true"`。
- 可通过 `aria-label` 描述输入框用途。
- 密码模式下的眼睛切换按钮、清除按钮均为可聚焦的 `<button>` 元素。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`（三档高度）
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色）
- `--lotus-color-warning` / `--lotus-color-danger`（校验状态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
