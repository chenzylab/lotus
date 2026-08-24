import { describe, expect, it } from 'vitest';
import { keyToCode, isValidHotKeys, matchHotKeys, Keys } from './foundation.js';

function makeEvent(overrides: Partial<Pick<KeyboardEvent, 'code' | 'key' | 'metaKey' | 'ctrlKey' | 'shiftKey' | 'altKey'>>) {
  return {
    code: '',
    key: '',
    metaKey: false,
    ctrlKey: false,
    shiftKey: false,
    altKey: false,
    ...overrides,
  };
}

describe('keyToCode', () => {
  it('已知键名映射到对应 code', () => {
    expect(keyToCode('a')).toBe('KeyA');
    expect(keyToCode('A')).toBe('KeyA');
    expect(keyToCode('1')).toBe('Digit1');
    expect(keyToCode('escape')).toBe('Escape');
  });

  it('未收录的键返回 undefined', () => {
    expect(keyToCode('unknown-key')).toBeUndefined();
  });
});

describe('isValidHotKeys', () => {
  it('恰好 1 个普通键 + 0 个修饰键时合法', () => {
    expect(isValidHotKeys(['s'])).toBe(true);
  });

  it('恰好 1 个普通键 + 多个修饰键时合法', () => {
    expect(isValidHotKeys(['control', 'shift', 's'])).toBe(true);
  });

  it('未知键名时抛错', () => {
    expect(() => isValidHotKeys(['not-a-real-key'])).toThrow('is not a valid key');
  });

  it('0 个普通键时抛错', () => {
    expect(() => isValidHotKeys(['control', 'shift'])).toThrow('one common key');
  });

  it('多于 1 个普通键时抛错', () => {
    expect(() => isValidHotKeys(['a', 'b'])).toThrow('one common key');
  });
});

describe('matchHotKeys', () => {
  it('普通键 + code 匹配命中', () => {
    const event = makeEvent({ code: 'KeyS', key: 's' });
    expect(matchHotKeys(event, ['s'])).toBe(true);
  });

  it('修饰键精确匹配：声明的必须按下', () => {
    const event = makeEvent({ code: 'KeyS', key: 's', ctrlKey: true });
    expect(matchHotKeys(event, ['control', 's'])).toBe(true);
    expect(matchHotKeys(event, ['s'])).toBe(false);
  });

  it('修饰键精确匹配：未声明的必须未按下（多按不命中）', () => {
    const event = makeEvent({ code: 'KeyS', key: 's', ctrlKey: true, shiftKey: true });
    expect(matchHotKeys(event, ['control', 's'])).toBe(false);
  });

  it('Meta 和 Control 严格区分，不互相替代', () => {
    const event = makeEvent({ code: 'KeyS', key: 's', metaKey: true });
    expect(matchHotKeys(event, ['control', 's'])).toBe(false);
    expect(matchHotKeys(event, ['meta', 's'])).toBe(true);
  });

  it('mergeMetaCtrl 是死 prop，传 true 不改变 Meta/Ctrl 严格区分的行为（对齐 Semi）', () => {
    const event = makeEvent({ code: 'KeyS', key: 's', metaKey: true });
    expect(matchHotKeys(event, ['control', 's'], { mergeMetaCtrl: true })).toBe(false);
  });

  it('code 未映射时回退比较 key（大小写不敏感）', () => {
    const event = makeEvent({ code: '', key: 'S' });
    expect(matchHotKeys(event, ['s'])).toBe(true);
  });

  it('code 不匹配但 key 匹配时仍回退命中', () => {
    const event = makeEvent({ code: 'SomeWeirdCode', key: 's' });
    expect(matchHotKeys(event, ['s'])).toBe(true);
  });

  it('普通键完全不匹配时不命中', () => {
    const event = makeEvent({ code: 'KeyA', key: 'a' });
    expect(matchHotKeys(event, ['s'])).toBe(false);
  });

  it('用 Keys 常量与原生字符串效果一致', () => {
    const event = makeEvent({ code: 'KeyS', key: 's', ctrlKey: true });
    expect(matchHotKeys(event, [Keys.Control, Keys.S])).toBe(true);
  });
});
