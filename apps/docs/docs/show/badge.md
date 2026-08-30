---
title: Badge 徽标
category: 展示类
---

出现在按钮、图标、头像旁的数字或状态标记。

## 代码演示

### 如何引入

```tsrx
import { Badge } from '@lotus/ripple';
```

### 基本用法

`count` 传数字/字符串，超过 `overflowCount` 时显示 `{overflowCount}+`；`dot` 展示纯圆点，不显示具体数值。

```tsrx demo
../../src/demos/show/badge/basic.tsrx
```

### 类型与主题

`type` 控制配色语义，`theme` 控制实心/浅色/描边三种视觉风格。

```tsrx demo
../../src/demos/show/badge/theme.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置外层 `<span>` 的 aria-label 属性 | string | - |
| children | 被标记的内容；不传时徽标以行内块形式独立展示 | any | - |
| className | 外层类名 | string | - |
| count | 展示的数值/自定义内容；`0`/`null`/`undefined` 时不显示 | any | - |
| countClassName | 徽标本身的类名 | string | - |
| countStyle | 徽标本身的自定义样式 | object | - |
| dot | 是否展示为纯圆点（忽略 `count`） | boolean | `false` |
| overflowCount | 数值超过此值时显示为 `{overflowCount}+` | number | - |
| position | 有 `children` 时徽标叠加的角落位置 | `'leftTop' \| 'leftBottom' \| 'rightTop' \| 'rightBottom'` | `'rightTop'` |
| style | 外层自定义样式（若设置会覆盖 `countStyle`） | object | - |
| theme | 视觉风格 | `'solid' \| 'light' \| 'inverted'` | `'solid'` |
| type | 语义配色 | `'primary' \| 'secondary' \| 'tertiary' \| 'danger' \| 'warning' \| 'success'` | `'primary'` |
| onClick / onMouseEnter / onMouseLeave | 外层容器的鼠标事件回调 | `(event: MouseEvent) => void` | - |

## Accessibility

- 徽标本体携带 `role="status"`，`dot` 模式下 `aria-label` 使用 `@lotus/locale` 的 `Badge.unreadMessage`（"有未读消息"），非 `dot` 模式下用数值本身作为 `aria-label`。
- `role="status"` 是非侵入式的 ARIA live region，数值变化会被屏幕阅读器适时播报，不会打断当前朗读。

## 设计变量

- `--lotus-color-primary` / `-secondary` / `-tertiary` / `-danger` / `-warning` / `-success`
- `--lotus-color-{type}-light-default`（light 主题背景色）
