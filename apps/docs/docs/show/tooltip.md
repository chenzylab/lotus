---
title: Tooltip 文字提示
category: 展示类
---

简单的文字提示气泡框。

## 代码演示

### 如何引入

```tsrx
import { Tooltip } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/tooltip/basic.tsrx
```

### 位置

Tooltip 支持 12 个方向的弹出位置。

```tsrx demo
../../src/demos/show/tooltip/position.tsrx
```

### 触发时机

支持 `hover`（默认）、`click`、`focus`、`custom`、`contextMenu` 五种触发方式。

```tsrx demo
../../src/demos/show/tooltip/trigger.tsrx
```

### condition 条件触发

通过 `condition` 属性可以控制是否允许 Tooltip 触发显示。

```tsrx demo
../../src/demos/show/tooltip/condition.tsrx
```

### 受控显示

将 `trigger` 设置为 `custom` 后，`visible` 属性生效，可以完全接管显隐。

```tsrx demo
../../src/demos/show/tooltip/custom.tsrx
```

### 不显示箭头

```tsrx demo
../../src/demos/show/tooltip/no-arrow.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| autoAdjustOverflow | 弹出层被遮挡时是否自动调整方向 | boolean | true |
| children | 触发元素 | any | - |
| class | 弹出层的样式名 | string | - |
| condition | 是否允许 Tooltip 触发显示 | boolean | true |
| content | 弹出层内容 | any | - |
| getPopupContainer | 指定父级 DOM | `() => HTMLElement \| null` | `() => document.body` |
| mouseEnterDelay | 鼠标移入后延迟显示时间(ms) | number | 50 |
| mouseLeaveDelay | 鼠标移出后延迟消失时间(ms) | number | 50 |
| position | 弹出层展示位置，共 12 个值 | string | "top" |
| spacing | 弹出层与 children 元素的距离(px) | number | 8 |
| showArrow | 是否显示箭头三角形 | boolean | true |
| style | 弹出层的内联样式 | object | - |
| trigger | 触发展示的时机，可选 hover、focus、click、custom、contextMenu | string | "hover" |
| visible | 是否展示弹出层，需配合 trigger="custom" | boolean | - |
| zIndex | 弹层层级 | number | 1060 |
| onVisibleChange | 弹出层展示/隐藏时触发的回调 | `(visible: boolean) => void` | - |

> 注意事项：lotus 的 `autoAdjustOverflow` 是简化版算法（原方向空间不足且对侧空间足够则整体翻转），不支持 Semi 那种半空间独立判断，也不支持 4 种 `xxxOver` 边缘变体。lotus 尚未实现 `arrowPointAtCenter`、`clickToHide`、`disableFocusListener`、`keepDOM`、`margin`、`motion`、`prefixCls`、`preventScroll`、`rePosKey`、`stopPropagation`、`transformFromCenter`、`wrapperClassName`、`wrapperId`、`onClickOutSide`。

## Accessibility

### ARIA

- Tooltip 内容容器渲染 `role="tooltip"`。

## 设计变量

- `--lotus-color-bg-3`（Tooltip 深色背景）
- `--lotus-color-text-0`（对应文字色）
