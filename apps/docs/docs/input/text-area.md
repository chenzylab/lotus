---
title: TextArea 多行输入框
category: 输入类
---

多行文本输入框，支持自适应高度、字数统计、清除按钮。

## 代码演示

### 如何引入

```tsrx
import { TextArea } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/text-area/basic.tsrx
```

### 自适应高度

`autosize` 传 `true` 不限制行数范围自动扩展；传 `{ minRows, maxRows }` 限制扩展区间。

```tsrx demo
../../src/demos/input/text-area/autosize.tsrx
```

### 字数统计与清除

`maxCount` 展示字数统计（不限制输入，仅展示）；`maxLength` 才是真正限制最大输入长度；`showClear` 展示清除按钮。

```tsrx demo
../../src/demos/input/text-area/count-clear.tsrx
```

### 行号栏

`showLineNumber` 展示代码编辑器式的左侧行号栏，每个逻辑行（按换行符拆分）按自动换行的实际视觉行数分配对应高度，滚动位置与内容区同步；`lineNumberStart` 设置起始行号。

```tsrx demo
../../src/demos/input/text-area/line-number.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoFocus | 挂载时是否自动聚焦，透传给原生 autofocus 属性 | boolean | `false` |
| autosize | 是否自适应高度，传对象可限制行数范围 | `boolean \| { minRows?: number; maxRows?: number }` | `false` |
| borderless | 无边框模式 | boolean | `false` |
| class | 类名 | string | - |
| cols | 原生 `cols` 属性 | number | - |
| composition | 中文输入法组合输入期间是否也触发 `onChange` | boolean | `false` |
| defaultValue | 非受控模式下的默认值 | string | `''` |
| disabled | 是否禁用 | boolean | `false` |
| id | 原生 id，配合 `Form.Field` 的 `<label for>` 建立语义关联 | string | - |
| lineNumberClassName | 行号栏自定义类名，配合 `showLineNumber` 使用 | string | - |
| lineNumberStart | 行号栏起始行号，配合 `showLineNumber` 使用 | number | `1` |
| lineNumberStyle | 行号栏自定义样式，配合 `showLineNumber` 使用 | object | - |
| maxCount | 展示的字数统计上限（仅展示，不限制输入） | number | - |
| maxLength | 实际限制的最大输入长度 | number | - |
| placeholder | 占位提示文字 | string | - |
| readonly | 是否只读 | boolean | `false` |
| resize | 原生 resize 行为 | `'none' \| 'both' \| 'horizontal' \| 'vertical'` | - |
| rows | 原生 `rows` 属性 | number | `4` |
| showClear | 是否展示清除按钮 | boolean | `false` |
| showCounter | 独立开关，不传 `maxCount` 也单独显示当前字符计数（不带 "/总数"）；传 `maxCount` 时无论是否传这个 prop 都会显示计数器 | boolean | `false` |
| showLineNumber | 是否展示左侧行号栏（代码编辑器式），每个逻辑行按自动换行的实际视觉行数对齐 | boolean | `false` |
| style | 外层容器样式 | object | - |
| textareaStyle | 内部原生 `<textarea>` 样式 | object | - |
| validateStatus | 校验状态，仅影响展示样式 | `'default' \| 'warning' \| 'error'` | `'default'` |
| value | 受控值 | string | - |
| onBlur | 失去焦点时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化时的回调 | `(value: string, event: Event) => void` | - |
| onClear | 点击清除按钮时的回调 | `(event: MouseEvent) => void` | - |
| onCompositionEnd / onCompositionStart / onCompositionUpdate | 中文输入法组合事件回调 | `(event: CompositionEvent) => void` | - |
| onEnterPress | 按下 Enter（非 Shift+Enter）时的回调 | `(event: KeyboardEvent) => void` | - |
| onFocus | 获得焦点时的回调 | `(event: FocusEvent) => void` | - |
| onKeyDown | 按键时的回调 | `(event: KeyboardEvent) => void` | - |
| onResize | `autosize` 高度变化时的回调 | `(size: { height: number }) => void` | - |

## Accessibility

- 内部原生 `<textarea>` 携带 `aria-label`，`id` 可配合 `Form.Field` 的 `<label for>` 建立真正语义关联（非仅视觉靠近）。
- 清除按钮是原生 `<button>`，本身键盘可达；`onMouseDown` 阶段 `preventDefault()` 避免点击清除按钮时输入框先失焦。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-border-width-control`
- `--lotus-color-border` / `-primary`（聚焦态边框）
- `--lotus-border-radius-small`
- `--lotus-spacing-tight`
- `--lotus-color-text-0` / `-text-2` / `-text-3`（placeholder）
- `--lotus-color-disabled-bg` / `-disabled-text`
- `--lotus-font-family` / `-font-body-size` / `-font-body-line-height` / `-font-label-size`
