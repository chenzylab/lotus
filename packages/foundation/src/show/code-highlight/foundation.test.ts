import { describe, expect, it } from 'vitest';
import { resolveCodeClassName } from './foundation.js';

describe('resolveCodeClassName', () => {
  it('空 className 时加上 language-* 与 line-numbers', () => {
    expect(resolveCodeClassName('', 'ts', true)).toBe('language-ts line-numbers');
  });

  it('lineNumber=false 时不加 line-numbers', () => {
    expect(resolveCodeClassName('', 'ts', false)).toBe('language-ts');
  });

  it('已存在 language-* 类时不重复添加', () => {
    expect(resolveCodeClassName('language-js', 'ts', true)).toBe('language-js line-numbers');
  });

  it('已存在 line-numbers 类时不重复叠加', () => {
    expect(resolveCodeClassName('language-ts line-numbers', 'ts', true)).toBe('language-ts line-numbers');
  });

  it('lineNumber 从 true 切到 false 时移除已有 line-numbers 类', () => {
    expect(resolveCodeClassName('language-ts line-numbers', 'ts', false)).toBe('language-ts');
  });

  it('保留其它自定义类名', () => {
    expect(resolveCodeClassName('foo language-js bar', 'ts', true)).toBe('foo language-js bar line-numbers');
  });

  it('language 为空字符串时不添加 language-* 类', () => {
    expect(resolveCodeClassName('', '', true)).toBe('line-numbers');
  });

  it('默认 lineNumber 为 true', () => {
    expect(resolveCodeClassName('', 'ts')).toBe('language-ts line-numbers');
  });
});
