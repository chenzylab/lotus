import { track, untrack } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import {
    type CalendarEvent,
    type DayInfo,
    layoutTimedEventsForDay,
    layoutRangeEvents,
    getWeekDays,
    getMonthWeeks,
    groupTimedEventsByDay,
    extractAllDayEvents,
} from '@lotus/foundation/show/calendar';

export type { CalendarEvent };
export type CalendarMode = 'week' | 'month';

export interface CalendarProps {
    mode?: CalendarMode;
    displayValue?: Date;
    events?: CalendarEvent[];
    weekStartsOn?: number;
    markWeekend?: boolean;
    minEventHeight?: number;
    height?: string | number;
    width?: string | number;
    onClick?: (event: MouseEvent, value: Date) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const HOURS = Array.from({ length: 24 }, (_, i) => i);

function formatHour(hour: number, locale: string): string {
    if (locale === 'zh-CN') return `${hour}:00`;
    const period = hour < 12 ? 'AM' : 'PM';
    const displayHour = hour % 12 === 0 ? 12 : hour % 12;
    return `${displayHour} ${period}`;
}

export function Calendar(&{
    mode = 'week',
    displayValue,
    events = [],
    weekStartsOn = 0,
    markWeekend = false,
    minEventHeight = 18,
    height = 600,
    width,
    onClick,
    dateGridRender,
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

    <>
        <div class={classes} style={{ ...(width !== undefined ? { width } : {}), height, ...style }} role="grid" aria-label={ariaLabel ?? 'Calendar'}>
            @if (mode === 'week') {
                <CalendarWeekView
                    anchor={anchor}
                    events={events}
                    weekStartsOn={weekStartsOn}
                    markWeekend={markWeekend}
                    minEventHeight={minEventHeight}
                    locale={locale}
                    onGridClick={handleGridClick}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
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

interface WeekViewProps {
    anchor: Date;
    events: CalendarEvent[];
    weekStartsOn: number;
    markWeekend: boolean;
    minEventHeight: number;
    locale: typeof zhCN;
    onGridClick: (event: MouseEvent, value: Date) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
}

function CalendarWeekView(&{
    anchor,
    events,
    weekStartsOn,
    markWeekend,
    minEventHeight,
    locale,
    onGridClick,
    dateGridRender,
    renderEvent,
}: WeekViewProps) @{
    let &[days] = track<DayInfo[]>(() => getWeekDays(anchor, weekStartsOn));

    let &[allDayEvents] = track<CalendarEvent[]>(() => extractAllDayEvents(events));

    let &[allDayLayout] = track(() => {
        const weekDays = days;
        const firstDay = weekDays[0];
        if (!firstDay) return [];
        return layoutRangeEvents(allDayEvents, firstDay.date, weekDays.length);
    });

    let &[allDayRowCount] = track<number>(() => {
        const maxTop = allDayLayout.reduce((max, item) => Math.max(max, item.topInd), -1);
        return maxTop + 1;
    });

    let &[timedEventsByDay] = track(() => groupTimedEventsByDay(events));

    function handleCellClick(event: MouseEvent, date: Date, hour: number) {
        const value = new Date(date);
        value.setHours(hour, 0, 0, 0);
        onGridClick(event, value);
    }

    <>
        <div class="lotus-calendar-week-header">
            <div class="lotus-calendar-week-header-gutter" />
            @for (const day of days; index i) {
                <div class={['lotus-calendar-week-header-cell', day.isToday ? 'lotus-calendar-today' : '', markWeekend && day.isWeekend ? 'lotus-calendar-weekend' : ''].filter(Boolean).join(' ')}>
                    <span class="lotus-calendar-week-header-weekday">{locale.Calendar.weekdays[day.weekday]}</span>
                    <span class="lotus-calendar-week-header-date">{String(day.date.getDate())}</span>
                </div>
            }
        </div>

        @if (allDayRowCount > 0) {
            <div class="lotus-calendar-allday-row" style={{ height: `${allDayRowCount * 1.75 + 0.5}em` }}>
                <div class="lotus-calendar-allday-label">{locale.Calendar.allDay}</div>
                <div class="lotus-calendar-allday-content">
                    @for (const item of allDayLayout; index i) {
                        <div
                            class="lotus-calendar-event lotus-calendar-event-allday"
                            style={{
                                left: `${item.leftPos * 100}%`,
                                width: `${item.width * 100}%`,
                                top: `${item.topInd * 1.75}em`,
                            }}
                        >
                            {renderEvent ? renderEvent(item.event) : item.event.children}
                        </div>
                    }
                </div>
            </div>
        }

        <div class="lotus-calendar-week-body">
            <div class="lotus-calendar-time-gutter">
                @for (const hour of HOURS; index i) {
                    <div class="lotus-calendar-time-gutter-cell">{formatHour(hour, locale.code)}</div>
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
                text-align: right;
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
            }

            .lotus-calendar-day-col {
                position: relative;
                flex: 1;
                border-left: 1px solid var(--lotus-color-border);
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

    <div class="lotus-calendar-day-events">
        @for (const item of layout; index i) {
            <div
                class="lotus-calendar-event"
                style={{
                    top: `${item.top * 100}%`,
                    height: `max(${minEventHeight}px, ${item.height * 100}%)`,
                    left: `${item.left * 100}%`,
                    width: `${item.width * 100}%`,
                }}
            >
                {renderEvent ? renderEvent(item.event) : item.event.children}
            </div>
        }

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
    </div>
}

interface MonthViewProps {
    anchor: Date;
    events: CalendarEvent[];
    weekStartsOn: number;
    markWeekend: boolean;
    locale: typeof zhCN;
    onGridClick: (event: MouseEvent, value: Date) => void;
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
    dateGridRender,
    renderEvent,
}: MonthViewProps) @{
    let &[weeks] = track<DayInfo[][]>(() => getMonthWeeks(anchor, weekStartsOn));

    let &[allEvents] = track<CalendarEvent[]>(() => extractAllDayEventsFromAll(events));

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
                    onDayClick={handleDayClick}
                    dateGridRender={dateGridRender}
                    renderEvent={renderEvent}
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
    onDayClick: (event: MouseEvent, date: Date) => void;
    dateGridRender?: (date: Date) => any;
    renderEvent?: (event: CalendarEvent) => any;
}

function CalendarMonthWeekRow(&{ week, monthAnchor, events, markWeekend, onDayClick, dateGridRender, renderEvent }: MonthWeekRowProps) @{
    let &[layout] = track(() => {
        const firstDay = week[0];
        if (!firstDay) return [];
        return layoutRangeEvents(events, firstDay.date, week.length);
    });

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
            >
                <div class="lotus-calendar-month-cell-date">{String(day.date.getDate())}</div>
                @if (dateGridRender) {
                    <div class="lotus-calendar-month-cell-custom">{dateGridRender(day.date)}</div>
                }
            </div>
        }
        <div class="lotus-calendar-month-week-events">
            @for (const item of layout; index i) {
                <div
                    class="lotus-calendar-event lotus-calendar-event-month"
                    style={{
                        left: `${item.leftPos * 100}%`,
                        width: `${item.width * 100}%`,
                        top: `${item.topInd * 1.5}em`,
                    }}
                >
                    {renderEvent ? renderEvent(item.event) : item.event.children}
                </div>
            }
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
                border-left: 1px solid var(--lotus-color-border);
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

            .lotus-calendar-month-week-events {
                position: absolute;
                left: 0;
                right: 0;
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
    </div>
}
