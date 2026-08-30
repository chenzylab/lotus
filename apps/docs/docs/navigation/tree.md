---
title: Tree 树形控件
category: 导航类
---

用于对树状结构的数据进行浏览、选择等操作。当前版本只交付静态展示、单选/多选、搜索过滤与异步懒加载，不做拖拽排序、虚拟化、搜索高亮（这些留待与 Select/Table 系列大数据虚拟化能力一并实现）。

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

`loadData` 返回 `Promise<TreeNodeData[]>`，首次展开无 `children` 的节点时触发调用，`onLoad` 在数据加载完成后触发。

```tsrx demo
../../src/demos/navigation/tree/lazy.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoExpandParent | 搜索/受控展开时是否自动展开匹配节点的祖先路径 | boolean | `true` |
| blockNode | 节点内容是否占满一行（增大点击区域） | boolean | `false` |
| class | 类名 | string | - |
| defaultExpandAll | 是否默认展开全部节点 | boolean | `false` |
| defaultExpandedKeys | 非受控模式下的默认展开节点 key 数组 | string[] | - |
| defaultValue | 非受控模式下的默认选中值（多选时为数组） | `string \| string[]` | - |
| disabled | 是否整体禁用 | boolean | `false` |
| emptyContent | 无数据/搜索无结果时的自定义展示内容 | any | - |
| expandedKeys | 受控的展开节点 key 数组 | string[] | - |
| filterTreeNode | 开启搜索过滤：`true` 走内置包含匹配，函数则自定义匹配逻辑 | `boolean \| ((input: string, label: string, node: TreeNodeData) => boolean)` | - |
| loadData | 异步加载子节点，返回 `Promise<TreeNodeData[]>` | `(node: TreeNodeData) => Promise<TreeNodeData[]>` | - |
| multiple | 是否多选（三态级联） | boolean | `false` |
| renderLabel | 自定义节点文案渲染 | `(label: any, node: TreeNodeData) => any` | - |
| searchPlaceholder | 搜索框占位文字（`filterTreeNode` 开启时生效） | string | 本地化默认值 |
| showFilteredOnly | 只展示搜索匹配的节点及其祖先路径 | boolean | `false` |
| style | 自定义样式 | object | - |
| treeData | 树形数据 | `TreeNodeData[]` | 必填 |
| value | 受控的选中值（多选时为数组） | `string \| string[]` | - |
| onChange | 选中值变化时的回调（多选场景） | `(value: string \| string[] \| undefined) => void` | - |
| onExpand | 展开/收起节点时的回调 | `(expandedKeys: string[], info: { expanded: boolean; node: TreeNodeData }) => void` | - |
| onLoad | 异步子节点加载完成后的回调 | `(loadedKeys: string[], node: TreeNodeData) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |
| onSelect | 选中/取消选中节点时的回调（单选场景） | `(selectedKey: string \| null, selected: boolean, node: TreeNodeData) => void` | - |

`TreeNodeData` 结构：`{ key, label, value?, icon?, disabled?, isLeaf?, children? }`。

## Accessibility

- 树节点用 `<div>`/`<span>` 渲染，当前不携带 `role="tree"`/`role="treeitem"` 这类 ARIA Tree 语义，如实记录为当前限制。
- 多选模式下每个节点的 `Checkbox` 携带来自节点 `label` 的 `aria-label`。
- 搜索框的清除按钮携带来自 `@lotus/locale` 的 `Tree.clearSearch` 本地化 `aria-label`。

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
