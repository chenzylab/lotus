import { Foundation, type Adapter } from '../../base/adapter.js';
import { parseTimeString } from './time-utils.js';

export * from './time-utils.js';

export type TimePickerPair = [Date | null, Date | null];

export interface TimePickerState {
  /** 已提交的值对；type='time' 时只用 [0]。 */
  pair: TimePickerPair;
  visible: boolean;
  /** 触发器键入中的草稿文本，null 表示未在编辑（展示已提交值的格式化文案）。 */
  inputDraft: string | null;
  /** 手输解析失败态。 */
  invalid: boolean;
}

function toDate(input: string): Date | null {
  const parts = parseTimeString(input);
  if (!parts) return null;
  const d = new Date();
  d.setHours(parts.hour, parts.minute, parts.second, 0);
  return d;
}

/**
 * TimePicker 状态机：面板开关、手输草稿解析提交、面板选择时间列合成。
 * 不做候选项过滤（时间列由 time-utils 纯函数在组件里直接算，不经本类）。
 */
export class TimePickerFoundation extends Foundation<TimePickerState> {
  constructor(adapter: Adapter<TimePickerState>) {
    super(adapter);
  }

  open(): void {
    const { visible } = this.getState();
    if (visible) return;
    this.setState({ visible: true });
  }

  close(): void {
    this.setState({ visible: false });
  }

  toggle(): void {
    const { visible } = this.getState();
    if (visible) this.close();
    else this.open();
  }

  onInputChange(v: string): void {
    this.setState({ inputDraft: v });
  }

  /**
   * 提交草稿（失焦/Enter 触发）：空串清空；单选解析整串；range 按 rangeSeparator 拆两端，
   * 任一端解析成功即接受（另一端保持 null）。解析失败标记 invalid，不改 pair。
   * 受控模式下仍返回解析结果供组件触发 onChange，但不直接写 state.pair（由外部 value 驱动）。
   */
  commitDraft(raw: string, isRange: boolean, rangeSeparator: string, isControlled: boolean): { pair: TimePickerPair | null } {
    const text = raw.trim();
    if (text === '') {
      const pair: TimePickerPair = [null, null];
      if (!isControlled) this.setState({ pair, inputDraft: null, invalid: false });
      else this.setState({ inputDraft: null, invalid: false });
      return { pair };
    }
    if (isRange) {
      const sepTrim = rangeSeparator.trim();
      const parts = text.split(sepTrim === '' ? '~' : sepTrim);
      const s = parts[0] ? toDate(parts[0].trim()) : null;
      const e = parts[1] ? toDate(parts[1].trim()) : null;
      if (s || e) {
        const pair: TimePickerPair = [s, e];
        if (!isControlled) this.setState({ pair, inputDraft: null, invalid: false });
        else this.setState({ inputDraft: null, invalid: false });
        return { pair };
      }
      this.setState({ invalid: true, inputDraft: null });
      return { pair: null };
    }
    const d = toDate(text);
    if (d) {
      const { pair: cur } = this.getState();
      const pair: TimePickerPair = [d, cur[1]];
      if (!isControlled) this.setState({ pair, inputDraft: null, invalid: false });
      else this.setState({ inputDraft: null, invalid: false });
      return { pair };
    }
    this.setState({ invalid: true, inputDraft: null });
    return { pair: null };
  }

  clearInvalid(): void {
    this.setState({ invalid: false });
  }

  /** 面板选择时间列：合成新 Date（保留该端已有日期部分，写入 h/m/s；无已有值则以今天为基）。 */
  commitColumn(panelIndex: 0 | 1, h: number, m: number, s: number, isControlled: boolean): TimePickerPair {
    const { pair } = this.getState();
    const src = pair[panelIndex];
    const base = src ? new Date(src) : new Date();
    base.setHours(h, m, s, 0);
    const next: TimePickerPair = [...pair];
    next[panelIndex] = base;
    if (!isControlled) this.setState({ pair: next });
    return next;
  }

  clear(isControlled: boolean): TimePickerPair {
    const next: TimePickerPair = [null, null];
    if (!isControlled) this.setState({ pair: next, inputDraft: null, invalid: false });
    else this.setState({ inputDraft: null, invalid: false });
    return next;
  }
}

export { toDate as parseTimeInput };
