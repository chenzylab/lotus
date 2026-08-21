import { describe, it, expect } from 'vitest';
import { normalizeNewTags, applyMaxCount } from './normalize.js';

describe('normalizeNewTags', () => {
  it('allowDuplicates=true：全部保留（不含纯空白项）', () => {
    expect(normalizeNewTags(['a', 'a', ' '], [], true)).toEqual(['a', 'a']);
  });

  it('allowDuplicates=false：剔除已存在于 existing 的项', () => {
    expect(normalizeNewTags(['a', 'b'], ['a'], false)).toEqual(['b']);
  });

  it('allowDuplicates=false：本批次内部重复只保留首次出现', () => {
    expect(normalizeNewTags(['a', 'b', 'a'], [], false)).toEqual(['a', 'b']);
  });

  it('去重大小写敏感：Tag 与 tag 视为不同', () => {
    expect(normalizeNewTags(['tag'], ['Tag'], false)).toEqual(['tag']);
  });

  it('去重不 trim：" tag" 与 "tag" 视为不同', () => {
    expect(normalizeNewTags([' tag'], ['tag'], false)).toEqual([' tag']);
  });

  it('空白过滤始终生效，与 allowDuplicates 无关', () => {
    expect(normalizeNewTags(['', '  ', 'a'], [], false)).toEqual(['a']);
    expect(normalizeNewTags(['', '  ', 'a'], [], true)).toEqual(['a']);
  });
});

describe('applyMaxCount', () => {
  it('max 未设置：全部接受', () => {
    expect(applyMaxCount(0, ['a', 'b', 'c'], undefined)).toEqual({ accepted: ['a', 'b', 'c'], exceeded: [] });
  });

  it('max 已用尽：全部拒绝', () => {
    expect(applyMaxCount(3, ['a'], 3)).toEqual({ accepted: [], exceeded: ['a'] });
  });

  it('max 部分可用：接受能放下的前 N 个', () => {
    expect(applyMaxCount(2, ['a', 'b', 'c'], 3)).toEqual({ accepted: ['a'], exceeded: ['b', 'c'] });
  });
});
