---
title: Dropdown 下拉菜单
category: 展示类
---

向下弹出的菜单。

## 代码演示

### 如何引入

```tsrx
import { Dropdown, DropdownMenu, DropdownItem, DropdownTitle, DropdownDivider } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/dropdown/basic.tsrx
```

### 嵌套使用

通过 `DropdownTitle` 和 `DropdownDivider` 可以对菜单项分组。

```tsrx demo
../../src/demos/show/dropdown/nested.tsrx
```

### 弹出位置

```tsrx demo
../../src/demos/show/dropdown/position.tsrx
```

### 触发方式

```tsrx demo
../../src/demos/show/dropdown/trigger.tsrx
```

### 触发事件

```tsrx demo
../../src/demos/show/dropdown/event.tsrx
```

## API 参考

### Dropdown

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| autoAdjustOverflow | 弹出层被遮挡时是否自动调整方向 | boolean | true |
| children | 触发弹出层的 Trigger 元素 | any | - |
| class | 下拉弹层外层样式类名 | string | - |
| closeOnEsc | 在 trigger 或弹出层按 Esc 键是否关闭面板 | boolean | true |
| getPopupContainer | 指定父级 DOM | `() => HTMLElement \| null` | - |
| position | 弹出菜单的位置 | string | "bottom" |
| render | 弹出层的内容，由 DropdownMenu 及 DropdownItem、DropdownTitle 构成 | any | - |
| spacing | 弹出层与 Trigger 元素的距离(px) | number | 透传给 Popover 默认逻辑 |
| style | 弹出层内联样式 | object | - |
| trigger | 触发下拉的行为 | string | "hover" |
| visible | 是否显示菜单，需配合 trigger="custom" | boolean | - |
| zIndex | 弹出层 z-index 值 | number | 1050 |
| onVisibleChange | 弹出层显示状态改变时的回调 | `(visible: boolean) => void` | - |

### DropdownMenu

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 下拉弹层菜单包裹的子元素，一般为 DropdownItem 或 DropdownTitle | any | - |
| class | 下拉弹层菜单样式类名 | string | - |
| style | 下拉弹层菜单样式 | object | - |

### DropdownItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| active | 当前项是否处于激活态 | boolean | false |
| children | 菜单项内容 | any | - |
| class | 样式类名 | string | - |
| disabled | 是否禁用菜单 | boolean | false |
| icon | 图标 | any | - |
| style | 内联样式 | object | - |
| type | 类型，可选 primary、secondary、tertiary、warning、danger | string | "tertiary" |
| onClick | 单击触发的回调事件 | `(event: MouseEvent) => void` | - |
| onMouseEnter | MouseEnter 触发的回调事件 | `(event: MouseEvent) => void` | - |
| onMouseLeave | MouseLeave 触发的回调事件 | `(event: MouseEvent) => void` | - |
| onContextMenu | 点击鼠标右键触发的回调事件 | `(event: MouseEvent) => void` | - |

### DropdownTitle

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 标题内容 | any | - |
| class | 样式类名 | string | - |
| style | 内联样式 | object | - |

### DropdownDivider

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 样式类名 | string | - |
| style | 内联样式 | object | - |

> 注意事项：lotus 不支持 Semi 的 `menu`（JSON Array 快速配置）prop，需用组合式 `DropdownMenu` + `DropdownItem` 等写法（如需数组驱动菜单可自行 `.map()` 生成 `DropdownItem` 数组传入 `render`）。无 `showTick`（active 项左侧勾选图标，`active` 只影响背景色和字重）。lotus 的 Dropdown 内部完全复用 Popover 的浮层能力，无独立 Foundation。未实现 `contentClassName`、`disableFocusListener`、`margin`、`rePosKey`、`stopPropagation`、`onClickOutSide`、`onEscKeyDown`。

## Accessibility

### ARIA

- `DropdownMenu` 渲染为 `role="menu"` `aria-orientation="vertical"`；`DropdownItem` 禁用时携带 `aria-disabled="true"`。

## 设计变量

- `--lotus-color-bg-1`（菜单背景色）
- `--lotus-color-fill-0`（菜单项 hover 底色）
- `--lotus-shadow-elevated`（菜单阴影）
