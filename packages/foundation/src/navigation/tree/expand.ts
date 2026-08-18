import { findAncestorKeys, type KeyEntities } from './tree-data.js';

/**
 * 计算初始/受控展开集合：autoExpandParent=true 时，传入 key 的祖先链
 * 也一并展开（保证指定的 key 一定可见），false 时只展开传入的 key 本身。
 */
export function calcExpandedKeys(keys: string[], entities: KeyEntities, autoExpandParent = true): Set<string> {
  if (autoExpandParent) {
    return new Set(findAncestorKeys(keys, entities, true));
  }
  return new Set(keys);
}

/** 展开全部有子节点的 key（defaultExpandAll/expandAll 用）。 */
export function calcAllExpandedKeys(entities: KeyEntities): Set<string> {
  return new Set(Object.values(entities).filter((e) => e.children.length > 0).map((e) => e.key));
}

/** 切换单个 key 的展开状态，返回新集合（不修改传入集合）。 */
export function toggleExpanded(key: string, expandedKeys: Set<string>): Set<string> {
  const next = new Set(expandedKeys);
  if (next.has(key)) {
    next.delete(key);
  } else {
    next.add(key);
  }
  return next;
}
