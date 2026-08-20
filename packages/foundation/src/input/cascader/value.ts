import { type CascaderEntities, type CascaderEntity, isLeafEntity } from './cascader-data.js';

/** 三态级联算出的内部选中态（checkedKeys，含被级联自动带上的父/子节点）
 * 折叠成对外暴露的 value 数组——这一层是 Cascader 特有的，Tree 没有
 * （Tree 直接把 checkedKeys 当 value）。
 *
 * - `autoMergeValue`（默认 true）：父节点的全部子孙都被选中时，value 只保留
 *   父节点这一条路径，不逐一列出每个子孙路径（避免多选一个省份时 value 里
 *   塞满几十个市/区）。
 * - `leafOnly`（默认 false）：value 只保留叶子节点路径，非叶子（即使是
 *   "完整子树被选中"的父节点）一律不出现在 value 里。`leafOnly` 优先级
 *   高于 autoMergeValue——为 true 时会绕开合并直接过滤成叶子集合。
 */
export function collapseCheckedKeysToValuePaths(
  checkedKeys: Set<string>,
  entities: CascaderEntities,
  options: { autoMergeValue?: boolean; leafOnly?: boolean } = {},
): Array<Array<string | number>> {
  const { autoMergeValue = true, leafOnly = false } = options;

  if (leafOnly) {
    return [...checkedKeys]
      .map((key) => entities[key])
      .filter((entity): entity is CascaderEntity => !!entity && isLeafEntity(entity))
      .map((entity) => entity.valuePath);
  }

  if (!autoMergeValue) {
    return [...checkedKeys]
      .map((key) => entities[key])
      .filter((entity): entity is CascaderEntity => !!entity)
      .map((entity) => entity.valuePath);
  }

  // autoMergeValue：跳过"祖先已经在 checkedKeys 里"的节点，只保留每条被选
  // 路径里"最靠近根"的那个节点（因为三态级联保证父节点被选中时其全部子孙
  // 也必然在 checkedKeys 里，过滤掉子孙即完成合并，不需要额外遍历子树）。
  const result: CascaderEntity[] = [];
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
    if (!hasCheckedAncestor) result.push(entity);
  }
  return result.map((entity) => entity.valuePath);
}
