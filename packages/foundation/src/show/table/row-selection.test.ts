import { describe, it, expect } from 'vitest';
import {
  toTreeNodeData,
  buildRowEntities,
  toggleRowSelection,
  syncRowSelection,
  toggleAllRowSelection,
  calcAllSelectedStatus,
  type SelectionResult,
} from './row-selection.js';

describe('toTreeNodeData', () => {
  it('扁平数据：无 children', () => {
    const data = [{ id: 'a' }, { id: 'b' }];
    const result = toTreeNodeData(data, (r) => r.id, 'children');
    expect(result.map((n) => n.key)).toEqual(['a', 'b']);
    expect(result[0]!.children).toBeUndefined();
  });

  it('树形数据：递归转换 children', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }] }];
    const result = toTreeNodeData(data, (r) => r.id, 'children');
    expect(result[0]!.children?.[0]!.key).toBe('a1');
  });
});

describe('toggleRowSelection', () => {
  const empty: SelectionResult = { selectedRowKeys: new Set(), halfSelectedRowKeys: new Set() };

  it('unRelated：只影响自身', () => {
    const entities = buildRowEntities([{ id: 'a' }], (r) => r.id, 'children');
    const checked = toggleRowSelection('a', true, empty, 'unRelated', entities);
    expect(checked.selectedRowKeys).toEqual(new Set(['a']));
    const unchecked = toggleRowSelection('a', false, checked, 'unRelated', entities);
    expect(unchecked.selectedRowKeys).toEqual(new Set());
  });

  it('related：勾选父节点级联选中全部子孙', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }, { id: 'a2' }] }];
    const entities = buildRowEntities(data, (r) => r.id, 'children');
    const result = toggleRowSelection('a', true, empty, 'related', entities);
    expect(result.selectedRowKeys).toEqual(new Set(['a', 'a1', 'a2']));
  });

  it('related：勾选单个子节点，父节点变半选', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }, { id: 'a2' }] }];
    const entities = buildRowEntities(data, (r) => r.id, 'children');
    const result = toggleRowSelection('a1', true, empty, 'related', entities);
    expect(result.selectedRowKeys).toEqual(new Set(['a1']));
    expect(result.halfSelectedRowKeys).toEqual(new Set(['a']));
  });
});

describe('syncRowSelection', () => {
  it('unRelated：直接构造集合', () => {
    const entities = buildRowEntities([{ id: 'a' }, { id: 'b' }], (r) => r.id, 'children');
    const result = syncRowSelection(['a'], 'unRelated', entities);
    expect(result.selectedRowKeys).toEqual(new Set(['a']));
    expect(result.halfSelectedRowKeys).toEqual(new Set());
  });

  it('related：全量重算三态', () => {
    const data = [{ id: 'a', children: [{ id: 'a1' }, { id: 'a2' }] }];
    const entities = buildRowEntities(data, (r) => r.id, 'children');
    const result = syncRowSelection(['a1'], 'related', entities);
    expect(result.selectedRowKeys).toEqual(new Set(['a1']));
    expect(result.halfSelectedRowKeys).toEqual(new Set(['a']));
  });
});

describe('toggleAllRowSelection', () => {
  it('全选：排除 disabled 行', () => {
    const result = toggleAllRowSelection(['a', 'b', 'c'], new Set(['b']), true, new Set());
    expect(result).toEqual(new Set(['a', 'c']));
  });

  it('取消全选：排除 disabled 行，保留其选中态', () => {
    const result = toggleAllRowSelection(['a', 'b', 'c'], new Set(['b']), false, new Set(['a', 'b', 'c']));
    expect(result).toEqual(new Set(['b']));
  });
});

describe('calcAllSelectedStatus', () => {
  it('全部非 disabled 行已选中：allChecked=true', () => {
    const result = calcAllSelectedStatus(['a', 'b'], new Set(), new Set(['a', 'b']));
    expect(result).toEqual({ allChecked: true, hasSelectable: true });
  });

  it('部分未选中：allChecked=false', () => {
    const result = calcAllSelectedStatus(['a', 'b'], new Set(), new Set(['a']));
    expect(result.allChecked).toBe(false);
  });

  it('disabled 行不参与判定', () => {
    const result = calcAllSelectedStatus(['a', 'b'], new Set(['b']), new Set(['a']));
    expect(result.allChecked).toBe(true);
  });

  it('全部行 disabled：hasSelectable=false', () => {
    const result = calcAllSelectedStatus(['a', 'b'], new Set(['a', 'b']), new Set());
    expect(result.hasSelectable).toBe(false);
  });
});
