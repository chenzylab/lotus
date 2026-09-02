import type { KeyEntities } from './tree-data.js';

function isLeafKey(key: string, entities: KeyEntities): boolean {
  const entity = entities[key];
  if (!entity) return true;
  return entity.data.isLeaf ?? entity.children.length === 0;
}

/**
 * 三态级联算出的内部 checkedKeys（含被级联自动带上的父/子节点）折叠成
 * 对外暴露的 value key 列表——对齐 Semi `normalizeKeyList` 语义，但操作
 * 对象是单一 key 集合（非 Cascader 的 valuePath 数组）。
 *
 * - `autoMergeValue`（默认 true）：父节点的全部子孙都被选中时，value 只
 *   保留父节点这一个 key，不逐一列出每个子孙 key。
 * - `leafOnly`（默认 false）：value 只保留叶子节点 key，非叶子一律不出现
 *   在 value 里。`leafOnly` 优先级高于 autoMergeValue。
 */
export function normalizeCheckedKeysToValue(
  checkedKeys: Set<string>,
  entities: KeyEntities,
  options: { autoMergeValue?: boolean; leafOnly?: boolean } = {},
): string[] {
  const { autoMergeValue = true, leafOnly = false } = options;

  if (leafOnly) {
    return [...checkedKeys].filter((key) => isLeafKey(key, entities));
  }

  if (!autoMergeValue) {
    return [...checkedKeys];
  }

  // autoMergeValue：跳过"祖先已经在 checkedKeys 里"的节点，只保留每条被选
  // 路径里"最靠近根"的那个节点（三态级联保证父节点被选中时其全部子孙也
  // 必然在 checkedKeys 里，过滤掉子孙即完成合并）。
  const result: string[] = [];
  for (const key of checkedKeys) {
    const entity = entities[key];
    if (!entity) continue;
    let hasCheckedAncestor = false;
    let node = entity.parent;
    while (node) {
      if (checkedKeys.has(node.key)) {
        hasCheckedAncestor = true;
        break;
      }
      node = node.parent;
    }
    if (!hasCheckedAncestor) result.push(key);
  }
  return result;
}
