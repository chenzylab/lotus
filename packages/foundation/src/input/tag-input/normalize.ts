/**
 * 新增标签前的归一化：去空白项 + （可选）去重，移植自 Semi
 * semi-foundation/tagInput/foundation.ts 的 _handleAddTags 过滤逻辑。
 * 去重大小写敏感、不 trim 后比较（Semi 用 Array.includes 严格 === 比较，
 * 忠实对齐，不做"更合理"的大小写不敏感修正——那是产品语义决策不是 bug）。
 * 空白过滤（trim() !== ''）始终生效，与 allowDuplicates 无关。
 */
export function normalizeNewTags(
  candidates: string[],
  existing: string[],
  allowDuplicates: boolean,
): string[] {
  return candidates.filter((item, idx) => {
    if (!allowDuplicates) {
      if (existing.includes(item)) return false;
      if (candidates.indexOf(item) !== idx) return false;
    }
    return item.trim() !== '';
  });
}

/** max 数量裁剪：返回能放下的部分和被拒绝的部分。 */
export function applyMaxCount(
  existingCount: number,
  candidates: string[],
  max: number | undefined,
): { accepted: string[]; exceeded: string[] } {
  if (max === undefined) return { accepted: candidates, exceeded: [] };
  const room = Math.max(0, max - existingCount);
  return { accepted: candidates.slice(0, room), exceeded: candidates.slice(room) };
}
