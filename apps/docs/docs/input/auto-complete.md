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

### 自定义触发器与回填

`triggerRender` 完全自定义触发器渲染；`renderSelectedItem` 自定义选中后回填输入框的文案；`onSelectWithObject` 控制 `onSelect` 回调传递候选项全量对象还是仅 `value`；`dropdownMatchSelectWidth` 让下拉面板最小宽度对齐触发器宽度。

```tsrx demo
../../src/demos/input/auto-complete/advanced.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-describedby / aria-errormessage / aria-invalid / aria-labelledby / aria-required | 无障碍关联属性透传给内部 Input | - | - |
| aria-label | 设置 aria-label 属性 | string | - |
| autoAdjustOverflow | 浮层超出视口时是否自动调整弹出方向 | boolean | `true` |
| autoFocus | 挂载后是否自动聚焦 | boolean | `false` |
| borderless | 无边框模式 | boolean | `false` |
| class | 类名 | string | - |
| clearIcon | 自定义清除按钮图标 | any | - |
| data | 候选项数组 | `AutoCompleteDataItem[]` | - |
| defaultActiveFirstOption | 打开面板时是否默认高亮第一项 | boolean | `false` |
| defaultValue | 非受控模式下的默认值 | `string \| number` | - |
| disabled | 是否禁用 | boolean | `false` |
| dropdownClassName / dropdownStyle | 下拉面板自定义类名/样式 | string / object | - |
| dropdownMatchSelectWidth | 下拉面板最小宽度是否对齐触发器宽度 | boolean | `true` |
| emptyContent | 无候选项时的自定义展示内容 | any | - |
| getPopupContainer | 浮层挂载的目标容器 | `() => HTMLElement \| null` | - |
| id | 原生 id 属性 | string | - |
| insetLabel / insetLabelId | 内嵌标签文案（未指定 `prefix` 时生效）及其 id | any / string | - |
| loading | 是否展示加载态 | boolean | `false` |
| maxHeight | 下拉面板最大高度 | `string \| number` | `300` |
| mouseEnterDelay / mouseLeaveDelay | 悬浮触发延迟（组件为 `trigger="custom"`，实际不消费，对齐 Semi 保留同名 dead prop） | number | - |
| motion | 是否开启浮层动画（当前对齐保留但不实际消费，浮层动画由 CSS 过渡统一处理） | boolean | `true` |
| placeholder | 占位提示文字 | string | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| prefix / suffix | 输入框前缀/后缀内容 | any | - |
| renderItem | 自定义候选项渲染 | `(option: AutoCompleteOptionItem) => any` | - |
| renderSelectedItem | 选中候选项后回填输入框的自定义转换，必须返回 string | `(option: AutoCompleteOptionItem) => string` | - |
| showClear | 有输入值时展示清除按钮 | boolean | `false` |
| size | 尺寸 | string | - |
| stopPropagation | 浮层内容点击是否阻止事件冒泡到 document | boolean | `false` |
| style | 自定义样式 | object | - |
| triggerRender | 完全自定义触发器渲染，替换默认的 Input | `(props: { inputValue, value, open }) => any` | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值 | `string \| number` | - |
| zIndex | 浮层层级 | number | `1030` |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化（输入或选中候选项）时的回调 | `(value: string \| number) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onDropdownVisibleChange | 下拉展开/收起时的回调 | `(visible: boolean) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onKeyDown | 触发器区域按键时的回调（先于内部方向键/回车等处理逻辑触发） | `(event: KeyboardEvent) => void` | - |
| onSearch | 输入值变化时的回调，用于使用方自行过滤生成新的 `data` | `(inputValue: string \| number) => void` | - |
| onSelect | 选中某个候选项时的回调，`onSelectWithObject` 为 true 时传候选项全量对象，否则仅传 `value` | `(option) => void` | - |
| onSelectWithObject | `onSelect` 回调传候选项全量对象还是仅 `value` | boolean | `false` |

`AutoCompleteDataItem` 结构：`string \| number \| { value: string \| number; label?: any; disabled?: boolean }`。

> 明确不做：`onChangeWithObject`——已核对 Semi 源码确认这是 Semi 自己的 dead prop（propTypes 声明了但 Foundation 从未消费），不作为已验证能力照搬。

## Accessibility

- 候选列表携带 `role="listbox"`，每项携带 `role="option"`、`aria-selected`（是否为当前高亮项）、`aria-disabled`。
- 输入框本身当前未携带 `role="combobox"`/`aria-expanded`/`aria-controls` 这类组合框关联属性，如实记录为当前限制。
- `triggerRender` 完全自定义渲染时，无障碍语义需调用方自行保证。

## 设计变量

- `--lotus-height-control-large` / `-default` / `-small`
- `--lotus-color-border`（默认边框色）
- `--lotus-color-primary`（聚焦态边框色/高亮项背景）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
