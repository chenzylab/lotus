---
title: Checkbox 多选框
category: 输入类
---

用于在一组备选项中进行多选。

## 代码演示

### 如何引入

```tsrx
import { Checkbox, CheckboxGroup } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/checkbox/basic.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/checkbox/disabled.tsrx
```

### 半选状态

`indeterminate` 用于表示"部分子项已选中"的中间态，纯视觉展示，不影响 `checked` 的实际值。

```tsrx demo
../../src/demos/input/checkbox/indeterminate.tsrx
```

### 受控组件

```tsrx demo
../../src/demos/input/checkbox/controlled.tsrx
```

### CheckboxGroup：options 数组方式

传入 `options` 数组声明一组选项，是官方推荐且完整支持的用法。

```tsrx demo
../../src/demos/input/checkbox/group-options.tsrx
```

### CheckboxGroup：JSX 组合方式

也可以在 `CheckboxGroup` 内直接嵌套 `Checkbox` 声明选项，此时子 `Checkbox` 的 `checked`/`defaultChecked` 会被 Group 接管（对齐 Semi「在 Group 中使用时无效」）。

```tsrx demo
../../src/demos/input/checkbox/group-jsx.tsrx
```

### 卡片样式

给 `CheckboxGroup` 设置 `type="card"`，组内每个 `Checkbox` 渲染成带背景边框的卡片。

```tsrx demo
../../src/demos/input/checkbox/group-card.tsrx
```

### 无 checkbox 的纯卡片样式

`type="pureCard"` 在卡片样式基础上隐藏 checkbox 方框图标，点击卡片本身即可切换选中。

```tsrx demo
../../src/demos/input/checkbox/group-pure-card.tsrx
```

## API 参考

### Checkbox

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| checked | 指示当前是否选中，配合 onChange 使用 | boolean | - |
| class | 类名 | string | - |
| defaultChecked | 初始是否选中 | boolean | false |
| disabled | 是否禁用 | boolean | false |
| extra | 选项右侧额外内容 | any | - |
| indeterminate | 半选中态（纯视觉，不影响 checked 实际值） | boolean | false |
| style | 内联样式 | object | - |
| value | 在 CheckboxGroup 中使用时的选项值 | string \| number | - |
| onChange | 选中状态变化时的回调 | `(checked: boolean) => void` | - |

### CheckboxGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultValue | 默认选中值数组 | `Array<string \| number>` | [] |
| direction | 排列方向，可选 horizontal、vertical | string | "vertical" |
| disabled | 统一禁用组内所有选项 | boolean | false |
| name | 原生 `name` 属性，透传给组内每个 Checkbox 的 input | string | - |
| options | 选项数组声明方式 | `CheckboxGroupOption[]` | [] |
| style | 内联样式 | object | - |
| type | 组内所有 Checkbox 的样式类型：`default` 默认；`card` 带背景边框的卡片样式；`pureCard` 卡片样式且不显示 checkbox 方框图标 | `'default'` \| `'card'` \| `'pureCard'` | `'default'` |
| value | 选中值数组 | `Array<string \| number>` | - |
| onChange | 选中集合变化时的回调 | `(value: Array<string \| number>) => void` | - |

`CheckboxGroupOption` 结构：`{ value: string \| number; label?: any; disabled?: boolean; extra?: any }`。

> 注意事项：lotus 尚未实现 `CheckboxGroup.optionLabelKey`/`optionValueKey` 自定义字段名映射、`addonId`/`extraId`（aria 关联 id，不传时自动生成）、`preventScroll`、命令式 `focus()`/`blur()`。

## Accessibility

### ARIA

- `CheckboxGroup` 内每个 `Checkbox` 携带 `role="listitem"`。
- 可通过 `aria-label` 描述选项/选项组用途。
- 原生隐藏的 `<input type="checkbox">` 承接键盘操作与屏幕阅读器语义，视觉呈现由自定义的勾选框元素接管。

## 设计变量

- `--lotus-color-primary`（选中态背景色）
- `--lotus-color-border`（未选中态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
