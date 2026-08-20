/** DatePicker 常量：class 前缀、format token、类型枚举，移植自参考实现（对齐 Semi）。 */

export const formatToken = {
  FORMAT_FULL_DATE: 'yyyy-MM-dd',
  FORMAT_TIME_PICKER: 'HH:mm:ss',
  FORMAT_DATE_TIME: 'yyyy-MM-dd HH:mm:ss',
  FORMAT_YEAR_MONTH: 'yyyy-MM',
} as const;

const defaultFormatTokens: Record<string, string> = {
  date: formatToken.FORMAT_FULL_DATE,
  dateTime: formatToken.FORMAT_DATE_TIME,
  dateRange: formatToken.FORMAT_FULL_DATE,
  dateTimeRange: formatToken.FORMAT_DATE_TIME,
  month: formatToken.FORMAT_YEAR_MONTH,
  monthRange: formatToken.FORMAT_YEAR_MONTH,
  // Semi 的 year 类型无默认 token，触发器改走 Intl 单独格式化年份；lotus 未搭建
  // 独立的 Intl 年份展示路径，直接给 'yyyy' 走同一套 date-fns 格式化足够且更简单。
  year: 'yyyy',
};

/** 按 type 取默认 format token。 */
export function getDefaultFormatTokenByType(type: string): string | undefined {
  return type ? defaultFormatTokens[type] : undefined;
}

export const strings = {
  DEFAULT_SEPARATOR_MULTIPLE: ',',
  DEFAULT_SEPARATOR_RANGE: ' ~ ',
  TYPE_SET: ['date', 'dateRange', 'year', 'month', 'monthRange', 'dateTime', 'dateTimeRange'] as const,
  PANEL_TYPE_LEFT: 'left',
  PANEL_TYPE_RIGHT: 'right',
  ...formatToken,
} as const;

export type PickerType = (typeof strings.TYPE_SET)[number];
export type PanelType = typeof strings.PANEL_TYPE_LEFT | typeof strings.PANEL_TYPE_RIGHT;

export function isRangeType(type: string): boolean {
  return /range/i.test(type);
}

export function isDateTimeType(type: string): boolean {
  return /dateTime/i.test(type);
}

export function isYearOrMonthType(type: string): boolean {
  return type === 'month' || type === 'year' || type === 'monthRange';
}
