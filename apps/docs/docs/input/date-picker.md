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

### 面板内直接输入日期

`insetInput` 开启后触发器变为只读展示，面板顶部渲染可编辑的分段输入框（date/month 一段，dateRange/monthRange 两段，dateTime 日期+时间两段，dateTimeRange 四段），直接打字输入而不必逐格点选。

```tsrx demo
../../src/demos/input/date-picker/inset-input.tsrx
```

### 面板外层插槽

`topSlot`/`bottomSlot` 分别在面板最外层顶部/底部渲染固定区域。

```tsrx demo
../../src/demos/input/date-picker/slots.tsrx
```

### 需要确认提交

`needConfirm` 开启后（仅 dateTime/dateTimeRange 生效）面板底部展示取消/确认按钮，点击确认才真正提交值，取消则丢弃暂存选择。

```tsrx demo
../../src/demos/input/date-picker/need-confirm.tsrx
```

### 自定义触发器

`triggerRender` 完全自定义触发器渲染，替换默认的 Input 展示。

```tsrx demo
../../src/demos/input/date-picker/trigger-render.tsrx
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
| borderless | 无边框模式 | boolean | `false` |
| bottomSlot | 面板最外层底部固定区域 | any | - |
| class | 类名 | string | - |
| defaultOpen | 非受控模式下的默认展开状态 | boolean | `false` |
| defaultPickerValue | 面板初始展示的年月（不影响已选值） | `Date \| Date[]` | - |
| defaultValue | 非受控模式下的默认值 | `DatePickerValue` | - |
| density | 紧凑面板样式 | `'default' \| 'compact'` | `'default'` |
| disabled | 是否禁用 | boolean | `false` |
| disabledDate | 判断某日期是否禁用 | `(date: Date, options?) => boolean` | - |
| disabledTime | 判断时间面板里哪些时/分/秒不可选 | `(date, panelType?) => DisabledTimeRulesDP` | - |
| disabledTimePicker | dateTime/dateTimeRange 下禁止切换到时间面板 | boolean | `false` |
| endYear | 年份滚轮结束年份 | number | - |
| format | 输入框显示的日期格式 | string | - |
| getPopupContainer | 浮层挂载的目标容器，不传则挂载在 Popover 默认位置 | `() => HTMLElement` | - |
| hideDisabledOptions | 时间列表隐藏禁用项而非置灰显示 | boolean | `false` |
| id | 触发器 id | string | - |
| insetInput | 面板内直接输入日期（分段 Input），而非只能点选；开启后触发器本身视觉禁用（不可手动编辑），焦点转移到面板内输入框 | boolean | `false` |
| max | `multiple` 模式下最多可选数量 | number | - |
| multiple | 是否允许多选（`type="date"` 下生效） | boolean | `false` |
| needConfirm | 范围/多选类型是否需要点击确认按钮才提交 | boolean | - |
| open | 受控的面板展开状态 | boolean | - |
| placeholder | 占位提示文字 | string | - |
| position | 下拉浮层弹出方向 | `FloatingPosition` | - |
| presets | 快捷预设选项 | `PresetType[]` | - |
| presetPosition | 快捷预设区域位置 | `'left' \| 'right' \| 'top' \| 'bottom'` | - |
| rangeSeparator | 范围类型输入框内两端日期的分隔符 | string | - |
| renderDate | 自定义单个日期格渲染内容，仅替换格内文案 | `(dayNumber, fullDate) => any` | - |
| renderFullDate | 自定义单个日期格完整渲染，替换整个格子内容，优先级高于 renderDate | `(dayNumber, fullDate, selectedDate) => any` | - |
| showClear | 有选中值时展示清除按钮 | boolean | `false` |
| size | 尺寸 | string | - |
| startYear | 年份滚轮起始年份 | number | - |
| style | 自定义样式 | object | - |
| syncSwitchMonth | 范围选择时左右面板翻月是否联动 | boolean | - |
| timePickerOpts | dateTime/dateTimeRange 时批量透传时间列配置，逐项覆盖同名的顶层 use12Hours/hourStep/minuteStep/secondStep/hideDisabledOptions/disabledHours/disabledMinutes/disabledSeconds | object | - |
| topSlot | 面板最外层顶部固定区域 | any | - |
| triggerRender | 完全自定义触发器渲染，替换默认 Input；需自行处理点击展开等交互 | `(props) => any` | - |
| type | 选择器类型 | `'date' \| 'dateRange' \| 'year' \| 'month' \| 'monthRange' \| 'dateTime' \| 'dateTimeRange'` | `'date'` |
| use12Hours | 时间面板是否使用 12 小时制（AM/PM） | boolean | - |
| hourStep / minuteStep / secondStep | 时间面板时/分/秒步长 | number | - |
| validateStatus | 校验状态，仅影响展示样式 | string | - |
| value | 受控值 | `DatePickerValue` | - |
| weekStartsOn | 周起始日 | `WeekStartNumber` | - |
| zIndex | 浮层层级，不传由 CSS 层级 token 控制 | number | - |
| onCancel | needConfirm 模式下点击取消按钮时触发 | `() => void` | - |
| onChange | 值变化时的回调，同时给出格式化后的字符串 | `(value, dateString) => void` | - |
| onConfirm | needConfirm 模式下点击确认按钮时触发，携带最终提交的值 | `(value: DatePickerValue) => void` | - |
| onOpenChange | 面板展开/收起时的回调 | `(open: boolean) => void` | - |
| onPanelChange | 面板翻月/翻年时的回调 | `(date: Date) => void` | - |
| onPresetClick | 点击快捷预设时的回调 | `(item: PresetType) => void` | - |

`DatePickerValue` 结构：`Date \| Date[] \| RangeValue \| null`（`RangeValue` 为 `[Date \| null, Date \| null]`）。

> 注意事项：lotus 尚未实现 Semi 的 `filterSorter`/`filterRender`/`treeNodeFilterProp` 等搜索自定义（DatePicker 本身不涉及搜索）、图标定制（`clearIcon`/`prefix`）、浮层样式定制（`dropdownStyle`/`dropdownMargin`/`dropdownClassName`）、`autoAdjustOverflow`/`motion`、`autoFocus`/`preventScroll`、`insetLabel`/`insetLabelId`、`stopPropagation`、`timeZone`、`autoSwitchDate`。这些是长尾自定义能力，已标记为已知简化。

## Accessibility

- 日历网格单元格携带 `role="gridcell"`。
- 导航区域的上一年/上个月/下个月/下一年四个按钮携带来自 `@lotus/locale` 的本地化 `aria-label`（切换语言后同步更新），RTL 模式下图标水平镜像。
- 年月滚轮的返回按钮、年份/月份滚动列表均携带本地化 `aria-label`。
- 可通过 `aria-label`/`aria-labelledby` 描述选择器用途，`aria-describedby`/`aria-errormessage`/`aria-invalid`/`aria-required` 用于表单校验语义。
- `insetInput` 模式下触发器不使用原生 `disabled`（会阻止点击展开面板），改用 `pointer-events: none` 达成视觉禁用效果，同时保留可点击性。

## 设计变量

- `--lotus-color-border`（默认边框色/面板边框）
- `--lotus-color-primary`（选中日期/聚焦态）
- `--lotus-color-fill-0` / `-fill-1`（hover/今日高亮背景）
- `--lotus-color-text-0` / `-text-2` / `-disabled-text`
- `--lotus-height-control-large` / `-default` / `-small`
