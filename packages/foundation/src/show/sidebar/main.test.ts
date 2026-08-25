import { describe, it, expect } from 'vitest';
import { isBackWardPending } from './main.js';

describe('isBackWardPending', () => {
  it('pending 状态返回 true', () => {
    expect(isBackWardPending('pending')).toBe(true);
  });

  it('idle 状态返回 false', () => {
    expect(isBackWardPending('idle')).toBe(false);
  });
});
