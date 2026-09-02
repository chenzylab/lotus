import { describe, it, expect } from 'vitest';
import { TreeFoundation, createInitialTreeState, type TreeState } from './foundation.js';
import { buildKeyEntities, type TreeNodeData } from './tree-data.js';
import type { Adapter } from '../../base/adapter.js';

const TREE: TreeNodeData[] = [
  {
    key: 'a',
    label: 'A',
    children: [{ key: 'a1', label: 'A1' }, { key: 'a2', label: 'A2' }],
  },
  { key: 'b', label: 'B' },
];

function createMockAdapter(initial: TreeState): { adapter: Adapter<TreeState>; getState: () => TreeState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch: Partial<TreeState>) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

function initialState(): TreeState {
  return createInitialTreeState();
}

describe('TreeFoundation', () => {
  describe('handleExpand', () => {
    it('展开一个未展开的节点', () => {
      const { adapter, getState } = createMockAdapter(initialState());
      const foundation = new TreeFoundation(adapter);

      foundation.handleExpand('a');

      expect(getState().expandedKeys.has('a')).toBe(true);
    });

    it('收起一个已展开的节点', () => {
      const { adapter, getState } = createMockAdapter({ ...initialState(), expandedKeys: new Set(['a']) });
      const foundation = new TreeFoundation(adapter);

      foundation.handleExpand('a');

      expect(getState().expandedKeys.has('a')).toBe(false);
    });
  });

  describe('handleSelect', () => {
    it('选中一个未选中的节点', () => {
      const { adapter, getState } = createMockAdapter(initialState());
      const foundation = new TreeFoundation(adapter);

      foundation.handleSelect('a1');

      expect(getState().selectedKey).toBe('a1');
    });

    it('再次点击已选中的节点会取消选中', () => {
      const { adapter, getState } = createMockAdapter({ ...initialState(), selectedKey: 'a1' });
      const foundation = new TreeFoundation(adapter);

      foundation.handleSelect('a1');

      expect(getState().selectedKey).toBeNull();
    });

    it('选中另一个节点会替换原有选中项（单选语义）', () => {
      const { adapter, getState } = createMockAdapter({ ...initialState(), selectedKey: 'a1' });
      const foundation = new TreeFoundation(adapter);

      foundation.handleSelect('a2');

      expect(getState().selectedKey).toBe('a2');
    });
  });

  describe('handleCheck', () => {
    it('勾选节点触发三态级联计算并写入 state', () => {
      const entities = buildKeyEntities(TREE);
      const { adapter, getState } = createMockAdapter(initialState());
      const foundation = new TreeFoundation(adapter);

      foundation.handleCheck('a1', entities);

      expect(getState().checkedKeys.has('a1')).toBe(true);
      expect(getState().halfCheckedKeys.has('a')).toBe(true);
    });

    it('取消勾选已选中的节点走反选级联', () => {
      const entities = buildKeyEntities(TREE);
      const { adapter, getState } = createMockAdapter({ ...initialState(), checkedKeys: new Set(['a1']) });
      const foundation = new TreeFoundation(adapter);

      foundation.handleCheck('a1', entities);

      expect(getState().checkedKeys.has('a1')).toBe(false);
    });
  });

  describe('handleSearch', () => {
    it('搜索匹配节点后自动展开其祖先链', () => {
      const entities = buildKeyEntities(TREE);
      const { adapter, getState } = createMockAdapter(initialState());
      const foundation = new TreeFoundation(adapter);

      foundation.handleSearch('A1', entities, true);

      expect(getState().searchInput).toBe('A1');
      expect(getState().expandedKeys.has('a')).toBe(true);
    });

    it('清空搜索词不会主动收起已展开的节点', () => {
      const entities = buildKeyEntities(TREE);
      const { adapter, getState } = createMockAdapter({ ...initialState(), expandedKeys: new Set(['a']) });
      const foundation = new TreeFoundation(adapter);

      foundation.handleSearch('', entities, true);

      expect(getState().searchInput).toBe('');
      expect(getState().expandedKeys.has('a')).toBe(true);
    });
  });

  describe('handleLoadStart / handleLoadEnd', () => {
    it('handleLoadStart 把 key 加入 loadingKeys', () => {
      const { adapter, getState } = createMockAdapter(initialState());
      const foundation = new TreeFoundation(adapter);

      foundation.handleLoadStart('a');

      expect(getState().loadingKeys.has('a')).toBe(true);
    });

    it('handleLoadEnd 把 key 从 loadingKeys 移出、加入 loadedKeys', () => {
      const { adapter, getState } = createMockAdapter({ ...initialState(), loadingKeys: new Set(['a']) });
      const foundation = new TreeFoundation(adapter);

      foundation.handleLoadEnd('a');

      expect(getState().loadingKeys.has('a')).toBe(false);
      expect(getState().loadedKeys.has('a')).toBe(true);
    });
  });
});
