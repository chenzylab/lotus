---
title: OverflowList 溢出列表
category: 展示类
---

根据容器宽度自动计算能完整显示多少项，超出部分折叠渲染（如"+N"标签），常用于标签组、面包屑等横向排列场景。

## 代码演示

### 如何引入

```tsrx
import { OverflowList } from '@lotus/ripple';
```

### 基本用法

容器不够宽时超出部分折叠为 `overflowRenderer` 渲染的内容（默认从末尾开始折叠，`collapseFrom="end"`）。

```tsrx demo
../../src/demos/show/overflow-list/basic.tsrx
```

### collapseFrom="start"：折叠头部，保留尾部

```tsrx demo
../../src/demos/show/overflow-list/collapse-from-start.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | 无 |
| class | 类名 | string | 无 |
| collapseFrom | 从哪一端开始折叠 | `'start' \| 'end'` | `'end'` |
| itemKey | 自定义 key 提取函数 | `(item, index) => string \| number` | 取 `item.key` 或索引 |
| items | 数据源 | T[] | `[]` |
| minVisibleItems | 至少保留可见的项数（即使容器很窄） | number | `0` |
| onOverflow | 溢出项变化时的回调 | `(overflowItems: T[]) => void` | 无 |
| overflowRenderer | 溢出项的渲染函数 | `(overflowItems: T[]) => any` | 无 |
| style | 自定义样式 | object | 无 |
| visibleItemRenderer | 单个可见项的渲染函数 | `(item, index) => any` | 无 |

## Accessibility

- 布局计算依赖真实测量每一项的渲染宽度（`ResizeObserver`），不是拍脑袋估算，容器尺寸变化时会重新计算可见/溢出项。

## 设计变量

本组件不直接消费 Token，视觉样式完全由 `visibleItemRenderer`/`overflowRenderer` 渲染的内容决定（如 Tag/Avatar 等）。
