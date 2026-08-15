---
title: Nav 导航
category: 导航类
---

为页面和功能提供导航的菜单列表。

## 代码演示

### 如何引入

```tsrx
import { Nav } from '@lotus/ripple';
```

### 基本使用

通过传递 `items` 参数，你能够快速得到一个导航栏。

每个导航项目包括：

- `itemKey`：导航项目的唯一标识（必须）
- `text`：导航文案
- `icon`：导航图标

参数含义详见 [NavItem](#NavItem) 或 [NavSub](#NavSub)。

开发者可能会经常定义 Logo 区域和收起按钮区域，Nav 则提供了这样的容器方便开发者快速定义导航头部和底部，你仅需按要求传入 `header` 或 `footer` 即可。

对于 `footer`，lotus 额外封装了一个收起功能按钮，开发者可以通过传递 `collapseButton = true` 开启此功能，不过该参数仅在 `mode = "vertical"`（垂直导航）生效。

参数详见 [NavHeader](#NavHeader) 和 [NavFooter](#NavFooter)。

```tsrx demo
../../src/demos/navigation/navigation/basic.tsrx
```

### 导航样式定义

Nav 目前提供了两个参数用于定义导航样式：`style` 和 `bodyStyle`，其中 `style` 用于定义导航组件最外层的样式，而 `bodyStyle` 用于定义导航列表的样式（导航头部和导航底部则都接受各自的 `style` 参数）。

例如你需要一个中间列表可以滚动，导航头部和底部固定的导航组件，可以这么使用：

```tsrx demo
../../src/demos/navigation/navigation/style.tsrx
```

### JSX 写法

可以使用 JSX 写法定义导航头部、导航项以及导航底部。lotus 版本用独立命名导出的 `NavHeader`/`NavItem`/`NavSub`/`NavFooter` 组件替代 Semi 的 `<Nav.Header>`/`<Nav.Item>`/`<Nav.Sub>`/`<Nav.Footer>` 静态属性写法——Ripple 没有 children 反射能力，无法在运行时给 `Nav` 函数挂载子组件，这是 Ripple 约束下的诚实设计取舍。这几个子组件通过 Context 与外层 `<Nav>` 通信，必须渲染在 `<Nav>` 内部，不能独立使用；且 children 模式下选中项不会自动展开祖先 SubNav（这份联动依赖 `items` 数组结构计算，children 模式没有这份结构化数据），仅支持基础的选中/展开/点击。

```tsrx demo
../../src/demos/navigation/navigation/jsx.tsrx
```

### 配合 react-router 等路由组件

为了在使用 react-router 等路由组件时，能将导航项包裹在路由组件提供的 Link 或者 NavLink 中来让用户点击导航项时候触发路由组件的点击事件，我们需要自定义渲染。

使用 `renderWrapper` 在每个导航项外包裹自定义导航组件。lotus 不依赖具体的路由库，下面用原生 `<a>` 标签模拟这种包裹方式，实际集成时把 `<a>` 换成对应路由库的 Link 组件即可。

```tsrx demo
../../src/demos/navigation/navigation/router.tsrx
```

### 垂直与水平布局

Nav 目前提供两种方向的导航：

- 垂直布局（默认）`mode = "vertical"`
- 水平布局 `mode = "horizontal"`

特别注意的是，有一些功能（参数）仅在 `mode = "vertical"` 时有效：

- `isCollapsed`（导航收起到侧边）
- `defaultOpenKeys` | `openKeys`（指定默认的以及受控的展开子导航项 key 数组，这个参数仅在 `mode = "vertical"` 且 `isCollapsed = false` 有效）
- `NavFooter` 的 `collapseButton` 收起侧边栏功能按钮

#### 垂直布局

```tsrx demo
../../src/demos/navigation/navigation/vertical.tsrx
```

#### 水平布局

```tsrx demo
../../src/demos/navigation/navigation/horizontal.tsrx
```

#### 水平加垂直

一般的平台设计会采取水平加垂直导航的模式，这里有一个比较常见的例子。

```tsrx demo
../../src/demos/navigation/navigation/horizontal-vertical.tsrx
```

### 展开收起箭头位置

可通过 `toggleIconPosition` 改变 NavSub 展开收起箭头的位置，默认为 `right` 右侧展示，可改为 `left`。

```tsrx demo
../../src/demos/navigation/navigation/toggle-icon-position.tsrx
```

### 导航缩进

默认导航缩进目前仅对第一级导航有效果。如果你希望对多级导航，按层级缩进，请先将 `limitIndent` 设置为 `false`（只在竖直方向生效）：

- 当以 JSX 方式用 `NavItem` 传入导航项时，请手动给 `NavItem` 传入 `level` props。
- 以 `items` 方式传入导航项时，无需关心 `level`。

```tsrx demo
../../src/demos/navigation/navigation/indent.tsrx
```

### 非受控属性

包括：

- `defaultSelectedKeys`（默认被选中的导航项 `key` 数组）
- `defaultOpenKeys`（默认展开的导航项 `key` 数组，仅 `mode = "vertical"` 且 `isCollapsed` | `defaultIsCollapsed = false` 的情况下有效）
- `defaultIsCollapsed`（侧边栏默认是否收起，仅 `mode = "vertical"` 时有效）

```tsrx demo
../../src/demos/navigation/navigation/uncontrolled.tsrx
```

### 受控属性

Nav 组件提供了几个受控属性，配合各种回调，可以很轻松地控制导航。

目前受控的属性为：

- `isCollapsed`（侧边栏是否收起，仅 `mode = "vertical"` 时生效）
- `selectedKeys`（当前选中的导航项 `key` 数组）
- `openKeys`（当前展开的导航项数组，仅 `mode = "vertical"` 且 `isCollapsed = false` 有效）

对应的回调为：

- `onCollapseChange(isCollapsed: boolean): void`
- `onSelect({ itemKey, selectedKeys, isOpen }): void`
- `onOpenChange({ itemKey, openKeys, isOpen }): void`

```tsrx demo
../../src/demos/navigation/navigation/controlled.tsrx
```

## API 参考

### Nav

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bodyStyle | 导航项列表的自定义样式 | object | - |
| class | 最外层元素的样式名 | string | - |
| children | JSX 组合写法：直接传入 `NavHeader`/`NavItem`/`NavSub`/`NavFooter` 作为 children，与 `items` 二选一，同时传入时 `items` 优先 | any | - |
| defaultIsCollapsed | 默认是否处于收起状态，仅 `mode = "vertical"` 时有效 | boolean | false |
| defaultOpenKeys | 初始打开的子导航 `itemKey` 数组，仅 `mode = "vertical"` 且侧边栏处于展开状态时有效 | ItemKey[] | [] |
| defaultSelectedKeys | 初始选中的导航项 `itemKey` 数组 | ItemKey[] | [] |
| footer | 底部区域配置对象，详见 [NavFooter](#NavFooter) | object | - |
| header | 头部区域配置对象，详见 [NavHeader](#NavHeader) | object | - |
| isCollapsed | 是否处于收起状态的受控属性，仅 `mode = "vertical"` 时有效 | boolean | - |
| items | 导航项目列表，每一项可以继续带有 items 属性。如果为 string 数组，则会取每一项作为 text 和 itemKey | `NavItemInput[]` | - |
| limitIndent | 解除缩进限制，可使用 level 自定义导航项缩进，水平模式只能为 true | boolean | true |
| mode | 导航类型，目前支持横向与竖直，可选值：`vertical`或`horizontal` | string | `vertical` |
| openKeys | 受控的打开的子导航 `itemKey` 数组，配合 `onOpenChange` 回调控制子导航项展开，仅 `mode = "vertical"` 且侧边栏处于展开状态时有效 | ItemKey[] | - |
| renderItem | 自定义单个节点渲染，返回值替换默认的 NavItem/NavSub 渲染 | `(item, level) => any` | - |
| renderWrapper | 自定义导航项外层组件 | `(data) => any` | - |
| selectedKeys | 受控的导航项 `itemKey` 数组，配合 `onSelect` 回调控制导航项选择 | ItemKey[] | - |
| style | 最外层元素的自定义样式 | object | - |
| toggleIconPosition | 带有子导航项的父级导航项箭头位置，可选 `left` 或 `right` | string | `right` |
| onClick | 点击任意导航项时触发 | `({ itemKey, isOpen }) => void` | - |
| onCollapseChange | 收起状态变化时的回调 | `(isCollapsed) => void` | - |
| onOpenChange | 切换某个子导航项目显隐状态时触发 | `({ itemKey, openKeys, isOpen }) => void` | - |
| onSelect | 选中某个可选中导航项目时触发 | `({ itemKey, selectedKeys, isOpen }) => void` | - |

### NavItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| disabled | 是否禁用 | boolean | false |
| icon | 导航项目图标 | any | - |
| indent | 如果 icon 为空，是否保留其占位，仅对一级导航生效 | boolean | false |
| itemKey | 导航项目唯一 key | ItemKey | - |
| level | 当前项所在嵌套层级，limitIndent 为 true 时，用于自定义缩进位置 | number | - |
| link | 导航项 href 链接，传入时导航项整体会包裹一个 a 标签 | string | - |
| linkOptions | 透传给 a 标签的参数 | object | - |
| text | 导航项目文案或元素 | any | - |
| onMouseEnter | mouse enter 时触发 | `(event) => void` | - |
| onMouseLeave | mouse leave 时触发 | `(event) => void` | - |

### NavSub

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| disabled | 是否禁用 | boolean | false |
| icon | 导航项目图标 | any | - |
| indent | 如果 icon 为空，是否保留其占位，仅对一级导航生效 | boolean | false |
| itemKey | 导航项目唯一 key | ItemKey | - |
| level | 当前项所在嵌套层级，limitIndent 为 true 时，用于自定义缩进位置 | number | 0 |
| maxHeight | 最大高度 | number | 999 |
| text | 导航项目文案或组件 | any | - |
| onMouseEnter | mouse enter 时触发 | `(event) => void` | - |
| onMouseLeave | mouse leave 时触发 | `(event) => void` | - |

### NavHeader

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 子元素 | any | - |
| class | 最外层样式名 | string | - |
| link | 导航项 href 链接，传入时导航项整体会包裹一个 a 标签 | string | - |
| linkOptions | 透传给 a 标签的参数 | object | - |
| logo | Logo | any | - |
| style | 最外层样式 | object | - |
| text | Logo 文案 | any | - |

### NavFooter

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 子元素 | any | - |
| class | 最外层样式名 | string | - |
| collapseButton | 是否展示底部"收起侧边栏"按钮，`mode="vertical"` 且 `children` 参数为空才有效果 | boolean | false |
| collapseText | "收起"按钮的文案 | `(collapsed) => any` | - |
| style | 最外层样式 | object | - |
| onClick | 点击事件回调 | `(event) => void` | - |

## Accessibility

### 键盘和焦点

- Nav 内的每个可点击 item 都可以被聚焦，相互之间使用 `Tab` 及 `Shift + Tab` 切换焦点，并且可以通过 `Enter` 键激活每个链接
- 键盘交互暂未完整支持嵌套场景

## 文案规范

- 导航栏菜单使用句子大小写格式
- 尽量精简

## 设计变量

- `--lotus-color-fill-0`（导航项 hover 底色）
- `--lotus-color-primary-light-default`（导航项选中底色）
- `--lotus-color-primary`（导航项选中文字色）
- `--lotus-color-disabled-text`（禁用项文字色）
- `--lotus-color-border`（分隔线颜色）
