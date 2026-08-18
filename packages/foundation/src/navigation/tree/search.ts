import { findAncestorKeys, findDescendantKeys, type KeyEntities, type TreeNodeData } from './tree-data.js';

export type FilterTreeNode = boolean | ((input: string, label: string, data: TreeNodeData) => boolean);

export interface SearchResult {
  filteredKeys: Set<string>;
  /** 匹配节点的祖先链（不含匹配节点自身），搜索时必须展开才能让匹配节点可见。 */
  expandedAncestorKeys: Set<string>;
  /** showFilteredOnly=true 时喂给 flattenTreeData 的白名单：匹配节点+其后代+其祖先链。 */
  filteredShownKeys: Set<string>;
}

function defaultMatch(input: string, label: string): boolean {
  return label.toLowerCase().includes(input.toLowerCase());
}

/**
 * 计算搜索结果：遍历全部节点找出文本匹配的 key，再算出"为了让匹配节点
 * 可见，需要强制展开的祖先链"，以及 showFilteredOnly 场景下的完整白名单
 * （匹配节点+其后代+其祖先链）。纯函数，不依赖 DOM，可脱离渲染单测。
 */
export function computeSearchResult(
  input: string,
  entities: KeyEntities,
  filterTreeNode: FilterTreeNode,
  labelOf: (data: TreeNodeData) => string = (d) => String(d.label ?? ''),
): SearchResult {
  if (!input || !filterTreeNode) {
    return { filteredKeys: new Set(), expandedAncestorKeys: new Set(), filteredShownKeys: new Set() };
  }
  const matchFn = typeof filterTreeNode === 'function' ? filterTreeNode : defaultMatch;

  const filteredKeys = new Set<string>();
  for (const entity of Object.values(entities)) {
    if (matchFn(input, labelOf(entity.data), entity.data)) {
      filteredKeys.add(entity.key);
    }
  }

  const expandedAncestorKeys = new Set(findAncestorKeys(filteredKeys, entities, false));
  const descendantKeys = findDescendantKeys(filteredKeys, entities, true);
  const filteredShownKeys = new Set([...descendantKeys, ...expandedAncestorKeys]);

  return { filteredKeys, expandedAncestorKeys, filteredShownKeys };
}
