/**
 * 多选标签折叠：超出 maxTagCount 时只展示前 N 个，其余折叠成一个 "+M" 汇总项。
 * 纯函数，不关心标签具体渲染内容，只做数量切分——对齐 Semi TagGroup
 * `mode="custom"` 的折叠语义，lotus 目前 Select/Cascader 都没有这个能力，
 * 为 TreeSelect 新写（后续如需要可以回填给 Select/Cascader）。
 */
export interface TagFoldResult<T> {
  visible: T[];
  restCount: number;
  rest: T[];
}

export function foldTags<T>(items: T[], maxTagCount: number | undefined): TagFoldResult<T> {
  if (maxTagCount === undefined || maxTagCount < 0 || items.length <= maxTagCount) {
    return { visible: items, restCount: 0, rest: [] };
  }
  return {
    visible: items.slice(0, maxTagCount),
    restCount: items.length - maxTagCount,
    rest: items.slice(maxTagCount),
  };
}
