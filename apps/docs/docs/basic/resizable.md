---
title: Resizable 可调整大小
category: 基础
---

8 方向可调整大小容器。拖拽算法（方向-delta 计算、边界约束、宽高比锁定）在 `ResizableFoundation` 里自研实现。

## 代码演示

### 如何引入

```tsrx
import { Resizable } from '@lotus/ripple';
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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 可访问名称 | string | 无 |
| children | 容器内容 | any | 无 |
| class | 类名 | string | 无 |
| defaultHeight | 非受控模式下的初始高度 | number | `200` |
| defaultWidth | 非受控模式下的初始宽度 | number | `320` |
| enable | 启用的手柄方向子集；不传则 8 方向全部启用 | `ResizeDirection[]` | 无 |
| height | 受控高度（需与 `width` 同时提供才生效） | number | 无 |
| lockAspectRatio | 是否锁定宽高比 | boolean | `false` |
| maxHeight | 最大高度 | number | `Infinity` |
| maxWidth | 最大宽度 | number | `Infinity` |
| minHeight | 最小高度 | number | `0` |
| minWidth | 最小宽度 | number | `0` |
| style | 自定义样式 | object | 无 |
| width | 受控宽度（需与 `height` 同时提供才生效） | number | 无 |
| onChange | 尺寸变化时的回调（拖拽/键盘调整过程中持续触发） | `(size: { width: number; height: number }, direction: ResizeDirection) => void` | 无 |
| onResizeEnd | 拖拽结束时的回调 | `(size: { width: number; height: number }, direction: ResizeDirection) => void` | 无 |
| onResizeStart | 拖拽开始时的回调 | `(direction: ResizeDirection) => void` | 无 |

`ResizeDirection` 取值：`'top'` \| `'right'` \| `'bottom'` \| `'left'` \| `'topRight'` \| `'bottomRight'` \| `'bottomLeft'` \| `'topLeft'`。

## Accessibility

- 每个手柄携带 `role="button"`、`tabIndex={0}`，可通过 Tab 依次聚焦。
- 聚焦手柄后可用方向键调整对应方向的尺寸（每次步进 10px），是鼠标拖拽之外的键盘等价操作；方向键与手柄方向不匹配时（如聚焦"右"手柄按上下方向键）不产生效果。
- 手柄的 `aria-label` 走 `@lotus/locale` 的 `locale.Resizable.handleLabel(direction)`，随语言切换更新。

## 设计变量

- `--lotus-border-width-control`、`--lotus-color-border`（容器边框）
- `--lotus-border-radius-small`（容器圆角）
- `--lotus-z-resizable-handler`（手柄层级）
