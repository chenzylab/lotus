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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultValue | 默认值 | number | - |
| disabled | 是否禁用 | boolean | false |
| hideButtons | 是否隐藏步进器按钮 | boolean | false |
| max | 允许的最大值 | number | Infinity |
| min | 允许的最小值 | number | -Infinity |
| placeholder | 占位提示文字 | string | - |
| prefix | 前缀内容 | any | - |
| showClear | 有内容时展示清除按钮 | boolean | false |
| size | 尺寸，可选 large、default、small | string | "default" |
| step | 步进器每次增减的数值 | number | 1 |
| style | 内联样式 | object | - |
| suffix | 后缀内容 | any | - |
| value | 当前值 | number | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化时的回调（含步进器操作、清除） | `(value: number \| undefined) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onNumberChange | 值变化且为合法数字时的回调（`undefined` 不触发） | `(value: number) => void` | - |

> 注意事项：lotus 尚未实现 Semi 的 `formatter`/`parser` 自定义格式化、`insetLabel`/`innerButtons` 布局变体、键盘上下方向键步进。空输入不会被强制置为 `0`，保持 `undefined`（对齐 Semi「不强加默认值」的语义）。

## Accessibility

### ARIA

- 步进器按钮携带 `aria-label`（"增加"/"减少"，随 locale 切换），边界处会自动 `disabled`。
- 可通过 `aria-label` 描述输入框用途。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`（三档高度）
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
