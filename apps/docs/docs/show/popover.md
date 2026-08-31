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

### 箭头指向

`arrowPointAtCenter`（默认 `true`）控制小三角是否指向触发元素中心；仅 `showArrow=true` 且 `position` 为 `top`/`bottom`/`left`/`right`（居中方向）时有意义——边缘对齐方向（如 `topLeft`）箭头位置固定在角落，不受这个 prop 影响。

```tsrx demo
../../src/demos/show/popover/arrow-point-at-center.tsrx
```

### 点击外部与 Esc 回调

```tsrx demo
../../src/demos/show/popover/click-outside.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| arrowPointAtCenter | "小三角"是否指向触发元素中心，需同时传 `showArrow=true` | boolean | `true` |
| autoAdjustOverflow | 是否自动调整弹出层展开方向 | boolean | true |
| children | 触发元素 | any | - |
| class | 弹出层的样式名 | string | - |
| clickToHide | 点击弹出层及内部任一元素时是否自动关闭 | boolean | `false` |
| closeOnEsc | 在 trigger 或弹出层按 Esc 键是否关闭面板 | boolean | true |
| condition | 是否允许 Popover 触发显示 | boolean | true |
| content | 显示的内容 | any | - |
| disableFocusListener | `trigger="hover"` 时是否不响应键盘聚焦触发浮层显示 | boolean | `false` |
| getPopupContainer | 指定父级 DOM | `() => HTMLElement \| null` | `() => document.body` |
| guardFocus | 焦点处于浮层内时，Tab/Shift+Tab 是否在浮层内首尾元素间循环 | boolean | `true` |
| keepDOM | 关闭时是否保留内部 DOM 不销毁 | boolean | `false` |
| mouseEnterDelay | 鼠标移入后延迟显示时间(ms) | number | 50 |
| mouseLeaveDelay | 鼠标移出后延迟消失时间(ms) | number | 50 |
| position | 方向，共 12 个值 | string | "bottom" |
| rePosKey | 更新该值可手动触发浮层重新定位 | string \| number | - |
| returnFocusOnClose | 关闭后焦点是否回到触发元素（仅 `trigger` 为 `hover`/`focus`/`click` 时生效） | boolean | `true` |
| spacing | 弹出层与 children 元素的距离(px) | number | 未传时按 `showArrow ? 10 : 4` 解析 |
| showArrow | 是否显示小三角 | boolean | false |
| stopPropagation | 是否阻止弹出层上的点击事件冒泡 | boolean | `false` |
| style | 弹出层的内联样式 | object | - |
| trigger | 触发方式 | string | "hover" |
| visible | 是否显示，配合 trigger="custom" | boolean | - |
| zIndex | 弹出层 z-index 值 | number | 1030 |
| onClickOutSide | 浮层展示时，点击非 children、非浮层内部区域的回调（`trigger` 为 `custom`/`click`/`contextMenu` 时有效） | `(event: MouseEvent) => void` | - |
| onEscKeyDown | 在 trigger 或弹出层按 Esc 键时调用（不受 `closeOnEsc` 影响，即使不关闭也会触发） | `(event: KeyboardEvent) => void` | - |
| onVisibleChange | 弹出层展示/隐藏时触发的回调 | `(visible: boolean) => void` | - |

> 注意事项：内容角色（role）会根据 `trigger` 动态判定——`trigger` 为 `click`/`custom` 时渲染 `role="dialog"`，其余情况渲染 `role="tooltip"`，对齐 Semi 的 a11y 语义。`content` 不支持函数式 `({ initialFocusRef }) => ReactNode` 写法（无 `initialFocusRef` 焦点初始化机制）；`margin`（object 类型的溢出冗余值）暂未实现，均属已知简化，非文档遗漏。

## Accessibility

### ARIA

- `trigger="click"` 或 `trigger="custom"` 时浮层渲染 `role="dialog"`，其余触发方式渲染 `role="tooltip"`。

### 键盘和焦点

- 默认 `closeOnEsc` 为 `true`：非受控模式下按 Esc 关闭浮层，且关闭后触发元素重新获得焦点。
- 默认 `guardFocus` 为 `true`：焦点处于浮层内时，Tab/Shift+Tab 在浮层内首尾可聚焦元素间循环，不会跳出浮层。
- 默认 `returnFocusOnClose` 为 `true`：无论通过哪种路径关闭（Esc、点击外部、`onVisibleChange` 驱动的受控关闭），焦点都会回到触发元素（`trigger="custom"` 除外——真源在外部，由调用方自行决定）。

## 设计变量

- `--lotus-color-bg-1`（浮层背景色）
- `--lotus-color-border`（浮层边框色）
- `--lotus-shadow-elevated`（浮层阴影）
