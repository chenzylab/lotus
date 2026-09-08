---
title: Tabs 标签页
category: 导航类
---

选项卡切换组件。

## 代码演示

### 如何引入

```tsrx
import { Tabs } from '@lotus/ripple';
```

### 基本用法

Tabs 数据通过 `tabList` 数组声明，每一项对应一个 `TabItem`。

```tsrx demo
../../src/demos/navigation/tabs/basic.tsrx
```

### 带图标的

```tsrx demo
../../src/demos/navigation/tabs/icon.tsrx
```

### 样式类型

Tabs 提供三种样式类型：`line`（默认，下划线）、`card`（卡片）、`button`（按钮）。

```tsrx demo
../../src/demos/navigation/tabs/type.tsrx
```

### 垂直的标签栏

设置 `tabPosition="left"` 可切换为垂直标签栏。

```tsrx demo
../../src/demos/navigation/tabs/vertical.tsrx
```

### 禁用

```tsrx demo
../../src/demos/navigation/tabs/disabled.tsrx
```

### 关闭

设置 `closable` 并监听 `onTabClose` 可以支持关闭标签页；组件本身不会从 `tabList` 中删除数据，需要由外部业务代码控制。

```tsrx demo
../../src/demos/navigation/tabs/closable.tsrx
```

### TabPane 声明式写法

除 `tabList` 数组外，也可以用嵌套的 `<TabPane>` 子组件声明每个标签页（对齐 Semi `<Tabs><TabPane>` 的 JSX 嵌套视觉）。两种写法二选一，`tabList` 存在时优先生效。

```tsrx demo
../../src/demos/navigation/tabs/declarative.tsrx
```

### 溢出滚动与折叠

`collapsible` 开启后标签栏可横向滚动，放不下的标签通过两侧箭头（`arrowPosition` 控制位置）滚动查看，`showRestInDropdown`（默认开启）额外提供下拉菜单直达；`more` 强制把末尾 N 个标签收进下拉菜单。

```tsrx demo
../../src/demos/navigation/tabs/overflow.tsrx
```

## API 参考

### Tabs

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeKey | 当前激活的 tab 页的 itemKey 值 | string | - |
| aria-label | 设置 aria-label 属性 | string | - |
| arrowPosition | 溢出滚动箭头的位置 | `'start' \| 'end' \| 'both'` | `'end'` |
| children | `<TabPane>` 声明式子组件写法（与 `tabList` 二选一） | any | - |
| class | 类名 | string | - |
| collapsible | tab 栏放不下时是否可横向滚动折叠；`'auto'` 由 ResizeObserver 自动检测换行/溢出 | `boolean \| 'auto'` | `false` |
| contentStyle | 内容区自定义样式 | object | - |
| defaultActiveKey | 初始化选中的 tab 页的 key 值 | string | 未传时使用首个非 disabled 项 |
| dropdownProps | 透传给溢出下拉菜单内部 Dropdown 的额外配置 | object | - |
| keepDOM | 是否渲染隐藏面板的 DOM 结构 | boolean | true |
| lazyRender | 懒渲染，仅当面板激活过才被渲染在 DOM 树中 | boolean | false |
| more | 强制把末尾 N 个标签收进下拉菜单；数字或 `{ count, render? }` 对象 | `number \| { count: number; render?: () => any }` | - |
| renderArrow | 自定义溢出滚动箭头渲染 | `(direction: 'start' \| 'end', onClick: () => void) => any` | - |
| showRestInDropdown | 折叠态下滚动隐藏的标签是否额外提供下拉菜单直达 | boolean | `true` |
| size | 尺寸，可选 small、medium、large | string | "large" |
| style | 样式对象 | object | - |
| tabBarClassName | tab 栏自定义类名 | string | - |
| tabBarExtraContent | tab 栏右侧额外内容，常用于放置操作按钮 | any | - |
| tabBarStyle | tab 栏自定义样式 | object | - |
| tabList | 标签页对象组成的数组（与 `children` 二选一） | `TabItem[]` | - |
| tabPaneMotion | 切换面板时是否带过渡动画 | boolean | `true` |
| tabPosition | tab 的位置，支持 top（水平）、left（垂直） | string | "top" |
| preventScroll | 键盘方向导航切换焦点时是否阻止浏览器自动滚动到目标 tab | boolean | `false` |
| type | 标签栏的样式，可选 line、card、button | string | "line" |
| onChange | 切换 tab 页时的回调函数 | `(activeKey: string) => void` | - |
| onTabClick | 单击事件 | `(activeKey: string, event: MouseEvent) => void` | - |
| onTabClose | 关闭 tab 页时的回调函数 | `(itemKey: string) => void` | - |
| onVisibleTabsChange | 可见/折叠 tab 集合变化时的回调 | `(visibleKeys: Set<string>) => void` | - |

### TabItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| itemKey | 对应 activeKey | string | - |
| tab | 标签页栏显示文字 | any | - |
| disabled | 标签页栏是否禁用 | boolean | false |
| closable | 允许关闭 tab | boolean | false |
| icon | 标签页栏 icon | any | - |
| render | 面板内容渲染函数 | `() => any` | - |

### TabPane

`<TabPane itemKey title icon disabled closable>` props 与 `TabItem` 基本一致，`children` 即面板内容（替代 `TabItem.render`）。

> 实现说明：`collapsible` 对齐 Semi TabBar `renderMode="scroll"` 语义——tab 栏本身可横向滚动，箭头把滚动位置移动到下一个隐藏项，不是把溢出项摘掉塞进下拉菜单隐藏（`showRestInDropdown` 是额外补充的直达入口，两者独立生效）。`TabPane` 通过 Context 注册模式实现（同 `Anchor` 的 `AnchorLink`）：mount 时把自己的元数据注册进 `Tabs` 的状态表，已知限制同 `AnchorLink`——多个顶层 `TabPane` 兄弟之间的相对顺序取决于各自注册的时序，不保证与 JSX 书写顺序完全一致。`renderTabBar`（完全自定义 tab 栏整体渲染）明确不做：Ripple 无法传递组件构造函数作为参数，只能传已渲染结果，与该 API 的设计意图冲突。

## Accessibility

### ARIA

- 标签栏容器渲染 `role="tablist"`，每个标签渲染 `role="tab"` 及 `aria-selected`/`aria-disabled`，对应面板渲染 `role="tabpanel"`。

### 键盘和焦点

- 支持方向键（`ArrowLeft`/`ArrowRight`）在启用的标签间循环切换并跳过 disabled 项，`Enter`/`Space` 激活当前聚焦标签。

## 设计变量

- `--lotus-color-primary`（激活态下划线/背景色）
- `--lotus-color-border`（card 类型边框色）
