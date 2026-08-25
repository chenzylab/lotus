import { describe, it, expect } from 'vitest';
import { resolveCodeItemViewer, type CodeItem } from './code-content.js';

describe('resolveCodeItemViewer', () => {
  it('isJson=true 走 json 分支', () => {
    const item: CodeItem = { key: 'a', isJson: true, content: '{}' };
    expect(resolveCodeItemViewer(item)).toBe('json');
  });

  it('isJson 未传或 false 走 code 分支', () => {
    expect(resolveCodeItemViewer({ key: 'a' })).toBe('code');
    expect(resolveCodeItemViewer({ key: 'a', isJson: false })).toBe('code');
  });
});
