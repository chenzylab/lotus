import { track, effect, untrack } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../popover/index.tsrx';
import { IconButton } from '../../basic/icon-button/index.tsrx';
import { IconClose } from '@lotus/icons';
import {
    type CalendarEvent,
    type DayInfo,
    layoutTimedEventsForDay,
    layoutRangeEvents,
    getWeekDays,
    getDateRangeDays,
    getMonthWeeks,
    groupTimedEventsByDay,
    extractAllDayEvents,
    calcMonthItemLimit,
    filterEventsByItemLimit,
    calcRemainingCount,
    getDayPos,
} from '@lotus/foundation/show/calendar';

export type { CalendarEvent };
export type CalendarMode = 'day' | 'week' | 'month' | 'range';

export interface CalendarProps {
    mode?: CalendarMode;
    displayValue?: Date;
    /** range 模式下的日期区间 [start, end]（含端点）。 */
    range?: [Date, Date];
    events?: CalendarEvent[];
    weekStartsOn?: number;
    markWeekend?: boolean;
    minEventHeight?: number;
    height?: string | number;
    width?: string | number;
    /** 自定义头部内容，渲染在日期表头之上。 */
    header?: any;
    /** day/week/range 模式下是否显示当前时间横线（仅 displayValue/range 覆盖今天时生效）。 */
    showCurrTime?: boolean;
    /** day/week/range 模式挂载时的初始滚动位置（像素）。 */
    scrollTop?: number;
    onClick?: (event: MouseEvent, value: Date) => void;
    onClose?: (event: MouseEvent) => void;
    /** 月视图某天事件数超过可见行数时，点击"+N 更多"的回调。 */
    onMoreClick?: (event: MouseEvent, date: Date, remaining: number) => void;
    dateGridRender?: (date: Date) => any;
    /** 自定义时间轴刻度文案，默认用 locale.Calendar.formatHour。 */
    renderTimeDisplay?: (hour: number) => any;
    /** 自定义 week/range 表头的单日展示（默认是"日期数字 + 星期"两行）。 */
    renderDateDisplay?: (date: Date) => any;
    /** 自定义全天事件区域的整体渲染，覆盖默认的逐条 li 列表。 */
    allDayEventsRender?: (events: CalendarEvent[]) => any;
    renderEvent?: (event: CalendarEvent) => any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const HOURS = Array.from({ length: 24 }, (_, i) => i);

export function Calendar(&{
    mode = 'week',
    displayValue,
    range,
    events = [],
    weekStartsOn = 0,
    markWeekend = false,
    minEventHeight = 18,
    height = 600,
    width,
    header,
    showCurrTime = true,
    scrollTop = 400,
    onClick,
    onClose,
    onMoreClick,
    dateGridRender,
    renderTimeDisplay,
    renderDateDisplay,
    allDayEventsRender,
    renderEvent,
    style,
    class: className,
    'aria-label': ariaLabel,
}: CalendarProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[anchor] = track<Date>(() => displayValue ?? untrack(() => new Date()));

    let &[classes] = track<string>(() =>
        ['lotus-calendar', `lotus-calendar-${mode}`, className ?? ''].filter(Boolean).join(' '),
    );

    function handleGridClick(event: MouseEvent, value: Date) {
        onClick?.(event, value);
    }

    function timeDisplay(hour: number): any {
        return renderTimeDisplay ? renderTimeDisplay(hour) : locale.Calendar.formatHour(hour);
    }

    <>
        <div class={classes} style={{ ...(width !== undefined ? { width } : {}), height, ...style }} role="grid" aria-label={ariaLabel ?? 'Calendar'}>
            @if (mode === 'day') {
                <CalendarDaysView
                    rangeStart={anchor}
                    dayCount={1}
                    events={events}
                    markWeekend={markWeekend}
                    minEventHeight={minEventHeight}
                    showCurrTime={showCurrTime}
                    scrollTop={scrollTop}
                    header={header}
                    locale={locale}
                    onGridClick={handleGridClick}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
                    timeDisplay={timeDisplay}
                    renderDateDisplay={renderDateDisplay}
                    allDayEventsRender={allDayEventsRender}
                    showHeader={false}
                />
            }
            @if (mode === 'week') {
                <CalendarDaysView
                    rangeStart={getWeekDays(anchor, weekStartsOn)[0]!.date}
                    dayCount={7}
                    events={events}
                    markWeekend={markWeekend}
                    minEventHeight={minEventHeight}
                    showCurrTime={showCurrTime}
                    scrollTop={scrollTop}
                    header={header}
                    locale={locale}
                    onGridClick={handleGridClick}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
                    timeDisplay={timeDisplay}
                    renderDateDisplay={renderDateDisplay}
                    allDayEventsRender={allDayEventsRender}
                    showHeader={true}
                />
            }
            @if (mode === 'range' && range) {
                <CalendarDaysView
                    rangeStart={range[0]}
                    dayCount={Math.max(1, Math.round((range[1].getTime() - range[0].getTime()) / 86400000) + 1)}
                    events={events}
                    markWeekend={markWeekend}
                    minEventHeight={minEventHeight}
                    showCurrTime={showCurrTime}
                    scrollTop={scrollTop}
                    header={header}
                    locale={locale}
                    onGridClick={handleGridClick}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
                    timeDisplay={timeDisplay}
                    renderDateDisplay={renderDateDisplay}
                    allDayEventsRender={allDayEventsRender}
                    showHeader={true}
                />
            }
            @if (mode === 'month') {
                <CalendarMonthView
                    anchor={anchor}
                    events={events}
                    weekStartsOn={weekStartsOn}
                    markWeekend={markWeekend}
                    locale={locale}
                    onGridClick={handleGridClick}
                    onMoreClick={onMoreClick}
                    onClose={onClose}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
                />
            }
        </div>

        <style>
            .lotus-calendar {
                display: flex;
                flex-direction: column;
                overflow: hidden;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}

interface DaysViewProps {
    /** 视图第一天的日期（day 模式是 anchor 本身，week 模式是自然周首日，range 模式是 range[0]）。 */
    rangeStart: Date;
    /** 视图跨越的天数（day=1, week=7, range=区间实际天数）。 */
    dayCount: number;
    events: CalendarEvent[];
    markWeekend: boolean;
    minEventHeight: number;
    showCurrTime: boolean;
    scrollTop: number;
    header?: any;
    locale: typeof zhCN;
    onGridClick: (event: MouseEvent, value: Date) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
    timeDisplay: (hour: number) => any;
    renderDateDisplay?: (date: Date) => any;
    allDayEventsRender?: (events: CalendarEvent[]) => any;
    /** day 模式不需要顶部"日期数字+星期"表头（只有一天，标题信息量为 0）。 */
    showHeader: boolean;
}

/** day（dayCount=1）/week（dayCount=7，从自然周首日起）/range（任意天数，从
 * 任意起点起）三种模式共用的逐日列视图——对齐 Semi rangeCalendar 用
 * differenceInCalendarDays 算天数、逐天铺开渲染跟 week 视图相同 DayCol
 * 结构的思路，三者本质是"同一套渲染，只是天数和起点不同"，不需要三份
 * 独立实现。 */
function CalendarDaysView(&{
    rangeStart,
    dayCount,
    events,
    markWeekend,
    minEventHeight,
    showCurrTime,
    scrollTop,
    header,
    locale,
    onGridClick,
    dateGridRender,
    renderEvent,
    timeDisplay,
    renderDateDisplay,
    allDayEventsRender,
    showHeader,
}: DaysViewProps) @{
    let &[days] = track<DayInfo[]>(() => getDateRangeDays(rangeStart, dayCount));

    let &[allDayEvents] = track<CalendarEvent[]>(() => extractAllDayEvents(events));

    let &[allDayLayout] = track(() => {
        const viewDays = days;
        const firstDay = viewDays[0];
        if (!firstDay) return [];
        return layoutRangeEvents(allDayEvents, firstDay.date, viewDays.length);
    });

    let &[allDayRowCount] = track<number>(() => {
        const maxTop = allDayLayout.reduce((max, item) => Math.max(max, item.topInd), -1);
        return maxTop + 1;
    });

    let &[timedEventsByDay] = track(() => groupTimedEventsByDay(events));

    // 当前时间横线：只在视图覆盖今天时显示，每 30 秒重新采样一次位置
    // （对齐 Semi getCurrLocation 用 requestAnimationFrame 节流到 30s 一次
    // 更新的做法，这里用更轻量的 setInterval——横线本身不需要逐帧动画，
    // 30s 采样一次已经足够跟随真实时间）。
    let &[coveringToday] = track<boolean>(() => days.some((day) => day.isToday));
    let &[currTimePos] = track<number>(() => getDayPos(untrack(() => new Date())));
    effect(() => {
        if (!showCurrTime || !coveringToday) return;
        const timer = setInterval(() => {
            currTimePos = getDayPos(new Date());
        }, 30000);
        return () => clearInterval(timer);
    });

    let scrollNode: HTMLElement | null = null;
    function handleScrollRef(node: HTMLElement | null) {
        scrollNode = node;
        if (node) node.scrollTop = scrollTop;
    }

    function handleCellClick(event: MouseEvent, date: Date, hour: number) {
        const value = new Date(date);
        value.setHours(hour, 0, 0, 0);
        onGridClick(event, value);
    }

    <>
        @if (header) {
            <div class="lotus-calendar-custom-header">{header}</div>
        }

        @if (showHeader) {
            <div class="lotus-calendar-week-header">
                <div class="lotus-calendar-week-header-gutter" />
                @for (const day of days; index i) {
                    <div class={['lotus-calendar-week-header-cell', day.isToday ? 'lotus-calendar-today' : '', markWeekend && day.isWeekend ? 'lotus-calendar-weekend' : ''].filter(Boolean).join(' ')}>
                        @if (renderDateDisplay) {
                            <>{renderDateDisplay(day.date)}</>
                        }
                        @if (!renderDateDisplay) {
                            <>
                                <span class="lotus-calendar-week-header-weekday">{locale.Calendar.weekdays[day.weekday]}</span>
                                <span class="lotus-calendar-week-header-date">{String(day.date.getDate())}</span>
                            </>
                        }
                    </div>
                }
            </div>
        }

        @if (allDayRowCount > 0) {
            <div class="lotus-calendar-allday-row" style={{ height: `${allDayRowCount * 1.75 + 0.5}em` }}>
                <div class="lotus-calendar-allday-label">{locale.Calendar.allDay}</div>
                <div class="lotus-calendar-allday-content">
                    @if (allDayEventsRender) {
                        <>{allDayEventsRender(allDayEvents)}</>
                    }
                    @if (!allDayEventsRender) {
                        <>
                            @for (const item of allDayLayout; index i) {
                                <div
                                    class="lotus-calendar-event lotus-calendar-event-allday"
                                    style={{
                                        insetInlineStart: `${item.leftPos * 100}%`,
                                        width: `${item.width * 100}%`,
                                        top: `${item.topInd * 1.75}em`,
                                    }}
                                >
                                    {renderEvent ? renderEvent(item.event) : item.event.children}
                                </div>
                            }
                        </>
                    }
                </div>
            </div>
        }

        <div class="lotus-calendar-week-body" ref={handleScrollRef}>
            <div class="lotus-calendar-time-gutter">
                @for (const hour of HOURS; index i) {
                    <div class="lotus-calendar-time-gutter-cell">{timeDisplay(hour)}</div>
                }
            </div>
            @for (const day of days; index i) {
                <div class={['lotus-calendar-day-col', day.isToday ? 'lotus-calendar-today' : '', markWeekend && day.isWeekend ? 'lotus-calendar-weekend' : ''].filter(Boolean).join(' ')}>
                    @for (const hour of HOURS; index j) {
                        <div class="lotus-calendar-day-col-cell" onClick={(e: MouseEvent) => handleCellClick(e, day.date, hour)} />
                    }
                    @if (dateGridRender) {
                        <div class="lotus-calendar-day-col-custom">{dateGridRender(day.date)}</div>
                    }
                    @if (showCurrTime && day.isToday) {
                        <>
                            <div class="lotus-calendar-curr-line" style={{ top: `${currTimePos * 100}%` }} aria-hidden="true" />
                            <div class="lotus-calendar-curr-circle" style={{ top: `${currTimePos * 100}%` }} aria-hidden="true" />
                        </>
                    }
                    <CalendarDayEvents
                        date={day.date}
                        events={timedEventsByDay.get(new Date(day.date.getFullYear(), day.date.getMonth(), day.date.getDate()).toISOString()) ?? []}
                        minEventHeight={minEventHeight}
                        renderEvent={renderEvent}
                    />
                </div>
            }
        </div>

        <style>
            .lotus-calendar-custom-header {
                flex-shrink: 0;
            }

            .lotus-calendar-week-header {
                display: flex;
                border-bottom: 1px solid var(--lotus-color-border);
                flex-shrink: 0;
            }

            .lotus-calendar-week-header-gutter {
                width: 56px;
                flex-shrink: 0;
            }

            .lotus-calendar-week-header-cell {
                flex: 1;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: var(--lotus-spacing-tight) 0;
            }

            .lotus-calendar-week-header-weekday {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-week-header-date {
                font-size: var(--lotus-font-h6-size);
                font-weight: 600;
            }

            .lotus-calendar-today .lotus-calendar-week-header-date {
                color: var(--lotus-color-primary);
            }

            .lotus-calendar-weekend {
                background: var(--lotus-color-fill-0);
            }

            .lotus-calendar-allday-row {
                display: flex;
                border-bottom: 1px solid var(--lotus-color-border);
                flex-shrink: 0;
            }

            .lotus-calendar-allday-label {
                width: 56px;
                flex-shrink: 0;
                display: flex;
                align-items: flex-start;
                justify-content: center;
                padding-top: var(--lotus-spacing-tight);
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-allday-content {
                position: relative;
                flex: 1;
                padding: var(--lotus-spacing-tight) 0;
            }

            .lotus-calendar-week-body {
                display: flex;
                flex: 1;
                overflow-y: auto;
            }

            .lotus-calendar-time-gutter {
                width: 56px;
                flex-shrink: 0;
            }

            .lotus-calendar-time-gutter-cell {
                height: 48px;
                box-sizing: border-box;
                border-top: 1px solid var(--lotus-color-border);
                padding: 2px 4px 0 0;
                text-align: end;
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-day-col {
                position: relative;
                flex: 1;
                border-inline-start: 1px solid var(--lotus-color-border);
            }

            .lotus-calendar-day-col-cell {
                height: 48px;
                box-sizing: border-box;
                border-top: 1px solid var(--lotus-color-border);
                cursor: pointer;
            }

            .lotus-calendar-day-col-cell:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-calendar-day-col-custom {
                position: absolute;
                inset: 0;
                pointer-events: none;
            }

            .lotus-calendar-event {
                position: absolute;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-primary-light-default);
                color: var(--lotus-color-primary);
                font-size: var(--lotus-font-caption-size);
                padding: 1px 4px;
                box-sizing: border-box;
                cursor: pointer;
            }

            .lotus-calendar-event-allday {
                position: absolute;
                height: 1.5em;
            }

            .lotus-calendar-curr-line {
                position: absolute;
                left: 0;
                right: 0;
                height: 1px;
                background: var(--lotus-color-danger);
                z-index: 2;
                pointer-events: none;
            }

            .lotus-calendar-curr-circle {
                position: absolute;
                left: -3px;
                width: 6px;
                height: 6px;
                margin-top: -2.5px;
                border-radius: 50%;
                background: var(--lotus-color-danger);
                z-index: 2;
                pointer-events: none;
            }
        </style>
    </>
}

interface DayEventsProps {
    date: Date;
    events: CalendarEvent[];
    minEventHeight: number;
    renderEvent?: (event: CalendarEvent) => any;
}

function CalendarDayEvents(&{ date, events, minEventHeight, renderEvent }: DayEventsProps) @{
    let &[layout] = track(() => layoutTimedEventsForDay(events));

    <>
        <div class="lotus-calendar-day-events">
            @for (const item of layout; index i) {
                <div
                    class="lotus-calendar-event"
                    style={{
                        top: `${item.top * 100}%`,
                        height: `max(${minEventHeight}px, ${item.height * 100}%)`,
                        insetInlineStart: `${item.left * 100}%`,
                        width: `${item.width * 100}%`,
                    }}
                >
                    {renderEvent ? renderEvent(item.event) : item.event.children}
                </div>
            }
        </div>

        <style>
            .lotus-calendar-day-events {
                position: absolute;
                inset: 0;
                pointer-events: none;
            }

            .lotus-calendar-event {
                position: absolute;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-primary-light-default);
                color: var(--lotus-color-primary);
                font-size: var(--lotus-font-caption-size);
                padding: 1px 4px;
                box-sizing: border-box;
                cursor: pointer;
                pointer-events: auto;
            }
        </style>
    </>
}

interface MonthViewProps {
    anchor: Date;
    events: CalendarEvent[];
    weekStartsOn: number;
    markWeekend: boolean;
    locale: typeof zhCN;
    onGridClick: (event: MouseEvent, value: Date) => void;
    onMoreClick?: (event: MouseEvent, date: Date, remaining: number) => void;
    onClose?: (event: MouseEvent) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
}

function CalendarMonthView(&{
    anchor,
    events,
    weekStartsOn,
    markWeekend,
    locale,
    onGridClick,
    onMoreClick,
    onClose,
    dateGridRender,
    renderEvent,
}: MonthViewProps) @{
    let &[weeks] = track<DayInfo[][]>(() => getMonthWeeks(anchor, weekStartsOn));

    let &[allEvents] = track<CalendarEvent[]>(() => extractAllDayEventsFromAll(events));

    // itemLimit：每个月历格子能完整显示几行事件，超出的用"+N 更多"聚合。
    // 用第一个格子的实测高度代表整月所有格子（月历里每格高度理论上一致，
    // 对齐 Semi 只测量一个 cellDom ref 的做法，不需要逐格单独测量）。
    let &[itemLimit] = track<number>(999);
    let cellNode: HTMLElement | null = null;
    function handleCellRef(node: HTMLElement | null) {
        if (cellNode || !node) return;
        cellNode = node;
        const remeasure = () => { itemLimit = calcMonthItemLimit(node.getBoundingClientRect().height); };
        remeasure();
        if (typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver(remeasure);
        observer.observe(node);
        return () => observer.disconnect();
    }

    function handleDayClick(event: MouseEvent, date: Date) {
        onGridClick(event, date);
    }

    <>
        <div class="lotus-calendar-month-header">
            @for (const weekday of locale.Calendar.weekdays; index i) {
                <div class="lotus-calendar-month-header-cell">{weekday}</div>
            }
        </div>
        <div class="lotus-calendar-month-body">
            @for (const week of weeks; index wi) {
                <CalendarMonthWeekRow
                    week={week}
                    monthAnchor={anchor}
                    events={allEvents}
                    markWeekend={markWeekend}
                    itemLimit={itemLimit}
                    isFirstRow={wi === 0}
                    onCellRef={handleCellRef}
                    onDayClick={handleDayClick}
                    onMoreClick={onMoreClick}
                    onClose={onClose}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
                    locale={locale}
                />
            }
        </div>

        <style>
            .lotus-calendar-month-header {
                display: flex;
                border-bottom: 1px solid var(--lotus-color-border);
                flex-shrink: 0;
            }

            .lotus-calendar-month-header-cell {
                flex: 1;
                text-align: center;
                padding: var(--lotus-spacing-tight) 0;
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-month-body {
                display: flex;
                flex-direction: column;
                flex: 1;
                overflow-y: auto;
            }
        </style>
    </>
}

function extractAllDayEventsFromAll(events: CalendarEvent[]): CalendarEvent[] {
    return events;
}

interface MonthWeekRowProps {
    week: DayInfo[];
    monthAnchor: Date;
    events: CalendarEvent[];
    markWeekend: boolean;
    itemLimit: number;
    isFirstRow: boolean;
    onCellRef: (node: HTMLElement | null) => (() => void) | void;
    onDayClick: (event: MouseEvent, date: Date) => void;
    onMoreClick?: (event: MouseEvent, date: Date, remaining: number) => void;
    onClose?: (event: MouseEvent) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
    locale: typeof zhCN;
}

function CalendarMonthWeekRow(&{
    week,
    monthAnchor,
    events,
    markWeekend,
    itemLimit,
    isFirstRow,
    onCellRef,
    onDayClick,
    onMoreClick,
    onClose,
    dateGridRender,
    renderEvent,
    locale,
}: MonthWeekRowProps) @{
    let &[layout] = track(() => {
        const firstDay = week[0];
        if (!firstDay) return [];
        return layoutRangeEvents(events, firstDay.date, week.length);
    });

    let &[visibleLayout] = track(() => filterEventsByItemLimit(layout, itemLimit));

    // 每天在这一周布局里实际覆盖的事件条数/完整事件列表（不区分跨天/单天，
    // 只看这一列被占用了多少行、覆盖了哪些 event）——countByCol 用来算
    // remaining（超出 itemLimit 的部分），eventsByCol 供"+N 更多"点击后
    // 弹出的 Popover 卡片展示当天全部事件（对齐 Semi renderCollapsed 传入
    // 的 day[ind] 完整事件数组，不受 itemLimit 截断）。
    let &[countByCol] = track<number[]>(() => {
        const counts = new Array(week.length).fill(0);
        for (const item of layout) {
            const startCol = Math.round(item.leftPos * week.length);
            const endCol = startCol + Math.round(item.width * week.length) - 1;
            for (let col = startCol; col <= endCol && col < counts.length; col++) counts[col]++;
        }
        return counts;
    });

    let &[eventsByCol] = track<CalendarEvent[][]>(() => {
        const cols: CalendarEvent[][] = Array.from({ length: week.length }, () => []);
        for (const item of layout) {
            const startCol = Math.round(item.leftPos * week.length);
            const endCol = startCol + Math.round(item.width * week.length) - 1;
            for (let col = startCol; col <= endCol && col < cols.length; col++) cols[col]!.push(item.event);
        }
        return cols;
    });

    let &[openCardKey] = track<string | null>(null);

    function handleMoreClick(event: MouseEvent, date: Date, remaining: number) {
        event.stopPropagation();
        openCardKey = date.toISOString();
        onMoreClick?.(event, date, remaining);
    }

    function handleCardClose(event: MouseEvent) {
        openCardKey = null;
        onClose?.(event);
    }

    <>
        <div class="lotus-calendar-month-week-row">
            @for (const day of week; index i) {
                <div
                    class={[
                        'lotus-calendar-month-cell',
                        day.isToday ? 'lotus-calendar-today' : '',
                        day.date.getMonth() !== monthAnchor.getMonth() ? 'lotus-calendar-month-cell-outside' : '',
                        markWeekend && day.isWeekend ? 'lotus-calendar-weekend' : '',
                    ].filter(Boolean).join(' ')}
                    onClick={(e: MouseEvent) => onDayClick(e, day.date)}
                    ref={isFirstRow && i === 0 ? onCellRef : undefined}
                >
                    <div class="lotus-calendar-month-cell-date">{String(day.date.getDate())}</div>
                    @if (dateGridRender) {
                        <div class="lotus-calendar-month-cell-custom">{dateGridRender(day.date)}</div>
                    }
                    @if (calcRemainingCount(countByCol[i] ?? 0, itemLimit) > 0) {
                        <Popover
                            trigger="custom"
                            visible={openCardKey === day.date.toISOString()}
                            position="bottomLeft"
                            onVisibleChange={(v: boolean) => { if (!v) openCardKey = null; }}
                            content={
                                <div class="lotus-calendar-event-card">
                                    <div class="lotus-calendar-event-card-header">
                                        <span class="lotus-calendar-event-card-header-weekday">{locale.Calendar.weekdays[day.weekday]}</span>
                                        <span class="lotus-calendar-event-card-header-date">{String(day.date.getDate())}</span>
                                        <IconButton
                                            class="lotus-calendar-event-card-close"
                                            icon={<IconClose />}
                                            type="tertiary"
                                            theme="borderless"
                                            size="small"
                                            onClick={handleCardClose}
                                            aria-label={locale.Calendar.close}
                                        />
                                    </div>
                                    <ul class="lotus-calendar-event-card-list">
                                        @for (const evt of eventsByCol[i] ?? []; key evt.key) {
                                            <li>{renderEvent ? renderEvent(evt) : evt.children}</li>
                                        }
                                    </ul>
                                </div>
                            }
                        >
                            <div
                                class="lotus-calendar-month-cell-more"
                                style={{ top: `${itemLimit * 1.5 + 1.5}em` }}
                                role="button"
                                tabIndex={0}
                                onClick={(e: MouseEvent) => handleMoreClick(e, day.date, calcRemainingCount(countByCol[i] ?? 0, itemLimit))}
                                onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleMoreClick(e as any, day.date, calcRemainingCount(countByCol[i] ?? 0, itemLimit)); } }}
                            >
                                {locale.Calendar.remaining(calcRemainingCount(countByCol[i] ?? 0, itemLimit))}
                            </div>
                        </Popover>
                    }
                </div>
            }
            <div class="lotus-calendar-month-week-events">
                @for (const item of visibleLayout; index i) {
                    <div
                        class="lotus-calendar-event lotus-calendar-event-month"
                        style={{
                            insetInlineStart: `${item.leftPos * 100}%`,
                            width: `${item.width * 100}%`,
                            top: `${item.topInd * 1.5}em`,
                        }}
                    >
                        {renderEvent ? renderEvent(item.event) : item.event.children}
                    </div>
                }
            </div>
        </div>

        <style>
            .lotus-calendar-month-week-row {
                position: relative;
                display: flex;
                flex: 1;
                min-height: 96px;
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-calendar-weekend {
                background: var(--lotus-color-fill-0);
            }

            .lotus-calendar-month-cell {
                flex: 1;
                box-sizing: border-box;
                border-inline-start: 1px solid var(--lotus-color-border);
                padding: var(--lotus-spacing-tight);
                cursor: pointer;
            }

            .lotus-calendar-month-cell:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-calendar-month-cell-date {
                font-size: var(--lotus-font-body-size);
                font-weight: 600;
            }

            .lotus-calendar-today .lotus-calendar-month-cell-date {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 22px;
                height: 22px;
                border-radius: 50%;
                background: var(--lotus-color-primary);
                color: var(--lotus-color-bg-1);
            }

            .lotus-calendar-month-cell-outside {
                color: var(--lotus-color-text-3);
            }

            .lotus-calendar-month-cell-more {
                position: absolute;
                inset-inline: var(--lotus-spacing-tight);
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
                cursor: pointer;
            }

            .lotus-calendar-month-cell-more:hover {
                color: var(--lotus-color-primary);
                text-decoration: underline;
            }

            .lotus-calendar-event-card {
                min-width: 200px;
                max-width: 280px;
            }

            .lotus-calendar-event-card-header {
                display: flex;
                align-items: center;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base);
                border-bottom: 1px solid var(--lotus-color-border);
            }

            .lotus-calendar-event-card-header-weekday {
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-event-card-header-date {
                font-weight: 600;
                flex: 1;
            }

            .lotus-calendar-event-card-list {
                list-style: none;
                margin: 0;
                padding: var(--lotus-spacing-tight) var(--lotus-spacing-base);
                max-height: 240px;
                overflow-y: auto;
            }

            .lotus-calendar-event-card-list li {
                padding: var(--lotus-spacing-super-tight) 0;
                font-size: var(--lotus-font-caption-size);
            }

            .lotus-calendar-month-week-events {
                position: absolute;
                inset-inline: 0;
                top: 28px;
                bottom: 0;
                pointer-events: none;
            }

            .lotus-calendar-event {
                position: absolute;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-small);
                background: var(--lotus-color-primary-light-default);
                color: var(--lotus-color-primary);
                font-size: var(--lotus-font-caption-size);
                padding: 1px 4px;
                box-sizing: border-box;
                cursor: pointer;
            }

            .lotus-calendar-event-month {
                height: 1.25em;
                pointer-events: auto;
            }
        </style>
    </>
}
