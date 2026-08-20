import type { LocaleShape } from './types.js';

const enUS: LocaleShape = {
  code: 'en-US',
  dir: 'ltr',
  Form: {
    requiredError: 'This field is required',
    patternError: 'Invalid format',
    minError: (min) => `Must be no less than ${min}`,
    maxError: (max) => `Must be no more than ${max}`,
  },
  Input: {
    clear: 'Clear',
    showPassword: 'Show password',
    hidePassword: 'Hide password',
  },
  InputNumber: {
    clear: 'Clear',
    increase: 'Increase',
    decrease: 'Decrease',
  },
  TextArea: {
    clear: 'Clear',
  },
  Select: {
    clear: 'Clear',
  },
  Modal: {
    okText: 'OK',
    cancelText: 'Cancel',
  },
  Calendar: {
    allDay: 'All Day',
    remaining: (remained) => `${remained} more`,
    weekdays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    months: [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ],
  },
  UserGuide: {
    next: 'Next',
    prev: 'Prev',
    skip: 'Skip',
    finish: 'Finish',
  },
  TimePicker: {
    placeholder: 'Select time',
    placeholderRange: 'Select time range',
    hour: '',
    minute: '',
    second: '',
    hourLabel: 'Hour',
    minuteLabel: 'Minute',
    secondLabel: 'Second',
    AM: 'AM',
    PM: 'PM',
    begin: 'Begin',
    end: 'End',
  },
  DatePicker: {
    placeholder: {
      date: 'Select date',
      dateRange: 'Select date range',
      dateTime: 'Select date time',
      dateTimeRange: 'Select date time range',
      month: 'Select month',
      monthRange: 'Select month range',
      year: 'Select year',
    },
    weeks: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    months: [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ],
    monthText: (year, month) => `${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1]} ${year}`,
    confirm: 'Confirm',
    cancel: 'Cancel',
    clear: 'Clear',
    today: 'Today',
    now: 'Now',
  },
};

export default enUS;
