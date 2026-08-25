import { describe, it, expect } from 'vitest';
import {
  suggestionContent,
  nextSuggestionIndex,
  referenceLabel,
  getAttachmentType,
  isImageType,
  getContentType,
  isImageReference,
} from './reference-suggestion.js';

describe('suggestionContent', () => {
  it('字符串直接返回', () => {
    expect(suggestionContent('hello')).toBe('hello');
  });

  it('对象取 content 字段', () => {
    expect(suggestionContent({ content: 'world' })).toBe('world');
  });
});

describe('nextSuggestionIndex', () => {
  it('无项时返回 -1', () => {
    expect(nextSuggestionIndex(-1, 0, 1)).toBe(-1);
  });

  it('未选中时向下从 0 开始，向上从末项开始', () => {
    expect(nextSuggestionIndex(-1, 3, 1)).toBe(0);
    expect(nextSuggestionIndex(-1, 3, -1)).toBe(2);
  });

  it('环绕导航', () => {
    expect(nextSuggestionIndex(2, 3, 1)).toBe(0);
    expect(nextSuggestionIndex(0, 3, -1)).toBe(2);
  });
});

describe('referenceLabel', () => {
  it('type=text 时用 content', () => {
    expect(referenceLabel({ id: 'r1', type: 'text', content: '引用文本' })).toBe('引用文本');
  });

  it('非 text 类型用 name，缺省回退到 id', () => {
    expect(referenceLabel({ id: 'r2', type: 'file', name: 'doc.pdf' })).toBe('doc.pdf');
    expect(referenceLabel({ id: 'r3', type: 'file' })).toBe('r3');
  });
});

describe('getAttachmentType', () => {
  it('显式 type 优先', () => {
    expect(getAttachmentType({ id: 'x', type: 'custom', name: 'a.png' })).toBe('custom');
  });

  it('从 name 后缀推导', () => {
    expect(getAttachmentType({ id: 'x', name: 'a.pdf' })).toBe('pdf');
  });

  it('从 fileInstance.type 尾段推导', () => {
    expect(getAttachmentType({ id: 'x', fileInstance: { type: 'image/png' } })).toBe('png');
  });

  it('全部缺省时返回 UNKNOWN', () => {
    expect(getAttachmentType({ id: 'x' })).toBe('UNKNOWN');
  });
});

describe('isImageType / isImageReference', () => {
  it('fileInstance.type 以 image/ 开头', () => {
    expect(isImageType({ id: 'x', fileInstance: { type: 'image/png' } })).toBe(true);
  });

  it('后缀命中图片白名单', () => {
    expect(isImageType({ id: 'x', name: 'a.webp' })).toBe(true);
  });

  it('svg 不在白名单内', () => {
    expect(isImageType({ id: 'x', name: 'a.svg' })).toBe(false);
  });

  it('isImageReference 与 isImageType 行为一致', () => {
    expect(isImageReference({ id: 'x', name: 'a.png' })).toBe(true);
  });
});

describe('getContentType', () => {
  it('已知后缀映射到分类', () => {
    expect(getContentType('docx')).toBe('word');
    expect(getContentType('mp3')).toBe('audio');
  });

  it('ts 后写覆盖前写，实际取 video（Semi 既定行为，照搬不修正）', () => {
    expect(getContentType('ts')).toBe('video');
  });

  it('未知后缀返回 unknown', () => {
    expect(getContentType('xyz')).toBe('unknown');
  });
});
