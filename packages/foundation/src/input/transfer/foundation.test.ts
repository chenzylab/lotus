import { describe, it, expect } from 'vitest';
import { TransferFoundation, type TransferState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';
import type { ResolvedDataItem } from './transfer-data.js';

function createFoundation(initialData: ResolvedDataItem[] = [], initialSelected: Array<[string | number, ResolvedDataItem]> = []) {
  let state: TransferState = {
    data: initialData,
    selectedItems: new Map(initialSelected),
    searchResult: new Set(),
    inputValue: '',
    leftCurrentPage: 1,
  };
  const adapter: Adapter<TransferState> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new TransferFoundation(adapter);
  return { foundation, getState: () => state };
}

const sampleData: ResolvedDataItem[] = [
  { key: 'k1', value: 'v1', label: 'Apple' },
  { key: 'k2', value: 'v2', label: 'Banana' },
  { key: 'k3', value: 'v3', label: 'Cherry', disabled: true },
];

describe('TransferFoundation', () => {
  describe('handleInputChange', () => {
    it('更新 inputValue，重算 searchResult，重置 leftCurrentPage 到 1', () => {
      const { foundation, getState } = createFoundation(sampleData);
      foundation.setLeftCurrentPage(3);
      foundation.handleInputChange('an', undefined);
      const state = getState();
      expect(state.inputValue).toBe('an');
      expect(state.searchResult).toEqual(new Set(['k2']));
      expect(state.leftCurrentPage).toBe(1);
    });
  });

  describe('getVisibleData', () => {
    it('无搜索时返回全量 data', () => {
      const { foundation } = createFoundation(sampleData);
      expect(foundation.getVisibleData()).toEqual(sampleData);
    });

    it('有搜索时按 searchResult 过滤', () => {
      const { foundation } = createFoundation(sampleData);
      foundation.handleInputChange('Apple', undefined);
      expect(foundation.getVisibleData().map((d) => d.key)).toEqual(['k1']);
    });
  });

  describe('handleSelectOrRemove', () => {
    it('未选中项 → 选中，direction=select', () => {
      const { foundation, getState } = createFoundation(sampleData);
      const result = foundation.handleSelectOrRemove(sampleData[0]!, false);
      expect(result?.direction).toBe('select');
      expect(getState().selectedItems.has('k1')).toBe(true);
      expect(result?.values).toEqual(['v1']);
    });

    it('已选中项 → 取消选中，direction=deselect', () => {
      const { foundation, getState } = createFoundation(sampleData, [['k1', sampleData[0]!]]);
      const result = foundation.handleSelectOrRemove(sampleData[0]!, false);
      expect(result?.direction).toBe('deselect');
      expect(getState().selectedItems.has('k1')).toBe(false);
    });

    it('disabled 项：直接返回 null，不做任何变更', () => {
      const { foundation, getState } = createFoundation(sampleData);
      const before = getState().selectedItems;
      const result = foundation.handleSelectOrRemove(sampleData[2]!, false);
      expect(result).toBeNull();
      expect(getState().selectedItems).toBe(before);
    });

    it('受控模式：不调用 setState，只返回计算结果', () => {
      const { foundation, getState } = createFoundation(sampleData);
      const before = getState().selectedItems;
      const result = foundation.handleSelectOrRemove(sampleData[0]!, true);
      expect(getState().selectedItems).toBe(before);
      expect(result?.selectedItems.has('k1')).toBe(true);
    });
  });

  describe('handleAll', () => {
    it('全选：非 disabled 项全部加入，disabled 项不受影响', () => {
      const { foundation, getState } = createFoundation(sampleData);
      const result = foundation.handleAll(true, false);
      expect([...getState().selectedItems.keys()].sort()).toEqual(['k1', 'k2']);
      expect(result.values.sort()).toEqual(['v1', 'v2']);
    });

    it('清空：非 disabled 项全部移除，已选的 disabled 项保留', () => {
      const { foundation, getState } = createFoundation(sampleData, [
        ['k1', sampleData[0]!],
        ['k2', sampleData[1]!],
        ['k3', sampleData[2]!],
      ]);
      foundation.handleAll(false, false);
      expect([...getState().selectedItems.keys()]).toEqual(['k3']);
    });

    it('全选只作用于当前可见（搜索过滤后）数据', () => {
      const { foundation, getState } = createFoundation(sampleData);
      foundation.handleInputChange('Apple', undefined);
      foundation.handleAll(true, false);
      expect([...getState().selectedItems.keys()]).toEqual(['k1']);
    });

    it('未选中的 disabled 项全选也不会被选中', () => {
      const { foundation, getState } = createFoundation(sampleData);
      foundation.handleAll(true, false);
      expect(getState().selectedItems.has('k3')).toBe(false);
    });
  });

  describe('handleSortEnd', () => {
    it('重新排列 selectedItems 的顺序', () => {
      const { foundation, getState } = createFoundation(sampleData, [
        ['k1', sampleData[0]!],
        ['k2', sampleData[1]!],
        ['k3', sampleData[2]!],
      ]);
      foundation.handleSortEnd(0, 2, false);
      expect([...getState().selectedItems.keys()]).toEqual(['k2', 'k3', 'k1']);
    });

    it('受控模式：不调用 setState', () => {
      const { foundation, getState } = createFoundation(sampleData, [
        ['k1', sampleData[0]!],
        ['k2', sampleData[1]!],
      ]);
      const before = getState().selectedItems;
      foundation.handleSortEnd(0, 1, true);
      expect(getState().selectedItems).toBe(before);
    });
  });

  describe('syncSelectedItems / syncData', () => {
    it('syncSelectedItems：按 value 重建 selectedItems（受控回灌场景）', () => {
      const { foundation, getState } = createFoundation(sampleData);
      foundation.syncSelectedItems(['v1', 'v2']);
      expect([...getState().selectedItems.keys()].sort()).toEqual(['k1', 'k2']);
    });

    it('syncData：dataSource 变化时重建 data', () => {
      const { foundation, getState } = createFoundation([]);
      foundation.syncData([{ key: 'x1' }], 'list');
      expect(getState().data).toEqual([{ key: 'x1' }]);
    });
  });

  describe('getSelectAllStatus', () => {
    it('组合 getVisibleData + calcSelectAllStatus', () => {
      const { foundation } = createFoundation(sampleData, [
        ['k1', sampleData[0]!],
        ['k2', sampleData[1]!],
      ]);
      expect(foundation.getSelectAllStatus()).toEqual({ allChecked: true, showButton: true });
    });
  });
});
