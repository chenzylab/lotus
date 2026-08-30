import { track, untrack, effect } from 'ripple';
import {
    DatePickerFoundation,
    getMonthTable,
    getDayOfWeek,
    getDayStatus,
    getTodayText,
    isValidDate,
    isRangeType,
    isDateTimeType,
    isYearOrMonthType,
    emptyInsetInputValue,
    type DatePickerState,
    type DatePickerFoundationOptions,
    type PickerType,
    type PanelType,
    type RangeValue,
    type PresetType,
    type BaseValueType,
    type WeekStartNumber,
    type MonthDayInfo,
} from '@lotus/foundation/input/date-picker';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';
import { Input, type InputSize, type InputValidateStatus } from '../input/index.tsrx';
import { Button } from '../../basic/button/index.tsrx';
import { IconButton } from '../../basic/icon-button/index.tsrx';
import { ScrollList } from '../../show/scroll-list/index.tsrx';
import { ScrollItem, type ScrollListItemData } from '../../show/scroll-list/item.tsrx';
import { TimeColumns } from '../time-picker/index.tsrx';
import { IconCalendar, IconChevronLeft, IconChevronRight, IconDoubleChevronLeft, IconDoubleChevronRight } from '@lotus/icons';

export type DatePickerType = PickerType;
export type DatePickerSize = InputSize;
export type DatePickerValidateStatus = InputValidateStatus;
export type DatePickerValue = Date | Date[] | RangeValue | null;

export interface DisabledDateOptions {
    rangeStart: string;
    rangeEnd: string;
    rangeInputFocus: 'rangeStart' | 'rangeEnd' | false;
}

export interface DisabledTimeRulesDP {
    disabledHours?: () => number[];
    disabledMinutes?: (hour: number) => number[];
    disabledSeconds?: (hour: number, minute: number) => number[];
}

export interface DatePickerProps {
    type?: DatePickerType;
    value?: DatePickerValue;
    defaultValue?: DatePickerValue;
    defaultPickerValue?: Date | Date[];
    format?: string;
    open?: boolean;
    defaultOpen?: boolean;
    onOpenChange?: (open: boolean) => void;
    disabled?: boolean;
    disabledDate?: (date: Date, options?: DisabledDateOptions) => boolean;
    disabledTime?: (date: Date | Date[] | null, panelType?: PanelType) => DisabledTimeRulesDP | undefined;
    placeholder?: string;
    size?: DatePickerSize;
    validateStatus?: DatePickerValidateStatus;
    borderless?: boolean;
    showClear?: boolean;
    position?: FloatingPosition;
    weekStartsOn?: WeekStartNumber;
    rangeSeparator?: string;
    multiple?: boolean;
    max?: number;
    syncSwitchMonth?: boolean;
    presets?: PresetType[];
    presetPosition?: 'left' | 'right' | 'top' | 'bottom';
    onPresetClick?: (item: PresetType) => void;
    needConfirm?: boolean;
    use12Hours?: boolean;
    hourStep?: number;
    minuteStep?: number;
    secondStep?: number;
    startYear?: number;
    endYear?: number;
    onChange?: (value: DatePickerValue, dateString: string | string[]) => void;
    onPanelChange?: (date: Date) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function resolveBaseValue(v: BaseValueType | (() => BaseValueType) | undefined): Date | null {
    const raw = typeof v === 'function' ? v() : v;
    if (raw == null) return null;
    if (raw instanceof Date) return raw;
    return new Date(raw);
}

function toValueArray(value: DatePickerValue): Array<Date | null> {
    if (Array.isArray(value)) return value;
    if (value) return [value];
    return [];
}

interface NavigationProps {
    monthText: string;
    onPrevYear: () => void;
    onPrevMonth: () => void;
    onNextMonth: () => void;
    onNextYear: () => void;
    onHeaderClick: () => void;
    prevYearLabel: string;
    prevMonthLabel: string;
    nextMonthLabel: string;
    nextYearLabel: string;
    /** RTL 模式下上/下月、上/下年箭头需要水平镜像（对齐 Semi 一手来源
     * semi-foundation/datePicker/rtl.scss 的 transform: scaleX(-1) 方案），
     * 由父组件读取 locale.dir 后传入，Navigation 自身不直接依赖 LocaleContext。 */
    rtlIconStyle?: Record<string, any>;
}

function Navigation(&{
    monthText,
    onPrevYear,
    onPrevMonth,
    onNextMonth,
    onNextYear,
    onHeaderClick,
    prevYearLabel,
    prevMonthLabel,
    nextMonthLabel,
    nextYearLabel,
    rtlIconStyle,
}: NavigationProps) @{
    <>
        <div class="lotus-date-picker-navigation">
            <IconButton icon={<IconDoubleChevronLeft style={rtlIconStyle} />} theme="borderless" size="small" onClick={onPrevYear} aria-label={prevYearLabel} />
            <IconButton icon={<IconChevronLeft style={rtlIconStyle} />} theme="borderless" size="small" onClick={onPrevMonth} aria-label={prevMonthLabel} />
            <button type="button" class="lotus-date-picker-navigation-text" onClick={onHeaderClick}>{monthText}</button>
            <IconButton icon={<IconChevronRight style={rtlIconStyle} />} theme="borderless" size="small" onClick={onNextMonth} aria-label={nextMonthLabel} />
            <IconButton icon={<IconDoubleChevronRight style={rtlIconStyle} />} theme="borderless" size="small" onClick={onNextYear} aria-label={nextYearLabel} />
        </div>

        <style>
            .lotus-date-picker-navigation {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 8px;
            }

            .lotus-date-picker-navigation-text {
                border: none;
                background: transparent;
                cursor: pointer;
                font-size: var(--lotus-font-body-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
                padding: 4px 8px;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-date-picker-navigation-text:hover {
                background: var(--lotus-color-fill-0);
            }
        </style>
    </>
}

interface MonthGridProps {
    pickerDate: Date;
    weekStartsOn: WeekStartNumber;
    selected: Set<string>;
    rangeStart: string;
    rangeEnd: string;
    isRange: boolean;
    offsetRangeStart: string;
    offsetRangeEnd: string;
    rangeInputFocus: 'rangeStart' | 'rangeEnd' | false;
    disabledDate?: (date: Date, options?: DisabledDateOptions) => boolean;
    weekdayLabels: string[];
    onDayClick: (fullDate: string) => void;
}

/**
 * hoverDay 是本组件的局部 state，不经过顶层 DatePicker 的共享 Foundation state
 * 往返——真机 e2e 排查发现，若 hover 写入顶层共享 state，会级联触发整个
 * DatePicker（含另一侧面板）重渲染，父组件重渲染又会给两个 MonthGrid 实例
 * 传入全新的内联箭头函数 prop（onDayClick 等），足以让 Playwright 判定目标
 * 元素"不稳定"甚至短暂从 DOM 摘除重挂载，导致 click 事件在按下与抬起之间丢失
 * （现象：日期格点击偶发无响应，`locator.click` 报 "element was detached"）。
 * hover 预览态本身只需要影响"当前鼠标所在这一侧面板"，本就没有必要经过顶层
 * 状态往返，改成局部 state 后重渲染范围收窄到本面板自身，问题消失。
 */
function MonthGrid(&{
    pickerDate,
    weekStartsOn,
    selected,
    rangeStart,
    rangeEnd,
    isRange,
    offsetRangeStart,
    offsetRangeEnd,
    rangeInputFocus,
    disabledDate,
    weekdayLabels,
    onDayClick,
}: MonthGridProps) @{
    let &[table] = track(() => getMonthTable(pickerDate, weekStartsOn));
    let &[todayText] = track<string>(() => getTodayText());
    let &[hoverDay] = track<string>('');

    function dayClass(day: MonthDayInfo): string {
        if (!day.fullDate) return 'lotus-date-picker-day lotus-date-picker-day-empty';
        const status = getDayStatus({
            fullDate: day.fullDate,
            todayText,
            selected,
            disabledDate,
            rangeStart,
            rangeEnd,
            hoverDay,
            offsetRangeStart,
            offsetRangeEnd,
            rangeInputFocus,
        });
        return [
            'lotus-date-picker-day',
            status.isToday ? 'lotus-date-picker-day-today' : '',
            status.isSelected ? 'lotus-date-picker-day-selected' : '',
            status.isDisabled ? 'lotus-date-picker-day-disabled' : '',
            status.isSelectedStart ? 'lotus-date-picker-day-selected-start' : '',
            status.isSelectedEnd ? 'lotus-date-picker-day-selected-end' : '',
            status.isInRange ? 'lotus-date-picker-day-inrange' : '',
            status.isHover ? 'lotus-date-picker-day-hover' : '',
            status.isOffsetRangeStart ? 'lotus-date-picker-day-offset-start' : '',
            status.isOffsetRangeEnd ? 'lotus-date-picker-day-offset-end' : '',
            status.isInOffsetRange ? 'lotus-date-picker-day-inoffsetrange' : '',
        ].filter(Boolean).join(' ');
    }

    function handleClick(day: MonthDayInfo) {
        if (!day.fullDate) return;
        const status = getDayStatus({
            fullDate: day.fullDate,
            todayText,
            selected,
            disabledDate,
            rangeStart,
            rangeEnd,
            hoverDay,
            offsetRangeStart,
            offsetRangeEnd,
            rangeInputFocus,
        });
        if (status.isDisabled) return;
        onDayClick(day.fullDate);
    }

    function handleHover(day: MonthDayInfo) {
        if (!isRange || !day.fullDate) return;
        hoverDay = day.fullDate;
    }

    <>
        <div class="lotus-date-picker-month">
            <div class="lotus-date-picker-weekdays">
                @for (const w of weekdayLabels; index i) {
                    <div class="lotus-date-picker-weekday">{w}</div>
                }
            </div>
            <div class="lotus-date-picker-weeks">
                @for (const week of table.weeks; index wi) {
                    <div class="lotus-date-picker-week">
                        @for (const day of week; index di; key day.dayNumberFull || day.fullDate) {
                            <div
                                role={day.fullDate ? 'gridcell' : undefined}
                                tabIndex={day.fullDate ? 0 : undefined}
                                class={dayClass(day)}
                                onClick={() => handleClick(day)}
                                onMouseEnter={() => handleHover(day)}
                            >
                                {day.dayNumber}
                            </div>
                        }
                    </div>
                }
            </div>
        </div>

        <style>
            .lotus-date-picker-month {
                padding: 0 8px 8px;
            }

            .lotus-date-picker-weekdays,
            .lotus-date-picker-week {
                display: flex;
            }

            .lotus-date-picker-weekday {
                flex: 1;
                text-align: center;
                font-size: var(--lotus-font-caption-size);
                color: var(--lotus-color-text-2);
                padding: 4px 0;
            }

            .lotus-date-picker-day {
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                height: 32px;
                margin: 1px 0;
                cursor: pointer;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-date-picker-day-empty {
                cursor: default;
            }

            .lotus-date-picker-day:not(.lotus-date-picker-day-empty):hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-date-picker-day-today {
                font-weight: 600;
                color: var(--lotus-color-primary);
            }

            .lotus-date-picker-day-selected {
                background: var(--lotus-color-primary);
                color: var(--lotus-color-text-inverse, #fff);
            }

            .lotus-date-picker-day-inrange,
            .lotus-date-picker-day-hover,
            .lotus-date-picker-day-inoffsetrange {
                background: var(--lotus-color-fill-0);
                border-radius: 0;
            }

            .lotus-date-picker-day-selected-start {
                border-start-end-radius: 0;
                border-end-end-radius: 0;
            }

            .lotus-date-picker-day-selected-end {
                border-start-start-radius: 0;
                border-end-start-radius: 0;
            }

            .lotus-date-picker-day-offset-start,
            .lotus-date-picker-day-offset-end {
                background: var(--lotus-color-primary);
                color: var(--lotus-color-text-inverse, #fff);
            }

            .lotus-date-picker-day-disabled {
                color: var(--lotus-color-text-3);
                cursor: not-allowed;
            }

            .lotus-date-picker-day-disabled:hover {
                background: transparent;
            }
        </style>
    </>
}

interface YearMonthWheelProps {
    years: Array<{ value: number; disabled: boolean }>;
    months: Array<{ value: number; disabled: boolean }>;
    selectedYear: number;
    selectedMonth: number;
    monthLabels: string[];
    showMonth: boolean;
    onSelectYear: (year: number) => void;
    onSelectMonth: (month: number) => void;
    onBack: () => void;
    backLabel: string;
    yearLabel: string;
    monthLabel: string;
    /** "返回"箭头是方向性图标，RTL 下语义镜像（LTR 指向左表示返回，RTL
     * 下阅读顺序反转，返回箭头应指向右）。 */
    rtlIconStyle?: Record<string, any>;
}

function YearMonthWheel(&{
    years,
    months,
    selectedYear,
    selectedMonth,
    monthLabels,
    showMonth,
    onSelectYear,
    onSelectMonth,
    onBack,
    backLabel,
    yearLabel,
    monthLabel,
    rtlIconStyle,
}: YearMonthWheelProps) @{
    let &[yearList] = track<ScrollListItemData<number>[]>(() => years.map((y) => ({ value: y.value, text: `${y.value}`, disabled: y.disabled })));
    let &[monthList] = track<ScrollListItemData<number>[]>(() => months.map((m) => ({ value: m.value, text: monthLabels[m.value - 1] ?? `${m.value}`, disabled: m.disabled })));
    let &[yearIndex] = track<number>(() => years.findIndex((y) => y.value === selectedYear));
    let &[monthIndex] = track<number>(() => months.findIndex((m) => m.value === selectedMonth));

    <>
        <div class="lotus-date-picker-yam">
            <div class="lotus-date-picker-yam-header">
                <IconButton icon={<IconChevronLeft style={rtlIconStyle} />} theme="borderless" size="small" onClick={onBack} aria-label={backLabel} />
            </div>
            <ScrollList bodyHeight={224}>
                <ScrollItem mode="normal" list={yearList} selectedIndex={yearIndex} onSelect={(item) => onSelectYear(item.value)} aria-label={yearLabel} />
                @if (showMonth) {
                    <ScrollItem mode="normal" list={monthList} selectedIndex={monthIndex} onSelect={(item) => onSelectMonth(item.value)} aria-label={monthLabel} />
                }
            </ScrollList>
        </div>

        <style>
            .lotus-date-picker-yam-header {
                padding: 4px 8px;
            }
        </style>
    </>
}

/**
 * DatePicker：日期/日期范围/日期时间/月份/年份选择。触发器复用 Input，浮层复用
 * Popover(trigger="custom")，日历网格/年月滚轮/时间列均为组件内私有子组件。
 * 状态机完整移植自参考实现（对齐 Semi 多协作 Foundation 的合集），合并为单一
 * DatePickerFoundation。dateTime 系列复用 TimePicker 拆出的 TimeColumns 时间列。
 */
export function DatePicker(&{
    type = 'date',
    value,
    defaultValue,
    defaultPickerValue,
    format,
    open,
    defaultOpen = false,
    onOpenChange,
    disabled = false,
    disabledDate,
    disabledTime,
    placeholder,
    size = 'default',
    validateStatus = 'default',
    borderless = false,
    showClear = true,
    position = 'bottomLeft',
    weekStartsOn = 0,
    rangeSeparator = ' ~ ',
    multiple = false,
    max,
    syncSwitchMonth = false,
    presets = [],
    presetPosition = 'bottom',
    onPresetClick,
    needConfirm = false,
    use12Hours = false,
    hourStep = 1,
    minuteStep = 1,
    secondStep = 1,
    startYear,
    endYear,
    onChange,
    onPanelChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: DatePickerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    // 上/下月、上/下年箭头是方向性图标，RTL 下需要水平镜像（对齐 Semi
    // 一手来源 semi-foundation/datePicker/rtl.scss 的 scaleX(-1) 方案）。
    let &[rtlIconStyle] = track<Record<string, any> | undefined>(() => (locale.dir === 'rtl' ? { transform: 'scaleX(-1)' } : undefined));

    const isRange = isRangeType(type);
    const isDateTime = isDateTimeType(type);
    const isYearOrMonth = isYearOrMonthType(type);
    const isControlled = value !== undefined;
    const effectiveNeedConfirm = needConfirm && isDateTime;

    function toRangePair(v: DatePickerValue): RangeValue {
        if (Array.isArray(v)) return [(v[0] as Date) ?? null, (v[1] as Date) ?? null];
        return [null, null];
    }

    function initialSingle(): Date | Date[] | null {
        const dv = (isControlled ? value : defaultValue) as Date | Date[] | null | undefined;
        if (multiple) {
            if (Array.isArray(dv)) return dv;
            if (dv instanceof Date) return [dv];
            return [];
        }
        if (Array.isArray(dv)) return (dv[0] as Date) ?? null;
        return (dv as Date | null) ?? null;
    }

    let &[state] = track<DatePickerState>({
        value: isRange ? null : initialSingle(),
        rangeValue: isRange ? toRangePair((isControlled ? value : defaultValue) ?? null) : [null, null],
        visible: open ?? defaultOpen,
        cachedValue: null,
        cachedRange: null,
        selected: new Set<string>(),
        rangeStart: '',
        rangeEnd: '',
        rangeInputFocus: false,
        hoverDay: '',
        offsetRangeStart: '',
        offsetRangeEnd: '',
        monthLeft: { pickerDate: new Date(), showDate: new Date(), isTimePickerOpen: false, isYearPickerOpen: false },
        monthRight: { pickerDate: new Date(), showDate: new Date(), isTimePickerOpen: false, isYearPickerOpen: false },
        yamYear: { left: 0, right: 0 },
        yamMonth: { left: 0, right: 0 },
        showYearMonthPicker: false,
        insetInputValue: emptyInsetInputValue(),
    });

    const foundationOpts: DatePickerFoundationOptions = {
        type,
        multiple,
        format,
        weekStartsOn,
        rangeSeparator,
        onChangeDateFirst: true,
    };

    const foundation = new DatePickerFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<DatePickerState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        foundationOpts,
    );

    untrack(() => {
        foundation.initPanels(defaultPickerValue);
        if (isYearOrMonth) foundation.initYearMonth((isControlled ? value : defaultValue) ?? null);
        else if (isRange) foundation.syncPanelsFromRangeValue(toRangePair((isControlled ? value : defaultValue) ?? null));
        else foundation.syncSelectedFromValue(initialSingle());
    });

    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value === undefined) return;
        untrack(() => { hasBeenControlled = true; });
        if (isRange) {
            const pair = toRangePair(value);
            untrack(() => { state = { ...state, rangeValue: pair }; foundation.syncPanelsFromRangeValue(pair); });
        } else if (isYearOrMonth) {
            untrack(() => { foundation.initYearMonth(value); });
        } else {
            const v = multiple ? ((Array.isArray(value) ? value : []) as Date[]) : ((Array.isArray(value) ? value[0] : value) as Date | null);
            untrack(() => { state = { ...state, value: v }; foundation.syncSelectedFromValue(v); });
        }
    });

    effect(() => {
        if (open !== undefined) untrack(() => { state = { ...state, visible: open }; });
    });

    let &[rootNode] = track<HTMLElement | null>(null);
    let &[panelNode] = track<HTMLElement | null>(null);

    function notifyOpenChange(next: boolean) {
        onOpenChange?.(next);
    }

    function emit(notifyValue: unknown) {
        if (!onChange) return;
        if (Array.isArray(notifyValue) && notifyValue.length === 0) {
            onChange(isRange ? [] : (multiple ? [] : null), isRange || multiple ? [] : '');
            return;
        }
        const token = foundation.getValidDateFormat();
        const arr = Array.isArray(notifyValue) ? (notifyValue as Array<Date | null>) : [notifyValue as Date | null];
        const strs = arr.filter((d): d is Date => !!d).map((d) => foundation.localeFormat(d, token));
        const dateString = isRange ? strs : (multiple ? strs : (strs[0] ?? ''));
        onChange(notifyValue as DatePickerValue, dateString as string | string[]);
    }

    function handleTriggerClick() {
        if (disabled) return;
        if (untrack(() => state).visible) return;
        foundation.open();
        notifyOpenChange(true);
    }

    function closePanel() {
        if (!untrack(() => state).visible) return;
        foundation.close();
        notifyOpenChange(false);
    }

    /**
     * dateTime/dateTimeRange 选完日期后不自动关闭——用户很可能还要点 Switch
     * 切到时间列调整时分秒，提前关闭面板会让这个交互路径完全不可达。
     * 仅 needConfirm=false 时的纯 date/dateRange（不含时间维度）才自动关闭。
     */
    function maybeAutoClose() {
        if (effectiveNeedConfirm || isDateTime) return;
        if (isRange) {
            const s = untrack(() => state);
            if (s.rangeStart && s.rangeEnd) closePanel();
        } else if (!multiple) {
            closePanel();
        }
    }

    function handleDayClick(fullDate: string, panelType: PanelType) {
        if (isRange) {
            const result = foundation.handleRangeSelected(fullDate, isControlled, effectiveNeedConfirm, {
                onFocusChange: (focus) => foundation.setRangeInputFocus(focus),
            });
            if (result?.shouldNotify) emit(result.notifyValue);
        } else {
            const result = foundation.handleDateSelected(fullDate, panelType, isControlled, effectiveNeedConfirm, max, undefined);
            if (result.shouldNotify) emit(result.notifyValue);
        }
        maybeAutoClose();
    }

    function handleTimeSelect(panelType: PanelType, h: number, m: number, s: number) {
        const panel = panelType === 'right' ? untrack(() => state).monthRight : untrack(() => state).monthLeft;
        const base = new Date(panel.showDate);
        base.setHours(h, m, s, 0);
        const result = foundation.handleTimeChange(panelType, base.getTime(), isControlled, effectiveNeedConfirm);
        if (result?.shouldNotify) emit(result.notifyValue);
    }

    function switchMonth(switchType: 'prevMonth' | 'nextMonth' | 'prevYear' | 'nextYear', panelType: PanelType) {
        foundation.switchMonthOrYear(switchType, panelType, syncSwitchMonth, onPanelChange);
    }

    function handleConfirm() {
        const result = foundation.commitCached(isControlled);
        if (result.shouldNotify) emit(result.notifyValue);
        closePanel();
    }

    function handleCancel() {
        foundation.clearCached();
        closePanel();
    }

    function handleClear() {
        const result = foundation.clear(isControlled);
        emit(result.notifyValue);
    }

    function handlePresetClick(item: PresetType) {
        const start = resolveBaseValue(item.start);
        if (isRange) {
            const end = resolveBaseValue(item.end);
            const result = foundation.handleRangeSelectedChange([start, end], isControlled, effectiveNeedConfirm);
            foundation.syncPanelsFromRangeValue([start, end]);
            if (result.shouldNotify) emit(result.notifyValue);
        } else if (start) {
            foundation.syncSelectedFromValue(start);
            const result = foundation.handleSelectedChange(multiple ? [start] : start, isControlled, effectiveNeedConfirm);
            if (result.shouldNotify) emit(result.notifyValue);
        }
        onPresetClick?.(item);
        maybeAutoClose();
    }

    function handleYamSelectYear(panelType: PanelType, year: number) {
        foundation.selectYear(year, panelType, disabledDate ? (d: Date) => disabledDate(d) : undefined);
        // type='year' 无月份列可选，选年即定终局，需在此直接提交（month/monthRange 由选月/确认按钮提交）。
        if (type === 'year') {
            const result = foundation.commitYearMonth(isControlled, effectiveNeedConfirm);
            if (result.shouldNotify) emit(result.notifyValue);
            maybeAutoClose();
        }
    }

    function handleYamSelectMonth(panelType: PanelType, month: number) {
        foundation.selectMonth(month, panelType);
        if (type === 'year' || type === 'month') {
            const result = foundation.commitYearMonth(isControlled, effectiveNeedConfirm);
            if (result.shouldNotify) emit(result.notifyValue);
            maybeAutoClose();
        } else if (!isYearOrMonth) {
            // date/dateRange/dateTime/dateTimeRange：YAM 只是"跳转日历游标"的导航
            // 辅助入口（对齐 Navigation 点标题 drill-down），选完年月要跳回日历网格
            // 定位到该年月，不能停留在滚轮视图——否则用户点了年月却回不去选日。
            const s = untrack(() => state);
            const y = s.yamYear[panelType];
            const target = new Date(y, month - 1, 1);
            foundation.toYearMonth(panelType, target);
            foundation.showDatePanel(panelType);
        }
    }

    function handleYamConfirmRange() {
        const result = foundation.commitYearMonth(isControlled, effectiveNeedConfirm);
        if (result.shouldNotify) emit(result.notifyValue);
        maybeAutoClose();
    }

    function handleInputBlur(raw: string) {
        const result = foundation.handleInputComplete(raw, isControlled);
        if (result?.shouldNotify) emit(result.notifyValue);
    }

    effect(() => {
        const handleDocumentMouseDown = (event: MouseEvent) => {
            if (!untrack(() => state).visible) return;
            if (!(event.target instanceof Node)) return;
            const root = untrack(() => rootNode);
            if (root?.contains(event.target)) return;
            const panel = untrack(() => panelNode);
            if (panel?.contains(event.target)) return;
            closePanel();
        };
        document.addEventListener('mousedown', handleDocumentMouseDown);
        return () => document.removeEventListener('mousedown', handleDocumentMouseDown);
    });

    // Esc 关闭面板（对齐 Popconfirm 已验证的模式）：面板打开时按 Esc 直接关闭，
    // 不触发任何值提交，语义上等同于点击外部区域取消当前操作。
    effect(() => {
        if (typeof window === 'undefined') return;
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key !== 'Escape') return;
            if (!untrack(() => state).visible) return;
            closePanel();
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    let &[displayValue] = track<string>(() => {
        if (isRange) return '';
        const v = state.cachedValue ?? state.value;
        return foundation.formatShowText(v);
    });

    let &[rangeLeftValue] = track<string>(() => {
        const [s] = state.cachedRange ?? state.rangeValue;
        return s ? foundation.localeFormat(s, foundation.getValidDateFormat()) : '';
    });
    let &[rangeRightValue] = track<string>(() => {
        const [, e] = state.cachedRange ?? state.rangeValue;
        return e ? foundation.localeFormat(e, foundation.getValidDateFormat()) : '';
    });

    let &[weekdayLabels] = track<string[]>(() => {
        const order = getDayOfWeek(weekStartsOn);
        const map: Record<string, string> = { Sun: locale.DatePicker.weeks[0], Mon: locale.DatePicker.weeks[1], Tue: locale.DatePicker.weeks[2], Wed: locale.DatePicker.weeks[3], Thu: locale.DatePicker.weeks[4], Fri: locale.DatePicker.weeks[5], Sat: locale.DatePicker.weeks[6] };
        return order.map((k) => map[k] ?? k);
    });

    let &[effPlaceholder] = track<string>(() => placeholder ?? locale.DatePicker.placeholder[type]);

    let &[classes] = track<string>(() =>
        ['lotus-date-picker', disabled ? 'lotus-date-picker-disabled' : '', className ?? ''].filter(Boolean).join(' '),
    );

    function panelDisabledDate(d: Date, opts?: DisabledDateOptions) {
        return disabledDate ? disabledDate(d, opts) : false;
    }

    function yamProps(panelType: PanelType) {
        const showMonth = type !== 'year';
        const years = foundation.yearList(panelType, startYear, endYear, disabledDate ? (d: Date) => disabledDate(d) : undefined);
        const months = foundation.monthList(panelType, disabledDate ? (d: Date) => disabledDate(d) : undefined);
        return {
            years,
            months,
            selectedYear: state.yamYear[panelType],
            selectedMonth: state.yamMonth[panelType],
            monthLabels: locale.DatePicker.months,
            showMonth,
            onSelectYear: (y: number) => handleYamSelectYear(panelType, y),
            onSelectMonth: (m: number) => handleYamSelectMonth(panelType, m),
            onBack: () => { if (!isYearOrMonth) foundation.showDatePanel(panelType); },
            backLabel: locale.DatePicker.cancel,
            yearLabel: locale.DatePicker.months[0],
            monthLabel: locale.DatePicker.months[0],
            rtlIconStyle,
        };
    }

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }}>
            <Popover
                trigger="custom"
                visible={state.visible}
                position={position}
                spacing={4}
                closeOnEsc={false}
                content={
                    <div class="lotus-date-picker-panel" data-type={type} ref={(node: HTMLElement) => { panelNode = node; }}>
                        @if (isYearOrMonth) {
                            <div class="lotus-date-picker-panel-body">
                                @if (type === 'monthRange') {
                                    <>
                                        <div class="lotus-date-picker-yam-double">
                                            <YearMonthWheel {...yamProps('left')} />
                                            <YearMonthWheel {...yamProps('right')} />
                                        </div>
                                        <div class="lotus-date-picker-yam-footer">
                                            <Button theme="solid" onClick={handleYamConfirmRange}>{locale.DatePicker.confirm}</Button>
                                        </div>
                                    </>
                                } @else {
                                    <YearMonthWheel {...yamProps('left')} />
                                }
                            </div>
                        } @else {
                            <div class="lotus-date-picker-container">
                                @if (presetPosition === 'left' && presets.length > 0) {
                                    <div class="lotus-date-picker-presets lotus-date-picker-presets-side">
                                        @for (const item of presets; index pi) {
                                            <div class="lotus-date-picker-preset-item" onClick={() => handlePresetClick(typeof item === 'function' ? (item as any)() : item)}>{(typeof item === 'function' ? (item as any)() : item).text}</div>
                                        }
                                    </div>
                                }
                                <div class="lotus-date-picker-body">
                                    @if (presetPosition === 'top' && presets.length > 0) {
                                        <div class="lotus-date-picker-presets">
                                            @for (const item of presets; index pi) {
                                                <Button theme="borderless" size="small" onClick={() => handlePresetClick(typeof item === 'function' ? (item as any)() : item)}>{(typeof item === 'function' ? (item as any)() : item).text}</Button>
                                            }
                                        </div>
                                    }
                                    <div class="lotus-date-picker-panels">
                                        <div class="lotus-date-picker-single-panel">
                                            @if (state.monthLeft.isYearPickerOpen) {
                                                <YearMonthWheel {...yamProps('left')} />
                                            } @else if (state.monthLeft.isTimePickerOpen) {
                                                <TimeColumns
                                                    date={state.monthLeft.showDate}
                                                    format="HH:mm:ss"
                                                    use12Hours={use12Hours}
                                                    hourStep={hourStep}
                                                    minuteStep={minuteStep}
                                                    secondStep={secondStep}
                                                    hideDisabledOptions={false}
                                                    hourLabel={locale.TimePicker.hourLabel}
                                                    minuteLabel={locale.TimePicker.minuteLabel}
                                                    secondLabel={locale.TimePicker.secondLabel}
                                                    hourUnit={locale.TimePicker.hour}
                                                    minuteUnit={locale.TimePicker.minute}
                                                    secondUnit={locale.TimePicker.second}
                                                    amText={locale.TimePicker.AM}
                                                    pmText={locale.TimePicker.PM}
                                                    triggerLabel={locale.TimePicker.hourLabel}
                                                    onSelect={(h, m, s) => handleTimeSelect('left', h, m, s)}
                                                />
                                            } @else {
                                                <>
                                                    <Navigation
                                                        monthText={locale.DatePicker.monthText(state.monthLeft.pickerDate.getFullYear(), state.monthLeft.pickerDate.getMonth() + 1)}
                                                        onPrevYear={() => switchMonth('prevYear', 'left')}
                                                        onPrevMonth={() => switchMonth('prevMonth', 'left')}
                                                        onNextMonth={() => switchMonth('nextMonth', 'left')}
                                                        onNextYear={() => switchMonth('nextYear', 'left')}
                                                        onHeaderClick={() => { foundation.initYearMonth(state.monthLeft.pickerDate); foundation.showYearPicker('left'); }}
                                                        prevYearLabel={locale.DatePicker.prevYearLabel}
                                                        prevMonthLabel={locale.DatePicker.prevMonthLabel}
                                                        nextMonthLabel={locale.DatePicker.nextMonthLabel}
                                                        nextYearLabel={locale.DatePicker.nextYearLabel}
                                                        rtlIconStyle={rtlIconStyle}
                                                    />
                                                    <MonthGrid
                                                        pickerDate={state.monthLeft.pickerDate}
                                                        weekStartsOn={weekStartsOn}
                                                        selected={state.selected}
                                                        rangeStart={state.rangeStart}
                                                        rangeEnd={state.rangeEnd}
                                                        isRange={isRange}
                                                        offsetRangeStart={state.offsetRangeStart}
                                                        offsetRangeEnd={state.offsetRangeEnd}
                                                        rangeInputFocus={state.rangeInputFocus}
                                                        disabledDate={disabledDate ? panelDisabledDate : undefined}
                                                        weekdayLabels={weekdayLabels}
                                                        onDayClick={(fd) => handleDayClick(fd, 'left')}
                                                    />
                                                    @if (isDateTime) {
                                                        <div class="lotus-date-picker-switch">
                                                            <button type="button" class="lotus-date-picker-switch-item lotus-date-picker-switch-item-active">{locale.DatePicker.today}</button>
                                                            <button type="button" class="lotus-date-picker-switch-item" onClick={() => foundation.showTimePicker('left')}>{locale.DatePicker.now}</button>
                                                        </div>
                                                    }
                                                </>
                                            }
                                        </div>
                                        @if (isRange) {
                                            <div class="lotus-date-picker-single-panel">
                                                @if (state.monthRight.isYearPickerOpen) {
                                                    <YearMonthWheel {...yamProps('right')} />
                                                } @else if (state.monthRight.isTimePickerOpen) {
                                                    <TimeColumns
                                                        date={state.monthRight.showDate}
                                                        format="HH:mm:ss"
                                                        use12Hours={use12Hours}
                                                        hourStep={hourStep}
                                                        minuteStep={minuteStep}
                                                        secondStep={secondStep}
                                                        hideDisabledOptions={false}
                                                        hourLabel={locale.TimePicker.hourLabel}
                                                        minuteLabel={locale.TimePicker.minuteLabel}
                                                        secondLabel={locale.TimePicker.secondLabel}
                                                        hourUnit={locale.TimePicker.hour}
                                                        minuteUnit={locale.TimePicker.minute}
                                                        secondUnit={locale.TimePicker.second}
                                                        amText={locale.TimePicker.AM}
                                                        pmText={locale.TimePicker.PM}
                                                        triggerLabel={locale.TimePicker.hourLabel}
                                                        onSelect={(h, m, s) => handleTimeSelect('right', h, m, s)}
                                                    />
                                                } @else {
                                                    <>
                                                        <Navigation
                                                            monthText={locale.DatePicker.monthText(state.monthRight.pickerDate.getFullYear(), state.monthRight.pickerDate.getMonth() + 1)}
                                                            onPrevYear={() => switchMonth('prevYear', 'right')}
                                                            onPrevMonth={() => switchMonth('prevMonth', 'right')}
                                                            onNextMonth={() => switchMonth('nextMonth', 'right')}
                                                            onNextYear={() => switchMonth('nextYear', 'right')}
                                                            onHeaderClick={() => { foundation.initYearMonth(state.monthRight.pickerDate); foundation.showYearPicker('right'); }}
                                                            prevYearLabel={locale.DatePicker.prevYearLabel}
                                                            prevMonthLabel={locale.DatePicker.prevMonthLabel}
                                                            nextMonthLabel={locale.DatePicker.nextMonthLabel}
                                                            nextYearLabel={locale.DatePicker.nextYearLabel}
                                                            rtlIconStyle={rtlIconStyle}
                                                        />
                                                        <MonthGrid
                                                            pickerDate={state.monthRight.pickerDate}
                                                            weekStartsOn={weekStartsOn}
                                                            selected={state.selected}
                                                            rangeStart={state.rangeStart}
                                                            rangeEnd={state.rangeEnd}
                                                            isRange={isRange}
                                                            offsetRangeStart={state.offsetRangeStart}
                                                            offsetRangeEnd={state.offsetRangeEnd}
                                                            rangeInputFocus={state.rangeInputFocus}
                                                            disabledDate={disabledDate ? panelDisabledDate : undefined}
                                                            weekdayLabels={weekdayLabels}
                                                            onDayClick={(fd) => handleDayClick(fd, 'right')}
                                                        />
                                                    </>
                                                }
                                            </div>
                                        }
                                    </div>
                                    @if (presetPosition === 'bottom' && presets.length > 0) {
                                        <div class="lotus-date-picker-presets">
                                            @for (const item of presets; index pi) {
                                                <Button theme="borderless" size="small" onClick={() => handlePresetClick(typeof item === 'function' ? (item as any)() : item)}>{(typeof item === 'function' ? (item as any)() : item).text}</Button>
                                            }
                                        </div>
                                    }
                                </div>
                                @if (presetPosition === 'right' && presets.length > 0) {
                                    <div class="lotus-date-picker-presets lotus-date-picker-presets-side">
                                        @for (const item of presets; index pi) {
                                            <div class="lotus-date-picker-preset-item" onClick={() => handlePresetClick(typeof item === 'function' ? (item as any)() : item)}>{(typeof item === 'function' ? (item as any)() : item).text}</div>
                                        }
                                    </div>
                                }
                            </div>
                        }
                        @if (effectiveNeedConfirm) {
                            <div class="lotus-date-picker-footer">
                                <Button theme="borderless" onClick={handleCancel}>{locale.DatePicker.cancel}</Button>
                                <Button theme="solid" onClick={handleConfirm}>{locale.DatePicker.confirm}</Button>
                            </div>
                        }
                    </div>
                }
            >
                @if (isRange) {
                    <div class="lotus-date-picker-trigger lotus-date-picker-trigger-range" onClick={handleTriggerClick}>
                        <Input
                            value={rangeLeftValue}
                            disabled={disabled}
                            size={size}
                            validateStatus={validateStatus}
                            borderless={borderless}
                            placeholder={effPlaceholder}
                            suffix={<IconCalendar />}
                            aria-label={ariaLabel}
                            onFocus={() => foundation.setRangeInputFocus('rangeStart')}
                            onBlur={(e) => handleInputBlur(`${(e.target as HTMLInputElement).value}${rangeSeparator}${rangeRightValue}`)}
                        />
                        <span class="lotus-date-picker-range-separator">{rangeSeparator}</span>
                        <Input
                            value={rangeRightValue}
                            disabled={disabled}
                            size={size}
                            validateStatus={validateStatus}
                            borderless={borderless}
                            showClear={showClear}
                            placeholder={effPlaceholder}
                            onFocus={() => foundation.setRangeInputFocus('rangeEnd')}
                            onBlur={(e) => handleInputBlur(`${rangeLeftValue}${rangeSeparator}${(e.target as HTMLInputElement).value}`)}
                            onClear={handleClear}
                        />
                    </div>
                } @else {
                    <div onClick={handleTriggerClick}>
                        <Input
                            value={displayValue}
                            disabled={disabled}
                            size={size}
                            validateStatus={validateStatus}
                            borderless={borderless}
                            showClear={showClear}
                            placeholder={effPlaceholder}
                            suffix={<IconCalendar />}
                            aria-label={ariaLabel}
                            onBlur={(e) => handleInputBlur((e.target as HTMLInputElement).value)}
                            onClear={handleClear}
                        />
                    </div>
                }
            </Popover>
        </div>

        <style>
            .lotus-date-picker {
                display: inline-block;
                width: 100%;
            }

            .lotus-date-picker-trigger-range {
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .lotus-date-picker-range-separator {
                color: var(--lotus-color-text-2);
            }

            .lotus-date-picker-panel {
                display: flex;
                flex-direction: column;
            }

            .lotus-date-picker-container {
                display: flex;
            }

            .lotus-date-picker-body {
                display: flex;
                flex-direction: column;
            }

            .lotus-date-picker-panels {
                display: flex;
            }

            .lotus-date-picker-single-panel {
                min-width: 240px;
            }

            .lotus-date-picker-single-panel + .lotus-date-picker-single-panel {
                border-inline-start: 1px solid var(--lotus-color-border);
            }

            .lotus-date-picker-presets {
                display: flex;
                flex-wrap: wrap;
                gap: 4px;
                padding: 8px;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-date-picker-presets-side {
                flex-direction: column;
                border-top: none;
                border-inline-end: 1px solid var(--lotus-color-border);
                min-width: 100px;
            }

            .lotus-date-picker-preset-item {
                padding: 6px 12px;
                cursor: pointer;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-date-picker-preset-item:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-date-picker-footer {
                display: flex;
                justify-content: flex-end;
                gap: 8px;
                padding: 8px;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-date-picker-switch {
                display: flex;
                border-top: 1px solid var(--lotus-color-border);
            }

            .lotus-date-picker-switch-item {
                flex: 1;
                border: none;
                background: transparent;
                cursor: pointer;
                padding: 8px;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-date-picker-switch-item-active {
                color: var(--lotus-color-primary);
                font-weight: 600;
            }

            .lotus-date-picker-yam-double {
                display: flex;
            }

            .lotus-date-picker-yam-footer {
                display: flex;
                justify-content: flex-end;
                padding: 8px;
                border-top: 1px solid var(--lotus-color-border);
            }
        </style>
    </>
}
