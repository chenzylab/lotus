---
title: AutoComplete 自动完成
category: 输入类
---

自由文本输入框 + 候选建议下拉。与 `Select` 的本质区别：`AutoComplete` 允许输入任意文本，候选项只是"建议"，不强制从中选择；组件本身不做候选过滤，`onSearch` 仅把当前输入值抛给使用方，由使用方决定如何生成新的 `data`。

## 代码演示

### 如何引入

```tsrx
import { AutoComplete } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/auto-complete/basic.tsrx
```

### 默认高亮第一项

`defaultActiveFirstOption` 开启后打开面板即高亮第一个候选项，可直接回车选中。

```tsrx demo
../../src/demos/input/auto-complete/active-first.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| borderless | 无边框模式 | boolean | `false` |
| class | 类名 | string | - |
| data | 候选项数组 | `AutoCompleteDataItem[]` | - |
| defaultActiveFirstOption | 打开面板时是否默认高亮第一项 | boolean | `false` |
| defaultValue | 非受控模式下的默认值 | `string \| number` | - |
| disabled | 是否禁用 | boolean | `false` |
| emptyContent | 无候选项时的自定义展示内容 | any | - |
| loading | 是否展示加载态 | boolean | `false` |
| placeholder | 占位提示文字 | string | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| renderItem | 自定义候选项渲染 | `(option: AutoCompleteOptionItem) => any` | - |
| showClear | 有输入值时展示清除按钮 | boolean | `false` |
| size | 尺寸 | string | - |
| style | 自定义样式 | object | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值 | `string \| number` | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化（输入或选中候选项）时的回调 | `(value: string \| number) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onSearch | 输入值变化时的回调，用于使用方自行过滤生成新的 `data` | `(inputValue: string \| number) => void` | - |
| onSelect | 选中某个候选项时的回调 | `(option: AutoCompleteOptionItem) => void` | - |

`AutoCompleteDataItem` 结构：`string \| number \| { value: string \| number; label?: any; disabled?: boolean }`。

## Accessibility

- 候选列表携带 `role="listbox"`，每项携带 `role="option"`、`aria-selected`（是否为当前高亮项）、`aria-disabled`。
- 输入框本身当前未携带 `role="combobox"`/`aria-expanded`/`aria-controls` 这类组合框关联属性，如实记录为当前限制。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/高亮项背景）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
