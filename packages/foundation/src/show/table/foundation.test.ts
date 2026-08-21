import { describe, it, expect } from 'vitest';
import { TableFoundation, type TableState, type TableFoundationOptions } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';
import type { ColumnDef } from './table-data.js';

interface Row {
  id: string;
  name: string;
  age: number;
  dept: string;
  disabled?: boolean;
  children?: Row[];
}

function createFoundation(optsOverride: Partial<TableFoundationOptions<Row>> = {}, initial: Partial<TableState<Row>> = {}) {
  let state: TableState<Row> = {
    sortState: {},
    filterState: {},
    selectedRowKeys: new Set(),
    halfSelectedRowKeys: new Set(),
    expandedRowKeys: new Set(),
    currentPage: 1,
    pageSize: 10,
    columnWidths: {},
    ...initial,
  };
  const adapter: Adapter<TableState<Row>> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new TableFoundation<Row>(adapter, {
    rowKey: 'id',
    childrenKey: 'children',
    checkRelation: 'unRelated',
    hasExpandedRowRender: false,
    ...optsOverride,
  });
  return { foundation, getState: () => state };
}

const sampleData: Row[] = [
  { id: 'a', name: 'Alice', age: 25, dept: 'eng' },
  { id: 'b', name: 'Bob', age: 30, dept: 'sales' },
  { id: 'c', name: 'Carl', age: 20, dept: 'eng' },
];

describe('TableFoundation', () => {
  describe('resolveKey', () => {
    it('rowKey 为字符串：取对应字段', () => {
      const { foundation } = createFoundation();
      expect(foundation.resolveKey(sampleData[0]!, 0)).toBe('a');
    });
  });

  describe('handleSortClick / processData', () => {
    it('点击排序：数据按对应列排序，重置到第一页', () => {
      const { foundation, getState } = createFoundation({}, { currentPage: 3 });
      const columns: ColumnDef<Row>[] = [{ key: 'age', dataIndex: 'age', sorter: (a, b) => a.age - b.age }];
      foundation.handleSortClick('age');
      expect(getState().sortState).toEqual({ age: 'ascend' });
      expect(getState().currentPage).toBe(1);
      const sorted = foundation.processData(sampleData, columns);
      expect(sorted.map((r) => r.age)).toEqual([20, 25, 30]);
    });
  });

  describe('handleFilterToggle / processData', () => {
    it('筛选后数据管线正确过滤', () => {
      const { foundation } = createFoundation();
      const columns: ColumnDef<Row>[] = [{ key: 'dept', dataIndex: 'dept', onFilter: (v, r) => r.dept === v }];
      foundation.handleFilterToggle('dept', 'eng', true);
      const result = foundation.processData(sampleData, columns);
      expect(result.map((r) => r.name)).toEqual(['Alice', 'Carl']);
    });
  });

  describe('paginate', () => {
    it('按 currentPage/pageSize 切片', () => {
      const { foundation } = createFoundation({}, { currentPage: 1, pageSize: 2 });
      const result = foundation.paginate(sampleData);
      expect(result.pageData).toHaveLength(2);
      expect(result.total).toBe(3);
    });

    it('setCurrentPage / setPageSize', () => {
      const { foundation, getState } = createFoundation();
      foundation.setCurrentPage(2);
      expect(getState().currentPage).toBe(2);
      foundation.setPageSize(20);
      expect(getState().pageSize).toBe(20);
      expect(getState().currentPage).toBe(1);
    });
  });

  describe('行选择', () => {
    it('toggleRow：非受控模式更新 state', () => {
      const { foundation, getState } = createFoundation();
      const result = foundation.toggleRow(sampleData[0]!, 0, true, sampleData, false);
      expect(result.selectedRowKeys).toEqual(new Set(['a']));
      expect(getState().selectedRowKeys).toEqual(new Set(['a']));
    });

    it('toggleRow：受控模式不更新内部 state', () => {
      const { foundation, getState } = createFoundation();
      foundation.toggleRow(sampleData[0]!, 0, true, sampleData, true);
      expect(getState().selectedRowKeys).toEqual(new Set());
    });

    it('toggleAllRows：排除 disabled 行', () => {
      const disabledData: Row[] = [...sampleData, { id: 'd', name: 'Dan', age: 40, dept: 'eng', disabled: true }];
      const { foundation, getState } = createFoundation();
      foundation.toggleAllRows(disabledData, true, false, new Set(['d']));
      expect(getState().selectedRowKeys).toEqual(new Set(['a', 'b', 'c']));
    });

    it('getAllSelectedStatus', () => {
      const { foundation } = createFoundation({}, { selectedRowKeys: new Set(['a', 'b', 'c']) });
      const status = foundation.getAllSelectedStatus(sampleData);
      expect(status.allChecked).toBe(true);
    });

    it('syncSelectedRowKeys：受控回灌', () => {
      const { foundation, getState } = createFoundation();
      foundation.syncSelectedRowKeys(['a', 'b'], sampleData);
      expect(getState().selectedRowKeys).toEqual(new Set(['a', 'b']));
    });

    it('related 模式：树形数据级联选中', () => {
      const treeData: Row[] = [{ id: 'p', name: 'Parent', age: 0, dept: '', children: [{ id: 'c1', name: 'Child1', age: 0, dept: '' }, { id: 'c2', name: 'Child2', age: 0, dept: '' }] }];
      const { foundation, getState } = createFoundation({ checkRelation: 'related' });
      foundation.toggleRow(treeData[0]!, 0, true, treeData, false);
      expect(getState().selectedRowKeys).toEqual(new Set(['p', 'c1', 'c2']));
    });
  });

  describe('展开行 / 树形数据', () => {
    it('flattenForRender：树形数据展开后打平', () => {
      const treeData: Row[] = [{ id: 'p', name: 'Parent', age: 0, dept: '', children: [{ id: 'c1', name: 'Child1', age: 0, dept: '' }] }];
      const { foundation } = createFoundation({}, { expandedRowKeys: new Set(['p']) });
      const flat = foundation.flattenForRender(treeData);
      expect(flat.map((r) => r.key)).toEqual(['p', 'c1']);
    });

    it('toggleExpand：非受控切换', () => {
      const { foundation, getState } = createFoundation();
      foundation.toggleExpand('a', false);
      expect(getState().expandedRowKeys).toEqual(new Set(['a']));
      foundation.toggleExpand('a', false);
      expect(getState().expandedRowKeys).toEqual(new Set());
    });

    it('syncExpandedRowKeys：受控回灌', () => {
      const { foundation, getState } = createFoundation();
      foundation.syncExpandedRowKeys(['a', 'b']);
      expect(getState().expandedRowKeys).toEqual(new Set(['a', 'b']));
    });
  });

  describe('固定列', () => {
    it('getFixedOffsets 委托给纯函数', () => {
      const { foundation } = createFoundation();
      const columns: ColumnDef<Row>[] = [{ fixed: 'left' }, { dataIndex: 'b' }];
      const offsets = foundation.getFixedOffsets(columns, [100, 200]);
      expect(offsets.left).toEqual([0, null]);
    });

    it('静态方法 hasFixedColumns', () => {
      expect(TableFoundation.hasFixedColumns([{ fixed: 'left' }])).toBe(true);
      expect(TableFoundation.hasFixedColumns([{ dataIndex: 'a' }])).toBe(false);
    });
  });

  describe('列宽调整', () => {
    it('resizeColumn：更新对应列宽度并写入 state', () => {
      const { foundation, getState } = createFoundation();
      const width = foundation.resizeColumn('name', 100, 50);
      expect(width).toBe(150);
      expect(getState().columnWidths).toEqual({ name: 150 });
    });
  });

  describe('getChangeInfo', () => {
    it('聚合当前分页/排序/筛选状态', () => {
      const { foundation } = createFoundation({}, { currentPage: 2, pageSize: 20, sortState: { age: 'ascend' }, filterState: { dept: ['eng'] } });
      expect(foundation.getChangeInfo()).toEqual({
        currentPage: 2,
        pageSize: 20,
        sortState: { age: 'ascend' },
        filterState: { dept: ['eng'] },
      });
    });
  });
});
