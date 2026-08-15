---
title: Breadcrumb 面包屑
category: 导航类
---

面包屑是用户界面中的一种辅助导航，可以显示当前页面在层级架构中的位置，并能返回之前的页面。

## 代码演示

### 如何引入

```tsrx
import { Breadcrumb } from '@lotus/ripple';
```

### 基本用法

lotus 只支持 `routes` 声明式数组模式——Ripple 没有 children 反射能力，做不到 Semi 的 `<Breadcrumb.Item>` children 模式，这是在 Ripple 约束下的诚实设计取舍（`routes` 模式本身也是 Semi 官方推荐且完整支持的用法）。

```tsrx demo
../../src/demos/navigation/breadcrumb/basic.tsrx
```

### 带图标的

支持标题只显示图标或者同时显示图标和文本。

```tsrx demo
../../src/demos/navigation/breadcrumb/with-icon.tsrx
```

### 尺寸

默认为紧凑（`compact`），设置为 `false` 可使图标和文字尺寸增加。

```tsrx demo
../../src/demos/navigation/breadcrumb/size.tsrx
```

### 自定义的分隔符

默认为 `/`。

```tsrx demo
../../src/demos/navigation/breadcrumb/separator.tsrx
```

### 截断逻辑

当级别名字溢出设定宽度后省略截断，可以通过 `showTooltip` 属性设置相关参数。默认宽度 150px，鼠标悬停时显示 Tooltip 完整显示级别名称。

```tsrx demo
../../src/demos/navigation/breadcrumb/truncate.tsrx
```

当路径层级超过 4 个级别，则：第二层至倒数第三层省略，点击省略号展开显示全部级别。可以通过 `maxItemCount` 来控制超过多少个级别进行折叠。

```tsrx demo
../../src/demos/navigation/breadcrumb/collapse.tsrx
```

### 自定义省略号区域

组件内部提供了两种省略号区域渲染的类型，可通过 `moreType` 来设置，`moreType` 的可选值为 `default` 和 `popover`。

```tsrx demo
../../src/demos/navigation/breadcrumb/more-type.tsrx
```

如果想要为省略号区域自定义其他形式的渲染，则可以使用 `renderMore` 方法。

```tsrx demo
../../src/demos/navigation/breadcrumb/render-more.tsrx
```

### 路由对象

Breadcrumb 支持通过 `routes` 传入路由对象 `{ name, path, href, icon }` 或字符串组成的数组。可以配合 `renderItem` 来渲染节点。通过这样实现的 Breadcrumb 同样会进行截断处理。

- `name` 为展示的名称，不传入时为空字符串。当 route 为字符串时，默认将字符串设置为名称。
- `path` 为路由路径。
- `href` 为链接目的地，挂载在 `<a>` 标签上。
- `icon` 为标签的显示图标。

```tsrx demo
../../src/demos/navigation/breadcrumb/route-object.tsrx
```

## API 参考

### Breadcrumb

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| routes | 路由信息，由路由对象或字符串组成的数组 | `Array<Route \| string>` | - |
| autoCollapse | 是否超出 maxItemCount 后自动折叠 | boolean | `true` |
| compact | 显示尺寸，是否紧凑 | boolean | `true` |
| maxItemCount | 超出多少个进行自动折叠 | number | `4` |
| moreType | 内置的省略号区域的渲染类型，可选值为 `default`、`popover` | string | `'default'` |
| renderMore | 自定义省略号区域的渲染 | `(restRoutes: Route[]) => any` | - |
| renderItem | 自定义链接函数，配合 routes 使用 | `(route: Route) => any` | - |
| separator | 自定义的分隔符 | any | `'/'` |
| showTooltip | 是否展示 Tooltip 及相关配置：`width` 溢出宽度，`ellipsisPos` 截断方式（`end`/`middle`） | `boolean \| { width?: number \| 'auto'; ellipsisPos?: 'end' \| 'middle' }` | `true`（150px，`end`） |
| style | 内联样式 | object | - |
| class | 类名 | string | - |
| aria-label | 面包屑的无障碍标签 | string | `'面包屑导航'` |
| onClick | 单击事件 | `(route: Route, e: MouseEvent) => void` | - |

### Route

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| name | 路由名 | string | - |
| path | 路由路径 | string | - |
| href | 链接目的地 | string | - |
| icon | 标签的显示图标（组件函数） | any | - |

## Accessibility

- Breadcrumb 支持传入 `aria-label` 来表示该 Breadcrumb 的作用，默认值为"面包屑导航"。
- Breadcrumb 会对当前项（最后一级）设置 `aria-current="page"`。
- 省略号触发按钮带 `role="button"`、`tabIndex={0}` 与 `aria-label`，支持键盘 Enter 触发展开。

## 设计变量

- `--lotus-color-text-2`（普通路由项文字色）
- `--lotus-color-text-0`（当前项文字色）
- `--lotus-color-text-3`（分隔符颜色）
- `--lotus-color-primary`（hover 态文字色）
