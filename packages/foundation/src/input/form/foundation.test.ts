import { describe, expect, it, vi } from 'vitest';
import { FormFoundation, type FormState } from './foundation.js';

function createFoundation(initial: FormState = { values: {}, errors: {}, touched: {}, validating: {} }) {
  let state = initial;
  const foundation = new FormFoundation({
    getState: () => state,
    setState: (patch) => {
      state = { ...state, ...patch };
    },
  });
  return { foundation, getState: () => state };
}

describe('FormFoundation', () => {
  it('registerField 携带 initValue 时写入 values（仅当当前值为 undefined）', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', {}, 'semi');
    expect(getState().values.username).toBe('semi');
  });

  it('registerField 不覆盖已存在的值', () => {
    const { foundation, getState } = createFoundation({ values: { username: 'existing' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', {}, 'semi');
    expect(getState().values.username).toBe('existing');
  });

  it('unregisterField 后该字段不再参与 validateAll', async () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', { rules: [{ required: true }] });
    foundation.unregisterField('username');
    const errors = await foundation.validateAll();
    expect(errors.username).toBeUndefined();
    expect(getState().errors.username).toBeUndefined();
  });

  it('setValue 更新 values 并回调 onValueChange', () => {
    const { foundation, getState } = createFoundation();
    const onValueChange = vi.fn();
    foundation.setValue('username', 'semi', onValueChange);
    expect(getState().values.username).toBe('semi');
    expect(onValueChange).toHaveBeenCalledWith({ username: 'semi' }, { username: 'semi' });
  });

  it('setTouched 更新 touched map', () => {
    const { foundation, getState } = createFoundation();
    foundation.setTouched('username', true);
    expect(getState().touched.username).toBe(true);
  });

  it('validateField：required 规则，空值不通过', async () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', { rules: [{ required: true, message: '必填' }] });
    const error = await foundation.validateField('username');
    expect(error).toBe('必填');
    expect(getState().errors.username).toBe('必填');
  });

  it('validateField：required 规则，有值时通过', async () => {
    const { foundation, getState } = createFoundation({ values: { username: 'semi' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', { rules: [{ required: true }] });
    const error = await foundation.validateField('username');
    expect(error).toBeUndefined();
    expect(getState().errors.username).toBeUndefined();
  });

  it('validateField：pattern 规则不匹配时返回错误', async () => {
    const { foundation } = createFoundation({ values: { email: 'not-an-email' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('email', { rules: [{ pattern: /^\S+@\S+\.\S+$/, message: '邮箱格式不正确' }] });
    const error = await foundation.validateField('email');
    expect(error).toBe('邮箱格式不正确');
  });

  it('validateField：min/max 规则', async () => {
    const { foundation } = createFoundation({ values: { age: 3 }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('age', { rules: [{ min: 18, message: '未成年' }] });
    expect(await foundation.validateField('age')).toBe('未成年');
  });

  it('validateField：自定义同步 validator', async () => {
    const { foundation } = createFoundation({ values: { age: 10 }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('age', {
      rules: [{ validator: (value) => (typeof value === 'number' && value < 18 ? '不满 18 岁' : undefined) }],
    });
    expect(await foundation.validateField('age')).toBe('不满 18 岁');
  });

  it('validateField：自定义异步 validator', async () => {
    const { foundation } = createFoundation({ values: { username: 'taken' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', {
      rules: [
        {
          validator: async (value) => {
            await Promise.resolve();
            return value === 'taken' ? '用户名已被占用' : undefined;
          },
        },
      ],
    });
    expect(await foundation.validateField('username')).toBe('用户名已被占用');
  });

  it('validateField：异步 validator 校验期间字段被 unregisterField 卸载，resolve 后不写入 errors/validating（回归防护：曾无条件写入已卸载字段，若同名字段后续重新挂载会继承这个过期结果，踩坑记录）', async () => {
    const { foundation, getState } = createFoundation({ values: { username: 'taken' }, errors: {}, touched: {}, validating: {} });
    let resolveValidator!: (value: string | undefined) => void;
    foundation.registerField('username', {
      rules: [
        {
          validator: () =>
            new Promise<string | undefined>((resolve) => {
              resolveValidator = resolve;
            }),
        },
      ],
    });

    const pending = foundation.validateField('username');
    expect(getState().validating.username).toBe(true);

    foundation.unregisterField('username');
    resolveValidator('用户名已被占用');
    const error = await pending;

    expect(error).toBe('用户名已被占用');
    expect(getState().errors.username).toBeUndefined();
    expect(getState().validating.username).toBe(true);
  });

  it('validateField：异步 validator 校验期间 validating 为 true，完成后恢复 false（Semi 自身没有这个状态，lotus 主动新增）', async () => {
    const { foundation, getState } = createFoundation({ values: { username: 'taken' }, errors: {}, touched: {}, validating: {} });
    let resolveValidator!: (value: string | undefined) => void;
    foundation.registerField('username', {
      rules: [
        {
          validator: () =>
            new Promise<string | undefined>((resolve) => {
              resolveValidator = resolve;
            }),
        },
      ],
    });

    const pending = foundation.validateField('username');
    // 校验函数尚未 resolve，validating 应该已经被标记为 true。
    expect(getState().validating.username).toBe(true);

    resolveValidator('用户名已被占用');
    await pending;
    expect(getState().validating.username).toBe(false);
    expect(getState().errors.username).toBe('用户名已被占用');
  });

  it('validateField：只有同步规则（required/pattern/min/max）时不标记 validating（同步校验是瞬时完成的，没有用户能感知到的进行中窗口）', async () => {
    const { foundation, getState } = createFoundation({ values: { username: '' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', { rules: [{ required: true, message: '必填' }] });
    await foundation.validateField('username');
    expect(getState().validating.username).toBeUndefined();
  });

  it('reset：清空 validating map', () => {
    const { foundation, getState } = createFoundation({
      values: {},
      errors: {},
      touched: {},
      validating: { username: true },
    });
    foundation.reset();
    expect(getState().validating).toEqual({});
  });

  it('validateField：数组规则按顺序执行，第一条不通过即返回', async () => {
    const { foundation } = createFoundation({ values: { username: '' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', {
      rules: [
        { required: true, message: '必填' },
        { pattern: /^a/, message: '必须以 a 开头' },
      ],
    });
    expect(await foundation.validateField('username')).toBe('必填');
  });

  it('validateAll：汇总所有字段的错误', async () => {
    const { foundation } = createFoundation({ values: { username: '', age: 3 }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', { rules: [{ required: true, message: '必填' }] });
    foundation.registerField('age', { rules: [{ min: 18, message: '未成年' }] });
    const errors = await foundation.validateAll();
    expect(errors).toEqual({ username: '必填', age: '未成年' });
  });

  it('validateAll：并发校验多个字段时，getState().errors 也要保留全部字段的错误（回归：并发写竞态曾导致后完成的字段覆盖先完成字段的 error）', async () => {
    const { foundation, getState } = createFoundation({
      values: { username: '', age: 3, businessLine: undefined },
      errors: {},
      touched: {},
      validating: {},
    });
    foundation.registerField('username', { rules: [{ required: true, message: '用户名不能为空' }] });
    foundation.registerField('age', { rules: [{ min: 18, message: '未成年' }] });
    foundation.registerField('businessLine', {
      rules: [{ validator: async (value) => (value ? undefined : '请选择业务线') }],
    });
    await foundation.validateAll();
    expect(getState().errors).toEqual({
      username: '用户名不能为空',
      age: '未成年',
      businessLine: '请选择业务线',
    });
  });

  it('submit：校验通过时调用 onSubmit，不调用 onSubmitFail', async () => {
    const { foundation } = createFoundation({ values: { username: 'semi' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', { rules: [{ required: true }] });
    const onSubmit = vi.fn();
    const onSubmitFail = vi.fn();
    await foundation.submit(onSubmit, onSubmitFail);
    expect(onSubmit).toHaveBeenCalledWith({ username: 'semi' });
    expect(onSubmitFail).not.toHaveBeenCalled();
  });

  it('submit：校验失败时调用 onSubmitFail，不调用 onSubmit', async () => {
    const { foundation } = createFoundation({ values: { username: '' }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('username', { rules: [{ required: true, message: '必填' }] });
    const onSubmit = vi.fn();
    const onSubmitFail = vi.fn();
    await foundation.submit(onSubmit, onSubmitFail);
    expect(onSubmit).not.toHaveBeenCalled();
    expect(onSubmitFail).toHaveBeenCalledWith({ username: '必填' }, { username: '' });
  });

  it('reset：恢复到 initValue，清空 errors 和 touched', async () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', {}, 'semi');
    foundation.setValue('username', 'changed');
    foundation.setTouched('username', true);
    await foundation.validateField('username');

    const onReset = vi.fn();
    foundation.reset(onReset);

    expect(getState().values).toEqual({ username: 'semi' });
    expect(getState().errors).toEqual({});
    expect(getState().touched).toEqual({});
    expect(onReset).toHaveBeenCalled();
  });

  it('reset：字段没有 initValue 时恢复为空', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', {});
    foundation.setValue('username', 'changed');
    foundation.reset();
    expect(getState().values).toEqual({});
  });

  it('reset：恢复到构造时（Form 挂载时）的 values 快照，即使字段从未通过 registerField 传 initValue（回归：Field 本身没有 initValue、只吃 Form 级 initValues 的字段，reset 后曾经不会被清空）', () => {
    const { foundation, getState } = createFoundation({
      values: { username: '', age: undefined, businessLine: undefined },
      errors: {},
      touched: {},
      validating: {},
    });
    foundation.registerField('username', {});
    foundation.registerField('age', {});
    foundation.registerField('businessLine', {});

    foundation.setValue('username', 'semi');
    foundation.setValue('age', 25);
    foundation.setValue('businessLine', 'douyin');
    foundation.reset();

    expect(getState().values).toEqual({ username: '', age: undefined, businessLine: undefined });
  });
});

describe('FormFoundation.unregisterField keepState', () => {
  it('keepState 未设置（默认 false）时卸载清除 values/errors/touched', () => {
    const { foundation, getState } = createFoundation({ values: { username: 'semi' }, errors: { username: '格式不对' }, touched: { username: true }, validating: {} });
    foundation.registerField('username', {});
    foundation.unregisterField('username');

    expect(getState().values.username).toBeUndefined();
    expect(getState().errors.username).toBeUndefined();
    expect(getState().touched.username).toBeUndefined();
  });

  it('keepState=true 时卸载保留 values/errors/touched', () => {
    const { foundation, getState } = createFoundation({ values: { username: 'semi' }, errors: { username: '格式不对' }, touched: { username: true }, validating: {} });
    foundation.registerField('username', { keepState: true });
    foundation.unregisterField('username');

    expect(getState().values.username).toBe('semi');
    expect(getState().errors.username).toBe('格式不对');
    expect(getState().touched.username).toBe(true);
  });
});

describe('FormFoundation.setValue convert', () => {
  it('未配置 convert 时原样写入', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', {});
    foundation.setValue('username', 'semi');
    expect(getState().values.username).toBe('semi');
  });

  it('配置 convert 时写入转换后的值', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', { convert: (v) => String(v).toUpperCase() });
    foundation.setValue('username', 'semi');
    expect(getState().values.username).toBe('SEMI');
  });

  it('convert 转换后的值同步传给 onValueChange 回调', () => {
    const { foundation } = createFoundation();
    foundation.registerField('username', { convert: (v) => String(v).toUpperCase() });
    const onValueChange = vi.fn();
    foundation.setValue('username', 'semi', onValueChange);
    expect(onValueChange).toHaveBeenCalledWith({ username: 'SEMI' }, { username: 'SEMI' });
  });
});

describe('FormFoundation 只读查询方法', () => {
  it('getInitValues 返回 Form 挂载时的完整快照', () => {
    const { foundation } = createFoundation({ values: { username: 'semi', age: 25 }, errors: {}, touched: {}, validating: {} });
    expect(foundation.getInitValues()).toEqual({ username: 'semi', age: 25 });
  });

  it('getInitValue 返回单个字段的初始值', () => {
    const { foundation } = createFoundation({ values: { username: 'semi' }, errors: {}, touched: {}, validating: {} });
    expect(foundation.getInitValue('username')).toBe('semi');
  });

  it('getFormState 返回完整当前状态', () => {
    const { foundation, getState } = createFoundation();
    expect(foundation.getFormState()).toEqual(getState());
  });

  it('getTouched 返回字段的 touched 状态，未设置时为 false', () => {
    const { foundation } = createFoundation({ values: {}, errors: {}, touched: { username: true }, validating: {} });
    expect(foundation.getTouched('username')).toBe(true);
    expect(foundation.getTouched('age')).toBe(false);
  });

  it('getError 返回字段的当前错误信息', () => {
    const { foundation } = createFoundation({ values: {}, errors: { username: '不能为空' }, touched: {}, validating: {} });
    expect(foundation.getError('username')).toBe('不能为空');
    expect(foundation.getError('age')).toBeUndefined();
  });

  it('getFieldExist 反映字段当前是否已注册', () => {
    const { foundation } = createFoundation();
    expect(foundation.getFieldExist('username')).toBe(false);
    foundation.registerField('username', {});
    expect(foundation.getFieldExist('username')).toBe(true);
    foundation.unregisterField('username');
    expect(foundation.getFieldExist('username')).toBe(false);
  });
});

describe('FormFoundation ArrayField 路径记法（field 名形如 contacts[0]）', () => {
  it('registerField 用路径写入数组元素', () => {
    const { foundation, getState } = createFoundation({ values: { contacts: ['张三'] }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('contacts[0]', {});
    expect(getState().values.contacts).toEqual(['张三']);
  });

  it('setValue 用路径读写数组元素，不影响数组其它项', () => {
    const { foundation, getState } = createFoundation({ values: { contacts: ['张三', '李四'] }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('contacts[0]', {});
    foundation.registerField('contacts[1]', {});
    foundation.setValue('contacts[0]', '王五');
    expect(getState().values.contacts).toEqual(['王五', '李四']);
  });

  it('setValue 对新增的数组索引路径正确创建数组', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('contacts[0]', {});
    foundation.setValue('contacts[0]', '张三');
    expect(getState().values.contacts).toEqual(['张三']);
  });

  it('setValue 支持嵌套对象字段路径（如 contacts[0].name）', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('contacts[0].name', {});
    foundation.setValue('contacts[0].name', '张三');
    expect(getState().values.contacts).toEqual([{ name: '张三' }]);
  });

  it('unregisterField 对 ArrayField 行内路径字段（形如 contacts[0]）豁免清值，不影响数组内容（回归防护：此前无条件清值，remove(index) 删除非尾部行时，Ripple 按 key 复用后续行 Field 组件实例、field prop 从 contacts[2] 变为 contacts[1]，与刚好卸载的旧 contacts[1] 实例操作同一路径，卸载清值会把复用实例刚写入的新值冲掉，界面上表现为删除中间行后其余行值错乱丢失）', () => {
    const { foundation, getState } = createFoundation({ values: { contacts: ['张三', '李四'] }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('contacts[0]', {});
    foundation.registerField('contacts[1]', {});
    foundation.unregisterField('contacts[0]');
    expect(getState().values.contacts).toEqual(['张三', '李四']);
  });

  it('unregisterField 对 ArrayField 行内路径字段仍清理 errors/touched（只豁免 values）', () => {
    const { foundation, getState } = createFoundation({ values: { contacts: ['张三'] }, errors: { 'contacts[0]': '不能为空' }, touched: { 'contacts[0]': true }, validating: {} });
    foundation.registerField('contacts[0]', {});
    foundation.unregisterField('contacts[0]');
    expect(getState().values.contacts).toEqual(['张三']);
    expect(getState().errors['contacts[0]']).toBeUndefined();
    expect(getState().touched['contacts[0]']).toBeUndefined();
  });

  it('validateField 对路径字段正确读取当前值参与校验', async () => {
    const { foundation } = createFoundation({ values: { contacts: ['taken'] }, errors: {}, touched: {}, validating: {} });
    foundation.registerField('contacts[0]', { rules: [{ required: true }] });
    const error = await foundation.validateField('contacts[0]');
    expect(error).toBeUndefined();
  });

  it('普通字段名（不含路径分隔符）行为与改动前完全等价', () => {
    const { foundation, getState } = createFoundation();
    foundation.registerField('username', {});
    foundation.setValue('username', 'semi');
    expect(getState().values.username).toBe('semi');
    foundation.unregisterField('username');
    expect(getState().values.username).toBeUndefined();
  });
});
