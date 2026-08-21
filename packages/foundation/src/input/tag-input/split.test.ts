import { describe, it, expect } from 'vitest';
import { splitBySeparator } from './split.js';

describe('splitBySeparator', () => {
  it('单个字符串分隔符', () => {
    expect(splitBySeparator('a,b,c', ',')).toEqual(['a', 'b', 'c']);
  });

  it('无分隔符命中：返回整串作为单一元素', () => {
    expect(splitBySeparator('abc', ',')).toEqual(['abc']);
  });

  it('多分隔符数组：统一按第一个分隔符拆分', () => {
    expect(splitBySeparator('a,b;c', [',', ';'])).toEqual(['a', 'b', 'c']);
  });

  it('多分隔符数组，分隔符顺序不影响结果集合', () => {
    expect(splitBySeparator('a;b,c', [';', ','])).toEqual(['a', 'b', 'c']);
  });

  it('separator=null：原样返回整串', () => {
    expect(splitBySeparator('a,b,c', null)).toEqual(['a,b,c']);
  });

  it('separator=undefined：原样返回整串', () => {
    expect(splitBySeparator('a,b,c', undefined)).toEqual(['a,b,c']);
  });

  it('空数组分隔符：原样返回整串', () => {
    expect(splitBySeparator('a,b,c', [])).toEqual(['a,b,c']);
  });
});
