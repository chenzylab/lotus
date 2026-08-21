import { describe, it, expect } from 'vitest';
import { computeSearchResult } from './search.js';
import type { ResolvedDataItem } from './transfer-data.js';

const data: ResolvedDataItem[] = [
  { key: 'k1', label: 'Apple' },
  { key: 'k2', label: 'Banana' },
  { key: 'k3', label: 'Cherry' },
  { key: 'k4', label: 42 as unknown as string },
];

describe('computeSearchResult', () => {
  it('input 为空：返回全量 key 集合', () => {
    const result = computeSearchResult('', data, undefined);
    expect(result).toEqual(new Set(['k1', 'k2', 'k3', 'k4']));
  });

  it('默认过滤：按 label.includes 匹配（区分大小写）', () => {
    const result = computeSearchResult('an', data, undefined);
    expect(result).toEqual(new Set(['k2']));
  });

  it('默认过滤：非字符串 label 永远不匹配', () => {
    const result = computeSearchResult('42', data, undefined);
    expect(result.has('k4')).toBe(false);
  });

  it('filter=false 时（由调用方决定是否调用本函数，此处验证函数本身对 false 的处理）：视为无自定义过滤，走默认逻辑', () => {
    const result = computeSearchResult('Apple', data, false);
    expect(result).toEqual(new Set(['k1']));
  });

  it('filter 为函数：完全交由自定义逻辑判定', () => {
    const result = computeSearchResult('x', data, (input, item) => item.key === 'k3');
    expect(result).toEqual(new Set(['k3']));
  });
});
