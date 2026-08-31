---
title: InputNumber 数字输入框
category: 输入类
---

用于接收用户输入的数字，支持步进器与边界钳制。

## 代码演示

### 如何引入

```tsrx
import { InputNumber } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/input-number/basic.tsrx
```

### 三种大小

```tsrx demo
../../src/demos/input/input-number/size.tsrx
```

### 边界与步进

`min`/`max` 限定取值范围，`step` 控制步进器每次增减的数值。失焦或按 Enter 时会把当前值 clamp 到边界内。

```tsrx demo
../../src/demos/input/input-number/boundary.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/input-number/disabled.tsrx
```

### 可清除

`showClear` 展示清除按钮，常与 `hideButtons` 搭配隐藏步进器。

```tsrx demo
../../src/demos/input/input-number/clear.tsrx
```

### 受控组件

```tsrx demo
../../src/demos/input/input-number/controlled.tsrx
```

### 自定义格式化

`formatter`/`parser` 搭配使用，实现千分位、单位后缀等自定义展示；`precision` 控制失焦/步进时四舍五入的小数位数；`shiftStep` 设置按住 Shift 时的步进值。

```tsrx demo
../../src/demos/input/input-number/format.tsrx
```

### innerButtons 与长按连续触发

`innerButtons` 让步进按钮显示在输入框内部；长按步进按钮会以 `pressTimeout` 延迟后按 `pressInterval` 间隔连续触发。

```tsrx demo
../../src/demos/input/input-number/inner-buttons.tsrx
```

### 科学计数法

`scientificNotation` 开启后，失焦时若有效数字位数达到阈值（默认 15，可传对象自定义 `threshold`）则用科学计数法展示，聚焦时展示完整数字。不支持与货币模式同时使用（货币模式优先）。

```tsrx demo
../../src/demos/input/input-number/scientific-notation.tsrx
```

### 货币模式

`currency` 为 `true` 时按 `localeCode`（或跟随 `ConfigProvider` 当前语言）自动推导货币种类展示，也可直接传货币代码；`currencyDisplay` 控制符号/代码/名称展示方式；`showCurrencySymbol=false` 时只展示纯数字格式。

```tsrx demo
../../src/demos/input/input-number/currency.tsrx
```

### 命令式 focus/blur

```tsrx demo
../../src/demos/input/input-number/imperative.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autofocus | 自动获取焦点 | boolean | false |
| class | 类名 | string | - |
| clearIcon | 自定义清除按钮图标 | any | - |
| currency | 货币种类；`true` 时按 localeCode 自动推导，也可直接传货币代码（如 'USD'） | boolean \| string | false |
| currencyDisplay | 货币展示方式 | `'symbol'` \| `'code'` \| `'name'` | "symbol" |
| defaultValue | 默认值 | number | - |
| disabled | 是否禁用 | boolean | false |
| formatter | 自定义输入框展示值的格式；聚焦/失焦态均生效 | `(value: number \| string) => string` | - |
| getInputNumberApi | 交出命令式 API（focus/blur） | `(api: InputNumberApi) => void` | - |
| hideButtons | 是否隐藏步进器按钮 | boolean | false |
| innerButtons | 步进按钮显示在输入框内部 | boolean | false |
| keepFocus | 点击步进按钮时保持输入框聚焦；innerButtons=true 时天然保持聚焦 | boolean | false |
| localeCode | 货币模式下的国家/地区代码；不传时跟随 ConfigProvider 当前语言 | string | - |
| max | 允许的最大值 | number | Infinity |
| min | 允许的最小值 | number | -Infinity |
| parser | 配合 formatter 使用，把展示字符串转换回可解析的原始数字字符串 | `(str: string) => string` | - |
| precision | 数值精度，失焦/步进时四舍五入到指定小数位数 | number | - |
| placeholder | 占位提示文字 | string | - |
| prefix | 前缀内容 | any | - |
| pressInterval | 长按步进按钮时的连续触发间隔（毫秒） | number | 250 |
| pressTimeout | 长按步进按钮到开始连续触发的延迟（毫秒） | number | 250 |
| scientificNotation | 科学计数法显示；不支持货币模式 | `boolean \| { threshold?: number }` | false |
| shiftStep | 按住 Shift 键时的步进值 | number | 10 |
| showClear | 有内容时展示清除按钮 | boolean | false |
| showCurrencySymbol | 是否显示货币符号/代码/名称，仅货币模式下生效 | boolean | true |
| size | 尺寸，可选 large、default、small | string | "default" |
| step | 步进器每次增减的数值 | number | 1 |
| style | 内联样式 | object | - |
| suffix | 后缀内容 | any | - |
| value | 当前值 | number | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化时的回调（含步进器操作、清除） | `(value: number \| undefined) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onNumberChange | 值变化且为合法数字时的回调（`undefined` 不触发） | `(value: number) => void` | - |

### InputNumberApi

`getInputNumberApi` 交出的命令式句柄，与 Input 的 `InputApi` 同一模式。

| 方法 | 说明 |
| --- | --- |
| focus(options?) | 命令式聚焦；`options.preventScroll` 透传给原生 focus() 的同名选项 |
| blur() | 命令式移出焦点 |

> 注意事项：空输入不会被强制置为 `0`，保持 `undefined`（对齐 Semi「不强加默认值」的语义）。货币格式化基于原生 `Intl.NumberFormat`（不引入第三方货币库），国家/地区代码到货币代码的映射覆盖 Semi 文档列出的常见 `localeCode`，未命中时按语言前缀回退，最终兜底 USD。

## Accessibility

### ARIA

- 步进器按钮携带 `aria-label`（"增加"/"减少"，随 locale 切换），边界处会自动 `disabled`。
- 可通过 `aria-label` 描述输入框用途。
- 支持键盘 ArrowUp/ArrowDown 等价于点击步进按钮，按住 Shift 时使用 `shiftStep`。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`（三档高度）
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
