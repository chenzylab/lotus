---
title: Calendar 日历
category: 展示类
---

按周/月两种视图展示日期网格与事件，支持全天事件、跨天事件自动分层布局。

## 代码演示

### 如何引入

```tsrx
import { Calendar } from '@lotus/ripple';
```

### week 模式

按周展示 7 天 × 24 小时的时间网格，支持全天事件行与定时事件。

```tsrx demo
../../src/demos/show/calendar/week.tsrx
```

### month 模式

按月展示日期网格，跨天事件按贪心算法分层排列，避免相互遮挡。

```tsrx demo
../../src/demos/show/calendar/month.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| dateGridRender | 自定义日期格内容渲染（month 模式） | `(date: Date) => any` | - |
| displayValue | 面板锚点日期（决定展示哪一周/哪一月） | Date | 当前日期 |
| events | 事件数组 | `CalendarEvent[]` | `[]` |
| height | 面板高度 | `string \| number` | `600` |
| markWeekend | 是否高亮周末列 | boolean | `false` |
| minEventHeight | 定时事件的最小高度（像素） | number | `18` |
| mode | 视图模式 | `'week' \| 'month'` | `'week'` |
| renderEvent | 自定义事件内容渲染 | `(event: CalendarEvent) => any` | - |
| style | 自定义样式 | object | - |
| width | 面板宽度 | `string \| number` | - |
| onClick | 点击时间格/日期格时的回调，携带精确到小时（week）的 `Date` | `(event: MouseEvent, value: Date) => void` | - |

`CalendarEvent` 结构：`{ key, start, end, allDay?, children? }`。

## Accessibility

- 星期表头、时间刻度文案均走 `@lotus/locale` 的 `Calendar.weekdays`/`Calendar.formatHour`，切换语言后同步更新（`formatHour` 此前曾硬编码 `locale === 'zh-CN'` 分支判断 12/24 小时制，违反"新增语言包不需要改组件代码"的架构要求，已重构为 locale 包暴露的格式化函数）。
- 全天事件行的标签文案（"全天"）来自 `Calendar.allDay`。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-0`（今日/hover 高亮）
- `--lotus-border-radius-medium`
