---
title: List 列表
category: 展示类
---

展示纵向排列的数据集合，支持分隔线、栅格布局、加载态。

## 代码演示

### 如何引入

```tsrx
import { List, ListItem } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/list/basic.tsrx
```

### 栅格布局

`grid` 传 `{ span, gutter, ... }` 时，内部用 `Row`/`Col` 按栅格排列每一项。

```tsrx demo
../../src/demos/show/list/grid.tsrx
```

## API 参考

### List

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| bordered | 是否显示外边框 | boolean | `false` |
| children | 直接传子项（与 `dataSource`+`renderItem` 二选一） | any | - |
| dataSource | 数据源 | T[] | - |
| emptyContent | 数据为空时的展示内容 | any | - |
| footer | 底部内容 | any | - |
| grid | 栅格布局配置 | `ListGrid` | - |
| header | 顶部内容 | any | - |
| layout | 排列方向 | `'vertical' \| 'horizontal'` | `'vertical'` |
| loading | 是否展示加载态 | boolean | `false` |
| loadMore | 底部"加载更多"区域内容 | any | - |
| renderItem | 根据数据项渲染每一行 | `(item: T, index: number) => any` | - |
| size | 尺寸 | `'small' \| 'default' \| 'large'` | `'default'` |
| split | 是否显示项间分隔线 | boolean | `true` |
| style | 自定义样式 | object | - |

`ListGrid` 结构：`{ span?, gutter?, xs?, sm?, md?, lg?, xl?, xxl? }`（响应式断点透传给内部 `Col`）。

### ListItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | 主内容与 `extra` 的纵向对齐方式 | `ListItemAlign` | `'flex-start'` |
| children | 直接传内容（与 `main` 二选一） | any | - |
| extra | 右侧额外内容 | any | - |
| header | 头部区域（如图标/头像） | any | - |
| main | 主内容 | any | - |
| onClick / onRightClick / onMouseEnter / onMouseLeave | 鼠标事件回调 | `(event: MouseEvent) => void` | - |

## Accessibility

- 使用原生 `<ul>`/`<li>` 语义结构渲染列表项，并显式携带 `role="list"`/`role="listitem"`（grid 布局下改用 `Row`/`Col`，不再是 `<ul>`/`<li>`）。
- `loading` 状态下展示 `Spin` 加载指示器。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-bg-1`
- `--lotus-spacing-base` / `-base-loose`
