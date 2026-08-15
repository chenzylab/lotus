import { describe, expect, it, vi } from 'vitest';
import { NavFoundation } from './foundation.js';
import { normalizeNavItems, buildItemKeysMap } from './navItem.js';

function createFoundation(initial: { selectedKeys?: (string | number)[]; openKeys?: (string | number)[]; isCollapsed?: boolean } = {}) {
  let state = {
    selectedKeys: initial.selectedKeys ?? [],
    openKeys: initial.openKeys ?? [],
    isCollapsed: initial.isCollapsed ?? false,
  };
  const foundation = new NavFoundation({
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  });
  return { foundation, getState: () => state };
}

describe('navItem 规范化', () => {
  it('字符串简写展开为完整字段', () => {
    const [item] = normalizeNavItems(['首页']);
    expect(item).toMatchObject({ itemKey: '首页', text: '首页', disabled: false, items: null });
  });

  it('对象缺失 text 时用 itemKey 兜底', () => {
    const [item] = normalizeNavItems([{ itemKey: 'home' }]);
    expect(item.text).toBe('home');
  });

  it('嵌套 items 递归规范化', () => {
    const [item] = normalizeNavItems([{ itemKey: 'a', items: ['b', { itemKey: 'c' }] }]);
    expect(item.items).toHaveLength(2);
    expect(item.items?.[0]).toMatchObject({ itemKey: 'b' });
    expect(item.items?.[1]).toMatchObject({ itemKey: 'c' });
  });

  it('无 items 字段时 items 为 null（非空数组）', () => {
    const [item] = normalizeNavItems(['leaf']);
    expect(item.items).toBeNull();
  });
});

describe('buildItemKeysMap', () => {
  it('顶层节点的父路径为空数组', () => {
    const items = normalizeNavItems(['a', 'b']);
    const map = buildItemKeysMap(items);
    expect(map.a).toEqual([]);
    expect(map.b).toEqual([]);
  });

  it('嵌套节点的父路径包含所有祖先 itemKey（由外到内）', () => {
    const items = normalizeNavItems([{ itemKey: 'a', items: [{ itemKey: 'b', items: ['c'] }] }]);
    const map = buildItemKeysMap(items);
    expect(map.a).toEqual([]);
    expect(map.b).toEqual(['a']);
    expect(map.c).toEqual(['a', 'b']);
  });
});

describe('NavFoundation.resolveAncestorOpenKeys', () => {
  it('选中叶子节点时返回其所有祖先 key', () => {
    const items = normalizeNavItems([{ itemKey: 'a', items: [{ itemKey: 'b', items: ['c'] }] }]);
    const map = buildItemKeysMap(items);
    expect(NavFoundation.resolveAncestorOpenKeys(map, ['c'])).toEqual(['a', 'b']);
  });

  it('选中顶层节点时返回空数组', () => {
    const items = normalizeNavItems(['a']);
    const map = buildItemKeysMap(items);
    expect(NavFoundation.resolveAncestorOpenKeys(map, ['a'])).toEqual([]);
  });

  it('多个选中项的祖先去重合并', () => {
    const items = normalizeNavItems([{ itemKey: 'a', items: ['x', 'y'] }]);
    const map = buildItemKeysMap(items);
    expect(NavFoundation.resolveAncestorOpenKeys(map, ['x', 'y'])).toEqual(['a']);
  });
});

describe('NavFoundation.handleItemClick', () => {
  it('非受控模式：点击后更新内部 selectedKeys 并触发 onSelect', () => {
    const { foundation, getState } = createFoundation({ selectedKeys: ['a'] });
    const onSelect = vi.fn();
    foundation.handleItemClick('b', false, onSelect);
    expect(getState().selectedKeys).toEqual(['b']);
    expect(onSelect).toHaveBeenCalledWith({ itemKey: 'b', selectedKeys: ['b'], isOpen: true });
  });

  it('受控模式：不更新内部状态，仍触发 onSelect 让外部决定', () => {
    const { foundation, getState } = createFoundation({ selectedKeys: ['a'] });
    const onSelect = vi.fn();
    foundation.handleItemClick('b', true, onSelect);
    expect(getState().selectedKeys).toEqual(['a']);
    expect(onSelect).toHaveBeenCalledWith({ itemKey: 'b', selectedKeys: ['b'], isOpen: true });
  });
});

describe('NavFoundation.handleSubNavToggle', () => {
  it('未展开时点击 → 加入 openKeys，isOpen=true', () => {
    const { foundation, getState } = createFoundation({ openKeys: [] });
    const onOpenChange = vi.fn();
    foundation.handleSubNavToggle('sub1', false, onOpenChange);
    expect(getState().openKeys).toEqual(['sub1']);
    expect(onOpenChange).toHaveBeenCalledWith({ itemKey: 'sub1', openKeys: ['sub1'], isOpen: true });
  });

  it('已展开时点击 → 从 openKeys 移除，isOpen=false', () => {
    const { foundation, getState } = createFoundation({ openKeys: ['sub1', 'sub2'] });
    foundation.handleSubNavToggle('sub1', false);
    expect(getState().openKeys).toEqual(['sub2']);
  });

  it('受控模式：不更新内部状态', () => {
    const { foundation, getState } = createFoundation({ openKeys: [] });
    foundation.handleSubNavToggle('sub1', true);
    expect(getState().openKeys).toEqual([]);
  });
});

describe('NavFoundation.handleCollapseToggle', () => {
  it('非受控模式：切换 isCollapsed 并触发回调', () => {
    const { foundation, getState } = createFoundation({ isCollapsed: false });
    const onCollapseChange = vi.fn();
    foundation.handleCollapseToggle(false, onCollapseChange);
    expect(getState().isCollapsed).toBe(true);
    expect(onCollapseChange).toHaveBeenCalledWith(true);
  });

  it('受控模式：不更新内部状态，仍触发回调', () => {
    const { foundation, getState } = createFoundation({ isCollapsed: false });
    const onCollapseChange = vi.fn();
    foundation.handleCollapseToggle(true, onCollapseChange);
    expect(getState().isCollapsed).toBe(false);
    expect(onCollapseChange).toHaveBeenCalledWith(true);
  });
});
