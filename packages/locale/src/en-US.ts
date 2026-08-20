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
};

export default enUS;
