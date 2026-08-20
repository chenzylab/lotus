import { describe, it, expect } from 'vitest';
import { TimePickerFoundation, type TimePickerState } from './foundation.js';

function makeFoundation(initial: Partial<TimePickerState> = {}) {
  let state: TimePickerState = { pair: [null, null], visible: false, inputDraft: null, invalid: false, ...initial };
  const foundation = new TimePickerFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('open / close / toggle', () => {
  it('open 设置 visible=true', () => {
    const { foundation, getState } = makeFoundation();
    foundation.open();
    expect(getState().visible).toBe(true);
  });

  it('已打开时 open 不做任何事（幂等）', () => {
    const { foundation, getState } = makeFoundation({ visible: true });
    foundation.open();
    expect(getState().visible).toBe(true);
  });

  it('close 设置 visible=false', () => {
    const { foundation, getState } = makeFoundation({ visible: true });
    foundation.close();
    expect(getState().visible).toBe(false);
  });

  it('toggle 在关闭时打开、打开时关闭', () => {
    const { foundation, getState } = makeFoundation();
    foundation.toggle();
    expect(getState().visible).toBe(true);
    foundation.toggle();
    expect(getState().visible).toBe(false);
  });
});

describe('onInputChange', () => {
  it('写入草稿', () => {
    const { foundation, getState } = makeFoundation();
    foundation.onInputChange('09:30');
    expect(getState().inputDraft).toBe('09:30');
  });
});

describe('commitDraft：单选', () => {
  it('空串提交清空 pair', () => {
    const { foundation, getState } = makeFoundation({ pair: [new Date(2024, 0, 1, 9), null], inputDraft: '' });
    const result = foundation.commitDraft('', false, ' ~ ', false);
    expect(result.pair).toEqual([null, null]);
    expect(getState().pair).toEqual([null, null]);
    expect(getState().inputDraft).toBeNull();
  });

  it('解析成功写入 pair[0]，保留 pair[1]', () => {
    const { foundation, getState } = makeFoundation();
    const result = foundation.commitDraft('09:30:00', false, ' ~ ', false);
    expect(result.pair?.[0]?.getHours()).toBe(9);
    expect(result.pair?.[0]?.getMinutes()).toBe(30);
    expect(getState().invalid).toBe(false);
    expect(getState().inputDraft).toBeNull();
  });

  it('解析失败标记 invalid，不改 pair', () => {
    const { foundation, getState } = makeFoundation({ pair: [new Date(2024, 0, 1, 9), null] });
    const result = foundation.commitDraft('not-a-time', false, ' ~ ', false);
    expect(result.pair).toBeNull();
    expect(getState().invalid).toBe(true);
    expect(getState().pair[0]?.getHours()).toBe(9);
  });

  it('受控模式下不写 pair 到 state，但仍返回解析结果', () => {
    const { foundation, getState } = makeFoundation({ pair: [null, null] });
    const result = foundation.commitDraft('09:30:00', false, ' ~ ', true);
    expect(result.pair?.[0]?.getHours()).toBe(9);
    expect(getState().pair).toEqual([null, null]);
    expect(getState().inputDraft).toBeNull();
  });
});

describe('commitDraft：range', () => {
  it('按分隔符拆两端解析', () => {
    const { foundation, getState } = makeFoundation();
    const result = foundation.commitDraft('09:00:00 ~ 18:00:00', true, ' ~ ', false);
    expect(result.pair?.[0]?.getHours()).toBe(9);
    expect(result.pair?.[1]?.getHours()).toBe(18);
    expect(getState().invalid).toBe(false);
  });

  it('只有一端解析成功也接受（另一端 null）', () => {
    const { foundation } = makeFoundation();
    const result = foundation.commitDraft('09:00:00 ~ ', true, ' ~ ', false);
    expect(result.pair?.[0]?.getHours()).toBe(9);
    expect(result.pair?.[1]).toBeNull();
  });

  it('两端都解析失败标记 invalid', () => {
    const { foundation, getState } = makeFoundation();
    const result = foundation.commitDraft('foo ~ bar', true, ' ~ ', false);
    expect(result.pair).toBeNull();
    expect(getState().invalid).toBe(true);
  });
});

describe('clearInvalid', () => {
  it('清除 invalid 标记', () => {
    const { foundation, getState } = makeFoundation({ invalid: true });
    foundation.clearInvalid();
    expect(getState().invalid).toBe(false);
  });
});

describe('commitColumn', () => {
  it('无已有值时以今天为基写入 h/m/s', () => {
    const { foundation, getState } = makeFoundation();
    const next = foundation.commitColumn(0, 14, 20, 5, false);
    expect(next[0]?.getHours()).toBe(14);
    expect(next[0]?.getMinutes()).toBe(20);
    expect(next[0]?.getSeconds()).toBe(5);
    expect(getState().pair[0]?.getHours()).toBe(14);
  });

  it('已有值时保留日期部分，只改时分秒', () => {
    const existing = new Date(2024, 5, 15, 8, 0, 0);
    const { foundation } = makeFoundation({ pair: [existing, null] });
    const next = foundation.commitColumn(0, 20, 0, 0, false);
    expect(next[0]?.getFullYear()).toBe(2024);
    expect(next[0]?.getMonth()).toBe(5);
    expect(next[0]?.getDate()).toBe(15);
    expect(next[0]?.getHours()).toBe(20);
  });

  it('range 场景只更新对应 panelIndex，另一端不动', () => {
    const existing1 = new Date(2024, 0, 1, 9);
    const { foundation, getState } = makeFoundation({ pair: [existing1, null] });
    const next = foundation.commitColumn(1, 18, 0, 0, false);
    expect(next[0]).toBe(existing1);
    expect(next[1]?.getHours()).toBe(18);
    expect(getState().pair[0]).toBe(existing1);
  });

  it('受控模式下不写入 state，仍返回合成结果', () => {
    const { foundation, getState } = makeFoundation({ pair: [null, null] });
    const next = foundation.commitColumn(0, 10, 0, 0, true);
    expect(next[0]?.getHours()).toBe(10);
    expect(getState().pair).toEqual([null, null]);
  });
});

describe('clear', () => {
  it('非受控：清空 pair、草稿、invalid', () => {
    const { foundation, getState } = makeFoundation({
      pair: [new Date(), new Date()],
      inputDraft: 'x',
      invalid: true,
    });
    const next = foundation.clear(false);
    expect(next).toEqual([null, null]);
    expect(getState().pair).toEqual([null, null]);
    expect(getState().inputDraft).toBeNull();
    expect(getState().invalid).toBe(false);
  });

  it('受控：不写 pair，仍清草稿/invalid', () => {
    const existing: [Date, Date] = [new Date(), new Date()];
    const { foundation, getState } = makeFoundation({ pair: existing, inputDraft: 'x', invalid: true });
    const next = foundation.clear(true);
    expect(next).toEqual([null, null]);
    expect(getState().pair).toBe(existing);
    expect(getState().inputDraft).toBeNull();
    expect(getState().invalid).toBe(false);
  });
});
