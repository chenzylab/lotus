---
title: Layout 布局
category: 基础
---

用于快捷划分页面整体布局。

## 概述

- `Layout`：布局容器，其下可嵌套 `Header`/`Sider`/`Content`/`Footer` 或 `Layout` 本身，可以放在任何父容器中。
- `Header`：顶部布局，其下可嵌套任何元素，只能放在 `Layout` 中。
- `Sider`：侧边栏，其下可嵌套任何元素，只能放在 `Layout` 中。
- `Content`：内容部分，其下可嵌套任何元素，只能放在 `Layout` 中。
- `Footer`：底部布局，其下可嵌套任何元素，只能放在 `Layout` 中。

> 注意事项：
> 1. 布局组件采用 Flex 布局实现，无法在非现代浏览器中工作。
> 2. Layout 组件仅会帮你实现布局，但不会附带背景色、文本色、宽高度等样式。你可以根据自己实际需求传入 `style` 或给定特定 `class` 另行编写 CSS 实现。
> 3. `hasSider` 在 lotus 版本是必需的显式声明——Semi 靠 React children 反射自动检测子元素类型，Ripple 没有等价的 children 反射能力，因此这个 prop 从 Semi 文档里"一般不用指定，仅用于避免 SSR 闪动"的可选优化项，变成了必需项，这是在 Ripple 约束下的诚实设计取舍。

## 代码演示

### 如何引入

```tsrx
import { Layout, Header, Footer, Sider, Content } from '@lotus/ripple';
```

### 三行布局

```tsrx demo
../../src/demos/basic/layout/three-row.tsrx
```

### 左侧边栏布局

```tsrx demo
../../src/demos/basic/layout/left-sider.tsrx
```

### 右侧边栏布局

```tsrx demo
../../src/demos/basic/layout/right-sider.tsrx
```

### 侧边栏布局

```tsrx demo
../../src/demos/basic/layout/full-sider.tsrx
```

### 响应式布局

侧边栏预设了六个响应尺寸：`xs`、`sm`、`md`、`lg`、`xl`、`xxl`。可以通过设置 `breakpoint` 属性设置断点，通过 `onBreakpoint` 调用回调函数。

```tsrx demo
../../src/demos/basic/layout/responsive.tsrx
```

## 布局示例

### 顶部导航布局

```tsrx demo
../../src/demos/basic/layout/top-nav.tsrx
```

### 顶部导航-侧边布局

```tsrx demo
../../src/demos/basic/layout/top-side-nav.tsrx
```

### 侧边导航

```tsrx demo
../../src/demos/basic/layout/side-nav.tsrx
```

## API 参考

### Layout

> `Header`/`Footer`/`Content` API 与 `Layout` 相同。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | - |
| hasSider | 表示子元素里有 Sider。lotus 版本为必需的显式声明（详见上方说明） | boolean | false |
| style | 样式 | object | - |
| aria-label | 提升可访问性的标签描述 | string | - |
| role | ARIA role 属性 | string | - |

### Sider

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| breakpoint | 触发响应式布局的断点，可选值 `xs`、`sm`、`md`、`lg`、`xl`、`xxl` | string[] | - |
| class | 类名 | string | - |
| style | 样式 | object | - |
| onBreakpoint | 触发响应式布局断点时的回调 | `(screen: string, matched: boolean) => void` | - |
| aria-label | 提升可访问性的标签描述 | string | - |
| role | ARIA role 属性 | string | - |

### responsive map

```text
{
    xs: '(max-width: 575px)',
    sm: '(min-width: 576px)',
    md: '(min-width: 768px)',
    lg: '(min-width: 992px)',
    xl: '(min-width: 1200px)',
    xxl: '(min-width: 1600px)',
}
```

## Accessibility

### ARIA

- Sider 可传入 `aria-label` props，描述该 Sider 作用。
- Header/Content/Footer 可传入 `role`/`aria-label` 描述对应元素作用。

## 设计变量

- `--lotus-color-fill-0`（Header/Footer 常用底色示例）
- `--lotus-color-fill-2`（Sider 常用底色示例）
- `--lotus-color-border`（分隔边框颜色）
