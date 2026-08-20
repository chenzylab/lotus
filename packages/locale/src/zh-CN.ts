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
  UserGuide: {
    next: '下一步',
    prev: '上一步',
    skip: '跳过',
    finish: '完成',
  },
  TimePicker: {
    placeholder: '请选择时间',
    placeholderRange: '请选择时间范围',
    hour: '时',
    minute: '分',
    second: '秒',
    hourLabel: '时',
    minuteLabel: '分',
    secondLabel: '秒',
    AM: '上午',
    PM: '下午',
    begin: '开始',
    end: '结束',
  },
  DatePicker: {
    placeholder: {
      date: '请选择日期',
      dateRange: '请选择日期范围',
      dateTime: '请选择日期时间',
      dateTimeRange: '请选择日期时间范围',
      month: '请选择月份',
      monthRange: '请选择月份范围',
      year: '请选择年份',
    },
    weeks: ['周日', '周一', '周二', '周三', '周四', '周五', '周六'],
    months: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
    monthText: (year, month) => `${year}年 ${month}月`,
    confirm: '确定',
    cancel: '取消',
    clear: '清除',
    today: '今天',
    now: '此刻',
  },
};

export default zhCN;
