import type { LocaleShape } from './types.js';

const zhCN: LocaleShape = {
  code: 'zh-CN',
  dir: 'ltr',
  Form: {
    requiredError: '该字段不能为空',
    patternError: '格式不正确',
    minError: (min) => `不能小于 ${min}`,
    maxError: (max) => `不能大于 ${max}`,
  },
  Input: {
    clear: '清除',
    showPassword: '显示密码',
    hidePassword: '隐藏密码',
  },
  InputNumber: {
    clear: '清除',
    increase: '增加',
    decrease: '减少',
  },
  TextArea: {
    clear: '清除',
  },
  Select: {
    clear: '清除',
  },
  Modal: {
    okText: '确定',
    cancelText: '取消',
  },
};

export default zhCN;
