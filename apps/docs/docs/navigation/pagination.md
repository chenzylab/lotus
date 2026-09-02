---
title: Pagination 分页
category: 导航类
---

采用分页的形式分隔长列表，每次只加载一个页面。

## 代码演示

### 如何引入

```tsrx
import { Pagination } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/navigation/pagination/basic.tsrx
```

### 完整功能

`showSizeChanger` 展示每页条数切换，`showQuickJumper` 展示快速跳转输入框，`showTotal` 展示总条数文案。

```tsrx demo
../../src/demos/navigation/pagination/full.tsrx
```

### 小尺寸与省略号截断

页码过多时中间页码用省略号折叠，hover 省略号展开完整页码列表（Popover）。

```tsrx demo
../../src/demos/navigation/pagination/small.tsrx
```

### 高级配置

`prevText`/`nextText` 自定义上一页/下一页文案；`hideOnSinglePage` 只有一页时不渲染；`hoverShowPageSelect` 配合 `size="small"` 用"当前页/总页数"紧凑文本替换数字按钮列表，hover 弹出全部页码的 Popover 选择列表。

```tsrx demo
../../src/demos/navigation/pagination/advanced.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| currentPage | 受控的当前页码 | number | - |
| defaultCurrentPage | 非受控模式下的默认页码 | number | `1` |
| disabled | 是否禁用 | boolean | `false` |
| hideOnSinglePage | 只有一页时整个组件不渲染（与 `showSizeChanger` 同时使用时不生效） | boolean | `false` |
| hoverShowPageSelect | `size="small"` 模式下用"当前页/总页数"紧凑文本替换数字按钮列表，hover 弹出全部页码的 Popover 选择列表 | boolean | `false` |
| nextText | 自定义下一页按钮文案，替换默认图标 | any | - |
| pageSize | 受控的每页条数 | number | - |
| pageSizeOpts | 每页条数可选项（`showSizeChanger` 开启时生效） | number[] | - |
| popoverPosition | 省略号 hover 展开的完整页码列表 Popover 弹出方向 | `FloatingPosition` | - |
| popoverZIndex | 省略号 hover 展开的完整页码列表 Popover 层级 | number | - |
| preventPageChangeOnPageSizeChange | 切换每页条数时是否阻止页码自动调整 | boolean | `false` |
| prevText | 自定义上一页按钮文案，替换默认图标 | any | - |
| showQuickJumper | 是否展示快速跳转输入框 | boolean | `false` |
| showSizeChanger | 是否展示每页条数切换器 | boolean | `false` |
| showTotal | 是否展示总条数文案，也可传自定义渲染函数 | `boolean \| ((total: number, range: [number, number]) => any)` | `false` |
| size | 尺寸 | `default` \| `small` | `default` |
| style | 自定义样式 | object | - |
| total | 数据总条数 | number | 必填 |
| onChange | 页码或每页条数变化时的回调 | `(currentPage: number, pageSize: number) => void` | - |
| onPageChange | 页码变化时的回调 | `(currentPage: number) => void` | - |
| onPageSizeChange | 每页条数变化时的回调 | `(pageSize: number) => void` | - |

## Accessibility

- 根容器携带 `role="navigation"`。
- 上一页/下一页按钮、每个页码按钮、跳转输入框均携带来自 `@lotus/locale` 的本地化 `aria-label`。
- 当前页码按钮携带 `aria-current="page"`。
- 省略号 hover 展开的页码列表携带 `role="list"`/`role="listitem"`。

## 设计变量

- `--lotus-color-bg-1`（默认背景）
- `--lotus-color-fill-0`（hover 态背景）
- `--lotus-color-primary` / `-primary-hover`（当前页背景色）
- `--lotus-color-border`（描边色）
- `--lotus-color-disabled-text`（禁用态文字色）
- `--lotus-color-text-0` / `-text-1`
- `--lotus-height-control-small`
- `--lotus-border-radius-small`
- `--lotus-border-width-control`
