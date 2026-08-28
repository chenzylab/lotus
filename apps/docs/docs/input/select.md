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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| borderless | 无边框模式 | boolean | false |
| class | 类名 | string | - |
| defaultValue | 默认选中值（多选时为数组） | `SelectValue \| SelectValue[]` | - |
| disabled | 是否禁用 | boolean | false |
| filter | 开启搜索过滤：`true` 走内置 label 包含匹配，函数则自定义匹配逻辑 | `boolean \| ((inputValue: string, option: SelectOption) => boolean)` | - |
| multiple | 是否多选 | boolean | false |
| optionList | 选项数组 | `SelectOption[]` | [] |
| placeholder | 占位提示文字 | any | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | "bottomLeft" |
| prefix | 前缀内容 | any | - |
| searchPlaceholder | 搜索框占位文字（`filter` 开启时生效） | string | - |
| searchPosition | 搜索框位置（`filter` 开启时生效）：`'trigger'` 叠加在触发器，`'dropdown'` 固定在面板顶部 | `'trigger' \| 'dropdown'` | "trigger" |
| showClear | 有选中值时展示清除按钮 | boolean | false |
| size | 尺寸，可选 large、default、small | string | "default" |
| style | 内联样式 | object | - |
| suffix | 后缀内容 | any | - |
| validateStatus | 校验状态，可选 default、error、warning，仅影响展示样式 | string | "default" |
| value | 当前选中值（多选时为数组） | `SelectValue \| SelectValue[]` | - |
| virtualize | 大数据量虚拟滚动配置，仅在 `optionList` 较大时需要传入 | `{ height?: number; itemSize: number }` | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 选中值变化时的回调 | `(value: SelectValue \| SelectValue[] \| undefined) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onSearch | 搜索框输入变化时的回调 | `(input: string) => void` | - |

`SelectOption` 结构：`{ value: string \| number; label?: any; disabled?: boolean }`。

> 注意事项：lotus 尚未实现 Semi 的 `remote`（远程数据源）、`allowCreate`（自定义新增选项）、`renderSelectedItem`/`renderOptionItem` 自定义渲染。这些是后续增强项。

## Accessibility

### ARIA

- 触发器携带 `role="combobox"` 与 `aria-expanded`。
- 下拉选项携带 `role="option"`。
- 可通过 `aria-label` 描述选择器用途。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`（三档高度）
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/选中项高亮色）
- `--lotus-color-danger` / `--lotus-color-warning`（校验状态边框色）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`（禁用态）
