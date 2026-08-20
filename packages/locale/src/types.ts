export interface FormLocale {
  requiredError: string;
  patternError: string;
  minError: (min: number) => string;
  maxError: (max: number) => string;
}

export interface InputLocale {
  clear: string;
  showPassword: string;
  hidePassword: string;
}

export interface InputNumberLocale {
  clear: string;
  increase: string;
  decrease: string;
}

export interface TextAreaLocale {
  clear: string;
}

export interface SelectLocale {
  clear: string;
}

export interface ModalLocale {
  okText: string;
  cancelText: string;
}

export interface CalendarLocale {
  allDay: string;
  remaining: (remained: number) => string;
  weekdays: [string, string, string, string, string, string, string];
  months: [string, string, string, string, string, string, string, string, string, string, string, string];
}

export interface UserGuideLocale {
  next: string;
  prev: string;
  skip: string;
  finish: string;
}

export interface TimePickerLocale {
  placeholder: string;
  placeholderRange: string;
  hour: string;
  minute: string;
  second: string;
  hourLabel: string;
  minuteLabel: string;
  secondLabel: string;
  AM: string;
  PM: string;
  begin: string;
  end: string;
}

export interface DatePickerLocale {
  placeholder: {
    date: string;
    dateRange: string;
    dateTime: string;
    dateTimeRange: string;
    month: string;
    monthRange: string;
    year: string;
  };
  weeks: [string, string, string, string, string, string, string];
  months: [string, string, string, string, string, string, string, string, string, string, string, string];
  monthText: (year: number, month: number) => string;
  confirm: string;
  cancel: string;
  clear: string;
  today: string;
  now: string;
}

export interface LocaleShape {
  code: string;
  dir: 'ltr' | 'rtl';
  Form: FormLocale;
  Input: InputLocale;
  InputNumber: InputNumberLocale;
  TextArea: TextAreaLocale;
  Select: SelectLocale;
  Modal: ModalLocale;
  Calendar: CalendarLocale;
  UserGuide: UserGuideLocale;
  TimePicker: TimePickerLocale;
  DatePicker: DatePickerLocale;
}
