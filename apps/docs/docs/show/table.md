---
title: Table 表格
category: 展示类
---

展示结构化数据集合，支持排序、筛选、行选择、分页、展开子行、固定列、大数据虚拟滚动。

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
| columns | 列定义 | `ColumnDef<T>[]` | 必填 |
| dataSource | 数据源 | T[] | `[]` |
| defaultExpandedRowKeys | 非受控模式下默认展开的行 key | `Array<string \| number>` | 无 |
| empty | 自定义空状态内容 | any | 无 |
| expandedRowKeys | 受控的展开行 key | `Array<string \| number>` | 无 |
| expandedRowRender | 展开行的渲染函数 | `(record, index) => any` | 无 |
| expandRowByClick | 点击行是否触发展开 | boolean | `false` |
| footer | 表格底部渲染函数 | `() => any` | 无 |
| hideExpandedColumn | 是否隐藏展开列 | boolean | `false` |
| loading | 加载中状态 | boolean | `false` |
| onChange | 排序/筛选/分页变化时的回调 | `(info) => void` | 无 |
| onExpand | 展开/收起某行时的回调 | `(expanded, record) => void` | 无 |
| onExpandedRowsChange | 展开行集合变化时的回调 | `(keys) => void` | 无 |
| onRow | 自定义行属性（事件等） | `(record, index) => object` | 无 |
| pagination | 分页配置，`false` 关闭分页 | `boolean \| PaginationProps` | `true` |
| rowExpandable | 判断某行是否可展开 | `(record) => boolean` | 无 |
| rowKey | 行唯一标识 | `string \| ((record, index) => string \| number)` | `'key'` |
| rowSelection | 行选择配置 | `TableRowSelection<T>` | 无 |
| scroll | 滚动配置，`{ x, y }` | object | 无 |
| size | 尺寸 | `'default' \| 'middle' \| 'small'` | `'default'` |
| style | 自定义样式 | object | 无 |
| title | 表格顶部渲染函数 | `() => any` | 无 |
| virtualize | 大数据虚拟滚动配置，`{ itemSize }`；需同时设置 `scroll.y` 才生效 | object | 无 |

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
| onFilter | 筛选判断函数 | `(value, record) => boolean` |
| render | 自定义单元格渲染 | `(text, record, index) => any` |
| sorter | 排序：`true` 或自定义比较函数 | `boolean \| ((a, b) => number)` |
| sortOrder | 受控的排序方向 | `SortOrder` |
| title | 列标题 | any |
| width | 列宽 | number |

## Accessibility

- 排序按钮、筛选按钮的可访问名称来自 `@lotus/locale`（`Table.filterLabel` 等），随语言切换更新。
- 行选择的全选/单选 checkbox 携带来自 `@lotus/locale` 的本地化 `aria-label`（`Table.selectRow`/`selectAll`）。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-border`
- `--lotus-color-fill-0`
