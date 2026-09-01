---
title: Transfer 穿梭框
category: 输入类
---

将元素在两栏之间双向流转，常用于成组选择场景。支持扁平列表、分组列表、树形结构三种数据源。

## 代码演示

### 如何引入

```tsrx
import { Transfer } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/transfer/basic.tsrx
```

### 分组列表

`type="groupList"`，`dataSource` 传 `{ title, children }[]` 结构。

```tsrx demo
../../src/demos/input/transfer/group.tsrx
```

### 拖拽排序已选列表

`draggable` 开启后已选列表左侧出现拖拽手柄。

```tsrx demo
../../src/demos/input/transfer/draggable.tsrx
```

### 自定义渲染

`renderSourceItem`/`renderSelectedItem` 自定义单项渲染（分别收到 `onChange`/`onRemove`/`dragHandleOnMouseDown` 回调，自行决定绑到哪个元素上）；`renderSourceHeader`/`renderSelectedHeader` 自定义头部；`renderSourcePanel`/`renderSelectedPanel` 完全替换整个面板。

```tsrx demo
../../src/demos/input/transfer/render-custom.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| dataSource | 数据源，结构随 `type` 变化 | `TransferDataSource` | - |
| defaultValue | 非受控模式下的默认已选值 | `Array<string \| number>` | - |
| disabled | 是否整体禁用 | boolean | `false` |
| draggable | 已选列表是否支持拖拽排序 | boolean | `false` |
| emptyContent | 左/右栏及搜索无结果时的自定义展示内容 | `{ left?: any; right?: any; search?: any }` | - |
| filter | 是否开启搜索：`true` 走内置 label 包含匹配，函数则自定义匹配逻辑；`type="treeList"` 时搜索固定走 `Tree` 自身的 `filterTreeNode` | `boolean \| ((input: string, item: ResolvedDataItem) => boolean)` | - |
| inputProps | 透传给左侧搜索框的 Input props（`value`/`onChange`/`placeholder`/`disabled` 仍由 Transfer 自己控制） | `Omit<InputProps, 'value' \| 'onChange' \| 'placeholder' \| 'disabled'>` | - |
| loading | 是否展示加载态 | boolean | `false` |
| pagination | 左侧列表分页配置 | `{ currentPage?; defaultCurrentPage?; pageSize?; onPageChange? }` | - |
| renderSelectedHeader | 自定义右侧面板头部渲染 | `(info: { length: number; onClear: () => void }) => any` | - |
| renderSelectedItem | 自定义已选项渲染，收到 `onRemove`/`dragHandleOnMouseDown`（draggable 时非 undefined）/`fullPath`（showPath 时非 undefined） | `(item: ResolvedDataItem & { onRemove: () => void; dragHandleOnMouseDown?: (e: MouseEvent) => void; fullPath?: PathEntry[] }) => any` | - |
| renderSelectedPanel | 完全自定义右侧（已选）面板渲染，替换整个面板 | `(props: { selectedData: ResolvedDataItem[]; onClear: () => void; onRemove: (item: ResolvedDataItem) => void }) => any` | - |
| renderSourceHeader | 自定义左侧面板头部渲染 | `(info: { num: number; showButton: boolean; allChecked: boolean; onAllClick: () => void }) => any` | - |
| renderSourceItem | 自定义可选项渲染，收到 `onChange` 回调 | `(item: ResolvedDataItem & { checked: boolean; onChange: () => void }) => any` | - |
| renderSourcePanel | 完全自定义左侧（源）面板渲染，替换整个面板（含头部/搜索框/列表） | `(props: {...}) => any` | - |
| showPath | 树形数据下已选项是否展示完整路径 | boolean | `false` |
| treeProps | 透传给 `type="treeList"` 内部 Tree 组件的 props（`value`/`onChange`/`treeData` 仍由 Transfer 自己控制） | `Omit<TreeProps, 'value' \| 'onChange' \| 'treeData'>` | - |
| type | 数据源结构类型 | `'list' \| 'groupList' \| 'treeList'` | `'list'` |
| value | 受控的已选值数组 | `Array<string \| number>` | - |
| virtualize | 已选列表虚拟滚动配置（数据量大时使用） | `{ height?: number; itemSize: number }` | - |
| onChange | 已选值变化时的回调 | `(values: Array<string \| number>, items: ResolvedDataItem[]) => void` | - |
| onDeselect | 取消选中某项时的回调 | `(item: ResolvedDataItem) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |
| onSelect | 选中某项时的回调 | `(item: ResolvedDataItem) => void` | - |

## Accessibility

- 过滤器容器携带 `role="search"` 与本地化 `aria-label`（`@lotus/locale` 的 `Transfer.filterLabel`）。
- 可选/已选列表容器携带 `role="list"` 与本地化 `aria-label`（`Transfer.optionListLabel`/`selectedListLabel`）——**此前是硬编码英文字面量 `"Transfer filter"`/`"Option list"`/`"Selected list"`，切换语言不会更新，已修复为走 locale**。
- 每个可选项是 `Checkbox`，已选项的移除按钮、拖拽手柄均携带本地化 `aria-label`。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-bg-1` / `-bg-2`（拖拽态背景）
- `--lotus-color-fill-0`（hover 背景）
- `--lotus-color-text-0` / `-text-2`
- `--lotus-border-radius-small`
