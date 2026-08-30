---
title: Timeline 时间轴
category: 展示类
---

垂直排列的时间轴，展示一系列有时间顺序的信息节点。

## 代码演示

### 如何引入

```tsrx
import { Timeline, TimelineItem } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/timeline/basic.tsrx
```

### alternate 模式

节点左右交替排列。

```tsrx demo
../../src/demos/show/timeline/alternate.tsrx
```

## API 参考

### Timeline

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| children | 直接传 `TimelineItem` 子项（与 `dataSource` 二选一） | any | - |
| dataSource | 数据源 | `TimelineDataItem[]` | - |
| mode | 排列模式 | `'left' \| 'right' \| 'center' \| 'alternate'` | `'left'` |
| style | 自定义样式 | object | - |

`TimelineDataItem` 结构：`{ content?, time?, type?, color?, dot?, extra?, position?, class?, style?, onClick? }`。

### TimelineItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 节点内容（与 `TimelineDataItem.content` 对应） | any | - |
| color | 自定义节点圆点颜色 | string | - |
| dot | 自定义节点图标/内容（覆盖默认圆点） | any | - |
| extra | 额外内容 | any | - |
| index | 节点序号，用于 `mode=alternate` 时计算左右交替。通过 `dataSource` 渲染时自动传入；直接用 JSX children 方式则需要手动传入（Ripple 没有 `React.Children.map`，无法像 Semi 那样自动推断子节点序号） | number | - |
| position | 单个节点覆盖 `Timeline.mode` 的位置 | `'left' \| 'right'` | - |
| time | 时间文案 | any | - |
| type | 节点类型（决定默认圆点配色） | `'default' \| 'ongoing' \| 'success' \| 'warning' \| 'error'` | `'default'` |

## Accessibility

- 根容器用原生 `<ul>` 渲染，`time`/`content` 分区清晰，屏幕阅读器可按顺序读出每个节点。
- 装饰性的连接线与节点圆点均携带 `aria-hidden="true"`，不会被朗读为无意义的图形元素。

## 设计变量

- `--lotus-color-border`（连接线）
- `--lotus-color-success` / `-warning` / `-danger` / `-primary`（节点类型配色）
- `--lotus-color-text-0` / `-text-2`
