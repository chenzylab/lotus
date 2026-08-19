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
  Calendar: {
    allDay: '全天',
    remaining: (remained) => `还有 ${remained} 项`,
    weekdays: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
    months: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  },
};

export default zhCN;
