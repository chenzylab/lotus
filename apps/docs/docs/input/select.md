---
title: Select 选择器
category: 输入类
---

从一组选项中选择单个或多个值。

## 代码演示

### 如何引入

```tsrx
import { Select } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/select/basic.tsrx
```

### 三种大小

```tsrx demo
../../src/demos/input/select/size.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/select/disabled.tsrx
```

### 校验状态

```tsrx demo
../../src/demos/input/select/validate-status.tsrx
```

### 可清除

```tsrx demo
../../src/demos/input/select/clear.tsrx
```

### 多选

`multiple` 开启多选，选中值为数组；选中一项后下拉不会自动收起（对齐 Semi 多选交互），可继续选择或点击标签上的删除按钮移除已选项。

```tsrx demo
../../src/demos/input/select/multiple.tsrx
```

### 受控组件

```tsrx demo
../../src/demos/input/select/controlled.tsrx
```

### 搜索过滤

`filter` 开启搜索：`true` 走内置的 label 大小写不敏感包含匹配，传入函数 `(inputValue, option) => boolean` 则完全自定义匹配逻辑。搜索框位置由 `searchPosition` 控制，默认 `'trigger'`（叠加在触发器本身，与已选值/多选 tags 共存），也可设为 `'dropdown'`（固定在下拉面板顶部）。选中候选项或关闭面板后搜索框自动清空。

```tsrx demo
../../src/demos/input/select/filter.tsrx
```

```tsrx demo
../../src/demos/input/select/filter-dropdown.tsrx
```

### 分组（optionList 数据驱动方式）

`optionList` 支持混排扁平项与 `{ label, options }` 分组项。

```tsrx demo
../../src/demos/input/select/group.tsrx
```

### 分组（SelectOption/SelectOptGroup 组合式声明）

对齐 Semi `Select.Option`/`Select.OptGroup` children 声明用法，与 `optionList` 并存（`optionList` 非空时优先）。

```tsrx demo
../../src/demos/input/select/group-jsx.tsrx
```

### 多选数量上限

`max` 限制多选最多可选项数，达上限后新增选中被拦截并触发 `onExceed`；取消选中不受限制。

```tsrx demo
../../src/demos/input/select/max.tsrx
```

### 多选标签折叠

`maxTagCount` 控制已选 tag 超出后折叠为 "+N"，纯展示不影响实际选中值。

```tsrx demo
../../src/demos/input/select/max-tag-count.tsrx
```

### 远程加载中

`loading` 显示加载指示，替代选项列表——常配合 `remote` 异步搜索场景使用。

```tsrx demo
../../src/demos/input/select/loading.tsrx
```

### 自定义空状态

`emptyContent` 替代默认的纯文本空状态提示。

```tsrx demo
../../src/demos/input/select/empty-content.tsrx
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
| borderless | 无边框模式 | boolean | false |
| children | 组合式候选项声明：`SelectOption`/`SelectOptGroup`，与 `optionList` 并存，`optionList` 非空时优先 | any | - |
| class | 类名 | string | - |
| defaultActiveFirstOption | 打开下拉面板时是否默认高亮第一个可选项 | boolean | true |
| defaultValue | 默认选中值（多选时为数组） | `SelectValue \| SelectValue[]` | - |
| disabled | 是否禁用 | boolean | false |
| emptyContent | 自定义空状态内容，替代默认纯文本 | any | - |
| filter | 开启搜索过滤：`true` 走内置 label 包含匹配，函数则自定义匹配逻辑 | `boolean \| ((inputValue: string, option: SelectOptionData) => boolean)` | - |
| id | 触发器 id | string | - |
| loading | 远程加载中态，显示 loading 指示替代选项列表 | boolean | false |
| max | 多选最多可选项数，达上限后新增选中被拦截并触发 `onExceed` | number | - |
| maxTagCount | 多选已选 tag 数量超出后折叠为 "+N"，0/不传表示不折叠 | number | - |
| multiple | 是否多选 | boolean | false |
| optionList | 选项列表，扁平项与 `{ label, options }` 分组项可混排；非空时优先于组合式 `children` | `SelectOptionListEntry[]` | [] |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | "bottomLeft" |
| prefix | 前缀内容 | any | - |
| remote | 远程搜索模式：不做本地过滤，仅回调 `onSearch`，由外部异步更新 `optionList` | boolean | false |
| searchPlaceholder | 搜索框占位文字（`filter` 开启时生效） | string | - |
| searchPosition | 搜索框位置（`filter` 开启时生效）：`'trigger'` 叠加在触发器，`'dropdown'` 固定在面板顶部 | `'trigger' \| 'dropdown'` | "trigger" |
| showClear | 有选中值时展示清除按钮 | boolean | false |
| size | 尺寸，可选 large、default、small | string | "default" |
| style | 内联样式 | object | - |
| suffix | 后缀内容 | any | - |
| validateStatus | 校验状态，可选 default、error、warning，仅影响展示样式 | string | "default" |
| value | 当前选中值（多选时为数组） | `SelectValue \| SelectValue[]` | - |
| virtualize | 大数据量虚拟滚动配置，仅在 `optionList` 较大且无分组时需要传入（分组场景不支持虚拟滚动，同 Semi） | `{ height?: number; itemSize: number }` | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 选中值变化时的回调 | `(value: SelectValue \| SelectValue[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDeselect | 多选取消某项选中时触发，携带被取消项的 value | `(value: SelectValue) => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onExceed | 多选达到 `max` 上限、新增选中被拦截时触发 | `() => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |
| onSelect | 选中某项时触发（单选/多选新增选中均触发），携带被选中项的 value——与 `onChange` 的区别是只含当次操作的单项 | `(value: SelectValue) => void` | - |

`SelectOptionData` 结构：`{ value: string \| number; label?: any; disabled?: boolean }`。`SelectOptionListEntry` 为 `SelectOptionData` 与 `{ label: any; options: SelectOptionData[] }` 分组项的联合类型。

`SelectOption`/`SelectOptGroup` 是组合式候选项声明组件（对齐 Semi `Select.Option`/`Select.OptGroup`），不渲染任何可见 DOM，只把自身信息注册进 Select——只支持两层，`SelectOptGroup` 内不能再嵌套 `SelectOptGroup`（同 Semi）。

> 注意事项：lotus 尚未实现 Semi 的 `allowCreate`（自定义新增选项）、`renderSelectedItem`/`renderOptionItem`/`triggerRender` 自定义渲染、`outerTopSlot`/`outerBottomSlot` 插槽、`getPopupContainer`/`zIndex` 浮层挂载与层级控制。这些是后续增强项。

## Accessibility

### ARIA

- 触发器携带 `role="combobox"`、`aria-expanded`、`aria-haspopup="listbox"`。
- 下拉选项携带 `role="option"`，选中态携带 `aria-selected`。
- 键盘导航时触发器携带 `aria-activedescendant` 指向当前高亮项（DOM 焦点始终留在触发器上）。
- 可通过 `aria-label`/`aria-labelledby` 描述选择器用途，`aria-describedby`/`aria-errormessage`/`aria-invalid`/`aria-required` 用于表单校验语义。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`（三档高度）
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/选中项高亮色）
- `--lotus-color-danger` / `--lotus-color-warning`（校验状态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
