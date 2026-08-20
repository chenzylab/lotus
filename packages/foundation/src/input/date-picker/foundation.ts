import { addMonths, addYears, differenceInCalendarMonths, setMonth, setYear, set as dateFnsSet, type Locale } from 'date-fns';
import { Foundation, type Adapter } from '../../base/adapter.js';
import {
  strings,
  getDefaultFormatTokenByType,
  isRangeType,
  isDateTimeType,
  type PickerType,
  type PanelType,
} from './constants.js';
import {
  formatFullDate,
  isValidDate,
  isBefore,
  isSameDay,
  getFullDateOffset,
  getYears,
  getYearAndMonth,
  compatibleParse,
  localeFormat,
  getInsetInputFormatToken,
  getInsetInputValueFromInsetInputStr,
  type InsetInputValue,
} from './utils.js';

export * from './constants.js';
export * from './utils.js';
export * from './day-status.js';

const LEFT = strings.PANEL_TYPE_LEFT;
const RIGHT = strings.PANEL_TYPE_RIGHT;

export type RangeValue = [Date | null, Date | null];
export type RangeInputFocus = 'rangeStart' | 'rangeEnd' | false;
export type YearMonthChangeType = 'prevMonth' | 'nextMonth' | 'prevYear' | 'nextYear';

export type BaseValueType = string | number | Date;
export interface PresetType {
  start?: BaseValueType | (() => BaseValueType);
  end?: BaseValueType | (() => BaseValueType);
  text?: string;
}

export interface PanelDetail {
  pickerDate: Date;
  showDate: Date;
  isTimePickerOpen: boolean;
  isYearPickerOpen: boolean;
}

export interface LR {
  left: number;
  right: number;
}

function initPanel(base: Date): PanelDetail {
  return { pickerDate: base, showDate: base, isTimePickerOpen: false, isYearPickerOpen: false };
}

function fullDateToDate(fullDate: string): Date {
  const [datePart, timePart] = fullDate.trim().split(/\s+/);
  const [y, m, d] = (datePart ?? fullDate).split('-').map(Number);
  const base = new Date(y ?? new Date().getFullYear(), (m ?? 1) - 1, d ?? 1);
  if (timePart) {
    const [h, mi, s] = timePart.split(':').map(Number);
    base.setHours(h ?? 0, mi ?? 0, s ?? 0, 0);
  }
  return base;
}

function mergeDateAndTime(date: Date, time: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), time.getHours(), time.getMinutes(), time.getSeconds(), time.getMilliseconds());
}

function fmtDateTime(d: Date): string {
  const p2 = (n: number) => (n < 10 ? `0${n}` : `${n}`);
  return `${formatFullDate(d.getFullYear(), d.getMonth() + 1, d.getDate())} ${p2(d.getHours())}:${p2(d.getMinutes())}:${p2(d.getSeconds())}`;
}

export interface DatePickerState {
  // 值模型
  value: Date | Date[] | null;
  rangeValue: RangeValue;
  visible: boolean;
  cachedValue: Date | Date[] | null;
  cachedRange: RangeValue | null;
  // 网格选择状态机
  selected: Set<string>;
  rangeStart: string;
  rangeEnd: string;
  rangeInputFocus: RangeInputFocus;
  hoverDay: string;
  offsetRangeStart: string;
  offsetRangeEnd: string;
  monthLeft: PanelDetail;
  monthRight: PanelDetail;
  // 年/月滚轮子视图（type=month/monthRange/year）
  yamYear: LR;
  yamMonth: LR;
  showYearMonthPicker: boolean;
  // insetInput
  insetInputValue: InsetInputValue;
}

export function emptyInsetInputValue(): InsetInputValue {
  return { monthLeft: { dateInput: '', timeInput: '' }, monthRight: { dateInput: '', timeInput: '' } };
}

export interface DatePickerFoundationOptions {
  type: PickerType;
  multiple: boolean;
  format?: string;
  weekStartsOn: number;
  rangeSeparator: string;
  onChangeDateFirst: boolean;
  dateFnsLocale?: Locale;
}

/**
 * DatePicker 统一状态机：值模型（受控/非受控 + needConfirm 暂存层）+ 日历网格
 * range 选择状态机（双面板导航、hover 预览、周选择 offset）+ 年月滚轮联动 +
 * insetInput 解析。方法名/算法移植自参考实现（对齐 Semi 多个协作 Foundation
 * 的合集），合并成单一 Foundation 类以贴合 lotus 既有的单 Foundation 直连
 * Adapter 惯例（同 Cascader）。
 */
export class DatePickerFoundation extends Foundation<DatePickerState> {
  private opts: DatePickerFoundationOptions;

  constructor(adapter: Adapter<DatePickerState>, opts: DatePickerFoundationOptions) {
    super(adapter);
    this.opts = opts;
  }

  // ===================== 格式化 =====================

  getValidDateFormat(): string {
    return this.opts.format || getDefaultFormatTokenByType(this.opts.type) || strings.FORMAT_FULL_DATE;
  }

  localeFormat(date: Date, token: string): string {
    return localeFormat(date, token, this.opts.dateFnsLocale);
  }

  /** 触发器展示文案：非 range 用逗号分隔多选，range 组内用 rangeSeparator、组间逗号。 */
  formatShowText(value: Date | Date[] | null): string {
    const token = this.getValidDateFormat();
    const one = (d: Date | null) => (d && token ? this.localeFormat(d, token) : '');
    if (!Array.isArray(value)) return one(value);
    const parts = value.map((d) => one(d));
    if (!isRangeType(this.opts.type)) return parts.join(strings.DEFAULT_SEPARATOR_MULTIPLE);
    const groups: string[] = [];
    for (let i = 0; i < parts.length; i += 2) {
      groups.push(parts.slice(i, i + 2).join(this.opts.rangeSeparator));
    }
    return groups.join(strings.DEFAULT_SEPARATOR_MULTIPLE);
  }

  /** 手输解析：单值/range 均要求「解析后再格式化=原串」往返一致才算有效，否则返回 []。 */
  parseInput(input: string): Date[] {
    const token = this.getValidDateFormat();
    if (!input || !token) return [];
    const now = new Date();
    if (isRangeType(this.opts.type)) {
      const sep = this.opts.rangeSeparator;
      const values = input.split(sep);
      const parsed = values.reduce<Date[]>((arr, cur) => {
        const v = cur ? compatibleParse(cur.trim(), token, now, this.opts.dateFnsLocale) : null;
        if (v) arr.push(v);
        return arr;
      }, []);
      const formatted = parsed.map((v) => this.localeFormat(v, token)).join(sep);
      if (parsed.length === values.filter((s) => s.trim()).length && formatted.replace(/\s/g, '') === input.replace(/\s/g, '')) {
        parsed.sort((a, b) => a.getTime() - b.getTime());
        return parsed;
      }
      return [];
    }
    const parsed = compatibleParse(input.trim(), token, now, this.opts.dateFnsLocale);
    if (parsed && this.localeFormat(parsed, token) === input.trim()) return [parsed];
    return [];
  }

  // ===================== 值模型（受控/非受控 + needConfirm）=====================

  open(): void {
    const { visible } = this.getState();
    if (visible) return;
    this.setState({ visible: true });
  }

  close(): void {
    this.setState({ visible: false, cachedValue: null, cachedRange: null });
  }

  toggle(): void {
    const { visible } = this.getState();
    if (visible) this.close();
    else this.open();
  }

  clearCached(): void {
    this.setState({ cachedValue: null, cachedRange: null });
  }

  /** 面板选择入口（单值/multiple）：needConfirm 时只写暂存，不通知；否则按受控与否写回并通知。 */
  handleSelectedChange(value: Date | Date[] | null, isControlled: boolean, needConfirm: boolean): { notifyValue: Date | Date[] | null; shouldNotify: boolean } {
    if (needConfirm) {
      this.setState({ cachedValue: value });
      return { notifyValue: value, shouldNotify: true };
    }
    if (!isControlled) this.setState({ value });
    return { notifyValue: value, shouldNotify: true };
  }

  /**
   * range 面板选择入口：全空视为清空；needConfirm 时只写暂存。
   * `shouldNotify` 是两端完整性守卫（对齐 Semi `_isRangeValueComplete`）——range
   * 组件永远不能对外吐出 `[Date, null]` 这种半选中值，调用方只在 `shouldNotify=true`
   * 时才触发外部 `onChange`，`false` 时仅用 `notifyValue` 驱动面板高亮/受控回显。
   */
  handleRangeSelectedChange(next: RangeValue, isControlled: boolean, needConfirm: boolean): { notifyValue: RangeValue | []; shouldNotify: boolean } {
    const emptied = next[0] == null && next[1] == null;
    const complete = emptied || (next[0] != null && next[1] != null);
    if (needConfirm) {
      this.setState({ cachedRange: next });
      return { notifyValue: emptied ? [] : next, shouldNotify: complete };
    }
    if (!isControlled) this.setState({ rangeValue: next });
    return { notifyValue: emptied ? [] : next, shouldNotify: complete };
  }

  /** 提交暂存（needConfirm 面板点确认）：写回已提交值并清暂存。 */
  commitCached(isControlled: boolean): { notifyValue: Date | Date[] | RangeValue | [] | null; shouldNotify: boolean } {
    if (isRangeType(this.opts.type)) {
      const { cachedRange, rangeValue } = this.getState();
      const next = cachedRange ?? rangeValue;
      if (!isControlled) this.setState({ rangeValue: next, cachedRange: null });
      else this.setState({ cachedRange: null });
      const emptied = next[0] == null && next[1] == null;
      return { notifyValue: emptied ? [] : next, shouldNotify: emptied || (next[0] != null && next[1] != null) };
    }
    const { cachedValue, value } = this.getState();
    const next = cachedValue ?? value;
    if (!isControlled) this.setState({ value: next, cachedValue: null });
    else this.setState({ cachedValue: null });
    return { notifyValue: next, shouldNotify: true };
  }

  handleInputComplete(input: string, isControlled: boolean): { notifyValue: Date | Date[] | RangeValue | [] | null; shouldNotify: boolean } | null {
    const parsed = input ? this.parseInput(input) : [];
    if (!parsed.length) return null;
    if (isRangeType(this.opts.type)) {
      const pair: RangeValue = [parsed[0] ?? null, parsed[1] ?? null];
      return this.handleRangeSelectedChange(pair, isControlled, false);
    }
    return this.handleSelectedChange(this.opts.multiple ? parsed : (parsed[0] ?? null), isControlled, false);
  }

  clear(isControlled: boolean): { notifyValue: Date | Date[] | RangeValue | [] | null; shouldNotify: boolean } {
    if (isRangeType(this.opts.type)) {
      const next: RangeValue = [null, null];
      if (!isControlled) this.setState({ rangeValue: next, selected: new Set(), rangeStart: '', rangeEnd: '' });
      return { notifyValue: [], shouldNotify: true };
    }
    const next = this.opts.multiple ? [] : null;
    if (!isControlled) this.setState({ value: next, selected: new Set() });
    return { notifyValue: next, shouldNotify: true };
  }

  // ===================== 日历网格：单选/多选 =====================

  handleDayClick(fullDate: string, panelType: PanelType, isControlled: boolean, needConfirm: boolean): { notifyValue: unknown; shouldNotify: boolean } | null {
    const type = this.opts.type;
    if (type === 'date' || type === 'dateTime') {
      return this.handleDateSelected(fullDate, panelType, isControlled, needConfirm);
    }
    return this.handleRangeSelected(fullDate, isControlled, needConfirm);
  }

  handleDateSelected(fullDate: string, panelType: PanelType, isControlled: boolean, needConfirm: boolean, max?: number, onMaxLimit?: () => void): { notifyValue: unknown; shouldNotify: boolean } {
    const state = this.getState();
    const multiple = this.opts.multiple;
    const newSelected = new Set<string>(multiple ? [...state.selected] : []);
    const time = this._getPanelDetail(panelType).pickerDate;

    if (!multiple) {
      newSelected.add(fullDate);
    } else if (newSelected.has(fullDate)) {
      newSelected.delete(fullDate);
    } else if (max && newSelected.size >= max) {
      onMaxLimit?.();
    } else {
      newSelected.add(fullDate);
    }

    const isDateTime = this.opts.type === 'dateTime';
    const newDates = [...newSelected].map((ds) => (isDateTime ? mergeDateAndTime(fullDateToDate(ds), time) : fullDateToDate(ds)));
    this._updatePanelDetail(panelType, { showDate: time, pickerDate: time });
    this.setState({ selected: newSelected });

    const value: Date | Date[] | null = multiple ? newDates : (newDates[0] ?? null);
    return this.handleSelectedChange(value, isControlled, needConfirm);
  }

  // ===================== 日历网格：range =====================

  private _isNeedSwap(rs: string, re: string): boolean {
    return !!rs && !!re && isBefore(re, rs);
  }

  handleRangeSelected(
    fullDate: string,
    isControlled: boolean,
    needConfirm: boolean,
    opts?: { startDateOffset?: (d: Date) => Date; endDateOffset?: (d: Date) => Date; isAnotherPanelHasOpened?: (focus: 'rangeStart' | 'rangeEnd') => boolean; onFocusChange?: (focus: 'rangeStart' | 'rangeEnd') => void },
  ): { notifyValue: RangeValue | []; shouldNotify: boolean } | null {
    const state = this.getState();
    let rs = state.rangeStart;
    let re = state.rangeEnd;
    const type = this.opts.type;
    const focus = state.rangeInputFocus;
    let rangeStartReset = false;
    let rangeEndReset = false;

    const startDateOffset = opts?.startDateOffset;
    const endDateOffset = opts?.endDateOffset;
    const isDateRangeAndHasOffset = (startDateOffset || endDateOffset) && type === 'dateRange';

    if (isDateRangeAndHasOffset) {
      rs = getFullDateOffset(startDateOffset, fullDate);
      re = getFullDateOffset(endDateOffset, fullDate);
    } else if (focus === 'rangeEnd') {
      re = fullDate;
      if (rs && re && isBefore(re, rs.trim().split(/\s+/)[0] ?? '')) {
        rs = '';
        rangeStartReset = true;
      }
    } else {
      rs = fullDate;
      if (rs && re && isBefore(re.trim().split(/\s+/)[0] ?? '', rs)) {
        re = '';
        rangeEndReset = true;
      }
    }

    if (isDateRangeAndHasOffset) {
      this.setState({ rangeStart: rs, rangeEnd: re });
    } else if (focus === 'rangeEnd') {
      const patch: Partial<DatePickerState> = { rangeEnd: re };
      if (rangeStartReset) patch.rangeStart = rs;
      this.setState(patch);
      if (!opts?.isAnotherPanelHasOpened?.('rangeEnd') || !rs) opts?.onFocusChange?.('rangeStart');
    } else {
      const patch: Partial<DatePickerState> = { rangeStart: rs };
      if (rangeEndReset) patch.rangeEnd = re;
      this.setState(patch);
      if (!opts?.isAnotherPanelHasOpened?.('rangeStart') || !re) opts?.onFocusChange?.('rangeEnd');
    }

    if (!rs && !re) return null;

    let start = rs ? fullDateToDate(rs.trim().split(/\s+/)[0] ?? rs) : null;
    let end = re ? fullDateToDate(re.trim().split(/\s+/)[0] ?? re) : null;

    if (type === 'dateTimeRange') {
      const s2 = this.getState();
      const startTime = s2.monthLeft.pickerDate;
      const endTime = s2.monthRight.pickerDate;
      const s = rs && start ? mergeDateAndTime(start, startTime) : null;
      const e = re && end ? mergeDateAndTime(end, endTime) : null;
      if (s && e && isSameDay(start!, end!) && isBefore(e, s)) {
        start = s;
        end = s;
      } else {
        start = s;
        end = e;
      }
    }

    const pair: RangeValue = [start, end];
    return this.handleRangeSelectedChange(pair, isControlled, needConfirm);
  }

  handleDayHover(fullDate: string, startDateOffset?: (d: Date) => Date, endDateOffset?: (d: Date) => Date): void {
    const patch: Partial<DatePickerState> = { hoverDay: fullDate };
    if ((startDateOffset || endDateOffset) && this.opts.type === 'dateRange') {
      patch.offsetRangeStart = getFullDateOffset(startDateOffset, fullDate);
      patch.offsetRangeEnd = getFullDateOffset(endDateOffset, fullDate);
    }
    this.setState(patch);
  }

  setRangeInputFocus(focus: RangeInputFocus): void {
    this.setState({ rangeInputFocus: focus });
  }

  // ===================== dateTime 时间列 =====================

  handleTimeChange(panelType: PanelType, timeStampValue: number, isControlled: boolean, needConfirm: boolean): { notifyValue: unknown; shouldNotify: boolean } | null {
    const panel = this._getPanelDetail(panelType);
    const showDate = panel.showDate;
    const timeDate = new Date(timeStampValue);
    const fullValidDate = new Date(showDate.getFullYear(), showDate.getMonth(), showDate.getDate(), timeDate.getHours(), timeDate.getMinutes(), timeDate.getSeconds(), timeDate.getMilliseconds());
    const type = this.opts.type;
    if (type === 'dateTimeRange') {
      this._updatePanelDetail(panelType, { showDate: fullValidDate, pickerDate: fullValidDate });
      return this._updateTimeInDateRange(panelType, fullValidDate, isControlled, needConfirm);
    }
    if (type === 'dateTime') {
      const fullDate = formatFullDate(fullValidDate.getFullYear(), fullValidDate.getMonth() + 1, fullValidDate.getDate());
      this._updatePanelDetail(panelType, { showDate: fullValidDate, pickerDate: fullValidDate });
      return this.handleDateSelected(fullDate, panelType, isControlled, needConfirm);
    }
    return null;
  }

  private _updateTimeInDateRange(panelType: PanelType, timeDate: Date, isControlled: boolean, needConfirm: boolean): { notifyValue: unknown; shouldNotify: boolean } | null {
    const state = this.getState();
    let rs = state.rangeStart;
    let re = state.rangeEnd;
    if (!rs || !re) return null;
    let startDate = fullDateToDate(rs);
    let endDate = fullDateToDate(re);
    const hasTime = (s: string) => /\s/.test(s.trim());
    if (!hasTime(rs)) {
      const t = state.monthLeft.pickerDate;
      startDate.setHours(t.getHours(), t.getMinutes(), t.getSeconds(), t.getMilliseconds());
    }
    if (!hasTime(re)) {
      const t = state.monthRight.pickerDate;
      endDate.setHours(t.getHours(), t.getMinutes(), t.getSeconds(), t.getMilliseconds());
    }
    const mergeSameDay = (src: Date, t: Date) => new Date(src.getFullYear(), src.getMonth(), src.getDate(), t.getHours(), t.getMinutes(), t.getSeconds(), t.getMilliseconds());
    if (panelType === RIGHT) {
      endDate = mergeSameDay(endDate, timeDate);
      re = fmtDateTime(endDate);
      if (this._isNeedSwap(rs, re)) {
        [rs, re] = [re, rs];
        [startDate, endDate] = [endDate, startDate];
      }
    } else {
      startDate = mergeSameDay(startDate, timeDate);
      rs = fmtDateTime(startDate);
      if (this._isNeedSwap(rs, re)) {
        [rs, re] = [re, rs];
        [startDate, endDate] = [endDate, startDate];
      }
    }
    this.setState({ rangeStart: rs, rangeEnd: re });
    return this.handleRangeSelectedChange([startDate, endDate], isControlled, needConfirm);
  }

  calcDisabledTime(
    panelType: PanelType,
    disabledTime?: (date: Date | Date[] | null, panelType?: PanelType) => { disabledHours?: () => number[]; disabledMinutes?: (h: number) => number[]; disabledSeconds?: (h: number, m: number) => number[] } | undefined,
  ) {
    const type = this.opts.type;
    if (typeof disabledTime !== 'function' || (type !== 'dateTime' && type !== 'dateTimeRange')) return undefined;
    const state = this.getState();
    const selectedRaw: Array<string | Date> = [];
    if (type === 'dateTimeRange') {
      if (state.rangeStart) selectedRaw.push(state.rangeStart);
      if (state.rangeStart && state.rangeEnd) selectedRaw.push(state.rangeEnd);
    } else {
      const showDate = this._getPanelDetail(panelType).showDate;
      if (showDate) selectedRaw.push(showDate);
    }
    const selectedDates = selectedRaw.map((s) => (s instanceof Date ? s : fullDateToDate((s.trim().split(/\s+/)[0] ?? s))));
    const cbDates = type === 'dateTimeRange' ? selectedDates : (selectedDates[0] ?? null);
    return disabledTime(cbDates, panelType);
  }

  // ===================== 面板：导航/初始化 =====================

  private _getPanelDetail(panelType: PanelType): PanelDetail {
    return panelType === RIGHT ? this.getState().monthRight : this.getState().monthLeft;
  }

  private _updatePanelDetail(panelType: PanelType, patch: Partial<PanelDetail>): void {
    const state = this.getState();
    if (panelType === RIGHT) this.setState({ monthRight: { ...state.monthRight, ...patch } });
    else this.setState({ monthLeft: { ...state.monthLeft, ...patch } });
  }

  private static dateCalcFns: Record<YearMonthChangeType, (d: Date, step: number) => Date> = {
    prevMonth: (d, step) => addMonths(d, -step),
    nextMonth: (d, step) => addMonths(d, step),
    prevYear: (d, step) => addYears(d, -step),
    nextYear: (d, step) => addYears(d, step),
  };

  private _handleYearOrMonthChange(switchType: YearMonthChangeType, panelType: PanelType, onPanelChange?: (date: Date) => void): void {
    const panelDetail = this._getPanelDetail(panelType);
    const targetMonth = DatePickerFoundation.dateCalcFns[switchType](panelDetail.pickerDate, 1);
    this._updatePanelDetail(panelType, { pickerDate: targetMonth });
    onPanelChange?.(targetMonth);
  }

  private _handleSyncChangeMonths(panelType: PanelType, target: Date, onPanelChange?: (date: Date) => void): void {
    const state = this.getState();
    if (panelType === RIGHT && differenceInCalendarMonths(target, state.monthLeft.pickerDate) === 0) {
      this._handleYearOrMonthChange('prevMonth', LEFT, onPanelChange);
    } else if (panelType === LEFT && differenceInCalendarMonths(state.monthRight.pickerDate, target) === 0) {
      this._handleYearOrMonthChange('nextMonth', RIGHT, onPanelChange);
    }
  }

  switchMonthOrYear(switchType: YearMonthChangeType, panelType: PanelType, syncSwitchMonth: boolean, onPanelChange?: (date: Date) => void): void {
    const rangeType = isRangeType(this.opts.type);
    if (rangeType && syncSwitchMonth) {
      this._handleYearOrMonthChange(switchType, LEFT, onPanelChange);
      this._handleYearOrMonthChange(switchType, RIGHT, onPanelChange);
      return;
    }
    const panelDetail = this._getPanelDetail(panelType);
    const target = DatePickerFoundation.dateCalcFns[switchType](panelDetail.pickerDate, 1);
    this._handleYearOrMonthChange(switchType, panelType, onPanelChange);
    if (rangeType) this._handleSyncChangeMonths(panelType, target, onPanelChange);
  }

  showYearPicker(panelType: PanelType): void {
    this._updatePanelDetail(panelType, { isTimePickerOpen: false, isYearPickerOpen: true });
  }

  showTimePicker(panelType: PanelType): void {
    this._updatePanelDetail(panelType, { isTimePickerOpen: true, isYearPickerOpen: false });
  }

  showDatePanel(panelType: PanelType): void {
    this._updatePanelDetail(panelType, { isTimePickerOpen: false, isYearPickerOpen: false });
  }

  toYearMonth(panelType: PanelType, target: Date): void {
    this._updatePanelDetail(panelType, { pickerDate: target });
  }

  /** 面板初始定位（挂载时/受控值变化重定位）：非 range 单面板；range 双面板按值各自定位并防撞月。 */
  initPanels(defaultPickerValue: Date | Date[] | undefined): void {
    const dpv = defaultPickerValue;
    const now = Array.isArray(dpv) ? dpv[0] : dpv;
    const next = Array.isArray(dpv) ? dpv[1] : undefined;
    const nowDate = now && isValidDate(now) ? now : new Date();
    const nextDate = next && isValidDate(next) ? next : addMonths(nowDate, 1);
    this.setState({ monthLeft: initPanel(nowDate), monthRight: initPanel(nextDate) });
  }

  syncPanelToBase(base: Date): void {
    if (!isValidDate(base)) return;
    this.setState({ monthLeft: { ...this.getState().monthLeft, pickerDate: base, showDate: base }, monthRight: { ...this.getState().monthRight, pickerDate: addMonths(base, 1), showDate: addMonths(base, 1) } });
  }

  /** range 受控值变化时，把两端各自的 Date 同步进对应面板定位（含防撞月：左>右则交换，相同则右+1）。 */
  syncPanelsFromRangeValue(values: RangeValue): void {
    const left = values[0];
    const right = values[1];
    let pLeft = left && isValidDate(left) ? left : undefined;
    let pRight = right && isValidDate(right) ? right : undefined;
    if (pLeft && pRight) {
      const diff = differenceInCalendarMonths(pLeft, pRight);
      if (diff > 0) [pLeft, pRight] = [pRight, pLeft];
      else if (diff === 0) pRight = addMonths(pRight, 1);
    }
    const state = this.getState();
    const patch: Partial<DatePickerState> = {};
    if (pLeft) patch.monthLeft = { ...state.monthLeft, pickerDate: pLeft, showDate: pLeft };
    if (pRight) patch.monthRight = { ...state.monthRight, pickerDate: pRight, showDate: pRight };

    const withTime = this.opts.type === 'dateTimeRange';
    const fmt = (d: Date) => (withTime ? fmtDateTime(d) : formatFullDate(d.getFullYear(), d.getMonth() + 1, d.getDate()));
    let rs = left && isValidDate(left) ? fmt(left) : '';
    let re = right && isValidDate(right) ? fmt(right) : '';
    if (rs && re && this._isNeedSwap(rs, re)) [rs, re] = [re, rs];
    patch.rangeStart = rs;
    patch.rangeEnd = re;
    patch.hoverDay = re;
    if (!rs && !re && state.selected.size) patch.selected = new Set();
    this.setState(patch);
  }

  /** 非 range 值变化时，把 selected 集合同步为该值对应的 fullDate 字符串集合。 */
  syncSelectedFromValue(value: Date | Date[] | null): void {
    const arr = Array.isArray(value) ? value : value ? [value] : [];
    const withTime = isDateTimeType(this.opts.type);
    const fmt = (d: Date) => (withTime ? fmtDateTime(d) : formatFullDate(d.getFullYear(), d.getMonth() + 1, d.getDate()));
    this.setState({ selected: new Set(arr.filter((d): d is Date => isValidDate(d)).map(fmt)) });
  }

  // ===================== 年/月滚轮（type=month/monthRange/year）=====================

  initYearMonth(value: Date | Date[] | RangeValue | null): void {
    const arr = Array.isArray(value) ? value : value ? [value] : [];
    const left = arr[0];
    const right = arr[1];
    const y: LR = { left: left ? (left as Date).getFullYear() : 0, right: right ? (right as Date).getFullYear() : 0 };
    const m: LR = { left: left ? (left as Date).getMonth() + 1 : 0, right: right ? (right as Date).getMonth() + 1 : 0 };
    const normalized = getYearAndMonth(y, m);
    this.setState({ yamYear: normalized.year, yamMonth: normalized.month });
  }

  yearList(panelType: PanelType, startYear: number | undefined, endYear: number | undefined, disabledDate?: (d: Date) => boolean): Array<{ value: number; year: number; disabled: boolean }> {
    const state = this.getState();
    const years = getYears(startYear, endYear);
    const cm = state.yamMonth[panelType];
    const currentDate = setMonth(Date.now(), cm - 1);
    const needDisabled = (year: number) => panelType === RIGHT && state.yamYear[LEFT] ? state.yamYear[LEFT] > year : false;
    return years.map((year) => {
      const isAllMonthDisabled = disabledDate
        ? Array.from({ length: 12 }, (_v, i) => i + 1).every((month) => disabledDate(dateFnsSet(currentDate, { year, month: month - 1 })))
        : false;
      return { value: year, year, disabled: isAllMonthDisabled || needDisabled(year) };
    });
  }

  monthList(panelType: PanelType, disabledDate?: (d: Date) => boolean): Array<{ value: number; month: number; disabled: boolean }> {
    const state = this.getState();
    const year = state.yamYear[panelType];
    return Array.from({ length: 12 }, (_v, i) => i + 1).map((month) => {
      const isRightPanelDisabled = panelType === RIGHT && !!state.yamMonth[LEFT] && state.yamYear[LEFT] === state.yamYear[RIGHT] && state.yamMonth[LEFT] > month;
      const byDisabledDate = disabledDate ? disabledDate(dateFnsSet(Date.now(), { year, month: month - 1 })) : false;
      return { value: month, month, disabled: byDisabledDate || isRightPanelDisabled };
    });
  }

  selectYear(yearValue: number, panelType: PanelType, disabledDate?: (d: Date) => boolean): void {
    const type = this.opts.type;
    const state = this.getState();
    const year: LR = { ...state.yamYear, [panelType]: yearValue };

    if (type === 'monthRange') {
      const isSameYearIllegal = year[LEFT] === year[RIGHT] && state.yamMonth[LEFT] > state.yamMonth[RIGHT];
      if ((panelType === LEFT && yearValue > year[RIGHT]) || (panelType === LEFT && isSameYearIllegal)) {
        year[RIGHT] = yearValue + 1;
      } else if (panelType === RIGHT && isSameYearIllegal) {
        year[LEFT] = yearValue - 1;
      }
    }
    this.setState({ yamYear: year });
    this._autoSelectMonth(yearValue, panelType, year, disabledDate);
  }

  selectMonth(monthValue: number, panelType: PanelType): void {
    const type = this.opts.type;
    const state = this.getState();
    const month: LR = { ...state.yamMonth, [panelType]: monthValue };
    if (type === 'monthRange' && panelType === LEFT && state.yamYear[LEFT] === state.yamYear[RIGHT] && monthValue > month[RIGHT]) {
      month[RIGHT] = monthValue;
    }
    this.setState({ yamMonth: month });
  }

  private _autoSelectMonth(yearValue: number, panelType: PanelType, year: LR, disabledDate?: (d: Date) => boolean): void {
    if (!disabledDate) return;
    const oppositeType: PanelType = panelType === LEFT ? RIGHT : LEFT;
    const state = this.getState();
    const currentDate = setYear(Date.now(), yearValue);
    const isCurrentMonthDisabled = disabledDate(setMonth(currentDate, state.yamMonth[panelType] - 1));
    const isOppositeMonthDisabled = disabledDate(setMonth(setYear(Date.now(), year[oppositeType]), state.yamMonth[oppositeType] - 1));
    if (!isCurrentMonthDisabled && !isOppositeMonthDisabled) return;

    let finalYear = year;
    let finalMonth = { ...state.yamMonth };
    const months = Array.from({ length: 12 }, (_v, i) => i + 1);
    if (isCurrentMonthDisabled) {
      const currentIndex = months.findIndex((m) => m === state.yamMonth[panelType]);
      let validMonth = months.slice(currentIndex).find((m) => !disabledDate(setMonth(currentDate, m - 1)));
      if (validMonth === undefined) validMonth = months.slice(0, currentIndex).find((m) => !disabledDate(setMonth(currentDate, m - 1)));
      if (validMonth !== undefined && !isOppositeMonthDisabled) {
        finalMonth[panelType] = validMonth;
      } else if (validMonth !== undefined && isOppositeMonthDisabled) {
        finalYear = { left: yearValue, right: yearValue };
        finalMonth = { left: validMonth, right: validMonth };
      }
    } else if (isOppositeMonthDisabled) {
      finalYear = { left: yearValue, right: yearValue };
      finalMonth = { left: state.yamMonth[panelType], right: state.yamMonth[panelType] };
    }
    this.setState({ yamYear: finalYear, yamMonth: finalMonth });
  }

  /** 年月滚轮确认选月：month 类型 → 单日期(该年月首日)；monthRange → [左首日, 右首日]。 */
  commitYearMonth(isControlled: boolean, needConfirm: boolean): { notifyValue: unknown; shouldNotify: boolean } {
    const state = this.getState();
    if (this.opts.type === 'monthRange') {
      const start = new Date(state.yamYear.left, state.yamMonth.left - 1, 1);
      const end = new Date(state.yamYear.right, state.yamMonth.right - 1, 1);
      return this.handleRangeSelectedChange([start, end], isControlled, needConfirm);
    }
    const d = new Date(state.yamYear.left, state.yamMonth.left - 1, 1);
    return this.handleSelectedChange(d, isControlled, needConfirm);
  }

  // ===================== insetInput =====================

  concatInsetDateAndTime(date: string, time: string): string {
    return `${date} ${time}`;
  }

  concatInsetDateRange(rangeStart: string, rangeEnd: string): string {
    return `${rangeStart}${this.opts.rangeSeparator}${rangeEnd}`;
  }

  concatInsetInputValue(insetInputValue: InsetInputValue): string {
    const type = this.opts.type;
    switch (type) {
      case 'date':
      case 'month':
      case 'monthRange':
        return insetInputValue.monthLeft.dateInput;
      case 'dateRange':
        return this.concatInsetDateRange(insetInputValue.monthLeft.dateInput, insetInputValue.monthRight.dateInput);
      case 'dateTime':
        return this.concatInsetDateAndTime(insetInputValue.monthLeft.dateInput, insetInputValue.monthLeft.timeInput);
      case 'dateTimeRange': {
        const rs = this.concatInsetDateAndTime(insetInputValue.monthLeft.dateInput, insetInputValue.monthLeft.timeInput);
        const re = this.concatInsetDateAndTime(insetInputValue.monthRight.dateInput, insetInputValue.monthRight.timeInput);
        return this.concatInsetDateRange(rs, re);
      }
      default:
        return '';
    }
  }

  getInsetInputPlaceholder(): { datePlaceholder: string; timePlaceholder: string } {
    const type = this.opts.type;
    const insetInputFormat = getInsetInputFormatToken({ type, format: this.opts.format });
    let datePlaceholder = '';
    let timePlaceholder = '';
    switch (type) {
      case 'date':
      case 'month':
      case 'dateRange':
        datePlaceholder = insetInputFormat;
        break;
      case 'dateTime':
      case 'dateTimeRange':
        [datePlaceholder = '', timePlaceholder = ''] = insetInputFormat.split(' ');
        break;
      case 'monthRange':
        datePlaceholder = insetInputFormat + this.opts.rangeSeparator + insetInputFormat;
        break;
      default:
        break;
    }
    return { datePlaceholder, timePlaceholder };
  }

  /** insetInput 某一格改值 → 写入 → 拼串 → 重新解析回 insetInputValue，返回新对象与拼接串。 */
  handleInsetInputChange(path: 'monthLeft.dateInput' | 'monthLeft.timeInput' | 'monthRight.dateInput' | 'monthRight.timeInput', value: string): { insetInputValue: InsetInputValue; insetInputStr: string } {
    const current = this.getState().insetInputValue;
    const [panel, field] = path.split('.') as ['monthLeft' | 'monthRight', 'dateInput' | 'timeInput'];
    const next: InsetInputValue = { monthLeft: { ...current.monthLeft }, monthRight: { ...current.monthRight } };
    next[panel][field] = value;
    const insetInputStr = this.concatInsetInputValue(next);
    const parsed = getInsetInputValueFromInsetInputStr({ inputValue: insetInputStr, type: this.opts.type, rangeSeparator: this.opts.rangeSeparator });
    const finalStr = this.concatInsetInputValue(parsed);
    this.setState({ insetInputValue: parsed });
    return { insetInputValue: parsed, insetInputStr: finalStr };
  }

  syncInsetInputFromValue(value: Array<Date | null>): void {
    const insetFormat = getInsetInputFormatToken({ type: this.opts.type, format: this.opts.format });
    const inputValueStr = value.filter((d): d is Date => d != null).map((d) => this.localeFormat(d, insetFormat)).join(this.opts.rangeSeparator);
    const parsed = getInsetInputValueFromInsetInputStr({ inputValue: inputValueStr, type: this.opts.type, rangeSeparator: this.opts.rangeSeparator });
    this.setState({ insetInputValue: parsed });
  }
}
