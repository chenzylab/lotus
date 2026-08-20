import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked, calcCheckedKeys } from '../../navigation/tree/check-cascade.js';
import { toggleExpanded } from '../../navigation/tree/expand.js';
import { computeSearchResult, type FilterTreeNode, type SearchResult } from '../../navigation/tree/search.js';
import type { KeyEntities } from '../../navigation/tree/tree-data.js';
import { normalizeCheckedKeysToValue } from './value.js';

export * from '../../navigation/tree/tree-data.js';
export * from '../../navigation/tree/check-cascade.js';
export * from '../../navigation/tree/search.js';
export * from '../../navigation/tree/expand.js';
export * from './value.js';
export * from './tag-fold.js';

export type TreeSelectCheckRelation = 'related' | 'unRelated';

export interface TreeSelectState {
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
}

/**
 * TreeSelect 的核心状态机：展开/收起、单选/多选三态级联、search、loadData
 * 与 Tree 完全一致（algorithm 层直接复用 Tree 的四个纯函数模块，见
 * 顶部 re-export），Foundation 方法群也是 TreeFoundation 同名方法的原样
 * 移植（state shape 多了 independentCheckedKeys 字段服务 unRelated 模式）。
 * TreeSelect 特有的部分：checkRelation='unRelated' 下的独立勾选（不调三态
 * 级联，纯 Set add/delete）、normalizeCheckedKeysToValue 折叠对外 value。
 */
export class TreeSelectFoundation extends Foundation<TreeSelectState> {
  constructor(adapter: Adapter<TreeSelectState>) {
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

  /** related 模式：三态级联。unRelated 模式：纯粹的 Set 增删，互不联动。 */
  handleCheck(key: string, entities: KeyEntities, checkRelation: TreeSelectCheckRelation = 'related'): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
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
      ? calcCheckedKeysForUnchecked(key, entities, checkedKeys, halfCheckedKeys)
      : calcCheckedKeysForChecked(key, entities, checkedKeys, halfCheckedKeys);
    this.setState(result);
    return result;
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

  handleLoadEnd(key: string, success: boolean): void {
    const { loadingKeys, loadedKeys } = this.getState();
    const nextLoading = new Set(loadingKeys);
    nextLoading.delete(key);
    const nextLoaded = success ? new Set([...loadedKeys, key]) : loadedKeys;
    this.setState({ loadingKeys: nextLoading, loadedKeys: nextLoaded });
  }

  /** 受控 value（多选）变化时全量重算内部选中态。unRelated 模式下 value
   * 本身就是独立 key 列表，不需要三态重算，直接替换。 */
  syncCheckedKeysFromValue(keys: string[], entities: KeyEntities, checkRelation: TreeSelectCheckRelation = 'related'): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
    if (checkRelation === 'unRelated') {
      const next = new Set(keys.filter((k) => entities[k]));
      this.setState({ independentCheckedKeys: next });
      return { checkedKeys: next, halfCheckedKeys: new Set() };
    }
    const validKeys = keys.filter((k) => entities[k]);
    const result = calcCheckedKeys(validKeys, entities);
    this.setState(result);
    return result;
  }

  resolveValue(entities: KeyEntities, checkRelation: TreeSelectCheckRelation = 'related', options: { autoMergeValue?: boolean; leafOnly?: boolean } = {}): string[] {
    const { checkedKeys, independentCheckedKeys } = this.getState();
    if (checkRelation === 'unRelated') return [...independentCheckedKeys];
    return normalizeCheckedKeysToValue(checkedKeys, entities, options);
  }
}
