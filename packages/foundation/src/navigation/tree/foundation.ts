import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked } from './check-cascade.js';
import { computeSearchResult, type FilterTreeNode, type SearchResult } from './search.js';
import { toggleExpanded } from './expand.js';
import type { KeyEntities } from './tree-data.js';

export * from './tree-data.js';
export * from './check-cascade.js';
export * from './search.js';
export * from './expand.js';

export interface TreeState {
  expandedKeys: Set<string>;
  checkedKeys: Set<string>;
  halfCheckedKeys: Set<string>;
  selectedKey: string | null;
  searchInput: string;
  loadedKeys: Set<string>;
  loadingKeys: Set<string>;
}

/**
 * Tree 的核心状态机：展开/收起、单选、多选三态级联、搜索过滤、
 * loadData 异步懒加载。所有算法都是从 tree-data/check-cascade/search/
 * expand 四个纯函数模块组合而来，Foundation 本身只负责状态读写和
 * 分支决策，不重复实现算法细节。
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

  handleCheck(key: string, entities: KeyEntities): { checkedKeys: Set<string>; halfCheckedKeys: Set<string> } {
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

  handleLoadEnd(key: string): void {
    const { loadingKeys, loadedKeys } = this.getState();
    const nextLoading = new Set(loadingKeys);
    nextLoading.delete(key);
    this.setState({ loadingKeys: nextLoading, loadedKeys: new Set([...loadedKeys, key]) });
  }
}
