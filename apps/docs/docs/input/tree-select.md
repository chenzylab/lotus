---
title: TreeSelect 树形选择器
category: 输入类
---

从树形结构数据中选择单个或多个值，弹出面板内交互与 `Tree` 一致（展开/收起、三态级联多选、搜索过滤、异步懒加载），但外观是选择器触发器 + 下拉面板。

## 代码演示

### 如何引入

```tsrx
import { TreeSelect } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/tree-select/basic.tsrx
```

### 多选（三态级联）

`multiple` 开启多选，父子节点三态级联；`maxTagCount` 超出后折叠为 "+N"。

```tsrx demo
../../src/demos/input/tree-select/multiple.tsrx
```

### 搜索

`filterTreeNode` 开启搜索：`true` 走内置 label 包含匹配，传入函数则自定义匹配逻辑。

```tsrx demo
../../src/demos/input/tree-select/search.tsrx
```

### 自定义渲染

`triggerRender` 完全自定义触发器；`renderSelectedItem` 自定义多选标签；`renderFullLabel` 完全自定义整行节点渲染。

```tsrx demo
../../src/demos/input/tree-select/render-custom.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoAdjustOverflow | 浮层超出视口时是否自动调整弹出方向 | boolean | `true` |
| autoExpandParent | 搜索/受控展开时是否自动展开匹配节点的祖先路径 | boolean | `true` |
| autoMergeValue | 多选：父全选时 value 只保留父 key，不逐一列出子孙 | boolean | `true` |
| borderless | 无边框模式 | boolean | `false` |
| checkRelation | 多选三态级联开关，`'unRelated'` 时选中态互相独立 | `'related' \| 'unRelated'` | `'related'` |
| class | 类名 | string | - |
| clearIcon | 自定义清除按钮图标 | any | - |
| clickToHide | 单选场景选中一个节点后是否自动关闭面板 | boolean | `true` |
| defaultExpandAll | 是否默认展开全部节点 | boolean | `false` |
| defaultExpandedKeys | 非受控模式下的默认展开节点 key 数组 | string[] | - |
| defaultOpen | 挂载时默认展开面板 | boolean | `false` |
| defaultValue | 非受控模式下的默认值（多选时为数组） | `string \| string[]` | - |
| disableStrictly | 多选场景勾选是否严格按 disabled 节点隔离级联（true 时 disabled 节点选中状态独立，不受父节点批量操作影响） | boolean | `false` |
| disabled | 是否禁用 | boolean | `false` |
| dropdownMargin | 浮层与触发器的间距微调 | number | - |
| expandAction | 触发展开/收起的方式：`'click'` 整行可点（同时触发选中），`'doubleClick'` 双击展开（不触发选中），`false` 只能点展开图标 | `'click' \| 'doubleClick' \| false` | `false` |
| expandIcon | 自定义展开图标，支持函数形式接收 `(onClick, className, expanded)` | any | - |
| expandedKeys | 受控的展开节点 key 数组 | string[] | - |
| filterTreeNode | 开启搜索过滤：`true` 走内置包含匹配，函数则自定义匹配逻辑 | `boolean \| ((input, label, node) => boolean)` | - |
| getPopupContainer | 浮层挂载的目标容器 | `() => HTMLElement \| null` | - |
| insetLabel | 内嵌标签文案，渲染在触发器内部 | any | - |
| leafOnly | 多选：value 只保留叶子节点 key，优先级高于 `autoMergeValue` | boolean | `false` |
| loadData | 异步加载子节点 | `(node: TreeNodeData) => Promise<TreeNodeData[]>` | - |
| maxTagCount | 多选标签超出该数量后折叠为 "+N" | number | - |
| multiple | 是否多选（三态级联） | boolean | `false` |
| outerTopSlot / outerBottomSlot | 面板上方/下方插槽 | any | - |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| preventScroll | 聚焦时是否阻止浏览器自动滚动到视口 | boolean | - |
| prefix / suffix | 触发器前缀/后缀内容 | any | - |
| renderFullLabel | 比 `renderLabel` 更完整的自定义渲染，替换整行内容 | `(props) => any` | - |
| renderLabel | 自定义节点文案渲染 | `(label: any, node: TreeNodeData) => any` | - |
| renderSelectedItem | 多选标签自定义渲染，接收 `(node, { index, onClose })` | `(node, meta) => any` | - |
| restTagsPopoverProps | 折叠气泡 Popover 的透传配置 | object | - |
| searchAutoFocus | 挂载后是否自动聚焦搜索框（仅 `filterTreeNode` 开启时有意义） | boolean | `false` |
| searchPlaceholder | 搜索框占位文字 | any | - |
| searchPosition | 搜索框位置，`'trigger'` 允许直接在触发器上输入过滤 | `'dropdown' \| 'trigger'` | `'dropdown'` |
| searchRender | 自定义搜索框渲染，传 `false` 完全隐藏搜索框 | `boolean \| ((inputProps) => any)` | - |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| showFilteredOnly | 只展示搜索匹配的节点及其祖先路径 | boolean | `false` |
| showRestTagsPopover | 折叠时 "+N" 是否 hover 弹出展示被折叠的标签 | boolean | `false` |
| showSearchClear | 搜索框内容非空时是否展示清除按钮 | boolean | `true` |
| size | 尺寸 | string | - |
| stopPropagation | 浮层内容点击是否阻止事件冒泡到 document | boolean | `true` |
| style | 自定义样式 | object | - |
| treeData | 树形数据 | `TreeNodeData[]` | - |
| treeNodeLabelProp | treeData 里自定义 label 字段名 | string | `'label'` |
| triggerRender | 完全自定义触发器渲染，替换默认展示区域 | `(props) => any` | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值（多选时为数组） | `string \| string[]` | - |
| virtualize | 大数据量场景下开启固定行高虚拟滚动 | `{ height?: number; itemSize: number }` | - |
| zIndex | 浮层层级 | number | - |
| onBlur | 触发器失焦时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化时的回调 | `(value: string \| string[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onExpand | 展开/收起节点时的回调 | `(expandedKeys: string[], info) => void` | - |
| onFocus | 触发器聚焦时的回调 | `(event: FocusEvent) => void` | - |
| onLoad | 异步子节点加载完成后的回调 | `(loadedKeys: string[], node: TreeNodeData) => void` | - |
| onLoadError | 异步加载失败时的回调 | `(node: TreeNodeData, error: unknown) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |
| onSelect | 选中/取消选中节点时的回调（单选场景） | `(selectedKey, selected, node) => void` | - |

> 实现说明：TreeSelect 的下拉面板是独立实现，不直接复用 `Tree` 组件（避免双重搜索框/容器样式冲突，状态也更容易和触发器同步），但节点交互逻辑与 `Tree` 共享同一套 Foundation 纯函数。

## Accessibility

- 触发器携带 `role="combobox"` 与 `aria-expanded`。
- 下拉面板容器携带 `role="tree"`，多选时携带 `aria-multiselectable`。
- 节点携带 `role="treeitem"`、`aria-selected`（单选态）、`aria-expanded`（有子节点的节点）。当前未携带 `aria-level`，如实记录为待补齐项（对照 `Tree` 组件已补齐的完整树形 ARIA 语义）。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-primary`（聚焦态/选中态）
- `--lotus-color-fill-0` / `-fill-1`（hover/选中背景）
- `--lotus-color-text-0` / `-text-2` / `-disabled-text`
- `--lotus-height-control-large` / `-default` / `-small`
