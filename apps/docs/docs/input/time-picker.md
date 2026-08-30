---
title: TimePicker 时间选择器
category: 输入类
---

时间/时间范围选择器，支持 12/24 小时制、时分秒步长、禁用规则。

## 代码演示

### 如何引入

```tsrx
import { TimePicker } from '@lotus/ripple';
```

### 基本用法

默认 24 小时制，点击触发器展开时/分/秒三列滚轮。

```tsrx demo
../../src/demos/input/time-picker/basic.tsrx
```

### 范围选择

`type="timeRange"` 展示左右双列独立滚轮，分别选择起止时间。

```tsrx demo
../../src/demos/input/time-picker/range.tsrx
```

### 禁用小时/分钟

`disabledHours`/`disabledMinutes`/`disabledSeconds` 按需返回禁用的数值数组；`hideDisabledOptions` 直接隐藏禁用项而非置灰展示。

```tsrx demo
../../src/demos/input/time-picker/disabled-options.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| borderless | 无边框模式 | boolean | `false` |
| class | 类名 | string | - |
| defaultOpen | 非受控模式下的默认展开状态 | boolean | `false` |
| defaultValue | 非受控模式下的默认值 | `TimePickerValue \| [TimePickerValue, TimePickerValue]` | - |
| disabled | 是否禁用 | boolean | `false` |
| disabledHours | 返回禁用的小时数组 | `() => number[]` | - |
| disabledMinutes | 按已选小时返回禁用的分钟数组 | `(hour: number) => number[]` | - |
| disabledSeconds | 按已选小时/分钟返回禁用的秒数组 | `(hour: number, minute: number) => number[]` | - |
| disabledTime | 按已选值整体返回禁用规则，仅 `timeRange` 生效，覆盖顶层 `disabledHours`/`disabledMinutes`/`disabledSeconds` | `(dates: Date[], panelType?: 'left' \| 'right') => DisabledTimeRules \| undefined` | - |
| format | 输入框显示的时间格式 | string | - |
| hideDisabledOptions | 是否隐藏（而非置灰）禁用项 | boolean | `false` |
| hourStep / minuteStep / secondStep | 时/分/秒滚轮步长 | number | - |
| open | 受控的面板展开状态 | boolean | - |
| placeholder | 占位提示文字 | string | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| rangeSeparator | 范围类型输入框内两端时间的分隔符 | string | - |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| size | 尺寸 | `small` \| `default` \| `large` | - |
| style | 自定义样式 | object | - |
| type | 选择器类型 | `'time' \| 'timeRange'` | `'time'` |
| use12Hours | 是否使用 12 小时制（AM/PM） | boolean | `false` |
| validateStatus | 校验状态，仅影响展示样式 | `'default' \| 'error' \| 'warning'` | - |
| value | 受控值 | `TimePickerValue \| [TimePickerValue, TimePickerValue]` | - |
| onChange | 值变化时的回调 | `(value: Date \| null \| [Date \| null, Date \| null]) => void` | - |
| onClear | 点击清除按钮时的回调 | `() => void` | - |
| onOpenChange | 面板展开/收起时的回调 | `(open: boolean) => void` | - |

`TimePickerValue` 结构：`Date \| string \| null`（字符串需符合 `HH:mm` 或 `HH:mm:ss` 格式）。

## Accessibility

- 触发器携带本地化 `aria-label`（`@lotus/locale` 的 `TimePicker.triggerLabel`/`begin`/`end`）。
- 时/分/秒滚轮各自携带本地化 `aria-label`（`hourLabel`/`minuteLabel`/`secondLabel`），单位文案（时/分/秒）与 AM/PM 文案随语言切换同步更新。

## 设计变量

- `--lotus-color-border`（默认边框色/面板边框）
- `--lotus-color-primary`（选中值/聚焦态）
- `--lotus-color-fill-0` / `-fill-1`（滚轮项 hover 背景）
- `--lotus-color-text-0` / `-text-2` / `-disabled-text`
- `--lotus-height-control-large` / `-default` / `-small`
