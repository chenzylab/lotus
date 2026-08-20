import { type CascaderEntities, type CascaderEntity, getPathData, isLeafEntity } from './cascader-data.js';

export type CascaderFilterFn = (input: string, pathLabel: string, entity: CascaderEntity) => boolean;
export type CascaderFilterTreeNode = boolean | CascaderFilterFn;

export interface CascaderSearchItem {
  key: string;
  pathData: import('./cascader-data.js').CascaderNodeData[];
  /** 用 separator 拼接的完整路径展示文本，如 "浙江 / 杭州 / 西湖区"。 */
  pathLabel: string;
}

function defaultLabelOf(data: { label: any }): string {
  return String(data.label ?? '');
}

/**
 * 搜索结果打平算法：与 Tree 的 `computeSearchResult`（展开祖先链、匹配节点
 * 在原树位置保留可见）模型不同——Cascader 把匹配节点抽取成独立的扁平列表，
 * 每项是"完整路径拼接文本"，对齐 Semi 源码 `filter()` + `getFilteredData()`
 * 的行为：`filterTreeNode` 为布尔值时用内置匹配（拼接后的路径整体做一次
 * `includes`，不是逐级分别匹配，避免逗号分隔符被误判成分隔搜索词的历史坑）；
 * 为函数时把拼接文本和 entity 一起交给用户判断。`leafOnly=true`（默认）时
 * 结果只保留叶子节点，非叶子即使路径文本匹配也不出现在结果里。
 */
export function computeCascaderSearchResult(
  input: string,
  entities: CascaderEntities,
  filterTreeNode: CascaderFilterTreeNode,
  options: { separator?: string; filterLeafOnly?: boolean; labelOf?: (data: { label: any }) => string } = {},
): CascaderSearchItem[] {
  if (!input || !filterTreeNode) return [];
  const { separator = ' / ', filterLeafOnly = true, labelOf = defaultLabelOf } = options;

  const matchFn: CascaderFilterFn =
    typeof filterTreeNode === 'function'
      ? filterTreeNode
      : (text, pathLabel) => pathLabel.toLowerCase().includes(text.toLowerCase());

  const result: CascaderSearchItem[] = [];
  for (const entity of Object.values(entities)) {
    if (filterLeafOnly && !isLeafEntity(entity)) continue;
    const pathData = getPathData(entity.key, entities);
    const pathLabel = pathData.map(labelOf).join(separator);
    if (!matchFn(input, pathLabel, entity)) continue;
    result.push({ key: entity.key, pathData, pathLabel });
  }
  return result;
}
