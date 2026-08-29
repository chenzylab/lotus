import { describe, it, expect } from 'vitest';
import { defaultMenuBarActiveState } from './file-item.js';

describe('defaultMenuBarActiveState', () => {
  it('全部字段初始为 false', () => {
    const state = defaultMenuBarActiveState();
    expect(Object.values(state).every((v) => v === false)).toBe(true);
  });

  it('返回新对象，多次调用互不影响', () => {
    const a = defaultMenuBarActiveState();
    const b = defaultMenuBarActiveState();
    a.bold = true;
    expect(b.bold).toBe(false);
  });
});
