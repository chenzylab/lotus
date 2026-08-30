---
title: Sidebar 侧边栏
category: 展示类
---

贴视口右侧的可伸缩浮层容器，主视图（选项列表/自定义内容）与详情视图（代码/文件/自定义）之间可来回切换。Phase 6 的 AI 场景会直接复用它作为侧边信息栏。

## 代码演示

### 如何引入

```tsrx
import { Sidebar } from '@lotus/ripple';
```

### 基本用法

`mode="main"` 渲染主视图（`renderMainContent` 优先，否则回退到内置 `options` 列表），其余 `mode` 渲染详情视图（`renderDetailContent` 优先，否则按 `mode` 分流到内置的 `code`/`file` 详情渲染）。`onBackWard` 从详情视图返回主视图，支持返回异步（如需要确认）。

```tsrx demo
../../src/demos/show/sidebar/basic.tsrx
```

### 配套子组件

`SidebarMCPConfigure`（内置/自定义 MCP 工具二选一切换 + 搜索）与 `SidebarAnnotation`（分组引用溯源列表）是与 Sidebar 配套的具名导出子组件，通常在 `renderMainContent` 里组合使用。

```tsrx demo
../../src/demos/show/sidebar/sub-components.tsrx
```

## API 参考

### SidebarProps

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeKey | 主视图选项列表的当前选中 key | string | 无 |
| defaultWidth | 默认宽度 | number | `360` |
| detailContent | 详情视图内容（`code`/`file` 模式下传给内置渲染） | `CodeItem \| FileContentItem \| any` | 无 |
| fileEditable | `mode="file"` 时内容是否可编辑 | boolean | `true` |
| maxWidth | 最大宽度（配合 `resizable`） | number | `800` |
| minWidth | 最小宽度（配合 `resizable`） | number | `150` |
| mode | 当前视图模式，`'main'` 之外的值均为详情视图 | `SidebarMode` | `'main'` |
| onActiveOptionChange | 主视图选项列表点击时的回调 | `(event, key) => void` | 无 |
| onBackWard | 从详情视图返回主视图时的回调，返回 Promise 时按钮进入防重复触发的 pending 态 | `(event, mode) => void \| Promise<any>` | 无 |
| onCancel | 关闭按钮/Esc 触发 | `(event) => void` | 无 |
| onDetailContentCopy | `mode="code"` 详情复制按钮点击后的回调 | `(event, content, succeeded) => void` | 无 |
| onFileContentChange | `mode="file"` 内容变化时的回调 | `(content) => void` | 无 |
| options | 主视图内置选项列表数据 | `SidebarOption[]` | 无 |
| renderDetailContent | 自定义详情视图渲染，优先级最高，完全接管非 main 模式的内容 | `(mode) => any` | 无 |
| renderDetailHeader | 自定义详情视图的头部内容 | `(mode, detailContent) => any` | 无 |
| renderMainContent | 自定义主视图渲染，优先于内置 `options` 列表 | `(activeKey) => any` | 无 |
| renderOptionItem | 自定义单个选项的渲染 | `(option, onChange) => any` | 无 |
| resizable | 是否可通过拖拽调整宽度 | boolean | `true` |
| showClose | 是否显示关闭按钮 | boolean | `true` |
| title | 标题 | any | 无 |
| visible | 是否显示 | boolean | `false` |

### SidebarMCPConfigureProps（`SidebarMCPConfigure`）

| 属性 | 说明 | 类型 |
| --- | --- | --- |
| customOptions | 自定义工具列表 | `MCPOption[]` |
| onAddClick | 点击新增自定义工具的回调 | `() => void` |
| onConfigureClick | 点击工具配置按钮的回调 | `(option) => void` |
| onEditClick | 点击编辑按钮的回调 | `(option) => void` |
| onStatusChange | 工具启用状态变化时的回调 | `(options, customOptions) => void` |
| options | 内置工具列表 | `MCPOption[]` |

## Accessibility

- 关闭按钮（`Container` 内置头部与 `SidebarHeader` 详情视图头部）的可访问名称来自 `@lotus/locale` 的 `Sidebar.close`；返回按钮来自 `Sidebar.back`，均随语言切换更新。
- 返回箭头图标在 RTL 模式下水平镜像（阅读顺序语义），关闭按钮图标不受方向影响。
- 支持 Esc 键关闭（`Container` 内部监听 `keydown`，`onCancel` 触发）。
- 拖拽调整宽度的手柄目前仅支持鼠标操作，暂无对应的键盘等价交互（如实记录为当前限制）。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-border`
- `--lotus-color-fill-0`
- `--lotus-shadow-elevated`
- `--lotus-z-modal`
- `--lotus-font-h5-size`
