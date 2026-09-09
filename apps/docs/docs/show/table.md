---
title: Table 表格
category: 展示类
---

展示结构化数据集合，支持排序、筛选、行选择、分页、展开子行、固定列、列宽拖拽调整、数据分组、大数据虚拟滚动。

## 代码演示

### 如何引入

```tsrx
import { Table } from '@lotus/ripple';
```

### 基础用法（排序 + 筛选）

`sorter` 传比较函数开启排序，`filters` + `onFilter` 开启筛选。`onChange` 携带当前排序/筛选状态。

```tsrx demo
../../src/demos/show/table/basic.tsrx
```

### 行选择

`rowSelection` 开启 checkbox 多选与全选。

```tsrx demo
../../src/demos/show/table/row-selection.tsrx
```

## API 参考

### TableProps

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | 无 |
| bordered | 是否显示边框 | boolean | `false` |
| childrenRecordName | 树形数据的子级字段名 | string | `'children'` |
| class | 类名 | string | 无 |
| clickGroupedRowToExpand | 点击分组标题行整体是否触发展开/收起（不仅限展开图标） | boolean | `false` |
| columns | 列定义 | `ColumnDef<T>[]` | 必填 |
| dataSource | 数据源 | T[] | `[]` |
| defaultExpandAllGroupRows | 非受控模式下是否默认展开所有分组 | boolean | `false` |
| defaultExpandedRowKeys | 非受控模式下默认展开的行 key | `Array<string \| number>` | 无 |
| empty | 自定义空状态内容 | any | 无 |
| expandAllGroupRows | 受控的"全部分组展开"状态 | boolean | 无 |
| expandedRowKeys | 受控的展开行 key（分组标题行的 groupKey 与普通行 key 共存同一个集合） | `Array<string \| number>` | 无 |
| expandedRowRender | 展开行的渲染函数 | `(record, index) => any` | 无 |
| expandRowByClick | 点击行是否触发展开 | boolean | `false` |
| footer | 表格底部渲染函数 | `() => any` | 无 |
| getVirtualizedListRef | 仅 virtualize 场景生效，暴露 `{ scrollTo, scrollToItem }` 滚动控制句柄（lotus 虚拟滚动是自研的、没有 react-window 那样的第三方 List 实例可透传，提供同语义的句柄） | `(ref) => void` | 无 |
| groupBy | 数据分组字段名或分组函数，分组后同组数据聚在一起、分组标题行插入到组前 | `string \| ((record: T) => string \| number)` | 无 |
| hideExpandedColumn | 是否隐藏展开列 | boolean | `false` |
| indentSize | 树形数据子行的缩进像素值 | number | `20` |
| keepDOM | 收起的子行/展开内容是否仍保留 DOM（视觉隐藏而非不渲染），避免反复挂载卸载丢状态 | boolean | `false` |
| loading | 加载中状态 | boolean | `false` |
| onChange | 排序/筛选/分页变化时的回调 | `(info) => void` | 无 |
| onExpand | 展开/收起某行时的回调 | `(expanded, record) => void` | 无 |
| onExpandedRowsChange | 展开行集合变化时的回调 | `(keys) => void` | 无 |
| onGroupedRow | 自定义分组标题行属性（事件等） | `(record, index) => object` | 无 |
| onHeaderRow | 自定义表头行属性（事件等） | `(columns, index) => object` | 无 |
| onRow | 自定义行属性（事件等） | `(record, index) => object` | 无 |
| pagination | 分页配置，`false` 关闭分页 | `boolean \| PaginationProps` | `true` |
| renderGroupSection | 自定义分组标题行渲染 | `(groupKey, group) => any \| { children, ...props }` | 无 |
| resizable | 列宽拖拽调整开关/回调（`onResize`/`onResizeStart`/`onResizeStop`），单列可用 `column.resize = false` 关闭 | `boolean \| ResizableProps<T>` | 无 |
| rowExpandable | 判断某行是否可展开 | `(record) => boolean` | 无 |
| rowKey | 行唯一标识 | `string \| ((record, index) => string \| number)` | `'key'` |
| rowSelection | 行选择配置 | `TableRowSelection<T>` | 无 |
| rowSpanHover | hover 合并单元格（`rowSpan > 1`）时是否联动高亮所有被跨越的行 | boolean | `false` |
| scroll | 滚动配置，`{ x, y }` | object | 无 |
| showHeader | 是否渲染表头 | boolean | `true` |
| size | 尺寸 | `'default' \| 'middle' \| 'small'` | `'default'` |
| sticky | 页面级吸顶表头（`boolean \| { top }`），与 `scroll.y` 场景下"内部滚动容器吸顶"是两种独立语义，两者同时设置时 `scroll.y` 优先 | `boolean \| { top?: number }` | 无 |
| style | 自定义样式 | object | 无 |
| title | 表格顶部渲染函数 | `() => any` | 无 |
| virtualize | 大数据虚拟滚动配置，`{ itemSize }`；需同时设置 `scroll.y` 才生效 | object | 无 |

> `components`（自定义替换 table/tr/td 等渲染标签）本次不实现：Semi 该 prop 接受任意用户自定义组件（`React.ComponentType`），而 tsrx 编译器的 JSX 是静态标签展开，不支持运行时动态组件引用（穷举 `@if` 分支只能覆盖有限枚举值，无法覆盖任意组件类型），是确认过的架构限制。

### ColumnDef

| 属性 | 说明 | 类型 |
| --- | --- | --- |
| align | 对齐方式 | `'left' \| 'center' \| 'right'` |
| children | 多级表头的子列 | `ColumnDef<T>[]` |
| dataIndex | 数据字段名 | string |
| defaultFilteredValue | 非受控模式下默认筛选值 | `Array<string \| number \| boolean>` |
| defaultSortOrder | 非受控模式下默认排序方向 | `SortOrder` |
| filteredValue | 受控的筛选值 | `Array<string \| number \| boolean>` |
| filterMultiple | 筛选是否多选 | boolean |
| filters | 筛选选项 | `FilterOption[]` |
| fixed | 固定列方向 | `'left' \| 'right'` |
| key | 列唯一标识 | string |
| maxWidth | 拖拽调整列宽时的最大宽度 | number |
| minWidth | 拖拽调整列宽时的最小宽度 | number |
| onFilter | 筛选判断函数 | `(value, record) => boolean` |
| render | 自定义单元格渲染，返回 `{ children, props: { rowSpan, colSpan } }` 形态可声明单元格合并（`rowSpan`/`colSpan` 为 0 时该格完全不渲染，被前一个跨行/跨列的格子吞并） | `(text, record, index) => any` |
| resize | 是否允许拖拽调整本列宽度（跟随 Table.resizable 总开关，`false` 单列关闭） | boolean |
| sorter | 排序：`true` 或自定义比较函数 | `boolean \| ((a, b) => number)` |
| sortOrder | 受控的排序方向 | `SortOrder` |
| title | 列标题 | any |
| width | 列宽 | number |

## Accessibility

- 排序按钮、筛选按钮的可访问名称来自 `@lotus/locale`（`Table.filterLabel` 等），随语言切换更新。
- 行选择的全选/单选 checkbox 携带来自 `@lotus/locale` 的本地化 `aria-label`（`Table.selectRow`/`selectAll`）。
- 可展开的行（树形父行、有 `expandedRowRender` 的行、分组标题行）携带 `aria-expanded` 反映当前展开态；无展开能力的普通行不携带该属性。
- 列宽拖拽手柄（`resizable`）是纯鼠标交互，无键盘等价——对齐 Semi 官方 `ResizableHeaderCell` 同样的设计：列宽本身有声明式 `width` 兜底，拖拽只是可选的增强体验，不是唯一操作路径。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-border`
- `--lotus-color-fill-0`
