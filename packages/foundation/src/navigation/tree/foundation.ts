import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked, calcCheckedKeys } from './check-cascade.js';
import { computeSearchResult, type FilterTreeNode, type SearchResult } from './search.js';
import { toggleExpanded } from './expand.js';
import type { KeyEntities } from './tree-data.js';
import { normalizeCheckedKeysToValue } from './value.js';
import { getDragNodesKeys, createInitialDragState, type TreeDragState } from './drag.js';

export * from './tree-data.js';
export * from './check-cascade.js';
export * from './search.js';
export * from './expand.js';
export * from './value.js';
export * from './drag.js';

export type TreeCheckRelation = 'related' | 'unRelated';

export interface TreeState {
  expandedKeys: Set<string>;
  /** related 模式下三态级联的选中集合。 */
  checkedKeys: Set<string>;
  halfCheckedKeys: Set<string>;
  /** unRelated 模式下的独立选中集合，与 checkedKeys 互不干扰、不做级联。 */
  independentCheckedKeys: Set<string>;
  selectedKey: string | null;
  searchInput: string;
  loadedKeys: Set<string>;
  loadingKeys: Set<string>;
  drag: TreeDragState;
}

export function createInitialTreeState(): TreeState {
  return {
    expandedKeys: new Set(),
    checkedKeys: new Set(),
    halfCheckedKeys: new Set(),
    independentCheckedKeys: new Set(),
    selectedKey: null,
    searchInput: '',
    loadedKeys: new Set(),
    loadingKeys: new Set(),
    drag: createInitialDragState(),
  };
}

/**
 * Tree 的核心状态机：展开/收起、单选、多选三态级联（含 checkRelation=
 * 'unRelated' 独立选中、disableStrictly 级联隔离）、搜索过滤、loadData
 * 异步懒加载、拖拽视觉状态。所有算法都是从 tree-data/check-cascade/
 * search/expand/drag/value 六个纯函数模块组合而来，Foundation 本身只
 * 负责状态读写和分支决策，不重复实现算法细节。
 *
 * 拖拽不在 Foundation 层做实际的 treeData 重排——这是 lotus 既有惯例
 * （对齐 Upload 真实 IO 下沉到 .tsrx 层同样的思路）：Foundation 只管
 * 拖拽过程中的视觉状态（dragging/dragOverNodeKey/dropPosition），真正
 * 的数据重排交给消费方在 onDrop 回调里自行操作 treeData（对齐 Semi
 * 本身也是这个设计——Semi onDrop 只给 dropPosition/dropToGap 信息，
 * 不直接修改 treeData）。
 */
export class TreeFoundation extends Foundation<TreeState> {
  constructor(adapter: Adapter<TreeState>) {
    super(adapter);
  }

  handleExpand(key: string): Set<string> {
    const { expandedKeys } = this.getState();
    const next = toggleExpanded(key, expandedKeys);
    this.setState({ expandedKeys: next });
    return next;
  }

  handleSelect(key: string): string | null {
    const { selectedKey } = this.getState();
    const next = selectedKey === key ? null : key;
    this.setState({ selectedKey: next });
    return next;
  }

  /** related 模式：三态级联。unRelated 模式：纯粹的 Set 增删，互不联动。
   * disabledKeys 非空时按 Semi disableStrictly 语义：级联范围排除
   * disabled 节点（它们的选中状态独立于父节点操作）。 */
  handleCheck(
    key: string,
    entities: KeyEntities,
    checkRelation: TreeCheckRelation = 'related',
    disabledKeys?: Set<string>,
  ): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
    if (checkRelation === 'unRelated') {
      const { independentCheckedKeys } = this.getState();
      const next = new Set(independentCheckedKeys);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      this.setState({ independentCheckedKeys: next });
      return { checkedKeys: next, halfCheckedKeys: new Set() };
    }

    const { checkedKeys, halfCheckedKeys } = this.getState();
    const isChecked = checkedKeys.has(key);
    const result = isChecked
      ? calcCheckedKeysForUnchecked(key, entities, checkedKeys, halfCheckedKeys, disabledKeys)
      : calcCheckedKeysForChecked(key, entities, checkedKeys, halfCheckedKeys, disabledKeys);
    this.setState(result);
    return result;
  }

  /** 受控 value（多选）变化时全量重算内部选中态。unRelated 模式下 value
   * 本身就是独立 key 列表，不需要三态重算，直接替换。 */
  syncCheckedKeysFromValue(keys: string[], entities: KeyEntities, checkRelation: TreeCheckRelation = 'related'): void {
    if (checkRelation === 'unRelated') {
      this.setState({ independentCheckedKeys: new Set(keys.filter((k) => entities[k])) });
      return;
    }
    const validKeys = keys.filter((k) => entities[k]);
    this.setState(calcCheckedKeys(validKeys, entities));
  }

  /** 三态级联算出的内部 checkedKeys 折叠成对外暴露的 value key 列表
   * （autoMergeValue/leafOnly，见 value.ts）。unRelated 模式下 value
   * 就是独立选中集合本身，不需要折叠。 */
  resolveValue(entities: KeyEntities, checkRelation: TreeCheckRelation = 'related', options: { autoMergeValue?: boolean; leafOnly?: boolean } = {}): string[] {
    const { checkedKeys, independentCheckedKeys } = this.getState();
    if (checkRelation === 'unRelated') return [...independentCheckedKeys];
    return normalizeCheckedKeysToValue(checkedKeys, entities, options);
  }

  handleSearch(input: string, entities: KeyEntities, filterTreeNode: FilterTreeNode): SearchResult {
    this.setState({ searchInput: input });
    const result = computeSearchResult(input, entities, filterTreeNode);
    if (input) {
      const { expandedKeys } = this.getState();
      this.setState({ expandedKeys: new Set([...expandedKeys, ...result.expandedAncestorKeys]) });
    }
    return result;
  }

  handleLoadStart(key: string): void {
    const { loadingKeys } = this.getState();
    this.setState({ loadingKeys: new Set([...loadingKeys, key]) });
  }

  handleLoadEnd(key: string, success = true): void {
    const { loadingKeys, loadedKeys } = this.getState();
    const nextLoading = new Set(loadingKeys);
    nextLoading.delete(key);
    const nextLoaded = success ? new Set([...loadedKeys, key]) : loadedKeys;
    this.setState({ loadingKeys: nextLoading, loadedKeys: nextLoaded });
  }

  // ===================== 拖拽视觉状态 =====================

  handleDragStart(key: string, entities: KeyEntities): void {
    const { drag } = this.getState();
    this.setState({
      drag: { ...drag, dragging: true, dragNodeKey: key, dragNodesKeys: getDragNodesKeys(key, entities) },
    });
  }

  /** dropPosition 由 .tsrx 层用 calcDropRelativePosition(clientY, rect) 算好传入
   * （DOM rect 测量属于渲染层职责，Foundation 不碰 DOM）。目标节点是自身/
   * 自己的后代时不允许作为拖拽目标。 */
  handleDragEnter(key: string, dropPosition: -1 | 0 | 1): boolean {
    const { drag } = this.getState();
    if (drag.dragNodesKeys.has(key)) return false;
    this.setState({ drag: { ...drag, dragOverNodeKey: key, dropPosition } });
    return true;
  }

  handleDragOver(key: string, dropPosition: -1 | 0 | 1): boolean {
    const { drag } = this.getState();
    if (drag.dragNodesKeys.has(key)) return false;
    if (drag.dragOverNodeKey === key && drag.dropPosition === dropPosition) return false;
    this.setState({ drag: { ...drag, dragOverNodeKey: key, dropPosition } });
    return true;
  }

  handleDragLeave(): void {
    const { drag } = this.getState();
    this.setState({ drag: { ...drag, dragOverNodeKey: null, dropPosition: null } });
  }

  /** drop/dragEnd 都清空拖拽态；返回 drop 前的快照供 .tsrx 层组装 onDrop 载荷。 */
  clearDragState(): TreeDragState {
    const { drag } = this.getState();
    this.setState({ drag: createInitialDragState() });
    return drag;
  }
}
