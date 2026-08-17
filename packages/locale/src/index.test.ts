import { describe, expect, it } from 'vitest';
import { locales } from './index.js';

describe('locales', () => {
  it('zh-CN 和 en-US 的顶层 key 完全一致', () => {
    expect(Object.keys(locales['zh-CN']).sort()).toEqual(Object.keys(locales['en-US']).sort());
  });

  it('每种语言包的每个命名空间下的 key 完全一致', () => {
    const namespaces = Object.keys(locales['zh-CN']).filter((k) => k !== 'code' && k !== 'dir');
    for (const ns of namespaces) {
      const zhKeys = Object.keys((locales['zh-CN'] as any)[ns]).sort();
      const enKeys = Object.keys((locales['en-US'] as any)[ns]).sort();
      expect(enKeys).toEqual(zhKeys);
    }
  });

  it('code 字段与语言包自身的 key 一致', () => {
    expect(locales['zh-CN'].code).toBe('zh-CN');
    expect(locales['en-US'].code).toBe('en-US');
  });

  it('Form.minError/maxError 是函数，插值正确', () => {
    expect(locales['zh-CN'].Form.minError(18)).toContain('18');
    expect(locales['en-US'].Form.maxError(100)).toContain('100');
  });
});
