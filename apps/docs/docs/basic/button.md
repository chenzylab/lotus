---
title: Button 按钮
category: 基础
---

用于开始一个即时操作。

## 代码演示

### 如何引入

```tsrx
import { Button, ButtonGroup } from '@lotus/ripple';
```

### 按钮类型

Button 提供五种类型：`primary`、`secondary`、`tertiary`、`warning`、`danger`。

```tsrx demo
../../src/demos/basic/button/type.tsrx
```

### 按钮主题

Button 提供四种主题：`solid`（有背景色）、`light`（浅背景色，默认）、`outline`（边框模式）、`borderless`（无背景色）。

```tsrx demo
../../src/demos/basic/button/theme.tsrx
```

### 尺寸

Button 提供三种尺寸：`large`、`default`、`small`。

```tsrx demo
../../src/demos/basic/button/size.tsrx
```

### 块级按钮

设置 `block` 属性可以将按钮宽度调整为其父宽度。

```tsrx demo
../../src/demos/basic/button/block.tsrx
```

### 图标按钮

通过 `icon` 属性设置按钮图标，`iconPosition` 控制图标位置，不传 `children` 时渲染为纯图标按钮。

```tsrx demo
../../src/demos/basic/button/icon.tsrx
```

### 禁用状态

```tsrx demo
../../src/demos/basic/button/disabled.tsrx
```

### 加载状态

```tsrx demo
../../src/demos/basic/button/loading.tsrx
```

### 按钮组合

将多个 Button 放入 `ButtonGroup` 可以组合成一个视觉整体。

> 注意事项：Semi 的 `ButtonGroup` 通过 React `cloneElement` 把 `size`/`disabled`/`type`/`theme` 批量注入子 Button；Ripple 没有等价的 children 克隆能力，因此 lotus 版 `ButtonGroup` 是纯 CSS 视觉分组容器（方形拼接、两端保留圆角），子按钮的 `size`/`disabled`/`type`/`theme` 需要在每个 `Button` 上显式设置。

```tsrx demo
../../src/demos/basic/button/group.tsrx
```

### 多彩风格

`colorful` 开启 AI 多彩风格，仅 `type="primary"`/`type="tertiary"` 有对应视觉效果，其余 `type` 静默无效果。

```tsrx demo
../../src/demos/basic/button/colorful.tsrx
```

### 去除水平内边距

`noHorizontalPadding` 去除图标按钮的水平内边距，仅对设置了 `icon` 的按钮有效；可传 `true`（等效 `['left', 'right']`）、`"left"`、`"right"` 或数组精确控制去除哪一侧。

```tsrx demo
../../src/demos/basic/button/no-horizontal-padding.tsrx
```

## API 参考

### Button

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 按钮的标签 | string | - |
| block | 将按钮设置为块级按钮 | boolean | false |
| children | 按钮内容 | any | - |
| class | 类名 | string | - |
| colorful | AI 多彩风格，仅 type=primary/tertiary 有对应样式 | boolean | false |
| contentClassName | 内容区域（`.lotus-button-content`）单独类名 | string | - |
| disabled | 禁用状态 | boolean | false |
| htmlType | 原生 button 的 type 值，可选 button、reset、submit | string | "button" |
| icon | 图标 | any | - |
| iconPosition | 图标位置，可选 left、right | string | "left" |
| loading | 加载状态 | boolean | false |
| noHorizontalPadding | 去除水平内边距，仅对设置了 icon 的按钮有效。可传 `true`（等效 `['left','right']`）、`"left"`、`"right"` 或数组 | boolean \| string \| string[] | false |
| size | 按钮大小，可选 large、default、small | string | "default" |
| style | 自定义样式 | object | - |
| theme | 按钮主题，可选 solid、borderless、light、outline | string | "light" |
| type | 类型，可选 primary、secondary、tertiary、warning、danger | string | "primary" |
| onClick | 单击事件 | `(event: MouseEvent) => void` | - |
| onMouseDown | 鼠标按下事件 | `(event: MouseEvent) => void` | - |
| onMouseEnter | 鼠标移入事件 | `(event: MouseEvent) => void` | - |
| onMouseLeave | 鼠标移出事件 | `(event: MouseEvent) => void` | - |

### ButtonGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 按钮组的标签 | string | - |
| children | 组内的 Button | any | - |
| class | 自定义类名 | string | - |
| style | 自定义样式 | object | - |

## Accessibility

### ARIA

- `ButtonGroup` 渲染为 `role="group"`，建议传入 `aria-label` 描述该按钮组的作用。
- 纯图标按钮（无 `children`）建议传入 `aria-label` 描述按钮功能。

## 设计变量

- `--lotus-color-primary`、`--lotus-color-primary-hover`（主要按钮相关色值）
- `--lotus-color-danger`、`--lotus-color-warning`（危险/警示按钮色值）
- `--lotus-radius-button`（按钮圆角）
