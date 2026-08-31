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

### 按钮样式（Semi 独有于 Radio）

给 `RadioGroup` 设置 `type="button"`，组内每个 `Radio` 渲染成分段按钮式外观；`buttonSize` 控制按钮尺寸（`small`/`middle`/`large`）。

```tsrx demo
../../src/demos/input/radio/group-button.tsrx
```

### 卡片样式

给 `RadioGroup` 设置 `type="card"`，组内每个 `Radio` 渲染成带背景边框的卡片。

```tsrx demo
../../src/demos/input/radio/group-card.tsrx
```

### 无圆点的纯卡片样式

`type="pureCard"` 在卡片样式基础上隐藏圆点图标，点击卡片本身即可切换选中。

```tsrx demo
../../src/demos/input/radio/group-pure-card.tsrx
```

### 自定义 id / 命令式 focus

`addonId`/`extraId` 分别关联 `aria-labelledby`/`aria-describedby`（不传则自动生成）；`autoFocus` 挂载时自动聚焦；`getRadioApi` 交出 `focus()`/`blur()` 命令式句柄。

```tsrx demo
../../src/demos/input/radio/imperative.tsrx
```

## API 参考

### Radio

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| addonClassName | addon（children+extra 容器）的自定义类名 | string | - |
| addonId | addon（children+extra 容器）的 id，配合 aria-labelledby 建立语义关联，不传则自动生成 | string | - |
| addonStyle | addon（children+extra 容器）的内联样式 | object | - |
| aria-label | 设置 aria-label 属性 | string | - |
| autoFocus | 挂载时是否自动聚焦 | boolean | false |
| checked | 指示当前是否选中，配合 onChange 使用 | boolean | - |
| class | 类名 | string | - |
| defaultChecked | 初始是否选中 | boolean | false |
| disabled | 是否禁用 | boolean | false |
| extra | 选项右侧额外内容 | any | - |
| extraId | extra 副文本的 id，配合 aria-describedby 建立语义关联，不传则自动生成 | string | - |
| getRadioApi | 交出命令式 API（focus/blur） | `(api: RadioApi) => void` | - |
| mode | 交互模式，可选 default、advanced（advanced 时已选中项可再次点击取消） | string | "default" |
| name | 原生 `name` 属性 | string | - |
| style | 内联样式 | object | - |
| value | 在 RadioGroup 中使用时的选项值 | string \| number | - |
| onChange | 选中状态变化时的回调 | `(checked: boolean) => void` | - |
| onMouseEnter | 鼠标移入时的回调 | `(event: MouseEvent) => void` | - |
| onMouseLeave | 鼠标移出时的回调 | `(event: MouseEvent) => void` | - |

### RadioApi

`getRadioApi` 交出的命令式句柄，与 Checkbox 的 `CheckboxApi` 同一模式。

| 方法 | 说明 |
| --- | --- |
| focus(options?) | 命令式聚焦；`options.preventScroll` 透传给原生 focus() 的同名选项 |
| blur() | 命令式移出焦点 |

> 无障碍提示：有 `children`/`extra` 时，`aria-labelledby`/`aria-describedby` 会分别关联到 addon/extra 容器；浏览器的可访问名称计算规则中 `aria-labelledby` 优先级高于 `aria-label`，此时容器文本内容才是真正的可访问名称（对齐 Semi 的既有行为）。

### RadioGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| buttonSize | `type="button"` 时的按钮尺寸 | `'small'` \| `'middle'` \| `'large'` | `'middle'` |
| class | 类名 | string | - |
| defaultValue | 默认选中值 | string \| number | - |
| direction | 排列方向，可选 horizontal、vertical（仅 `type="default"` 生效） | string | "horizontal" |
| disabled | 统一禁用组内所有选项 | boolean | false |
| name | 原生 `name` 属性，透传给组内每个 Radio 的 input | string | - |
| options | 选项数组声明方式 | `RadioGroupOption[]` | [] |
| style | 内联样式 | object | - |
| type | 组内所有 Radio 的样式类型：`default` 默认；`button` 分段按钮式（Semi 独有于 Radio）；`card` 带背景边框的卡片样式；`pureCard` 卡片样式且不显示圆点图标 | `'default'` \| `'button'` \| `'card'` \| `'pureCard'` | `'default'` |
| value | 选中值 | string \| number | - |
| onChange | 选中值变化时的回调 | `(value: string \| number) => void` | - |

`RadioGroupOption` 结构：`{ value: string \| number; label?: any; disabled?: boolean; extra?: any }`。

> 注意事项：lotus 尚未实现 `RadioGroup.optionLabelKey`/`optionValueKey` 自定义字段名映射；`preventScroll` 未作为独立 prop 暴露——已通过命令式 `focus(options)` 的参数覆盖同等能力。

## Accessibility

### ARIA

- `RadioGroup` 内每个 `Radio` 携带 `role="listitem"`。
- 可通过 `aria-label` 描述选项/选项组用途。
- 原生隐藏的 `<input type="radio">` 承接键盘操作与屏幕阅读器语义，同组内共享 `name` 属性以维持原生单选语义。

## 设计变量

- `--lotus-color-primary`（选中态边框/圆点色）
- `--lotus-color-border`（未选中态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
