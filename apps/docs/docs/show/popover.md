---
title: Popover 气泡卡片
category: 展示类
---

点击/鼠标移入元素，弹出气泡式的卡片浮层。

## 代码演示

### 如何引入

```tsrx
import { Popover } from '@lotus/ripple';
```

### 基本使用

```tsrx demo
../../src/demos/show/popover/basic.tsrx
```

### 弹出位置

```tsrx demo
../../src/demos/show/popover/position.tsrx
```

### 受控显示

将 `trigger` 设置为 `custom` 后，`visible` 属性生效。

```tsrx demo
../../src/demos/show/popover/controlled.tsrx
```

### condition 条件触发

```tsrx demo
../../src/demos/show/popover/condition.tsrx
```

### 显示小三角

```tsrx demo
../../src/demos/show/popover/arrow.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| autoAdjustOverflow | 是否自动调整弹出层展开方向 | boolean | true |
| children | 触发元素 | any | - |
| class | 弹出层的样式名 | string | - |
| closeOnEsc | 在 trigger 或弹出层按 Esc 键是否关闭面板 | boolean | true |
| condition | 是否允许 Popover 触发显示 | boolean | true |
| content | 显示的内容 | any | - |
| getPopupContainer | 指定父级 DOM | `() => HTMLElement \| null` | `() => document.body` |
| mouseEnterDelay | 鼠标移入后延迟显示时间(ms) | number | 50 |
| mouseLeaveDelay | 鼠标移出后延迟消失时间(ms) | number | 50 |
| position | 方向，共 12 个值 | string | "bottom" |
| spacing | 弹出层与 children 元素的距离(px) | number | 未传时按 `showArrow ? 10 : 4` 解析 |
| showArrow | 是否显示小三角 | boolean | false |
| style | 弹出层的内联样式 | object | - |
| trigger | 触发方式 | string | "hover" |
| visible | 是否显示，配合 trigger="custom" | boolean | - |
| zIndex | 弹出层 z-index 值 | number | 1030 |
| onVisibleChange | 弹出层展示/隐藏时触发的回调 | `(visible: boolean) => void` | - |

> 注意事项：内容角色（role）会根据 `trigger` 动态判定——`trigger` 为 `click`/`custom` 时渲染 `role="dialog"`，其余情况渲染 `role="tooltip"`，对齐 Semi 的 a11y 语义。`content` 不支持函数式 `({ initialFocusRef }) => ReactNode` 写法（无 `initialFocusRef` 焦点初始化机制）。lotus 尚未实现 `arrowPointAtCenter`、`clickToHide`、`disableFocusListener`、`guardFocus`、`keepDOM`、`margin`、`rePosKey`、`returnFocusOnClose`、`stopPropagation`、`onClickOutSide`、`onEscKeyDown`。

## Accessibility

### ARIA

- `trigger="click"` 或 `trigger="custom"` 时浮层渲染 `role="dialog"`，其余触发方式渲染 `role="tooltip"`。

### 键盘和焦点

- 默认 `closeOnEsc` 为 `true`：非受控模式下按 Esc 关闭浮层，且关闭后触发元素重新获得焦点。

## 设计变量

- `--lotus-color-bg-1`（浮层背景色）
- `--lotus-color-border`（浮层边框色）
- `--lotus-shadow-elevated`（浮层阴影）
