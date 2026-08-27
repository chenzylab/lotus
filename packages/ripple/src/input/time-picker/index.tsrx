import { track, untrack, effect } from 'ripple';
import {
    TimePickerFoundation,
    type TimePickerState,
    type TimePickerPair,
    buildHourOptions,
    buildMinuteOptions,
    buildSecondOptions,
    applyHideDisabled,
    parseFormatSpec,
    formatTime,
    to12Hour,
    meridiemOf,
    type TimeOption,
} from '@lotus/foundation/input/time-picker';
import type { FloatingPosition } from '@lotus/foundation/base/floating-position';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Popover } from '../../show/popover/index.tsrx';
import { Input, type InputSize, type InputValidateStatus } from '../input/index.tsrx';
import { ScrollList } from '../../show/scroll-list/index.tsrx';
import { ScrollItem, type ScrollListItemData } from '../../show/scroll-list/item.tsrx';
import { IconClock } from '@lotus/icons';

export type TimePickerType = 'time' | 'timeRange';
export type TimePickerSize = InputSize;
export type TimePickerValidateStatus = InputValidateStatus;
export type TimePickerValue = Date | string | null;

export interface DisabledTimeRules {
    disabledHours?: () => number[];
    disabledMinutes?: (hour: number) => number[];
    disabledSeconds?: (hour: number, minute: number) => number[];
}

export interface TimePickerProps {
    type?: TimePickerType;
    value?: TimePickerValue | [TimePickerValue, TimePickerValue];
    defaultValue?: TimePickerValue | [TimePickerValue, TimePickerValue];
    format?: string;
    open?: boolean;
    defaultOpen?: boolean;
    onOpenChange?: (open: boolean) => void;
    placeholder?: string;
    size?: TimePickerSize;
    validateStatus?: TimePickerValidateStatus;
    disabled?: boolean;
    borderless?: boolean;
    showClear?: boolean;
    position?: FloatingPosition;
    hourStep?: number;
    minuteStep?: number;
    secondStep?: number;
    use12Hours?: boolean;
    disabledHours?: () => number[];
    disabledMinutes?: (hour: number) => number[];
    disabledSeconds?: (hour: number, minute: number) => number[];
    /** 按已选值返回禁用规则，覆盖顶层 disabledHours/Minutes/Seconds（仅 timeRange 生效，对齐 Semi）。 */
    disabledTime?: (dates: Date[], panelType?: 'left' | 'right') => DisabledTimeRules | undefined;
    hideDisabledOptions?: boolean;
    rangeSeparator?: string;
    onChange?: (value: Date | null | [Date | null, Date | null]) => void;
    onClear?: () => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function toDateValue(input: TimePickerValue): Date | null {
    if (input == null) return null;
    if (input instanceof Date) return input;
    const m = /^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?$/.exec(input.trim());
    if (!m) return null;
    const d = new Date();
    d.setHours(Number(m[1]), Number(m[2]), m[3] ? Number(m[3]) : 0, 0);
    return d;
}

function toPair(input: TimePickerProps['value']): TimePickerPair {
    if (Array.isArray(input)) return [toDateValue(input[0] ?? null), toDateValue(input[1] ?? null)];
    return [toDateValue((input ?? null) as TimePickerValue), null];
}

function pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`;
}

export interface ColumnsProps {
    date: Date | null;
    format: string;
    use12Hours: boolean;
    hourStep: number;
    minuteStep: number;
    secondStep: number;
    hideDisabledOptions: boolean;
    disabledHours?: () => number[];
    disabledMinutes?: (hour: number) => number[];
    disabledSeconds?: (hour: number, minute: number) => number[];
    hourLabel: string;
    minuteLabel: string;
    secondLabel: string;
    hourUnit: string;
    minuteUnit: string;
    secondUnit: string;
    amText: string;
    pmText: string;
    triggerLabel: string;
    onSelect: (h: number, m: number, s: number) => void;
    class?: string;
}

/** 单侧时间列面板：ampm?/hour/minute/second，对齐参考实现 Combobox（照搬 Semi ComboxFoundation）。 */
export function TimeColumns(&{
    date,
    format,
    use12Hours,
    hourStep,
    minuteStep,
    secondStep,
    hideDisabledOptions,
    disabledHours,
    disabledMinutes,
    disabledSeconds,
    hourLabel,
    minuteLabel,
    secondLabel,
    hourUnit,
    minuteUnit,
    secondUnit,
    amText,
    pmText,
    triggerLabel,
    onSelect,
    class: className,
}: ColumnsProps) @{
    let &[spec] = track(() => parseFormatSpec(format));
    let &[current] = track<Date>(() => {
        if (date) return date;
        const now = new Date();
        return new Date(now.getFullYear(), now.getMonth(), now.getDate());
    });
    let &[isAM] = track<boolean>(() => meridiemOf(current.getHours()) === 'am');

    let &[hourOptions] = track<TimeOption[]>(() =>
        applyHideDisabled(buildHourOptions(hourStep, use12Hours, isAM ? 'am' : 'pm', disabledHours), hideDisabledOptions),
    );
    let &[minuteOptions] = track<TimeOption[]>(() =>
        applyHideDisabled(buildMinuteOptions(minuteStep, current.getHours(), disabledMinutes), hideDisabledOptions),
    );
    let &[secondOptions] = track<TimeOption[]>(() =>
        applyHideDisabled(buildSecondOptions(secondStep, current.getHours(), current.getMinutes(), disabledSeconds), hideDisabledOptions),
    );

    let &[hourDisplay] = track<number>(() => (use12Hours ? to12Hour(current.getHours()) : current.getHours()));

    let &[hourList] = track<ScrollListItemData<number>[]>(() =>
        hourOptions.map((o) => ({ value: o.value, text: `${pad2(o.value)}${hourUnit}`, disabled: o.disabled })),
    );
    let &[minuteList] = track<ScrollListItemData<number>[]>(() =>
        minuteOptions.map((o) => ({ value: o.value, text: `${pad2(o.value)}${minuteUnit}`, disabled: o.disabled })),
    );
    let &[secondList] = track<ScrollListItemData<number>[]>(() =>
        secondOptions.map((o) => ({ value: o.value, text: `${pad2(o.value)}${secondUnit}`, disabled: o.disabled })),
    );
    let &[ampmList] = track<ScrollListItemData<'AM' | 'PM'>[]>(() => [
        { value: 'AM' as const, text: amText },
        { value: 'PM' as const, text: pmText },
    ]);

    function commit(h: number, m: number, s: number) {
        onSelect(h, m, s);
    }

    function handleHourSelect(item: ScrollListItemData<number> & { index: number }) {
        let h = item.value;
        if (use12Hours) h = isAM ? h % 12 : (h % 12) + 12;
        commit(h, current.getMinutes(), current.getSeconds());
    }
    function handleMinuteSelect(item: ScrollListItemData<number> & { index: number }) {
        commit(current.getHours(), item.value, current.getSeconds());
    }
    function handleSecondSelect(item: ScrollListItemData<number> & { index: number }) {
        commit(current.getHours(), current.getMinutes(), item.value);
    }
    function handleAmPmSelect(item: ScrollListItemData<'AM' | 'PM'> & { index: number }) {
        let h = current.getHours();
        if (item.value === 'PM' && h < 12) h += 12;
        if (item.value === 'AM' && h >= 12) h -= 12;
        commit(h, current.getMinutes(), current.getSeconds());
    }

    <ScrollList class={className} bodyHeight={224}>
        @if (use12Hours) {
            <ScrollItem
                mode="normal"
                list={ampmList}
                selectedIndex={isAM ? 0 : 1}
                onSelect={handleAmPmSelect}
                aria-label={triggerLabel}
            />
        }
        @if (spec.showHour) {
            <ScrollItem
                mode="normal"
                list={hourList}
                selectedIndex={hourOptions.findIndex((o) => o.value === hourDisplay)}
                onSelect={handleHourSelect}
                aria-label={hourLabel}
            />
        }
        @if (spec.showMinute) {
            <ScrollItem
                mode="normal"
                list={minuteList}
                selectedIndex={minuteOptions.findIndex((o) => o.value === current.getMinutes())}
                onSelect={handleMinuteSelect}
                aria-label={minuteLabel}
            />
        }
        @if (spec.showSecond) {
            <ScrollItem
                mode="normal"
                list={secondList}
                selectedIndex={secondOptions.findIndex((o) => o.value === current.getSeconds())}
                onSelect={handleSecondSelect}
                aria-label={secondLabel}
            />
        }
    </ScrollList>
}

/**
 * TimePicker：触发器复用 Input（可键入时间串，Enter/失焦解析提交），面板复用
 * ScrollList/ScrollItem 滚动列。单选 type='time'；type='timeRange' 左右双列并排选起止，
 * 触发器仍是单个输入框（一段串按 rangeSeparator 分两端，对齐参考实现设计）。
 * 浮层开关复用 Cascader/AutoComplete 已验证的 Popover(trigger="custom") 模式；触发器本身
 * 可编辑，采用"仅关闭态点击才打开"语义（对齐 AutoComplete 踩坑 #76，不能无条件 toggle）。
 */
export function TimePicker(&{
    type = 'time',
    value,
    defaultValue,
    format,
    open,
    defaultOpen = false,
    onOpenChange,
    placeholder,
    size = 'default',
    validateStatus = 'default',
    disabled = false,
    borderless = false,
    showClear = true,
    position = 'bottomLeft',
    hourStep = 1,
    minuteStep = 1,
    secondStep = 1,
    use12Hours = false,
    disabledHours,
    disabledMinutes,
    disabledSeconds,
    disabledTime,
    hideDisabledOptions = false,
    rangeSeparator = ' ~ ',
    onChange,
    onClear,
    'aria-label': ariaLabel,
    style,
    class: className,
}: TimePickerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isRange = type === 'timeRange';
    const isControlled = value !== undefined;
    const isOpenControlled = open !== undefined;

    let &[effFormat] = track<string>(() => format ?? (use12Hours ? 'a h:mm:ss' : 'HH:mm:ss'));

    let &[state] = track<TimePickerState>({
        pair: isControlled ? toPair(value) : toPair(defaultValue),
        visible: isOpenControlled ? !!open : defaultOpen,
        inputDraft: null,
        invalid: false,
    });

    const foundation = new TimePickerFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<TimePickerState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let &[hasBeenControlled] = track<boolean>(false);
    effect(() => {
        if (value !== undefined) {
            hasBeenControlled = true;
            untrack(() => { state = { ...state, pair: toPair(value) }; });
        } else if (untrack(() => hasBeenControlled)) {
            untrack(() => { state = { ...state, pair: [null, null] }; });
        }
    });

    effect(() => {
        if (open !== undefined) {
            untrack(() => { state = { ...state, visible: open }; });
        }
    });

    let &[rootNode] = track<HTMLElement | null>(null);
    let &[panelNode] = track<HTMLElement | null>(null);

    function notify(pair: TimePickerPair) {
        onChange?.(isRange ? pair : pair[0]);
    }

    function handleTriggerClick() {
        if (disabled) return;
        if (untrack(() => state).visible) return;
        foundation.open();
        onOpenChange?.(true);
    }

    function closePanel() {
        if (!untrack(() => state).visible) return;
        foundation.close();
        onOpenChange?.(false);
    }

    function handleInputChange(v: string) {
        foundation.onInputChange(v);
    }

    function commitDraftIfAny() {
        const draft = untrack(() => state).inputDraft;
        if (draft === null) return;
        const { pair } = foundation.commitDraft(draft, isRange, rangeSeparator, isControlled);
        if (pair) notify(pair);
    }

    function handleInputBlur() {
        commitDraftIfAny();
    }

    function handleClear() {
        const next = foundation.clear(isControlled);
        notify(next);
        onClear?.();
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (event.key === 'Enter') {
            commitDraftIfAny();
            if (!untrack(() => state).visible) {
                foundation.open();
                onOpenChange?.(true);
            }
            return;
        }
        if (event.key === 'ArrowDown') {
            if (!untrack(() => state).visible) {
                event.preventDefault();
                foundation.open();
                onOpenChange?.(true);
            }
            return;
        }
        if (event.key === 'Escape') {
            closePanel();
        }
    }

    function handleColumnSelect(panelIndex: 0 | 1, h: number, m: number, s: number) {
        const next = foundation.commitColumn(panelIndex, h, m, s, isControlled);
        notify(next);
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

    let &[displayValue] = track<string>(() => {
        const draft = state.inputDraft;
        if (draft !== null) return draft;
        const [s, e] = state.pair;
        if (!isRange) return s ? formatTime({ hour: s.getHours(), minute: s.getMinutes(), second: s.getSeconds() }, effFormat) : '';
        const fmt = (d: Date | null) => (d ? formatTime({ hour: d.getHours(), minute: d.getMinutes(), second: d.getSeconds() }, effFormat) : '');
        if (!s && !e) return '';
        return `${fmt(s)}${rangeSeparator}${fmt(e)}`;
    });

    let &[effPlaceholder] = track<string>(() =>
        placeholder ?? (isRange ? locale.TimePicker.placeholderRange : locale.TimePicker.placeholder),
    );

    let &[disabledRulesLeft] = track<DisabledTimeRules | undefined>(() => {
        if (!isRange || !disabledTime) return undefined;
        const dates = state.pair.filter((d): d is Date => d != null);
        return disabledTime(dates, 'left');
    });
    let &[disabledRulesRight] = track<DisabledTimeRules | undefined>(() => {
        if (!isRange || !disabledTime) return undefined;
        const dates = state.pair.filter((d): d is Date => d != null);
        return disabledTime(dates, 'right');
    });

    let &[classes] = track<string>(() =>
        ['lotus-time-picker', disabled ? 'lotus-time-picker-disabled' : '', isRange ? 'lotus-time-picker-range' : '', className ?? ''].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} ref={(node: HTMLElement) => { rootNode = node; }} onKeyDown={handleKeyDown}>
            <Popover
                trigger="custom"
                visible={state.visible}
                position={position}
                spacing={4}
                closeOnEsc={false}
                content={
                    <div class="lotus-time-picker-panel" ref={(node: HTMLElement) => { panelNode = node; }}>
                        @if (isRange) {
                            <div class="lotus-time-picker-lists">
                                <TimeColumns
                                    date={state.pair[0]}
                                    format={effFormat}
                                    use12Hours={use12Hours}
                                    hourStep={hourStep}
                                    minuteStep={minuteStep}
                                    secondStep={secondStep}
                                    hideDisabledOptions={hideDisabledOptions}
                                    disabledHours={disabledRulesLeft?.disabledHours ?? disabledHours}
                                    disabledMinutes={disabledRulesLeft?.disabledMinutes ?? disabledMinutes}
                                    disabledSeconds={disabledRulesLeft?.disabledSeconds ?? disabledSeconds}
                                    hourLabel={locale.TimePicker.hourLabel}
                                    minuteLabel={locale.TimePicker.minuteLabel}
                                    secondLabel={locale.TimePicker.secondLabel}
                                    hourUnit={locale.TimePicker.hour}
                                    minuteUnit={locale.TimePicker.minute}
                                    secondUnit={locale.TimePicker.second}
                                    amText={locale.TimePicker.AM}
                                    pmText={locale.TimePicker.PM}
                                    triggerLabel={locale.TimePicker.begin}
                                    onSelect={(h, m, s) => handleColumnSelect(0, h, m, s)}
                                    class="lotus-time-picker-list-left"
                                />
                                <TimeColumns
                                    date={state.pair[1]}
                                    format={effFormat}
                                    use12Hours={use12Hours}
                                    hourStep={hourStep}
                                    minuteStep={minuteStep}
                                    secondStep={secondStep}
                                    hideDisabledOptions={hideDisabledOptions}
                                    disabledHours={disabledRulesRight?.disabledHours ?? disabledHours}
                                    disabledMinutes={disabledRulesRight?.disabledMinutes ?? disabledMinutes}
                                    disabledSeconds={disabledRulesRight?.disabledSeconds ?? disabledSeconds}
                                    hourLabel={locale.TimePicker.hourLabel}
                                    minuteLabel={locale.TimePicker.minuteLabel}
                                    secondLabel={locale.TimePicker.secondLabel}
                                    hourUnit={locale.TimePicker.hour}
                                    minuteUnit={locale.TimePicker.minute}
                                    secondUnit={locale.TimePicker.second}
                                    amText={locale.TimePicker.AM}
                                    pmText={locale.TimePicker.PM}
                                    triggerLabel={locale.TimePicker.end}
                                    onSelect={(h, m, s) => handleColumnSelect(1, h, m, s)}
                                    class="lotus-time-picker-list-right"
                                />
                            </div>
                        } @else {
                            <TimeColumns
                                date={state.pair[0]}
                                format={effFormat}
                                use12Hours={use12Hours}
                                hourStep={hourStep}
                                minuteStep={minuteStep}
                                secondStep={secondStep}
                                hideDisabledOptions={hideDisabledOptions}
                                disabledHours={disabledHours}
                                disabledMinutes={disabledMinutes}
                                disabledSeconds={disabledSeconds}
                                hourLabel={locale.TimePicker.hourLabel}
                                minuteLabel={locale.TimePicker.minuteLabel}
                                secondLabel={locale.TimePicker.secondLabel}
                                hourUnit={locale.TimePicker.hour}
                                minuteUnit={locale.TimePicker.minute}
                                secondUnit={locale.TimePicker.second}
                                amText={locale.TimePicker.AM}
                                pmText={locale.TimePicker.PM}
                                triggerLabel={locale.TimePicker.hourLabel}
                                onSelect={(h, m, s) => handleColumnSelect(0, h, m, s)}
                            />
                        }
                    </div>
                }
            >
                <div onClick={handleTriggerClick}>
                    <Input
                        value={displayValue}
                        disabled={disabled}
                        size={size}
                        validateStatus={state.invalid ? 'error' : validateStatus}
                        borderless={borderless}
                        showClear={showClear}
                        placeholder={effPlaceholder}
                        suffix={<IconClock />}
                        aria-label={ariaLabel}
                        onChange={handleInputChange}
                        onBlur={handleInputBlur}
                        onClear={handleClear}
                    />
                </div>
            </Popover>
        </div>

        <style>
            .lotus-time-picker {
                display: inline-block;
                width: 100%;
            }

            .lotus-time-picker-panel {
                min-width: 120px;
            }

            .lotus-time-picker-lists {
                display: flex;
            }

            .lotus-time-picker-list-left {
                border-inline-end: 1px solid var(--lotus-color-border);
            }
        </style>
    </>
}
