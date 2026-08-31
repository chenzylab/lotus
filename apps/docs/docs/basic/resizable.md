---
title: Resizable 可调整大小
category: 基础
---

8 方向可调整大小容器，支持单个容器伸缩与组合分栏伸缩两种模式。拖拽算法（方向-delta 计算、边界约束、宽高比锁定、分栏比例分配）在 Foundation 层自研实现。

## 代码演示

### 如何引入

```tsrx
import { Resizable, ResizeGroup, ResizeItem, ResizeHandler } from '@lotus/ripple';
```

### 基本用法

未指定 `enable` 时 8 个方向手柄全部启用，拖拽边缘或角落即可调整大小；每个手柄也可 Tab 聚焦后用方向键调整（每次步进 10px）。

```tsrx demo
../../src/demos/basic/resizable/basic.tsrx
```

### 限定可调整方向

`enable` 传入方向子集，只渲染列出的手柄。

```tsrx demo
../../src/demos/basic/resizable/enable.tsrx
```

### 限制调整范围与网格吸附

`boundElement` 限制可调整的最大范围（`'parent'` 用父节点、`'window'` 用视口、也可传入自定义 DOM 元素）；`grid` 让尺寸吸附到指定步长的网格；`snap`/`snapGap` 吸附到指定的绝对像素点；`handleStyle`/`handleClass`/`handleNode` 自定义各方向手柄的样式/类名/渲染内容；`ratio` 控制拖动像素与实际尺寸变化的比例；`scale` 用于容器被 CSS `transform: scale()` 缩放时还原真实的指针位移。

```tsrx demo
../../src/demos/basic/resizable/constraints.tsrx
```

### 组合分栏（ResizeGroup）

`ResizeGroup` + `ResizeItem` + `ResizeHandler` 组成可拖拽分隔条的多栏面板。`direction` 控制主轴方向；每个 `ResizeItem` 的 `defaultSize` 是三选一语义：`'400px'` 固定像素、`'20%'` 固定百分比、纯数字（如 `1`、`0.5`）表示按比例分配剩余空间（类似 flex-grow）；`min`/`max` 限制单个面板的收缩/扩张范围。拖拽某个 `ResizeHandler` 只影响紧邻的前后两个 `ResizeItem`。

```tsrx demo
../../src/demos/basic/resizable/group.tsrx
```

### ResizeGroup 的简化写法

不想手写 `ResizeItem`/`ResizeHandler` 协作组件时，可以直接给 `ResizeGroup` 传 `items` 配置数组，内部自动渲染面板与分隔条——这是 Ripple 架构下的等价简化写法，两种写法二选一（`items` 优先于 `children`）。

```tsrx demo
../../src/demos/basic/resizable/group-items.tsrx
```

## API 参考

### Resizable

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 可访问名称 | string | 无 |
| boundElement | 限制调整范围的边界元素 | `'parent'` \| `'window'` \| `HTMLElement` | 无 |
| children | 容器内容 | any | 无 |
| class | 类名 | string | 无 |
| defaultHeight | 非受控模式下的初始高度 | number | `200` |
| defaultWidth | 非受控模式下的初始宽度 | number | `320` |
| enable | 启用的手柄方向子集；不传则 8 方向全部启用 | `ResizeDirection[]` | 无 |
| grid | 增量对齐步长 | `[number, number]` | 无（不生效） |
| handleClass | 每个方向手柄的自定义类名 | `Partial<Record<ResizeDirection, string>>` | 无 |
| handleNode | 每个方向自定义手柄渲染内容 | `Partial<Record<ResizeDirection, any>>` | 无 |
| handleStyle | 每个方向手柄的自定义样式 | `Partial<Record<ResizeDirection, object>>` | 无 |
| height | 受控高度（需与 `width` 同时提供才生效） | number | 无 |
| lockAspectRatio | 是否锁定宽高比 | boolean | `false` |
| maxHeight | 最大高度 | number | `Infinity` |
| maxWidth | 最大宽度 | number | `Infinity` |
| minHeight | 最小高度 | number | `0` |
| minWidth | 最小宽度 | number | `0` |
| ratio | 拖动像素与实际尺寸变化的比例 | number | `1` |
| scale | 容器被 CSS transform scale 缩放时的坐标还原系数 | number | `1` |
| snap | 吸附到指定绝对像素点 | `{ x?: number[]; y?: number[] }` | 无 |
| snapGap | 吸附生效的最小间隙阈值 | number | `0`（总是吸附到最近目标） |
| style | 自定义样式 | object | 无 |
| width | 受控宽度（需与 `height` 同时提供才生效） | number | 无 |
| onChange | 尺寸变化时的回调（拖拽/键盘调整过程中持续触发） | `(size: { width: number; height: number }, direction: ResizeDirection) => void` | 无 |
| onResizeEnd | 拖拽结束时的回调 | `(size: { width: number; height: number }, direction: ResizeDirection) => void` | 无 |
| onResizeStart | 拖拽开始时的回调 | `(direction: ResizeDirection) => void` | 无 |

`ResizeDirection` 取值：`'top'` \| `'right'` \| `'bottom'` \| `'left'` \| `'topRight'` \| `'bottomRight'` \| `'bottomLeft'` \| `'topLeft'`。

### ResizeGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 可访问名称 | string | 无 |
| children | `ResizeItem`/`ResizeHandler` 协作组件（JSX 写法） | any | 无 |
| class | 类名 | string | 无 |
| direction | 分栏主轴方向 | `'horizontal'` \| `'vertical'` | `'horizontal'` |
| items | 简化 API：面板配置数组，传入时忽略 `children` | `ResizeGroupItemConfig[]` | 无 |
| style | 自定义样式 | object | 无 |

`ResizeGroupItemConfig` 字段：`content`（渲染内容）、`defaultSize`/`min`/`max`（同 `ResizeItem`）、`style`、`class`、`onResizeStart`/`onChange`/`onResizeEnd`。

### ResizeItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 面板内容 | any | 无 |
| class | 类名 | string | 无 |
| defaultSize | 三选一语义：像素/百分比字符串固定尺寸，纯数字按比例分配剩余空间 | `string \| number` | 无（按比例均分） |
| max | 最大尺寸（百分比或像素字符串） | string | 无（100%） |
| min | 最小尺寸（百分比或像素字符串） | string | 无（0%） |
| style | 自定义样式 | object | 无 |
| onChange | 拖拽过程中的回调 | `(size, direction) => void` | 无 |
| onResizeEnd | 拖拽结束时的回调 | `(size, direction) => void` | 无 |
| onResizeStart | 拖拽开始时的回调 | `(direction, event) => void` | 无 |

### ResizeHandler

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 自定义分隔条渲染内容 | any | 无 |
| class | 类名 | string | 无 |
| style | 自定义样式 | object | 无 |

必须作为 `ResizeGroup` 的直接/间接子级使用，放在两个 `ResizeItem` 之间。

## Accessibility

- 单组件模式：每个手柄携带 `role="button"`、`tabIndex={0}`，可通过 Tab 依次聚焦；聚焦后可用方向键调整对应方向的尺寸（每次步进 10px），是鼠标拖拽之外的键盘等价操作；方向键与手柄方向不匹配时（如聚焦"右"手柄按上下方向键）不产生效果；手柄的 `aria-label` 走 `@lotus/locale` 的 `locale.Resizable.handleLabel(direction)`，随语言切换更新。
- 组合分栏模式：`ResizeHandler` 目前仅支持鼠标拖拽，键盘等价操作留待后续补齐（对齐 Semi 组合组件的现状——Semi 的 `ResizeHandler` 同样未提供键盘调整入口）。

## 设计变量

- `--lotus-border-width-control`、`--lotus-color-border`（容器边框、`ResizeHandler` 分隔条背景色）
- `--lotus-border-radius-small`（容器圆角）
- `--lotus-z-resizable-handler`（手柄层级）
