---
title: Empty 空状态
category: 展示类
---

无数据、无结果、无权限等场景下的占位展示，配合 `@lotus/illustrations` 提供的插画使用。

## 代码演示

### 如何引入

```tsrx
import { Empty } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/empty/basic.tsrx
```

### 水平布局

```tsrx demo
../../src/demos/show/empty/horizontal.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| children | 底部额外内容（如操作按钮） | any | - |
| class | 类名 | string | - |
| description | 描述文案 | any | - |
| image | 插画/图标 | any | - |
| imageStyle | 插画容器自定义样式 | object | - |
| layout | 布局方向 | `'vertical' \| 'horizontal'` | `'vertical'` |
| style | 自定义样式 | object | - |
| title | 标题 | any | - |

## Accessibility

- 标题为字符串时使用 `TypographyTitle` 渲染，保留原生标题语义（有 `image` 时用 `h4`，否则用 `h6`）。

## 设计变量

- `--lotus-color-text-2`（描述文案颜色）
- `--lotus-font-body-size`
- `--lotus-spacing-loose` / `-extra-loose` / `-super-tight`
