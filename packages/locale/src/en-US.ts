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
};

export default enUS;
