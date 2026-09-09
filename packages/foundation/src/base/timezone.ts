/**
 * 时区转换：供 DatePicker/TimePicker 的 `timeZone` prop（可由 ConfigProvider 全局下发）
 * 使用。基于 `date-fns-tz`（内容处理类库，不受 AGENTS.md「基础能力自研」条款约束——
 * 该条款仅针对浮层定位/拖拽/虚拟滚动这类"交互行为"库）。
 *
 * 时区取值对齐 Semi 语义：IANA 时区名（如 `Asia/Shanghai`）、`GMT±HH:MM` 形式字符串
 * （Semi 官方演示的写法），或数值（UTC 偏移小时数，支持半小时/45 分制如 5.5/5.75）。
 */
import { toZonedTime, fromZonedTime } from 'date-fns-tz';

export type TimeZone = string | number;

/** 数值偏移（小时）→ `+HH:MM` / `-HH:MM` 字符串，date-fns-tz 能识别的格式。 */
function numericOffsetToString(hours: number): string {
    const sign = hours >= 0 ? '+' : '-';
    const abs = Math.abs(hours);
    const wholeHours = Math.floor(abs);
    const minutes = Math.round((abs - wholeHours) * 60);
    return `${sign}${String(wholeHours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}

/**
 * 把 Semi 允许的 `GMT+08:00` / `GMT-05:00` 写法转成 date-fns-tz 认识的 `+08:00` 格式；
 * 其余字符串（IANA 名、已经是 `+08:00` 格式的）原样返回。
 */
function normalizeTimeZoneString(timeZone: string): string {
    const match = /^GMT([+-]\d{2}:\d{2})$/i.exec(timeZone.trim());
    return match?.[1] ?? timeZone;
}

/** 归一化为 date-fns-tz 可直接消费的时区标识（IANA 名或 `±HH:MM` 偏移字符串）。 */
export function normalizeTimeZone(timeZone: TimeZone): string {
    return typeof timeZone === 'number' ? numericOffsetToString(timeZone) : normalizeTimeZoneString(timeZone);
}

/** 对齐 Semi `isValidTimeZone`：只做类型/空值粗校验，具体是否是合法时区交给 date-fns-tz 运行时处理。 */
export function isValidTimeZone(timeZone: unknown): timeZone is TimeZone {
    return (typeof timeZone === 'string' || typeof timeZone === 'number') && timeZone !== '';
}

/** UTC 时刻 → 目标时区下的挂钟时间（返回的 Date 用本地 getter 读取即为目标时区的年月日时分）。 */
export function utcToZonedTime(date: Date, timeZone: TimeZone): Date {
    return toZonedTime(date, normalizeTimeZone(timeZone));
}

/** 目标时区下的挂钟时间 → UTC 时刻。 */
export function zonedTimeToUtc(date: Date, timeZone: TimeZone): Date {
    return fromZonedTime(date, normalizeTimeZone(timeZone));
}
