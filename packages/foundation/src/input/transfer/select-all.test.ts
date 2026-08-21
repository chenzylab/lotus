import { describe, it, expect } from 'vitest';
import { calcSelectAllStatus } from './select-all.js';
import type { ResolvedDataItem } from './transfer-data.js';

describe('calcSelectAllStatus', () => {
  it('全部未选中：allChecked=false, showButton=true', () => {
    const data: ResolvedDataItem[] = [{ key: 'k1' }, { key: 'k2' }];
    const status = calcSelectAllStatus(data, new Map());
    expect(status).toEqual({ allChecked: false, showButton: true });
  });

  it('全部已选中：allChecked=true', () => {
    const data: ResolvedDataItem[] = [{ key: 'k1' }, { key: 'k2' }];
    const selected = new Map(data.map((d) => [d.key, d]));
    const status = calcSelectAllStatus(data, selected);
    expect(status.allChecked).toBe(true);
  });

  it('disabled 项不参与判定：可见项里非 disabled 的全选中，disabled 未选中也算 allChecked', () => {
    const data: ResolvedDataItem[] = [
      { key: 'k1' },
      { key: 'k2', disabled: true },
    ];
    const selected = new Map([['k1', data[0]!]]);
    const status = calcSelectAllStatus(data, selected);
    expect(status.allChecked).toBe(true);
  });

  it('可见项全部 disabled：showButton=false', () => {
    const data: ResolvedDataItem[] = [{ key: 'k1', disabled: true }, { key: 'k2', disabled: true }];
    const status = calcSelectAllStatus(data, new Map());
    expect(status.showButton).toBe(false);
    expect(status.allChecked).toBe(false);
  });

  it('空数据：showButton=false, allChecked=false', () => {
    const status = calcSelectAllStatus([], new Map());
    expect(status).toEqual({ allChecked: false, showButton: false });
  });
});
