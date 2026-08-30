---
title: Cascader 级联选择
category: 输入类
---

从多级联动的树形结构数据中选择一条或多条路径，如省市区选择。

## 代码演示

### 如何引入

```tsrx
import { Cascader } from '@lotus/ripple';
```

### 基本用法

非叶子节点默认点击展开下一级（`showNext="click"`），选中叶子节点后收起面板并回填完整路径文本。

```tsrx demo
../../src/demos/input/cascader/basic.tsrx
```

### 多选

`multiple` 开启多选，父子节点选中态三态级联（`checkRelation` 可切换为 `'unRelated'` 使选中态互相独立）。

```tsrx demo
../../src/demos/input/cascader/multiple.tsrx
```

### 搜索

`filterTreeNode` 开启内置路径文本匹配搜索，仅展示叶子节点结果（`filterLeafOnly` 控制）。

```tsrx demo
../../src/demos/input/cascader/search.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoMergeValue | 多选：父节点全选时 value 只保留父路径，不逐一列出子孙 | boolean | `true` |
| borderless | 无边框模式 | boolean | `false` |
| changeOnSelect | 非叶子节点是否可直接选中（单选场景） | boolean | `false` |
| checkRelation | 多选三态级联开关，`'unRelated'` 时选中态互相独立 | `'related' \| 'unRelated'` | `'related'` |
| class | 类名 | string | - |
| defaultValue | 非受控模式下的默认值（多选为数组） | `ValuePath \| ValuePath[]` | - |
| disabled | 是否禁用 | boolean | `false` |
| filterLeafOnly | 搜索结果是否只保留叶子节点路径 | boolean | `true` |
| filterTreeNode | 开启搜索：`true` 走内置路径文本匹配，函数则完全自定义 | `boolean \| function` | - |
| leafOnly | 多选：value 只保留叶子节点路径，优先级高于 `autoMergeValue` | boolean | `false` |
| loadData | 异步加载子节点，约定回调里自行更新 `treeData` 对应节点的 `children` | `(entity) => Promise<void>` | - |
| multiple | 是否多选 | boolean | `false` |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| searchPlaceholder | 搜索框占位文字（`filterTreeNode` 开启时生效） | any | - |
| separator | 路径展示分隔符 | string | `' / '` |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| showNext | 触发下一级展开的方式 | `'click' \| 'hover'` | `'click'` |
| size | 尺寸 | string | - |
| style | 自定义样式 | object | - |
| treeData | 树形数据 | `CascaderNodeData[]` | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值（多选为数组） | `ValuePath \| ValuePath[]` | - |
| virtualize | 单列固定行高虚拟滚动配置（大数据量场景，每列独立虚拟化） | `{ height?: number; itemSize: number }` | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 选中值变化时的回调 | `(value: ValuePath \| ValuePath[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onLoadError | `loadData` 异步加载失败时的回调 | `(entity, error) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |

`CascaderNodeData` 结构：`{ value, label, disabled?, isLeaf?, children? }`；`ValuePath` 为 `Array<string \| number>`。

## Accessibility

- 触发器携带 `role="combobox"`、`aria-expanded`、`aria-haspopup="listbox"`、`aria-activedescendant`（指向当前激活的列/行坐标）。
- 每列携带 `role="menu"`，每个节点携带 `role="menuitem"`、`aria-expanded`（非叶子节点）、`aria-disabled`。
- 搜索结果列表携带 `role="listbox"`，每项 `role="option"`。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/选中项高亮色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
