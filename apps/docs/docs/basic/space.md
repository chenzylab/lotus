---
title: Space 间距
category: 基础
---

## 代码演示

### 如何引入

```tsrx
import { Space } from '@lotus/ripple';
```

### 基本用法

设置组件之间的间距。

```tsrx demo
../../src/demos/basic/space/basic.tsrx
```

### 对齐方式

可使用 `align` 设置对齐方式，可选值：`start`、`center`（默认）、`end`、`baseline`。

```tsrx demo
../../src/demos/basic/space/align.tsrx
```

### 间距尺寸

可使用 `spacing` 设置间距大小，内置可选值：`tight`（8px，默认）、`medium`（16px）、`loose`（24px），并且支持传入 number 来自定义间距大小，也支持传入 `[水平, 垂直]` 数组来分别设置两个方向的间距。

```tsrx demo
../../src/demos/basic/space/spacing.tsrx
```

### 间距方向

可使用 `vertical` 设置间距是否为垂直方向，默认情况下为 `false`。

```tsrx demo
../../src/demos/basic/space/vertical.tsrx
```

### 设置换行

当间距为水平方向时，可使用 `wrap` 设置是否自动换行，默认情况下为 `false`。

```tsrx demo
../../src/demos/basic/space/wrap.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | 对齐方式，支持 `start`、`end`、`center`、`baseline` | string | `center` |
| spacing | 间距尺寸，支持 `tight`(8px)、`medium`(16px)、`loose`(24px) 或 number、`[水平, 垂直]` 数组 | string \| number \| array | `tight` |
| vertical | 是否为垂直间距 | boolean | `false` |
| wrap | 是否自动换行 | boolean | `false` |
| style | 内联样式 | object | - |

## Accessibility

- Space 是纯布局容器（`<div>`），不引入额外语义，子元素的可访问性由子元素自身负责。
- 使用 `wrap` 自动换行时，视觉顺序与 DOM 顺序保持一致，不影响 Tab 键导航顺序。

## 设计变量

- `--lotus-spacing-tight`（tight，8px）
- `--lotus-spacing-base`（medium，16px）
- `--lotus-spacing-loose`（loose，24px）
