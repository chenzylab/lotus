---
title: DatePicker 日期选择器
category: 输入类
---

日期/日期范围/年月选择器，支持日期时间联动、禁用规则、快捷预设。

## 代码演示

### 如何引入

```tsrx
import { DatePicker } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/date-picker/basic.tsrx
```

### 范围选择

`type="dateRange"` 展示双面板，左右面板可独立翻月/翻年，点选起止两端后提交。

```tsrx demo
../../src/demos/input/date-picker/range.tsrx
```

### 类型变体

`type` 支持 `date`/`dateRange`/`year`/`month`/`monthRange`/`dateTime`/`dateTimeRange` 七种，`month`/`year` 走年月滚轮而非日历网格。

```tsrx demo
../../src/demos/input/date-picker/type-variants.tsrx
```

### 禁用日期与快捷选项

```tsrx demo
../../src/demos/input/date-picker/disabled-date-presets.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| borderless | 无边框模式 | boolean | `false` |
| class | 类名 | string | - |
| defaultOpen | 非受控模式下的默认展开状态 | boolean | `false` |
| defaultPickerValue | 面板初始展示的年月（不影响已选值） | `Date \| Date[]` | - |
| defaultValue | 非受控模式下的默认值 | `DatePickerValue` | - |
| disabled | 是否禁用 | boolean | `false` |
| disabledDate | 判断某日期是否禁用 | `(date: Date, options?) => boolean` | - |
| disabledTime | 判断时间面板里哪些时/分/秒不可选 | `(date, panelType?) => DisabledTimeRulesDP` | - |
| endYear | 年份滚轮结束年份 | number | - |
| format | 输入框显示的日期格式 | string | - |
| max | `multiple` 模式下最多可选数量 | number | - |
| multiple | 是否允许多选（`type="date"` 下生效） | boolean | `false` |
| needConfirm | 范围/多选类型是否需要点击确认按钮才提交 | boolean | - |
| open | 受控的面板展开状态 | boolean | - |
| placeholder | 占位提示文字 | string | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| presets | 快捷预设选项 | `PresetType[]` | - |
| presetPosition | 快捷预设区域位置 | `'left' \| 'right' \| 'top' \| 'bottom'` | - |
| rangeSeparator | 范围类型输入框内两端日期的分隔符 | string | - |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| size | 尺寸 | string | - |
| startYear | 年份滚轮起始年份 | number | - |
| style | 自定义样式 | object | - |
| syncSwitchMonth | 范围选择时左右面板翻月是否联动 | boolean | - |
| type | 选择器类型 | `'date' \| 'dateRange' \| 'year' \| 'month' \| 'monthRange' \| 'dateTime' \| 'dateTimeRange'` | `'date'` |
| use12Hours | 时间面板是否使用 12 小时制（AM/PM） | boolean | - |
| hourStep / minuteStep / secondStep | 时间面板时/分/秒步长 | number | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值 | `DatePickerValue` | - |
| weekStartsOn | 周起始日 | `WeekStartNumber` | - |
| onChange | 值变化时的回调，同时给出格式化后的字符串 | `(value, dateString) => void` | - |
| onOpenChange | 面板展开/收起时的回调 | `(open: boolean) => void` | - |
| onPanelChange | 面板翻月/翻年时的回调 | `(date: Date) => void` | - |
| onPresetClick | 点击快捷预设时的回调 | `(item: PresetType) => void` | - |

`DatePickerValue` 结构：`Date \| Date[] \| RangeValue \| null`（`RangeValue` 为 `[Date \| null, Date \| null]`）。

## Accessibility

- 日历网格单元格携带 `role="gridcell"`。
- 导航区域的上一年/上个月/下个月/下一年四个按钮携带来自 `@lotus/locale` 的本地化 `aria-label`（切换语言后同步更新），RTL 模式下图标水平镜像。
- 年月滚轮的返回按钮、年份/月份滚动列表均携带本地化 `aria-label`。

## 设计变量

- `--lotus-color-border`（默认边框色/面板边框）
- `--lotus-color-primary`（选中日期/聚焦态）
- `--lotus-color-fill-0` / `-fill-1`（hover/今日高亮背景）
- `--lotus-color-text-0` / `-text-2` / `-disabled-text`
- `--lotus-height-control-large` / `-default` / `-small`
