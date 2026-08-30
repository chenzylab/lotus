---
title: Descriptions 描述列表
category: 展示类
---

以键值对形式展示成组的静态信息，支持垂直/水平两种布局。

## 代码演示

### 如何引入

```tsrx
import { Descriptions } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/descriptions/basic.tsrx
```

### 水平布局

`layout="horizontal"` 时按 `column` 总列数分组换行，单项可用 `span` 跨列。

```tsrx demo
../../src/demos/show/descriptions/horizontal.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | `vertical` 布局下每项内部键值对齐方式 | `'center' \| 'justify' \| 'left' \| 'plain'` | `'center'` |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| column | `horizontal` 布局下每行的总列数 | number | `3` |
| data | 数据项数组 | `DescriptionsItemData[]` | `[]` |
| layout | 布局方向 | `'horizontal' \| 'vertical'` | `'vertical'` |
| row | 是否使用双行（key 一行、value 一行）紧凑样式 | boolean | `false` |
| size | `row` 模式下的尺寸 | `'small' \| 'medium' \| 'large'` | `'medium'` |
| style | 自定义样式 | object | - |

`DescriptionsItemData` 结构：`{ key, value, hidden?, span?, keyStyle?, className?, style? }`（`value` 可传函数，渲染时求值）。

## Accessibility

- 使用原生 `<table>`/`<tbody>`/`<tr>` 渲染，天然具备表格语义，屏幕阅读器可正确读出行列结构。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-border`
- `--lotus-font-body-size`
