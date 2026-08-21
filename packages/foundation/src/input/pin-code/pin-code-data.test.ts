import { describe, it, expect } from 'vitest';
import { validatePinChar, toValueList, distributePaste } from './pin-code-data.js';

describe('validatePinChar', () => {
  it('format=number：只接受单个数字字符', () => {
    expect(validatePinChar('5', 'number')).toBe(true);
    expect(validatePinChar('a', 'number')).toBe(false);
    expect(validatePinChar('', 'number')).toBe(false);
    expect(validatePinChar('12', 'number')).toBe(false);
  });

  it('format=mixed：接受字母和数字', () => {
    expect(validatePinChar('a', 'mixed')).toBe(true);
    expect(validatePinChar('Z', 'mixed')).toBe(true);
    expect(validatePinChar('5', 'mixed')).toBe(true);
    expect(validatePinChar('#', 'mixed')).toBe(false);
  });

  it('format=RegExp：按正则匹配', () => {
    expect(validatePinChar('a', /[a-f]/)).toBe(true);
    expect(validatePinChar('z', /[a-f]/)).toBe(false);
  });

  it('format=function：完全交由自定义逻辑', () => {
    expect(validatePinChar('x', (v) => v === 'x')).toBe(true);
    expect(validatePinChar('y', (v) => v === 'x')).toBe(false);
  });

  it('未知格式：默认放行（对齐 Semi validateValue 默认分支）', () => {
    expect(validatePinChar('#', 'unknown-format' as never)).toBe(true);
  });
});

describe('toValueList', () => {
  it('value 为空：返回 count 个空字符串', () => {
    expect(toValueList(undefined, 4)).toEqual(['', '', '', '']);
  });

  it('value 长度不足：补空字符串到 count', () => {
    expect(toValueList('12', 4)).toEqual(['1', '2', '', '']);
  });

  it('value 超长：截断到 count', () => {
    expect(toValueList('123456', 4)).toEqual(['1', '2', '3', '4']);
  });

  it('value 长度恰好等于 count', () => {
    expect(toValueList('1234', 4)).toEqual(['1', '2', '3', '4']);
  });
});

describe('distributePaste', () => {
  it('从 startIndex 开始逐字符写入', () => {
    const result = distributePaste(['', '', '', ''], 0, '123', 'number');
    expect(result.valueList).toEqual(['1', '2', '3', '']);
    expect(result.focusIndex).toBe(3);
    expect(result.reachedLast).toBe(false);
  });

  it('写满全部格：reachedLast=true，focusIndex 钳制在末格', () => {
    const result = distributePaste(['', '', '', ''], 0, '1234', 'number');
    expect(result.valueList).toEqual(['1', '2', '3', '4']);
    expect(result.focusIndex).toBe(3);
    expect(result.reachedLast).toBe(true);
  });

  it('粘贴文本超出剩余格数：多余字符被忽略', () => {
    const result = distributePaste(['', '', '', ''], 0, '123456', 'number');
    expect(result.valueList).toEqual(['1', '2', '3', '4']);
  });

  it('遇到第一个不合法字符立即停止（不跳过继续找下一个合法字符）', () => {
    const result = distributePaste(['', '', '', ''], 0, '12a34', 'number');
    expect(result.valueList).toEqual(['1', '2', '', '']);
    expect(result.focusIndex).toBe(2);
  });

  it('从中间格开始粘贴', () => {
    const result = distributePaste(['9', '', '', ''], 1, '23', 'number');
    expect(result.valueList).toEqual(['9', '2', '3', '']);
    expect(result.focusIndex).toBe(3);
  });

  it('第一个字符就不合法：不写入任何内容，focusIndex 回落到 startIndex', () => {
    const result = distributePaste(['', '', '', ''], 1, 'abc', 'number');
    expect(result.valueList).toEqual(['', '', '', '']);
    expect(result.focusIndex).toBe(1);
    expect(result.reachedLast).toBe(false);
  });
});
