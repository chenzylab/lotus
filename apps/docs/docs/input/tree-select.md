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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoExpandParent | 搜索/受控展开时是否自动展开匹配节点的祖先路径 | boolean | `true` |
| autoMergeValue | 多选：父全选时 value 只保留父 key，不逐一列出子孙 | boolean | `true` |
| borderless | 无边框模式 | boolean | `false` |
| checkRelation | 多选三态级联开关，`'unRelated'` 时选中态互相独立 | `'related' \| 'unRelated'` | `'related'` |
| class | 类名 | string | - |
| defaultExpandAll | 是否默认展开全部节点 | boolean | `false` |
| defaultExpandedKeys | 非受控模式下的默认展开节点 key 数组 | string[] | - |
| defaultValue | 非受控模式下的默认值（多选时为数组） | `string \| string[]` | - |
| disabled | 是否禁用 | boolean | `false` |
| expandedKeys | 受控的展开节点 key 数组 | string[] | - |
| filterTreeNode | 开启搜索过滤：`true` 走内置包含匹配，函数则自定义匹配逻辑 | `boolean \| ((input, label, node) => boolean)` | - |
| leafOnly | 多选：value 只保留叶子节点 key，优先级高于 `autoMergeValue` | boolean | `false` |
| loadData | 异步加载子节点 | `(node: TreeNodeData) => Promise<TreeNodeData[]>` | - |
| maxTagCount | 多选标签超出该数量后折叠为 "+N" | number | - |
| multiple | 是否多选（三态级联） | boolean | `false` |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| renderLabel | 自定义节点文案渲染 | `(label: any, node: TreeNodeData) => any` | - |
| searchPlaceholder | 搜索框占位文字 | any | - |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| showFilteredOnly | 只展示搜索匹配的节点及其祖先路径 | boolean | `false` |
| size | 尺寸 | string | - |
| style | 自定义样式 | object | - |
| treeData | 树形数据 | `TreeNodeData[]` | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值（多选时为数组） | `string \| string[]` | - |
| virtualize | 大数据量场景下开启固定行高虚拟滚动 | `{ height?: number; itemSize: number }` | - |
| onChange | 值变化时的回调 | `(value: string \| string[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onExpand | 展开/收起节点时的回调 | `(expandedKeys: string[], info) => void` | - |
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
