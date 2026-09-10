---
title: Calendar 日历
category: 展示类
---

按日/周/月/任意区间四种视图展示日期网格与事件，支持全天事件、跨天事件自动分层布局，当前时间线，月视图事件超出可见行数时聚合为"+N 更多"并弹出详情卡片。

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

### day 模式

单日视图，只渲染一天的时间网格，不显示日期表头（信息量为 0，直接省略）。

### range 模式

任意区间视图，通过 `range: [Date, Date]` 指定起止日期（含端点），渲染跨越对应天数的时间网格——是 day/week 的泛化版本，三者共用同一套逐日列渲染逻辑，只是天数和起点不同。

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| allDayEventsRender | 自定义全天事件区域的整体渲染，覆盖默认的逐条列表 | `(events: CalendarEvent[]) => any` | - |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| dateGridRender | 自定义日期格内容渲染 | `(date: Date) => any` | - |
| displayValue | 面板锚点日期（决定展示哪一天/哪一周/哪一月） | Date | 当前日期 |
| events | 事件数组 | `CalendarEvent[]` | `[]` |
| header | 自定义头部内容，渲染在日期表头之上（day/week/range 模式） | any | - |
| height | 面板高度 | `string \| number` | `600` |
| markWeekend | 是否高亮周末列 | boolean | `false` |
| minEventHeight | 定时事件的最小高度（像素） | number | `18` |
| mode | 视图模式 | `'day' \| 'week' \| 'month' \| 'range'` | `'week'` |
| range | range 模式下的日期区间 `[start, end]`（含端点） | `[Date, Date]` | - |
| renderDateDisplay | 自定义 week/range 表头的单日展示（默认是"日期数字 + 星期"两行） | `(date: Date) => any` | - |
| renderEvent | 自定义事件内容渲染 | `(event: CalendarEvent) => any` | - |
| renderTimeDisplay | 自定义时间轴刻度文案，默认用 `locale.Calendar.formatHour` | `(hour: number) => any` | - |
| scrollTop | day/week/range 模式挂载时的初始滚动位置（像素） | number | `400` |
| showCurrTime | day/week/range 模式下是否显示当前时间横线（仅视图覆盖今天时生效，每 30 秒重新采样位置） | boolean | `true` |
| style | 自定义样式 | object | - |
| width | 面板宽度 | `string \| number` | - |
| onClick | 点击时间格/日期格时的回调，携带精确到小时（day/week/range）的 `Date` | `(event: MouseEvent, value: Date) => void` | - |
| onClose | 月视图"+N 更多"弹出的事件详情卡片关闭时的回调 | `(event: MouseEvent) => void` | - |
| onMoreClick | 月视图某天事件数超过可见行数、点击"+N 更多"时的回调 | `(event: MouseEvent, date: Date, remaining: number) => void` | - |

`CalendarEvent` 结构：`{ key, start, end, allDay?, children? }`。

### 月视图 itemLimit（事件超出可见行数自动聚合）

月视图每个格子会根据实测高度动态计算能完整显示几行事件（`itemLimit`），超出的事件不再渲染绝对定位横条，改为在格子底部显示"+N 更多"，点击后弹出 Popover 卡片展示当天全部事件（不受 `itemLimit` 截断），卡片带关闭按钮触发 `onClose`。这个换算不需要任何配置，容器 `height` 越大、每格子能容纳的行数越多。

## Accessibility

- 星期表头、时间刻度文案均走 `@lotus/locale` 的 `Calendar.weekdays`/`Calendar.formatHour`，切换语言后同步更新（`formatHour` 此前曾硬编码 `locale === 'zh-CN'` 分支判断 12/24 小时制，违反"新增语言包不需要改组件代码"的架构要求，已重构为 locale 包暴露的格式化函数）。
- 全天事件行的标签文案（"全天"）来自 `Calendar.allDay`。
- 月视图"+N 更多"携带 `role="button"`/`tabIndex={0}`，支持 Enter/Space 键盘触发（对齐 Semi 官方实现本身缺失键盘可访问性的这处，lotus 版本额外补齐）。
- 事件详情卡片的关闭按钮携带来自 `Calendar.close` 的本地化 `aria-label`。
- 当前时间横线是纯视觉装饰，携带 `aria-hidden="true"` 且 `pointer-events: none`，不影响屏幕阅读器和鼠标操作。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-0`（今日/hover 高亮）
- `--lotus-border-radius-medium`
