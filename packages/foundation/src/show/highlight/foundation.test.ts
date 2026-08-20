import { describe, it, expect } from 'vitest';
import { findHighlightChunks } from './foundation.js';

describe('findHighlightChunks', () => {
  it('空字符串返回空数组', () => {
    expect(findHighlightChunks('', ['a'])).toEqual([]);
  });

  it('无匹配时整个字符串作为单个非高亮片段', () => {
    const result = findHighlightChunks('hello world', ['xyz']);
    expect(result).toEqual([{ start: 0, end: 11, highlight: false, className: undefined, style: undefined }]);
  });

  it('单个关键词单次命中，正确切分前后非高亮段', () => {
    const result = findHighlightChunks('hello world', ['world']);
    expect(result).toEqual([
      { start: 0, end: 6, highlight: false, className: undefined, style: undefined },
      { start: 6, end: 11, highlight: true, className: undefined, style: undefined },
    ]);
  });

  it('关键词命中文本开头，不产生零长度前置片段', () => {
    const result = findHighlightChunks('hello world', ['hello']);
    expect(result[0]).toEqual({ start: 0, end: 5, highlight: true, className: undefined, style: undefined });
    expect(result.every((c) => c.end - c.start > 0)).toBe(true);
  });

  it('关键词命中文本结尾，不产生零长度末尾片段', () => {
    const result = findHighlightChunks('hello world', ['world']);
    expect(result[result.length - 1]).toEqual({ start: 6, end: 11, highlight: true, className: undefined, style: undefined });
  });

  it('整个字符串都是关键词时只产生一个高亮片段', () => {
    const result = findHighlightChunks('hello', ['hello']);
    expect(result).toEqual([{ start: 0, end: 5, highlight: true, className: undefined, style: undefined }]);
  });

  it('多个关键词各自独立命中，产生多个高亮片段', () => {
    const result = findHighlightChunks('the quick brown fox', ['quick', 'fox']);
    const highlighted = result.filter((c) => c.highlight).map((c) => `${c.start}-${c.end}`);
    expect(highlighted).toEqual(['4-9', '16-19']);
  });

  it('重叠关键词合并为一个连续高亮片段（"ab"+"bc"命中"abc"应合并为0-3，不重复渲染"b"）', () => {
    const result = findHighlightChunks('abc', ['ab', 'bc']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 0, end: 3 });
  });

  it('相邻但不重叠的关键词也会被合并（end === start）', () => {
    const result = findHighlightChunks('abcdef', ['abc', 'def']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 0, end: 6 });
  });

  it('大小写不敏感（默认）时忽略大小写匹配', () => {
    const result = findHighlightChunks('Hello World', ['world']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 6, end: 11 });
  });

  it('大小写敏感时精确匹配大小写', () => {
    const result = findHighlightChunks('Hello World', ['world'], true);
    expect(result.some((c) => c.highlight)).toBe(false);
  });

  it('autoEscape=true（默认）时关键词中的正则特殊字符按字面量匹配', () => {
    const result = findHighlightChunks('price: $5.00', ['$5.00']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 7, end: 12 });
  });

  it('autoEscape=false 时关键词被当作正则表达式片段', () => {
    const result = findHighlightChunks('a1b2c3', ['\\d'], false, false);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(3);
  });

  it('空字符串关键词被忽略，不产生零宽匹配死循环', () => {
    const result = findHighlightChunks('hello', ['', 'ell']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 1, end: 4 });
  });

  it('ComplexSearchWord 对象形式的关键词携带 className/style', () => {
    const result = findHighlightChunks('hello world', [{ text: 'world', className: 'foo', style: { color: 'red' } }]);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted[0]).toMatchObject({ className: 'foo', style: { color: 'red' } });
  });

  it('重叠片段合并时 className 取先出现者，style 后者覆盖前者同名属性', () => {
    const result = findHighlightChunks('abc', [
      { text: 'ab', className: 'first', style: { color: 'red', fontSize: '12px' } },
      { text: 'bc', className: 'second', style: { color: 'blue' } },
    ]);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0].className).toBe('first');
    expect(highlighted[0].style).toEqual({ color: 'blue', fontSize: '12px' });
  });

  it('searchWords 为空数组时返回整串非高亮', () => {
    const result = findHighlightChunks('hello', []);
    expect(result).toEqual([{ start: 0, end: 5, highlight: false, className: undefined, style: undefined }]);
  });

  it('同一关键词连续出现两次，因相邻（end===start）被合并为一个连续高亮片段', () => {
    const result = findHighlightChunks('abcabc', ['abc']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(1);
    expect(highlighted[0]).toMatchObject({ start: 0, end: 6 });
  });

  it('同一关键词非相邻多次出现，各自独立命中', () => {
    const result = findHighlightChunks('abc-abc', ['abc']);
    const highlighted = result.filter((c) => c.highlight);
    expect(highlighted).toHaveLength(2);
    expect(highlighted.map((c) => `${c.start}-${c.end}`)).toEqual(['0-3', '4-7']);
  });
});
