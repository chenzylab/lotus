import type { ResolvedDataItem } from './transfer-data.js';

export interface SelectAllStatus {
  /** 当前可见（过滤后）的非 disabled 项是否已全部选中。 */
  allChecked: boolean;
  /** 是否显示全选/清空按钮——可见项全部 disabled 时不显示。 */
  showButton: boolean;
}

/**
 * 全选/清空按钮的判定，移植自 Semi renderLeft 里的 leftContainsNotInSelected
 * 算法。这不是三态 indeterminate（Semi 本身也没有真正的三态 header checkbox，
 * 只是按钮文案在"全选"/"清空所选"间切换——见调研报告 §2 负面清单第3条），
 * 是纯布尔判定：可见的非 disabled 项里只要还有一项未选中，就还没到"全选"态。
 * disabled 项完全不参与判定，也不影响是否显示按钮之外的语义。
 */
export function calcSelectAllStatus(
  visibleData: ResolvedDataItem[],
  selectedItems: Map<string | number, ResolvedDataItem>,
): SelectAllStatus {
  let hasSelectable = false;
  let hasUnselected = false;
  for (const item of visibleData) {
    if (item.disabled) continue;
    hasSelectable = true;
    if (!selectedItems.has(item.key)) {
      hasUnselected = true;
      break;
    }
  }
  return { allChecked: hasSelectable && !hasUnselected, showButton: hasSelectable };
}
