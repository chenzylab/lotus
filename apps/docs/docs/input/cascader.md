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

### 点击行即可勾选

`clickToSelect` 使多选下点击任意节点的行本身（非仅 checkbox）即可勾选，同时该行仍会展开进入下一级。

```tsrx demo
../../src/demos/input/cascader/click-to-select.tsrx
```

### 多选数量上限

`max` 限制多选最多可选叶子节点数（按折叠后的外部 value 路径数计算），达上限后新增勾选被拦截并触发 `onExceed`。

```tsrx demo
../../src/demos/input/cascader/max.tsrx
```

### 多选标签折叠

`maxTagCount` 控制已选 tag 超出后折叠为 "+N"。

```tsrx demo
../../src/demos/input/cascader/max-tag-count.tsrx
```

### 自定义空状态

`emptyContent` 替代搜索无匹配结果时默认的纯文本提示。

```tsrx demo
../../src/demos/input/cascader/empty-content.tsrx
```

### 自定义已选路径渲染

`displayRender` 完全自定义单选已选路径的展示内容；`displayProp` 则只需指定改用节点上的哪个字段展示（默认用 `label`）。

```tsrx demo
../../src/demos/input/cascader/display-render.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-describedby | 关联描述性文本的 id | string | - |
| aria-errormessage | 关联校验错误信息的 id | string | - |
| aria-invalid | 校验失败语义标记 | boolean | - |
| aria-label | 设置 aria-label 属性 | string | - |
| aria-labelledby | 关联外部 label 的 id | string | - |
| aria-required | 必填语义标记 | boolean | - |
| autoMergeValue | 多选：父节点全选时 value 只保留父路径，不逐一列出子孙 | boolean | `true` |
| borderless | 无边框模式 | boolean | `false` |
| bottomSlot | 下拉面板最外层底部固定区域 | any | - |
| changeOnSelect | 非叶子节点是否可直接选中（单选场景） | boolean | `false` |
| checkRelation | 多选三态级联开关，`'unRelated'` 时选中态互相独立 | `'related' \| 'unRelated'` | `'related'` |
| class | 类名 | string | - |
| clickToSelect | 多选：任意节点点击行本身即可勾选（优先级高于 enableLeafClick） | boolean | `false` |
| defaultValue | 非受控模式下的默认值（多选为数组） | `ValuePath \| ValuePath[]` | - |
| disableStrictly | 多选：已勾选节点是否禁止被再次点击取消勾选 | boolean | `false` |
| disabled | 是否禁用 | boolean | `false` |
| displayProp | 单选已选路径的展示字段名，指定后改为读取每级节点对应字段（默认展示 label） | string | - |
| displayRender | 单选已选路径完全自定义渲染，优先级高于 displayProp | `(selectedPathLabel: string, entities: CascaderEntity[]) => any` | - |
| emptyContent | 自定义空状态内容（搜索无匹配结果时），替代默认纯文本 | any | - |
| enableLeafClick | 多选：叶子节点点击行本身即可勾选 | boolean | `false` |
| filterLeafOnly | 搜索结果是否只保留叶子节点路径 | boolean | `true` |
| filterTreeNode | 开启搜索：`true` 走内置路径文本匹配，函数则完全自定义 | `boolean \| function` | - |
| getPopupContainer | 浮层挂载的目标容器，不传则挂载在 Popover 默认位置 | `() => HTMLElement` | - |
| id | 触发器 id | string | - |
| leafOnly | 多选：value 只保留叶子节点路径，优先级高于 `autoMergeValue` | boolean | `false` |
| loadData | 异步加载子节点，约定回调里自行更新 `treeData` 对应节点的 `children` | `(entity) => Promise<void>` | - |
| max | 多选最多可选项数（按折叠后的外部 value 路径数计算），达上限后新增勾选被拦截并触发 onExceed | number | - |
| maxTagCount | 多选已选 tag 数量超出后折叠为 "+N"，0/不传表示不折叠 | number | - |
| multiple | 是否多选 | boolean | `false` |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| searchPlaceholder | 搜索框占位文字（`filterTreeNode` 开启时生效） | any | - |
| separator | 路径展示分隔符 | string | `' / '` |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| showNext | 触发下一级展开的方式 | `'click' \| 'hover'` | `'click'` |
| size | 尺寸 | string | - |
| style | 自定义样式 | object | - |
| topSlot | 下拉面板最外层顶部固定区域 | any | - |
| treeData | 树形数据 | `CascaderNodeData[]` | - |
| triggerRender | 完全自定义触发器渲染，替换默认 combobox 触发框；需自行处理点击展开等交互 | `(props) => any` | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值（多选为数组） | `ValuePath \| ValuePath[]` | - |
| virtualize | 单列固定行高虚拟滚动配置（大数据量场景，每列独立虚拟化） | `{ height?: number; itemSize: number }` | - |
| zIndex | 浮层层级，不传由 CSS 层级 token 控制 | number | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 选中值变化时的回调 | `(value: ValuePath \| ValuePath[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onExceed | 多选达到 max 上限、新增勾选被拦截时触发 | `() => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onLoad | 异步加载成功后触发，携带本次新增的 loaded key 集合与刚加载完的节点数据 | `(newLoadedKeys: Set<string>, data) => void` | - |
| onLoadError | `loadData` 异步加载失败时的回调 | `(entity, error) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |

`CascaderNodeData` 结构：`{ value, label, disabled?, isLeaf?, children? }`；`ValuePath` 为 `Array<string \| number>`。

> 注意事项：lotus 尚未实现 Semi 的 `filterSorter`/`filterRender`/`treeNodeFilterProp` 搜索自定义、`autoClearSearchValue`、`remote` 远程搜索标记、`onChangeWithObject`、图标定制（`arrowIcon`/`clearIcon`/`expandIcon`）、`prefix`/`suffix`/`insetLabel`、浮层样式定制（`dropdownStyle`/`dropdownMargin`/`dropdownClassName`）、`defaultOpen`。这些是长尾自定义渲染能力，已标记为已知简化。

## Accessibility

- 触发器携带 `role="combobox"`、`aria-expanded`、`aria-haspopup="listbox"`、`aria-activedescendant`（指向当前激活的列/行坐标）。
- 每列携带 `role="menu"`，每个节点携带 `role="menuitem"`、`aria-expanded`（非叶子节点）、`aria-disabled`。
- 搜索结果列表携带 `role="listbox"`，每项 `role="option"`。
- 可通过 `aria-label`/`aria-labelledby` 描述选择器用途，`aria-describedby`/`aria-errormessage`/`aria-invalid`/`aria-required` 用于表单校验语义。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/选中项高亮色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
