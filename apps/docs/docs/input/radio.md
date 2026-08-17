---
title: Radio 单选框
category: 输入类
---

用于在一组备选项中进行单选。

## 代码演示

### 如何引入

```tsrx
import { Radio, RadioGroup } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/radio/basic.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/radio/disabled.tsrx
```

### 受控组件

```tsrx demo
../../src/demos/input/radio/controlled.tsrx
```

### 高级模式

`mode="advanced"` 时，已选中的 Radio 再次点击会变回未选中态；默认模式下已选中项再次点击不产生变化（对齐原生 radio 语义——同组内必须始终有且只有一个选中）。

```tsrx demo
../../src/demos/input/radio/advanced-mode.tsrx
```

### RadioGroup：options 数组方式

```tsrx demo
../../src/demos/input/radio/group-options.tsrx
```

### RadioGroup：JSX 组合方式

也可以在 `RadioGroup` 内直接嵌套 `Radio` 声明选项，此时子 `Radio` 的 `checked`/`defaultChecked` 会被 Group 接管（对齐 Semi「在 Group 中使用时无效」）。

```tsrx demo
../../src/demos/input/radio/group-jsx.tsrx
```

## API 参考

### Radio

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| checked | 指示当前是否选中，配合 onChange 使用 | boolean | - |
| class | 类名 | string | - |
| defaultChecked | 初始是否选中 | boolean | false |
| disabled | 是否禁用 | boolean | false |
| extra | 选项右侧额外内容 | any | - |
| mode | 交互模式，可选 default、advanced（advanced 时已选中项可再次点击取消） | string | "default" |
| name | 原生 `name` 属性 | string | - |
| style | 内联样式 | object | - |
| value | 在 RadioGroup 中使用时的选项值 | string \| number | - |
| onChange | 选中状态变化时的回调 | `(checked: boolean) => void` | - |

### RadioGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultValue | 默认选中值 | string \| number | - |
| direction | 排列方向，可选 horizontal、vertical | string | "horizontal" |
| disabled | 统一禁用组内所有选项 | boolean | false |
| name | 原生 `name` 属性，透传给组内每个 Radio 的 input | string | - |
| options | 选项数组声明方式 | `RadioGroupOption[]` | [] |
| style | 内联样式 | object | - |
| value | 选中值 | string \| number | - |
| onChange | 选中值变化时的回调 | `(value: string \| number) => void` | - |

`RadioGroupOption` 结构：`{ value: string \| number; label?: any; disabled?: boolean; extra?: any }`。

> 注意事项：lotus 尚未实现 Semi 的 `RadioGroup.type="button"` 按钮样式变体、`RadioGroup.optionLabelKey`/`optionValueKey` 自定义字段名映射。

## Accessibility

### ARIA

- `RadioGroup` 内每个 `Radio` 携带 `role="listitem"`。
- 可通过 `aria-label` 描述选项/选项组用途。
- 原生隐藏的 `<input type="radio">` 承接键盘操作与屏幕阅读器语义，同组内共享 `name` 属性以维持原生单选语义。

## 设计变量

- `--lotus-color-primary`（选中态边框/圆点色）
- `--lotus-color-border`（未选中态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
