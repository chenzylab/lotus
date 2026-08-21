import {
  buildKeyEntities,
  type TreeNodeData,
  type KeyEntities,
} from '../../navigation/tree/tree-data.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked, calcCheckedKeys } from '../../navigation/tree/check-cascade.js';

export type CheckRelation = 'related' | 'unRelated';

export interface SelectionResult {
  selectedRowKeys: Set<string>;
  halfSelectedRowKeys: Set<string>;
}

/**
 * 行选择状态机：只支持 checkbox 多选（Semi 源码没有 radio 单选模式，调研
 * 已核实，不臆造）。checkRelation='related' 时直接复用 Tree 组件的三态
 * 级联算法（calcCheckedKeysForChecked/calcCheckedKeysForUnchecked）——
 * Semi 官方实现本身就是这么做的（foundation.ts 直接 import 同名函数），
 * lotus 这里是同源复用，不是碰巧算法相似。
 */

/** 把 Table 的树形 dataSource（含 children 字段的任意行数据）转成 buildKeyEntities 需要的 TreeNodeData[] 形状。 */
export function toTreeNodeData<T = any>(
  data: T[],
  rowKey: (record: T, index: number) => string,
  childrenKey: string,
): TreeNodeData[] {
  return data.map((record, index) => {
    const key = rowKey(record, index);
    const children = (record as any)[childrenKey] as T[] | undefined;
    return {
      key,
      label: key,
      children: children ? toTreeNodeData(children, rowKey, childrenKey) : undefined,
    };
  });
}

export function buildRowEntities<T = any>(
  data: T[],
  rowKey: (record: T, index: number) => string,
  childrenKey: string,
): KeyEntities {
  return buildKeyEntities(toTreeNodeData(data, rowKey, childrenKey));
}

/** 单行切换选中态。unRelated：只改自己；related：走三态级联。 */
export function toggleRowSelection(
  key: string,
  checked: boolean,
  current: SelectionResult,
  checkRelation: CheckRelation,
  entities: KeyEntities,
): SelectionResult {
  if (checkRelation === 'unRelated') {
    const selectedRowKeys = new Set(current.selectedRowKeys);
    if (checked) selectedRowKeys.add(key);
    else selectedRowKeys.delete(key);
    return { selectedRowKeys, halfSelectedRowKeys: current.halfSelectedRowKeys };
  }
  const result = checked
    ? calcCheckedKeysForChecked(key, entities, current.selectedRowKeys, current.halfSelectedRowKeys)
    : calcCheckedKeysForUnchecked(key, entities, current.selectedRowKeys, current.halfSelectedRowKeys);
  return { selectedRowKeys: result.checkedKeys, halfSelectedRowKeys: result.halfCheckedKeys };
}

/** 受控/初始值同步：从一批应选中的 key 全量重算（related 模式走三态级联重建）。 */
export function syncRowSelection(
  keys: string[],
  checkRelation: CheckRelation,
  entities: KeyEntities,
): SelectionResult {
  if (checkRelation === 'unRelated') {
    return { selectedRowKeys: new Set(keys), halfSelectedRowKeys: new Set() };
  }
  const result = calcCheckedKeys(keys, entities);
  return { selectedRowKeys: result.checkedKeys, halfSelectedRowKeys: result.halfCheckedKeys };
}

/** 全选/取消全选：排除 disabled 行（对齐 Semi allIsSelected 判定排除禁用行的逻辑）。 */
export function toggleAllRowSelection<T = any>(
  visibleKeys: string[],
  disabledKeys: Set<string>,
  wantAllChecked: boolean,
  current: Set<string>,
): Set<string> {
  const next = new Set(current);
  for (const key of visibleKeys) {
    if (disabledKeys.has(key)) continue;
    if (wantAllChecked) next.add(key);
    else next.delete(key);
  }
  return next;
}

export function calcAllSelectedStatus(visibleKeys: string[], disabledKeys: Set<string>, selectedRowKeys: Set<string>): { allChecked: boolean; hasSelectable: boolean } {
  let hasSelectable = false;
  let hasUnselected = false;
  for (const key of visibleKeys) {
    if (disabledKeys.has(key)) continue;
    hasSelectable = true;
    if (!selectedRowKeys.has(key)) {
      hasUnselected = true;
      break;
    }
  }
  return { allChecked: hasSelectable && !hasUnselected, hasSelectable };
}
