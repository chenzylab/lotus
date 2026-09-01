import { describe, it, expect } from 'vitest';
import { buildKeyEntities, type TreeNodeData } from './tree-data.js';
import { calcCheckedKeysForChecked, calcCheckedKeysForUnchecked, calcCheckedKeys } from './check-cascade.js';

const TREE: TreeNodeData[] = [
  {
    key: 'a',
    label: 'A',
    children: [
      { key: 'a1', label: 'A1', children: [{ key: 'a1a', label: 'A1a' }, { key: 'a1b', label: 'A1b' }] },
      { key: 'a2', label: 'A2' },
    ],
  },
  { key: 'b', label: 'B', children: [{ key: 'b1', label: 'B1' }] },
];

describe('calcCheckedKeysForChecked', () => {
  it('勾选叶子节点：自己被选中，父节点因兄弟未全选而变半选', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeysForChecked('a2', entities, new Set(), new Set());

    expect(result.checkedKeys.has('a2')).toBe(true);
    expect(result.checkedKeys.has('a')).toBe(false);
    expect(result.halfCheckedKeys.has('a')).toBe(true);
  });

  it('勾选一个有子孙的节点：全部后代联动选中', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeysForChecked('a1', entities, new Set(), new Set());

    expect(result.checkedKeys.has('a1')).toBe(true);
    expect(result.checkedKeys.has('a1a')).toBe(true);
    expect(result.checkedKeys.has('a1b')).toBe(true);
  });

  it('兄弟节点全部选中时，父节点也变为全选（冒泡）', () => {
    const entities = buildKeyEntities(TREE);
    let checked = new Set<string>();
    let halfChecked = new Set<string>();

    let result = calcCheckedKeysForChecked('a1', entities, checked, halfChecked);
    checked = result.checkedKeys;
    halfChecked = result.halfCheckedKeys;
    result = calcCheckedKeysForChecked('a2', entities, checked, halfChecked);

    expect(result.checkedKeys.has('a')).toBe(true);
    expect(result.halfCheckedKeys.has('a')).toBe(false);
  });

  it('多层嵌套：勾选最深层叶子节点，中间层和顶层都应变半选', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeysForChecked('a1a', entities, new Set(), new Set());

    expect(result.checkedKeys.has('a1a')).toBe(true);
    expect(result.halfCheckedKeys.has('a1')).toBe(true);
    expect(result.halfCheckedKeys.has('a')).toBe(true);
  });

  it('disableStrictly（对齐 Semi disableStrictly）：勾选父节点时排除 disabled 后代，disabled 节点不被联动选中', () => {
    const entities = buildKeyEntities(TREE);
    const disabledKeys = new Set(['a1a']);
    const result = calcCheckedKeysForChecked('a1', entities, new Set(), new Set(), disabledKeys);

    expect(result.checkedKeys.has('a1')).toBe(true);
    expect(result.checkedKeys.has('a1b')).toBe(true);
    expect(result.checkedKeys.has('a1a')).toBe(false);
  });

  it('disableStrictly：disabled 兄弟不参与"是否全部选中"的冒泡判断，非 disabled 兄弟全选时父节点仍能冒泡为全选', () => {
    const entities = buildKeyEntities(TREE);
    const disabledKeys = new Set(['a1a']);
    // a1 的子节点是 a1a(disabled)/a1b；只勾选 a1b（未涉及 a1a），
    // disabled 兄弟被排除在外后，a1b 是唯一需要判断的兄弟，理应冒泡全选。
    const result = calcCheckedKeysForChecked('a1b', entities, new Set(), new Set(), disabledKeys);

    expect(result.checkedKeys.has('a1b')).toBe(true);
    expect(result.checkedKeys.has('a1')).toBe(true);
    expect(result.halfCheckedKeys.has('a1')).toBe(false);
  });

  it('不同顶层子树互不影响：勾选 b1 不影响 a 子树的状态', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeysForChecked('b1', entities, new Set(), new Set());

    expect(result.checkedKeys.has('b1')).toBe(true);
    expect(result.checkedKeys.has('b')).toBe(true); // b1 是 b 唯一的子节点，全选后冒泡
    expect(result.halfCheckedKeys.has('a')).toBe(false);
  });
});

describe('calcCheckedKeysForUnchecked', () => {
  it('取消勾选一个全选的父节点：自己和全部后代都被移出', () => {
    const entities = buildKeyEntities(TREE);
    const checked = new Set(['a1', 'a1a', 'a1b']);
    const result = calcCheckedKeysForUnchecked('a1', entities, checked, new Set());

    expect(result.checkedKeys.has('a1')).toBe(false);
    expect(result.checkedKeys.has('a1a')).toBe(false);
    expect(result.checkedKeys.has('a1b')).toBe(false);
  });

  it('取消勾选后，若兄弟还有选中/半选，祖先的全选状态降级为半选', () => {
    const entities = buildKeyEntities(TREE);
    // 先让 a 完全选中（a1+a2 都选中 -> a 冒泡全选）
    let result = calcCheckedKeysForChecked('a1', entities, new Set(), new Set());
    result = calcCheckedKeysForChecked('a2', entities, result.checkedKeys, result.halfCheckedKeys);
    expect(result.checkedKeys.has('a')).toBe(true);

    // 取消勾选 a2：a1 及其后代仍选中，a 应该降级为半选
    const afterUncheck = calcCheckedKeysForUnchecked('a2', entities, result.checkedKeys, result.halfCheckedKeys);
    expect(afterUncheck.checkedKeys.has('a')).toBe(false);
    expect(afterUncheck.halfCheckedKeys.has('a')).toBe(true);
    expect(afterUncheck.checkedKeys.has('a1')).toBe(true);
  });

  it('取消勾选最后一个选中的兄弟后，父节点及祖先链彻底清空（不再半选）', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeysForChecked('a2', entities, new Set(), new Set());
    expect(result.halfCheckedKeys.has('a')).toBe(true);

    const afterUncheck = calcCheckedKeysForUnchecked('a2', entities, result.checkedKeys, result.halfCheckedKeys);
    expect(afterUncheck.checkedKeys.has('a')).toBe(false);
    expect(afterUncheck.halfCheckedKeys.has('a')).toBe(false);
  });

  it('取消勾选深层叶子节点后，逐层向上清空到顶层（全树最终无任何选中）', () => {
    const entities = buildKeyEntities(TREE);
    let result = calcCheckedKeysForChecked('a1a', entities, new Set(), new Set());
    result = calcCheckedKeysForChecked('a1b', entities, result.checkedKeys, result.halfCheckedKeys);
    // a1 应该已经全选（子节点 a1a/a1b 都选中）
    expect(result.checkedKeys.has('a1')).toBe(true);

    const afterUncheckA = calcCheckedKeysForUnchecked('a1a', entities, result.checkedKeys, result.halfCheckedKeys);
    const afterUncheckB = calcCheckedKeysForUnchecked('a1b', entities, afterUncheckA.checkedKeys, afterUncheckA.halfCheckedKeys);

    expect(afterUncheckB.checkedKeys.size).toBe(0);
    expect(afterUncheckB.halfCheckedKeys.size).toBe(0);
  });

  it('disableStrictly：取消勾选父节点时不影响 disabled 后代的选中状态', () => {
    const entities = buildKeyEntities(TREE);
    const disabledKeys = new Set(['a1a']);
    // 先手动构造一个"a1a 已选中（视为外部预设，与 disableStrictly 无关）
    // + a1/a1b 也选中"的状态，模拟 disabled 节点本身可以有独立初始值。
    const checked = new Set(['a1', 'a1a', 'a1b']);
    const result = calcCheckedKeysForUnchecked('a1', entities, checked, new Set(), disabledKeys);

    expect(result.checkedKeys.has('a1')).toBe(false);
    expect(result.checkedKeys.has('a1b')).toBe(false);
    expect(result.checkedKeys.has('a1a')).toBe(true);
  });
});

describe('calcCheckedKeys（全量重算）', () => {
  it('传入一批叶子 key，等价于依次勾选后的最终三态结果', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeys(['a1a', 'a1b'], entities);

    expect(result.checkedKeys.has('a1a')).toBe(true);
    expect(result.checkedKeys.has('a1b')).toBe(true);
    expect(result.checkedKeys.has('a1')).toBe(true); // 冒泡全选
    expect(result.halfCheckedKeys.has('a')).toBe(true); // a2 未选，a 半选
  });

  it('传入空数组时返回全空结果', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeys([], entities);

    expect(result.checkedKeys.size).toBe(0);
    expect(result.halfCheckedKeys.size).toBe(0);
  });

  it('传入不存在的 key 时被安全忽略', () => {
    const entities = buildKeyEntities(TREE);
    const result = calcCheckedKeys(['not-exist', 'a2'], entities);

    expect(result.checkedKeys.has('a2')).toBe(true);
    expect(result.checkedKeys.has('not-exist')).toBe(false);
  });
});
