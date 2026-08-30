---
title: DragMove 拖拽移动
category: 基础
---

用于设置元素可被拖拽改变位置，支持限制拖拽范围、自定义拖拽把手。

## 代码演示

### 如何引入

```tsrx
import { DragMove } from '@lotus/ripple';
```

### 基本用法

`DragMove` 包裹的元素默认可通过鼠标/触摸拖拽改变位置，内部用 `position: absolute` 定位（`positionStrategy` 可设为 `'relative'` 保留元素原有布局位置）。

```tsrx demo
../../src/demos/basic/drag-move/basic.tsrx
```

### 限制拖拽范围

传入 `constrainer="parent"` 将拖拽范围限制在父元素内（父元素需要非 `static` 定位，本例用 `position: relative`）；也可传入函数自定义约束容器。

```tsrx demo
../../src/demos/basic/drag-move/constrainer.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| allowInputDrag | input/textarea 上点击时是否仍允许触发拖拽 | boolean | `false` |
| allowMove | 拖拽发起前的谓词，返回 `false` 时本次不进入拖拽态 | `(event: MouseEvent \| TouchEvent, element: HTMLElement) => boolean` | 无 |
| children | 被包裹的可拖拽内容 | any | 无 |
| class | 类名 | string | 无 |
| constrainer | 约束容器：`'parent'` 取父元素，或自定义函数返回目标元素 | `(() => HTMLElement \| null) \| 'parent'` | 无（不设边界） |
| customMove | 自定义位置写入逻辑；不传则组件直接写 `style.top`/`style.left` | `(element: HTMLElement, top: number, left: number) => void` | 无 |
| handler | 拖拽把手；不传时整个元素都可拖拽 | `() => HTMLElement \| null` | 无 |
| positionStrategy | 定位策略 | `'absolute'` \| `'relative'` | `'absolute'` |
| style | 自定义样式 | object | 无 |
| onMouseDown / onMouseMove / onMouseUp | 鼠标事件回调（在内部处理逻辑之外额外触发） | `(event: MouseEvent) => void` | 无 |
| onTouchStart / onTouchMove / onTouchEnd / onTouchCancel | 触摸事件回调 | `(event: TouchEvent) => void` | 无 |

## Accessibility

- `DragMove` 只负责坐标计算与样式写入，不渲染任何具备语义的容器元素本身（渲染出的 `<div class="lotus-drag-move">` 无 ARIA role）；拖拽操作依赖鼠标/触摸事件，未提供键盘等价操作。若被拖拽的内容承载了需要键盘可达的交互，应在其内部自行补充键盘处理逻辑。

## 设计变量

`DragMove` 组件本身不含 `<style>` 块，不消费任何 `--lotus-*` Token；拖拽内容的视觉样式（如本文档示例中的背景色、圆角）由调用方自行决定。
