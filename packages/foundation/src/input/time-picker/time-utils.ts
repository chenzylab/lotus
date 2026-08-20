/**
 * 纯函数时间列工具，无框架依赖。移植自参考实现（chenzy.design packages/core/src/time.ts），
 * 逻辑对齐 Semi timePicker 的列生成/12小时制换算/format token 解析。
 */

export type Meridiem = 'am' | 'pm';

export interface TimeOption {
  value: number;
  disabled: boolean;
}

export interface DisabledTime {
  disabledHours?: () => number[];
  disabledMinutes?: (hour: number) => number[];
  disabledSeconds?: (hour: number, minute: number) => number[];
}

export function buildRange(max: number, step: number): number[] {
  const safeStep = step > 0 ? Math.floor(step) : 1;
  const out: number[] = [];
  for (let i = 0; i < max; i += safeStep) out.push(i);
  return out;
}

export function to12Hour(hour24: number): number {
  const h = ((hour24 % 24) + 24) % 24;
  const mod = h % 12;
  return mod === 0 ? 12 : mod;
}

export function meridiemOf(hour24: number): Meridiem {
  const h = ((hour24 % 24) + 24) % 24;
  return h < 12 ? 'am' : 'pm';
}

export function from12Hour(hour12: number, meridiem: Meridiem): number {
  const h = ((Math.floor(hour12) - 1 + 12) % 12) + 1;
  const base = h % 12;
  return meridiem === 'pm' ? base + 12 : base;
}

export function buildHourOptions(
  step: number,
  use12Hours: boolean,
  meridiem: Meridiem,
  disabledHours?: () => number[],
): TimeOption[] {
  const disabledSet = new Set(disabledHours ? disabledHours() : []);
  if (!use12Hours) {
    return buildRange(24, step).map((value) => ({ value, disabled: disabledSet.has(value) }));
  }
  const safeStep = step > 0 ? Math.floor(step) : 1;
  const out: TimeOption[] = [];
  for (let display = 1; display <= 12; display += safeStep) {
    const hour24 = from12Hour(display, meridiem);
    out.push({ value: display, disabled: disabledSet.has(hour24) });
  }
  return out;
}

export function buildMinuteOptions(
  step: number,
  hour24: number,
  disabledMinutes?: (hour: number) => number[],
): TimeOption[] {
  const disabledSet = new Set(disabledMinutes ? disabledMinutes(hour24) : []);
  return buildRange(60, step).map((value) => ({ value, disabled: disabledSet.has(value) }));
}

export function buildSecondOptions(
  step: number,
  hour24: number,
  minute: number,
  disabledSeconds?: (hour: number, minute: number) => number[],
): TimeOption[] {
  const disabledSet = new Set(disabledSeconds ? disabledSeconds(hour24, minute) : []);
  return buildRange(60, step).map((value) => ({ value, disabled: disabledSet.has(value) }));
}

export function applyHideDisabled(options: TimeOption[], hideDisabledOptions: boolean): TimeOption[] {
  return hideDisabledOptions ? options.filter((o) => !o.disabled) : options;
}

export function isTimeDisabled(hour24: number, minute: number, second: number, d: DisabledTime): boolean {
  if (d.disabledHours && d.disabledHours().includes(hour24)) return true;
  if (d.disabledMinutes && d.disabledMinutes(hour24).includes(minute)) return true;
  if (d.disabledSeconds && d.disabledSeconds(hour24, minute).includes(second)) return true;
  return false;
}

export interface TimeParts {
  hour: number;
  minute: number;
  second: number;
}

export interface FormatSpec {
  showHour: boolean;
  showMinute: boolean;
  showSecond: boolean;
  use12Hours: boolean;
}

/**
 * 解析 format 串（如 'HH:mm:ss'、'a h:mm'）得到该显示哪些列、是否 12 小时制。
 * H/HH=24小时，h/hh=12小时（隐含 use12Hours），m/mm=分，s/ss=秒，A/a=AM/PM（隐含 use12Hours）。
 */
export function parseFormatSpec(format: string): FormatSpec {
  const spec: FormatSpec = { showHour: false, showMinute: false, showSecond: false, use12Hours: false };
  const re = /H+|h+|m+|s+|A+|a+/g;
  let match: RegExpExecArray | null;
  while ((match = re.exec(format)) !== null) {
    const tok = match[0]![0];
    switch (tok) {
      case 'H':
        spec.showHour = true;
        break;
      case 'h':
        spec.showHour = true;
        spec.use12Hours = true;
        break;
      case 'm':
        spec.showMinute = true;
        break;
      case 's':
        spec.showSecond = true;
        break;
      case 'A':
      case 'a':
        spec.use12Hours = true;
        break;
      default:
        break;
    }
  }
  return spec;
}

function pad2(n: number): string {
  return n < 10 ? `0${n}` : `${n}`;
}

export function formatTime(parts: TimeParts, format: string): string {
  const { hour, minute, second } = parts;
  const h12 = to12Hour(hour);
  const mer = meridiemOf(hour);
  return format.replace(/H+|h+|m+|s+|A+|a+/g, (token) => {
    const tok = token[0];
    const padded = token.length >= 2;
    switch (tok) {
      case 'H':
        return padded ? pad2(hour) : `${hour}`;
      case 'h':
        return padded ? pad2(h12) : `${h12}`;
      case 'm':
        return padded ? pad2(minute) : `${minute}`;
      case 's':
        return padded ? pad2(second) : `${second}`;
      case 'A':
        return mer.toUpperCase();
      case 'a':
        return mer;
      default:
        return token;
    }
  });
}

/**
 * 容错解析时间串（'HH:mm'、'HH:mm:ss'，可选前导零，可选结尾 AM/PM）。
 * 有 meridiem 标记时前导数字按 12 小时制解读。
 */
export function parseTimeString(input: string): TimeParts | null {
  const str = input.trim();
  if (!str) return null;
  const m = /^(\d{1,2})(?::(\d{1,2}))?(?::(\d{1,2}))?\s*([AaPp][Mm])?$/.exec(str);
  if (!m) return null;
  let hour = Number(m[1]);
  const minute = m[2] === undefined ? 0 : Number(m[2]);
  const second = m[3] === undefined ? 0 : Number(m[3]);
  const mer = m[4]?.toLowerCase();
  if (Number.isNaN(hour) || Number.isNaN(minute) || Number.isNaN(second)) return null;
  if (mer) {
    if (hour < 1 || hour > 12) return null;
    hour = from12Hour(hour, mer.startsWith('p') ? 'pm' : 'am');
  }
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) return null;
  return { hour, minute, second };
}
