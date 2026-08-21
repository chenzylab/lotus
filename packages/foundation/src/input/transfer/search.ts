import type { ResolvedDataItem } from './transfer-data.js';

export type TransferFilter = boolean | ((input: string, item: ResolvedDataItem) => boolean);

/**
 * 纯客户端过滤，移植自 Semi handleInputChange 的过滤逻辑（不含 treeList 分支——
 * lotus 统一走同一条 Foundation 层过滤路径，不做"树形数据委托给子组件搜索"
 * 的旁路，这是调研报告 §8.4 指出的、对 Semi 架构不一致的主动修正）。
 * 默认过滤要求 label 是 string 类型，非字符串 label 不匹配，需传自定义 filter。
 */
export function computeSearchResult(
  input: string,
  data: ResolvedDataItem[],
  filter: TransferFilter | undefined,
): Set<string | number> {
  if (!input) return new Set(data.map((item) => item.key));
  const matcher =
    typeof filter === 'function'
      ? (item: ResolvedDataItem) => filter(input, item)
      : (item: ResolvedDataItem) => typeof item.label === 'string' && item.label.includes(input);
  return new Set(data.filter(matcher).map((item) => item.key));
}
