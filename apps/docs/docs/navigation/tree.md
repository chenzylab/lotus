---
title: Tree 树形控件
category: 导航类
---

用于对树状结构的数据进行浏览、选择等操作。支持单选/多选三态级联（含 `checkRelation='unRelated'` 三态解除、`disableStrictly` 级联隔离 disabled 后代）、搜索过滤、异步懒加载、拖拽排序、大数据量虚拟滚动、directory 文件夹风格、完全自定义渲染。

## 代码演示

### 如何引入

```tsrx
import { Tree } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/navigation/tree/basic.tsrx
```

### 多选（三态级联）

`multiple` 开启多选，父子节点选中态自动三态级联（父节点部分子节点选中时显示 indeterminate）。

```tsrx demo
../../src/demos/navigation/tree/multiple.tsrx
```

### 搜索过滤

`filterTreeNode` 开启搜索：`true` 走内置的 label 包含匹配，传入函数 `(input, label, node) => boolean` 则完全自定义匹配逻辑。`showFilteredOnly` 只展示匹配到的节点（及其祖先路径），不匹配的节点整体隐藏而非置灰。

```tsrx demo
../../src/demos/navigation/tree/search.tsrx
```

### 异步懒加载

`loadData` 返回 `Promise<TreeNodeData[]>`，首次展开无 `children` 的节点时触发调用，`onLoad` 在数据加载完成后触发。`loadedKeys` 可受控传入，标记为已加载的节点展开时不再触发 `loadData`。

```tsrx demo
../../src/demos/navigation/tree/lazy.tsrx
```

### 三态解除 / 级联隔离 / directory 风格

`checkRelation='unRelated'` 让多选三态解除，父子选中状态互相独立；`disableStrictly` 让级联操作跳过 disabled 后代（disabled 节点选中状态独立，不受父节点批量操作影响）；`directory` 展示文件夹/文件风格图标，配合 `expandAction='click'` 可整行点击同时触发选中与展开。

```tsrx demo
../../src/demos/navigation/tree/advanced.tsrx
```

### 拖拽排序

`draggable` 开启拖拽，`onDrop` 等回调只提供拖拽信息（`dragNode`/`dropPosition`/`dropToGap`），实际的 `treeData` 重排由使用方在回调里自行完成（对齐 Semi 本身的设计）。

```tsrx demo
../../src/demos/navigation/tree/drag.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoExpandParent | 搜索/受控展开时是否自动展开匹配节点的祖先路径 | boolean | `true` |
| autoExpandWhenDragEnter | 拖拽悬停在节点上时是否自动展开该节点 | boolean | `false` |
| autoMergeValue | 多选：父节点全部子孙都选中时，value 只保留父 key | boolean | `true` |
| blockNode | 节点内容是否占满一行（增大点击区域） | boolean | `true` |
| checkRelation | 多选三态级联开关，`'unRelated'` 时选中态互相独立 | `'related' \| 'unRelated'` | `'related'` |
| class | 类名 | string | - |
| defaultExpandAll | 是否默认展开全部节点 | boolean | `false` |
| defaultExpandedKeys | 非受控模式下的默认展开节点 key 数组 | string[] | - |
| defaultValue | 非受控模式下的默认选中值（多选时为数组） | `string \| string[]` | - |
| directory | 文件夹风格：无自定义 icon 时自动展示文件夹/文件图标 | boolean | `false` |
| disableStrictly | 多选级联是否严格隔离 disabled 后代 | boolean | `false` |
| disabled | 是否整体禁用 | boolean | `false` |
| draggable | 是否支持拖拽节点 | boolean | `false` |
| emptyContent | 无数据/搜索无结果时的自定义展示内容 | any | - |
| expandAction | 触发展开/收起的方式：`'click'` 整行可点（同时触发选中），`'doubleClick'` 双击展开，`false` 只能点展开图标 | `'click' \| 'doubleClick' \| false` | `false` |
| expandIcon | 自定义展开图标 | any | - |
| expandedKeys | 受控的展开节点 key 数组 | string[] | - |
| filterTreeNode | 开启搜索过滤：`true` 走内置包含匹配，函数则自定义匹配逻辑 | `boolean \| ((input: string, label: string, node: TreeNodeData) => boolean)` | - |
| hideDraggingNode | 拖拽时是否隐藏原节点的拖拽镜像 | boolean | `false` |
| icon | 自定义节点图标，支持函数形式接收 `(node: TreeNodeData)` | `any \| ((node) => any)` | - |
| leafOnly | 多选：value 只保留叶子节点 key，优先级高于 `autoMergeValue` | boolean | `false` |
| loadData | 异步加载子节点，返回 `Promise<TreeNodeData[]>` | `(node: TreeNodeData) => Promise<TreeNodeData[]>` | - |
| loadedKeys | 受控的已加载节点 key 数组，标记的节点展开不再触发 `loadData` | string[] | - |
| multiple | 是否多选（三态级联） | boolean | `false` |
| onChangeWithObject | `onChange` 回调传节点数据（对象/对象数组）而非 key | boolean | `false` |
| renderFullLabel | 完全自定义整行节点渲染，替换默认的展开开关+checkbox+label 结构 | `(props) => any` | - |
| renderLabel | 自定义节点文案渲染 | `(label: any, node: TreeNodeData) => any` | - |
| searchRender | 自定义搜索框渲染，传 `false` 完全隐藏搜索框 | `boolean \| ((props) => any)` | - |
| searchPlaceholder | 搜索框占位文字（`filterTreeNode` 开启时生效） | string | 本地化默认值 |
| showFilteredOnly | 只展示搜索匹配的节点及其祖先路径 | boolean | `false` |
| showLine | 是否用连线展示层级关系 | boolean | `false` |
| style | 自定义样式 | object | - |
| treeData | 树形数据 | `TreeNodeData[]` | 必填 |
| treeNodeFilterProp | 搜索匹配的节点字段名 | string | `'label'` |
| value | 受控的选中值（多选时为数组） | `string \| string[]` | - |
| virtualize | 大数据量场景下开启固定行高虚拟滚动 | `{ height?: number; itemSize: number }` | - |
| onChange | 选中值变化时的回调 | `(value) => void` | - |
| onContextMenu | 右键节点时的回调 | `(event: MouseEvent, node: TreeNodeData) => void` | - |
| onDoubleClick | 双击节点时的回调 | `(event: MouseEvent, node: TreeNodeData) => void` | - |
| onDragEnd / onDragEnter / onDragLeave / onDragOver / onDragStart / onDrop | 拖拽生命周期回调，均携带 `{ event, node, dragNode?, dragNodesKeys?, dropPosition?, dropToGap? }` | `(info) => void` | - |
| onExpand | 展开/收起节点时的回调 | `(expandedKeys: string[], info: { expanded: boolean; node: TreeNodeData }) => void` | - |
| onLoad | 异步子节点加载完成后的回调 | `(loadedKeys: string[], node: TreeNodeData) => void` | - |
| onSearch | 搜索框输入变化时的回调，第二个参数是搜索匹配节点的祖先展开 key 列表 | `(input: string, filteredExpandedKeys: string[]) => void` | - |
| onSelect | 选中/取消选中节点时的回调（单选场景） | `(selectedKey: string \| null, selected: boolean, node: TreeNodeData) => void` | - |

`TreeNodeData` 结构：`{ key, label, value?, icon?, disabled?, isLeaf?, children? }`。

> 明确不做：`keyMaps`（自定义字段名映射）、`treeDataSimpleJson`（简化 JSON 转 treeData）——这两项是 Semi 为兼容历史数据格式提供的便捷层，lotus 直接要求标准 `TreeNodeData` 结构，不需要额外的字段映射/格式转换。

## Accessibility

- 根容器携带 `role="tree"`，多选模式下额外携带 `aria-multiselectable={true}`。
- 每个节点携带 `role="treeitem"`、`aria-level`（从 1 开始）、`aria-expanded`（仅有子节点或配置了 `loadData` 的节点才设置）、`aria-selected`（单选态反映 `selectedKey`，多选态反映 `checkedKeys`）、`aria-disabled`（节点或整树 `disabled` 时设置）、`aria-label`（取自节点 `label`）。
- 多选模式下每个节点的 `Checkbox` 携带来自节点 `label` 的 `aria-label`。
- 搜索框的清除按钮携带来自 `@lotus/locale` 的 `Tree.clearSearch` 本地化 `aria-label`。
- `renderFullLabel` 完全自定义渲染时，无障碍语义需调用方自行保证。

## 设计变量

- `--lotus-color-bg-1`（面板背景）
- `--lotus-color-fill-0` / `-fill-1`（节点 hover/选中态背景）
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-disabled-text`
- `--lotus-color-border`
- `--lotus-height-control-default`
- `--lotus-spacing-base` / `-tight`
- `--lotus-border-radius-small`
- `--lotus-border-width-control`
