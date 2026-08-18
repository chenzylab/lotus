import { findAncestorKeys, findDescendantKeys, findSiblingKeys, type KeyEntities } from './tree-data.js';

export interface CascadeResult {
  checkedKeys: Set<string>;
  halfCheckedKeys: Set<string>;
}

/**
 * 勾选一个节点后的三态级联计算：自己+全部后代强制选中；从自己开始向上
 * 逐层判断兄弟是否全部选中——全部选中则父节点也变全选并继续向上冒泡，
 * 否则父节点及更高祖先全部标记半选（半选状态不需要继续判断，只要有一层
 * 兄弟未全选，更高层必然也不可能全选）。对齐 Semi `calcCheckedKeysForChecked`
 * 的算法结构。
 */
export function calcCheckedKeysForChecked(
  key: string,
  entities: KeyEntities,
  checkedKeys: Set<string>,
  halfCheckedKeys: Set<string>,
): CascadeResult {
  const descendantKeys = findDescendantKeys([key], entities, true);
  let nextChecked = new Set([...checkedKeys, key]);
  let nextHalfChecked = new Set(halfCheckedKeys);

  function bubbleUp(currentKey: string) {
    const entity = entities[currentKey];
    if (!entity?.parent) return;
    const siblingKeys = findSiblingKeys(currentKey, entities, true);
    const allChecked = siblingKeys.every((k) => nextChecked.has(k));
    if (!allChecked) {
      const ancestorKeys = findAncestorKeys([currentKey], entities, false);
      nextHalfChecked = new Set([...nextHalfChecked, ...ancestorKeys]);
      return;
    }
    // 兄弟全部选中 -> 父节点冒泡为全选，必须同步清除父节点身上可能残留的
    // 半选标记（例如先勾选 a1 时 a2 未选、a 被标记半选；再勾选 a2 后 a
    // 冒泡为全选，若不清除，半选/全选会同时为 true，产生矛盾状态）。
    nextChecked.add(entity.parent.key);
    nextHalfChecked.delete(entity.parent.key);
    bubbleUp(entity.parent.key);
  }
  bubbleUp(key);

  nextChecked = new Set([...nextChecked, ...descendantKeys]);
  descendantKeys.forEach((k) => nextHalfChecked.delete(k));

  return { checkedKeys: nextChecked, halfCheckedKeys: nextHalfChecked };
}

/**
 * 取消勾选一个节点后的三态级联计算：自己+全部后代彻底移出选中/半选；
 * 从自己开始向上逐层判断兄弟是否还有选中/半选——有则祖先链的"全选"
 * 降级为"半选"（不再递归，半选状态一次性标满整条祖先链）；兄弟全部
 * 未选中则父节点彻底清空并继续向上递归判断爷爷节点。
 */
export function calcCheckedKeysForUnchecked(
  key: string,
  entities: KeyEntities,
  checkedKeys: Set<string>,
  halfCheckedKeys: Set<string>,
): CascadeResult {
  const descendantKeys = findDescendantKeys([key], entities, true);
  const nextChecked = new Set(checkedKeys);
  const nextHalfChecked = new Set(halfCheckedKeys);
  descendantKeys.forEach((k) => {
    nextChecked.delete(k);
    nextHalfChecked.delete(k);
  });

  function bubbleUp(currentKey: string) {
    const entity = entities[currentKey];
    const parent = entity?.parent;
    if (!parent) return;
    if (!nextChecked.has(parent.key) && !nextHalfChecked.has(parent.key)) return;

    const siblingKeys = findSiblingKeys(currentKey, entities, true);
    const anyChecked = siblingKeys.some((k) => nextChecked.has(k) || nextHalfChecked.has(k));
    if (anyChecked) {
      const ancestorKeys = findAncestorKeys([currentKey], entities, false);
      ancestorKeys.forEach((k) => {
        if (nextChecked.has(k)) {
          nextChecked.delete(k);
          nextHalfChecked.add(k);
        }
      });
      return;
    }
    nextChecked.delete(parent.key);
    nextHalfChecked.delete(parent.key);
    bubbleUp(parent.key);
  }
  bubbleUp(key);

  return { checkedKeys: nextChecked, halfCheckedKeys: nextHalfChecked };
}

/**
 * 从一批"应选中"的 key（通常是受控 value/defaultValue 传入的叶子或
 * 任意层级 key）全量重算三态——用于初始化/受控值变化场景，而非单次
 * 交互（单次交互用上面两个增量函数，性能更好）。实现方式：依次对每个
 * 传入 key 调用 calcCheckedKeysForChecked 累积计算，等价于"依次勾选
 * 这些节点"的最终结果。
 */
export function calcCheckedKeys(keys: string[], entities: KeyEntities): CascadeResult {
  let checkedKeys = new Set<string>();
  let halfCheckedKeys = new Set<string>();
  for (const key of keys) {
    if (!entities[key]) continue;
    const result = calcCheckedKeysForChecked(key, entities, checkedKeys, halfCheckedKeys);
    checkedKeys = result.checkedKeys;
    halfCheckedKeys = result.halfCheckedKeys;
  }
  return { checkedKeys, halfCheckedKeys };
}
