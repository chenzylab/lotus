---
title: Descriptions 描述列表
category: 展示类
---

以键值对形式展示成组的静态信息，支持垂直/水平两种布局。

## 代码演示

### 如何引入

```tsrx
import { Descriptions, DescriptionsItem } from '@lotus/ripple';
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

### children 声明式写法

除了 `data` 数组配置，也可以用 `<Descriptions><DescriptionsItem>` 声明式写法——仅在 `layout="vertical"`（默认值）下支持，`horizontal` 布局需要用 `data` 数组（见下方说明）。

```tsrx
<Descriptions>
    <DescriptionsItem itemKey="姓名">李四</DescriptionsItem>
    <DescriptionsItem itemKey="部门">产品组</DescriptionsItem>
</Descriptions>
```

## API 参考

### Descriptions

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | `vertical` 布局下每项内部键值对齐方式 | `'center' \| 'justify' \| 'left' \| 'plain'` | `'center'` |
| aria-label | 设置 aria-label 属性 | string | - |
| children | `DescriptionsItem` 子项（声明式写法，仅 `layout="vertical"` 支持） | any | - |
| class | 类名 | string | - |
| column | `horizontal` 布局下每行的总列数 | number | `3` |
| data | 数据项数组 | `DescriptionsItemData[]` | `[]` |
| layout | 布局方向 | `'horizontal' \| 'vertical'` | `'vertical'` |
| row | 是否使用双行（key 一行、value 一行）紧凑样式 | boolean | `false` |
| size | `row` 模式下的尺寸 | `'small' \| 'medium' \| 'large'` | `'medium'` |
| style | 自定义样式 | object | - |

`DescriptionsItemData` 结构：`{ key, value, hidden?, span?, keyStyle?, className?, style? }`（`value` 可传函数，渲染时求值）。

### DescriptionsItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 值内容 | any | - |
| class | 类名 | string | - |
| hidden | 是否隐藏该条目 | boolean | `false` |
| itemKey | 键名 | any | - |
| keyStyle | 键名的自定义样式 | object | - |
| span | 占列数（对齐用途，`horizontal` 分组场景请改用 `data` 数组配置） | number | `1` |
| style | 行的自定义样式 | object | - |

> `horizontal` 布局下的 `children` 声明式写法不支持：该布局需要先收集全部条目按 `column` 总列数统一分组换行，这要求父组件能拿到"全部子节点的完整列表"才能分组——Semi 靠 `React.Children.toArray` 做到，tsrx 没有等价机制。实际使用中 `horizontal` 场景的数据多来自后端接口，`data` 数组形式本身就更自然，不构成实用性缺口。

## Accessibility

- 使用原生 `<table>`/`<tbody>`/`<tr>` 渲染，天然具备表格语义，屏幕阅读器可正确读出行列结构。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-border`
- `--lotus-font-body-size`
