import { describe, it, expect, vi } from 'vitest';
import { DatePickerFoundation, type DatePickerState, type DatePickerFoundationOptions, emptyInsetInputValue } from './foundation.js';

function makeFoundation(type: DatePickerFoundationOptions['type'], stateOverrides: Partial<DatePickerState> = {}, optsOverrides: Partial<DatePickerFoundationOptions> = {}) {
  let state: DatePickerState = {
    value: null,
    rangeValue: [null, null],
    visible: false,
    cachedValue: null,
    cachedRange: null,
    selected: new Set(),
    rangeStart: '',
    rangeEnd: '',
    rangeInputFocus: false,
    hoverDay: '',
    offsetRangeStart: '',
    offsetRangeEnd: '',
    monthLeft: { pickerDate: new Date(2024, 2, 1), showDate: new Date(2024, 2, 1), isTimePickerOpen: false, isYearPickerOpen: false },
    monthRight: { pickerDate: new Date(2024, 3, 1), showDate: new Date(2024, 3, 1), isTimePickerOpen: false, isYearPickerOpen: false },
    yamYear: { left: 2024, right: 2024 },
    yamMonth: { left: 3, right: 4 },
    showYearMonthPicker: false,
    insetInputValue: emptyInsetInputValue(),
    ...stateOverrides,
  };
  const opts: DatePickerFoundationOptions = {
    type,
    multiple: false,
    weekStartsOn: 0,
    rangeSeparator: ' ~ ',
    onChangeDateFirst: true,
    ...optsOverrides,
  };
  const foundation = new DatePickerFoundation(
    { getState: () => state, setState: (patch) => { state = { ...state, ...patch }; } },
    opts,
  );
  return { foundation, getState: () => state };
}

describe('open / close / toggle', () => {
  it('open 设置 visible=true', () => {
    const { foundation, getState } = makeFoundation('date');
    foundation.open();
    expect(getState().visible).toBe(true);
  });

  it('close 同时清空 needConfirm 暂存', () => {
    const { foundation, getState } = makeFoundation('date', { visible: true, cachedValue: new Date() });
    foundation.close();
    expect(getState().visible).toBe(false);
    expect(getState().cachedValue).toBeNull();
  });

  it('toggle 开关互换', () => {
    const { foundation, getState } = makeFoundation('date');
    foundation.toggle();
    expect(getState().visible).toBe(true);
    foundation.toggle();
    expect(getState().visible).toBe(false);
  });
});

describe('handleDateSelected：单选', () => {
  it('非受控：写入 selected 与 value，返回 notifyValue', () => {
    const { foundation, getState } = makeFoundation('date');
    const result = foundation.handleDateSelected('2024-03-05', 'left', false, false);
    expect(getState().selected.has('2024-03-05')).toBe(true);
    expect((getState().value as Date).getDate()).toBe(5);
    expect((result.notifyValue as Date).getDate()).toBe(5);
  });

  it('受控：不写 state.value，仍返回 notifyValue', () => {
    const { foundation, getState } = makeFoundation('date', {}, {});
    const result = foundation.handleDateSelected('2024-03-05', 'left', true, false);
    expect(getState().value).toBeNull();
    expect((result.notifyValue as Date).getDate()).toBe(5);
  });

  it('needConfirm：写入 cachedValue，不写 value', () => {
    const { foundation, getState } = makeFoundation('dateTime');
    foundation.handleDateSelected('2024-03-05', 'left', false, true);
    expect(getState().value).toBeNull();
    expect((getState().cachedValue as Date).getDate()).toBe(5);
  });
});

describe('handleDateSelected：multiple', () => {
  it('多选累加，再点一次已选项则取消', () => {
    const { foundation, getState } = makeFoundation('date', {}, { multiple: true });
    foundation.handleDateSelected('2024-03-05', 'left', false, false);
    foundation.handleDateSelected('2024-03-06', 'left', false, false);
    expect(getState().selected.size).toBe(2);
    foundation.handleDateSelected('2024-03-05', 'left', false, false);
    expect(getState().selected.size).toBe(1);
    expect(getState().selected.has('2024-03-06')).toBe(true);
  });

  it('达到 max 时触发 onMaxLimit 且不再新增', () => {
    const { foundation, getState } = makeFoundation('date', {}, { multiple: true });
    foundation.handleDateSelected('2024-03-05', 'left', false, false);
    const onMaxLimit = vi.fn();
    foundation.handleDateSelected('2024-03-06', 'left', false, false, 1, onMaxLimit);
    expect(onMaxLimit).toHaveBeenCalled();
    expect(getState().selected.size).toBe(1);
  });
});

describe('handleRangeSelected：核心状态机', () => {
  it('未聚焦时点击设为 rangeStart，并把焦点切到 rangeEnd', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    const onFocusChange = vi.fn();
    foundation.handleRangeSelected('2024-03-05', false, false, { onFocusChange });
    expect(getState().rangeStart).toBe('2024-03-05');
    expect(onFocusChange).toHaveBeenCalledWith('rangeEnd');
  });

  it('rangeEnd 早于已有 rangeStart 时静默清空 rangeStart 重选', () => {
    const { foundation, getState } = makeFoundation('dateRange', { rangeStart: '2024-03-10', rangeInputFocus: 'rangeEnd' });
    foundation.handleRangeSelected('2024-03-05', false, false, {});
    expect(getState().rangeStart).toBe('');
    expect(getState().rangeEnd).toBe('2024-03-05');
  });

  it('两端都选完后返回完整 notifyValue 且 shouldNotify=true', () => {
    const { foundation } = makeFoundation('dateRange', { rangeStart: '2024-03-01', rangeInputFocus: 'rangeEnd' });
    const result = foundation.handleRangeSelected('2024-03-10', false, false, {});
    expect(result?.notifyValue).toHaveLength(2);
    expect(result?.shouldNotify).toBe(true);
    const [s, e] = result!.notifyValue as [Date, Date];
    expect(s.getDate()).toBe(1);
    expect(e.getDate()).toBe(10);
  });

  it('只选一端时 shouldNotify=false（半选中值不能对外通知，对齐 Semi 完整性守卫）', () => {
    const { foundation } = makeFoundation('dateRange');
    const result = foundation.handleRangeSelected('2024-03-05', false, false, {});
    expect(result).not.toBeNull();
    expect(result?.shouldNotify).toBe(false);
  });

  it('startDateOffset/endDateOffset：周选择模式忽略 rangeInputFocus，直接算整周', () => {
    const startOfWeekMon = (d: Date) => {
      const day = d.getDay();
      const diff = (day + 6) % 7;
      const r = new Date(d);
      r.setDate(d.getDate() - diff);
      return r;
    };
    const endOfWeekMon = (d: Date) => {
      const r = startOfWeekMon(d);
      r.setDate(r.getDate() + 6);
      return r;
    };
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.handleRangeSelected('2024-03-06', false, false, { startDateOffset: startOfWeekMon, endDateOffset: endOfWeekMon });
    expect(getState().rangeStart).toBe('2024-03-04');
    expect(getState().rangeEnd).toBe('2024-03-10');
  });
});

describe('handleDayHover', () => {
  it('写入 hoverDay', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.handleDayHover('2024-03-05');
    expect(getState().hoverDay).toBe('2024-03-05');
  });

  it('dateRange + offset 函数时同步写入 offsetRange', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    const offsetFn = (d: Date) => d;
    foundation.handleDayHover('2024-03-05', offsetFn, offsetFn);
    expect(getState().offsetRangeStart).toBe('2024-03-05');
    expect(getState().offsetRangeEnd).toBe('2024-03-05');
  });
});

describe('needConfirm 提交流程', () => {
  it('commitCached：单值场景把 cachedValue 写回 value 并清空暂存', () => {
    const cached = new Date(2024, 2, 5);
    const { foundation, getState } = makeFoundation('dateTime', { cachedValue: cached });
    const result = foundation.commitCached(false);
    expect(getState().value).toBe(cached);
    expect(getState().cachedValue).toBeNull();
    expect(result.notifyValue).toBe(cached);
  });

  it('commitCached：range 场景把 cachedRange 写回 rangeValue', () => {
    const cached: [Date, Date] = [new Date(2024, 2, 1), new Date(2024, 2, 10)];
    const { foundation, getState } = makeFoundation('dateTimeRange', { cachedRange: cached });
    const result = foundation.commitCached(false);
    expect(getState().rangeValue).toBe(cached);
    expect(getState().cachedRange).toBeNull();
    expect(result.notifyValue).toBe(cached);
  });

  it('commitCached：无暂存时回退到已提交的 value/rangeValue', () => {
    const existing = new Date(2024, 2, 1);
    const { foundation, getState } = makeFoundation('dateTime', { value: existing });
    const result = foundation.commitCached(false);
    expect(result.notifyValue).toBe(existing);
    expect(getState().value).toBe(existing);
  });
});

describe('clear', () => {
  it('单选非受控：清空 value 和 selected', () => {
    const { foundation, getState } = makeFoundation('date', { value: new Date(), selected: new Set(['2024-03-05']) });
    const result = foundation.clear(false);
    expect(getState().value).toBeNull();
    expect(getState().selected.size).toBe(0);
    expect(result.notifyValue).toBeNull();
  });

  it('multiple 非受控：清空为空数组', () => {
    const { foundation } = makeFoundation('date', {}, { multiple: true });
    const result = foundation.clear(false);
    expect(result.notifyValue).toEqual([]);
  });

  it('range 场景：清空 rangeValue/rangeStart/rangeEnd', () => {
    const { foundation, getState } = makeFoundation('dateRange', { rangeValue: [new Date(), new Date()], rangeStart: '2024-03-01', rangeEnd: '2024-03-10' });
    const result = foundation.clear(false);
    expect(getState().rangeValue).toEqual([null, null]);
    expect(getState().rangeStart).toBe('');
    expect(result.notifyValue).toEqual([]);
  });
});

describe('parseInput / handleInputComplete', () => {
  it('单值：格式往返一致才算有效', () => {
    const { foundation } = makeFoundation('date');
    const result = foundation.parseInput('2024-03-05');
    expect(result).toHaveLength(1);
    expect(result[0]!.getDate()).toBe(5);
  });

  it('单值：非法格式返回空数组', () => {
    const { foundation } = makeFoundation('date');
    expect(foundation.parseInput('not-a-date')).toEqual([]);
  });

  it('range：按 rangeSeparator 拆分两端并排序', () => {
    const { foundation } = makeFoundation('dateRange');
    const result = foundation.parseInput('2024-03-10 ~ 2024-03-01');
    expect(result).toHaveLength(2);
    expect(result[0]!.getDate()).toBe(1);
    expect(result[1]!.getDate()).toBe(10);
  });

  it('handleInputComplete：解析失败返回 null（不提交）', () => {
    const { foundation, getState } = makeFoundation('date', { value: new Date(2024, 0, 1) });
    const result = foundation.handleInputComplete('garbage', false);
    expect(result).toBeNull();
    expect((getState().value as Date).getMonth()).toBe(0);
  });

  it('handleInputComplete：解析成功提交新值', () => {
    const { foundation, getState } = makeFoundation('date');
    foundation.handleInputComplete('2024-03-05', false);
    expect((getState().value as Date).getDate()).toBe(5);
  });
});

describe('switchMonthOrYear：双面板导航', () => {
  it('非 range 单面板翻月', () => {
    const { foundation, getState } = makeFoundation('date');
    foundation.switchMonthOrYear('nextMonth', 'left', false);
    expect(getState().monthLeft.pickerDate.getMonth()).toBe(3);
  });

  it('range 默认（syncSwitchMonth=false）：只翻被操作面板，撞月时自动联动另一侧', () => {
    // monthLeft=2024-03, monthRight=2024-04；左边翻到 4 月会撞右边，右边应自动 +1 到 5 月。
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.switchMonthOrYear('nextMonth', 'left', false);
    expect(getState().monthLeft.pickerDate.getMonth()).toBe(3);
    expect(getState().monthRight.pickerDate.getMonth()).toBe(4);
  });

  it('range + syncSwitchMonth=true：两面板同步翻页', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.switchMonthOrYear('nextMonth', 'left', true);
    expect(getState().monthLeft.pickerDate.getMonth()).toBe(3);
    expect(getState().monthRight.pickerDate.getMonth()).toBe(4);
  });
});

describe('syncPanelsFromRangeValue：防撞月', () => {
  it('两端同月时右面板自动 +1 月', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.syncPanelsFromRangeValue([new Date(2024, 4, 5), new Date(2024, 4, 20)]);
    expect(getState().monthLeft.pickerDate.getMonth()).toBe(4);
    expect(getState().monthRight.pickerDate.getMonth()).toBe(5);
  });

  it('左晚于右时整体交换', () => {
    const { foundation, getState } = makeFoundation('dateRange');
    foundation.syncPanelsFromRangeValue([new Date(2024, 5, 5), new Date(2024, 2, 20)]);
    expect(getState().monthLeft.pickerDate.getMonth()).toBe(2);
    expect(getState().monthRight.pickerDate.getMonth()).toBe(5);
  });

  it('两端皆空时清空 selected 高亮', () => {
    const { foundation, getState } = makeFoundation('dateRange', { selected: new Set(['2024-03-05']) });
    foundation.syncPanelsFromRangeValue([null, null]);
    expect(getState().selected.size).toBe(0);
  });
});

describe('年/月滚轮：selectYear / selectMonth / autoSelectMonth', () => {
  it('selectYear 写入 yamYear 对应 panel', () => {
    const { foundation, getState } = makeFoundation('month');
    foundation.selectYear(2025, 'left');
    expect(getState().yamYear.left).toBe(2025);
  });

  it('monthRange：左年晚于右年时右年自动 +1', () => {
    const { foundation, getState } = makeFoundation('monthRange', { yamYear: { left: 2024, right: 2024 }, yamMonth: { left: 3, right: 4 } });
    foundation.selectYear(2026, 'left');
    expect(getState().yamYear.right).toBe(2027);
  });

  it('selectMonth 写入 yamMonth 对应 panel', () => {
    const { foundation, getState } = makeFoundation('month');
    foundation.selectMonth(7, 'left');
    expect(getState().yamMonth.left).toBe(7);
  });

  it('autoSelectMonth：选年后若当前月被禁用则自动跳到未禁用月', () => {
    const { foundation, getState } = makeFoundation('month', { yamYear: { left: 2024, right: 0 }, yamMonth: { left: 3, right: 0 } });
    const disabledDate = (d: Date) => d.getMonth() === 2;
    foundation.selectYear(2025, 'left', disabledDate);
    expect(getState().yamMonth.left).not.toBe(3);
  });

  it('commitYearMonth：month 类型提交该年月首日', () => {
    const { foundation } = makeFoundation('month', { yamYear: { left: 2024, right: 0 }, yamMonth: { left: 7, right: 0 } });
    const result = foundation.commitYearMonth(false, false);
    const d = result.notifyValue as Date;
    expect(d.getFullYear()).toBe(2024);
    expect(d.getMonth()).toBe(6);
    expect(d.getDate()).toBe(1);
  });

  it('commitYearMonth：monthRange 类型提交 [左首日, 右首日]', () => {
    const { foundation } = makeFoundation('monthRange', { yamYear: { left: 2024, right: 2024 }, yamMonth: { left: 3, right: 6 } });
    const result = foundation.commitYearMonth(false, false);
    const [s, e] = result.notifyValue as [Date, Date];
    expect(s.getMonth()).toBe(2);
    expect(e.getMonth()).toBe(5);
  });
});

describe('insetInput', () => {
  it('handleInsetInputChange：date 类型写 monthLeft.dateInput', () => {
    const { foundation, getState } = makeFoundation('date');
    const result = foundation.handleInsetInputChange('monthLeft.dateInput', '2024-03-05');
    expect(result.insetInputValue.monthLeft.dateInput).toBe('2024-03-05');
    expect(getState().insetInputValue.monthLeft.dateInput).toBe('2024-03-05');
  });

  it('concatInsetInputValue：dateRange 拼两端', () => {
    const { foundation } = makeFoundation('dateRange');
    const str = foundation.concatInsetInputValue({ monthLeft: { dateInput: '2024-03-01', timeInput: '' }, monthRight: { dateInput: '2024-03-10', timeInput: '' } });
    expect(str).toBe('2024-03-01 ~ 2024-03-10');
  });

  it('getInsetInputPlaceholder：dateTime 类型拆日期/时间占位符', () => {
    const { foundation } = makeFoundation('dateTime');
    const ph = foundation.getInsetInputPlaceholder();
    expect(ph.datePlaceholder).toBe('yyyy-MM-dd');
    expect(ph.timePlaceholder).toBe('HH:mm:ss');
  });
});

describe('formatShowText', () => {
  it('单值格式化', () => {
    const { foundation } = makeFoundation('date');
    expect(foundation.formatShowText(new Date(2024, 2, 5))).toBe('2024-03-05');
  });

  it('range：组内 rangeSeparator', () => {
    const { foundation } = makeFoundation('dateRange');
    const text = foundation.formatShowText([new Date(2024, 2, 1), new Date(2024, 2, 10)]);
    expect(text).toBe('2024-03-01 ~ 2024-03-10');
  });

  it('multiple：逗号分隔', () => {
    const { foundation } = makeFoundation('date', {}, { multiple: true });
    const text = foundation.formatShowText([new Date(2024, 2, 1), new Date(2024, 2, 10)]);
    expect(text).toBe('2024-03-01,2024-03-10');
  });
});
