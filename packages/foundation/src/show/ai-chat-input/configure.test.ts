import { describe, it, expect } from 'vitest';
import { setConfigureField, removeConfigureField, mcpConfigureLabel } from './configure.js';

describe('setConfigureField', () => {
  it('合并字段补丁，返回新对象', () => {
    const value = { a: 1 };
    const next = setConfigureField(value, { b: 2 });
    expect(next).toEqual({ a: 1, b: 2 });
    expect(next).not.toBe(value);
  });

  it('覆盖已存在的字段', () => {
    expect(setConfigureField({ a: 1 }, { a: 2 })).toEqual({ a: 2 });
  });
});

describe('removeConfigureField', () => {
  it('移除指定字段，返回新对象', () => {
    const value = { a: 1, b: 2 };
    const next = removeConfigureField(value, 'a');
    expect(next).toEqual({ b: 2 });
    expect(next).not.toBe(value);
  });

  it('字段不存在时原样返回等价对象', () => {
    expect(removeConfigureField({ a: 1 }, 'x')).toEqual({ a: 1 });
  });
});

describe('mcpConfigureLabel', () => {
  it('统计 active 数量并格式化', () => {
    expect(mcpConfigureLabel([{ value: 'a', active: true }, { value: 'b', active: false }])).toBe('MCP · 1');
  });

  it('空数组返回 MCP · 0', () => {
    expect(mcpConfigureLabel([])).toBe('MCP · 0');
  });
});
