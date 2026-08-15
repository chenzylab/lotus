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

## API 参考

### Tabs

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeKey | 当前激活的 tab 页的 itemKey 值 | string | - |
| class | 类名 | string | - |
| defaultActiveKey | 初始化选中的 tab 页的 key 值 | string | 未传时使用首个非 disabled 项 |
| keepDOM | 是否渲染隐藏面板的 DOM 结构 | boolean | true |
| lazyRender | 懒渲染，仅当面板激活过才被渲染在 DOM 树中 | boolean | false |
| size | 尺寸，可选 small、medium、large | string | "large" |
| style | 样式对象 | object | - |
| tabList | 标签页对象组成的数组 | `TabItem[]` | - |
| tabPosition | tab 的位置，支持 top（水平）、left（垂直） | string | "top" |
| type | 标签栏的样式，可选 line、card、button | string | "line" |
| onChange | 切换 tab 页时的回调函数 | `(activeKey: string) => void` | - |
| onTabClick | 单击事件 | `(activeKey: string, event: MouseEvent) => void` | - |
| onTabClose | 关闭 tab 页时的回调函数 | `(itemKey: string) => void` | - |

### TabItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| itemKey | 对应 activeKey | string | - |
| tab | 标签页栏显示文字 | any | - |
| disabled | 标签页栏是否禁用 | boolean | false |
| closable | 允许关闭 tab | boolean | false |
| icon | 标签页栏 icon | any | - |
| render | 面板内容渲染函数 | `() => any` | - |

> 注意事项：lotus 只支持 `tabList` 数组式写法，无 Semi 的 `<TabPane>` children 式写法（Ripple 没有 children 反射能力）；`type` 只有 `line`/`card`/`button` 三种（无 `slash`）；未实现 `collapsible`（滚动折叠/自动溢出检测）、`more`（收入下拉）、`tabBarExtraContent`、`renderTabBar`、`renderArrow` 等高级特性，也没有独立的 `TabPane` 导出组件。

## Accessibility

### ARIA

- 标签栏容器渲染 `role="tablist"`，每个标签渲染 `role="tab"` 及 `aria-selected`/`aria-disabled`，对应面板渲染 `role="tabpanel"`。

### 键盘和焦点

- 支持方向键（`ArrowLeft`/`ArrowRight`）在启用的标签间循环切换并跳过 disabled 项，`Enter`/`Space` 激活当前聚焦标签。

## 设计变量

- `--lotus-color-primary`（激活态下划线/背景色）
- `--lotus-color-border`（card 类型边框色）
