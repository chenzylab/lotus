import { describe, it, expect } from 'vitest';
import { formatFileSize, formatToolArguments, normalizeToolCallStatus } from './content-item.js';

describe('formatFileSize', () => {
  it('undefined 返回空字符串', () => {
    expect(formatFileSize(undefined)).toBe('');
  });

  it('小于 1024 字节直接显示 B', () => {
    expect(formatFileSize(512)).toBe('512 B');
  });

  it('KB/MB/GB 逐级换算', () => {
    expect(formatFileSize(2048)).toBe('2.0 KB');
    expect(formatFileSize(1024 * 1024 * 3)).toBe('3.0 MB');
    expect(formatFileSize(1024 * 1024 * 1024 * 1.5)).toBe('1.5 GB');
  });
});

describe('formatToolArguments', () => {
  it('空值返回空字符串', () => {
    expect(formatToolArguments(undefined)).toBe('');
  });

  it('合法 JSON 字符串格式化为缩进形式', () => {
    expect(formatToolArguments('{"a":1}')).toBe('{\n  "a": 1\n}');
  });

  it('非法 JSON 原样返回', () => {
    expect(formatToolArguments('not json')).toBe('not json');
  });
});

describe('normalizeToolCallStatus', () => {
  it('completed/failed 原样返回', () => {
    expect(normalizeToolCallStatus('completed')).toBe('completed');
    expect(normalizeToolCallStatus('failed')).toBe('failed');
  });

  it('未知/缺省值归一化为 in_progress', () => {
    expect(normalizeToolCallStatus(undefined)).toBe('in_progress');
    expect(normalizeToolCallStatus('weird')).toBe('in_progress');
  });
});
