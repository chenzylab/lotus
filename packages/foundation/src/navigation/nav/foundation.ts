import { Foundation, type Adapter } from '../../base/adapter.js';
import type { ItemKey, NavMode, NavToggleIconPosition } from './constants.js';
import { type NormalizedNavItem, type NavItemInput, buildItemKeysMap, normalizeNavItems } from './navItem.js';

export type { ItemKey, NavMode, NavToggleIconPosition } from './constants.js';
export type { NormalizedNavItem, NavItemInput } from './navItem.js';
export { normalizeNavItems, buildItemKeysMap } from './navItem.js';
export {
  DEFAULT_SUBNAV_MAX_HEIGHT,
  DEFAULT_SUB_NAV_OPEN_DELAY,
  DEFAULT_SUB_NAV_CLOSE_DELAY,
  DEFAULT_TOOLTIP_SHOW_DELAY,
  DEFAULT_TOOLTIP_HIDE_DELAY,
} from './constants.js';

export interface NavState {
  selectedKeys: ItemKey[];
  openKeys: ItemKey[];
  isCollapsed: boolean;
}

export interface OnSelectData {
  itemKey: ItemKey;
  selectedKeys: ItemKey[];
  isOpen: boolean;
}

export interface OnOpenChangeData {
  itemKey: ItemKey;
  openKeys: ItemKey[];
  isOpen: boolean;
}

function addKey(keys: ItemKey[], key: ItemKey): ItemKey[] {
  return keys.includes(key) ? keys : [...keys, key];
}

function removeKey(keys: ItemKey[], key: ItemKey): ItemKey[] {
  return keys.filter((k) => k !== key);
}

/**
 * Nav 顶层状态机：selectedKeys/openKeys 的受控/非受控管理 + 选中项与其祖先 SubNav 的级联展开。
 * 设计参考 Semi NavigationFoundation 的核心意图（itemKeysMap 级联联动），用 lotus 的
 * Foundation<S> + 受控优先模式重新表达——不搬运 Semi 的 React 生命周期耦合部分
 * （getCalcState/init(lifecycle)分支/_isControlledComponent），isControlled 直接由
 * 调用方（Adapter 侧）显式传入，Foundation 本身不感知 props。
 */
export class NavFoundation extends Foundation<NavState> {
  /** 递归构建 itemKey → 祖先 itemKey 路径映射，供选中/展开级联查询。 */
  static buildItemKeysMap = buildItemKeysMap;

  /** 选中某个 itemKey 时，其所有祖先 itemKey 也应加入 openKeys（对齐 Semi 的默认展开行为）。 */
  static resolveAncestorOpenKeys(itemKeysMap: Record<ItemKey, ItemKey[]>, selectedKeys: ItemKey[]): ItemKey[] {
    const ancestors = new Set<ItemKey>();
    for (const key of selectedKeys) {
      const parents = itemKeysMap[key];
      if (parents) {
        for (const parent of parents) ancestors.add(parent);
      }
    }
    return [...ancestors];
  }

  handleItemClick(
    itemKey: ItemKey,
    isSelectedKeysControlled: boolean,
    onSelect?: (data: OnSelectData) => void,
  ): void {
    const { selectedKeys } = this.getState();
    const nextSelectedKeys = [itemKey];

    if (!isSelectedKeysControlled) {
      this.setState({ selectedKeys: nextSelectedKeys });
    }
    onSelect?.({ itemKey, selectedKeys: nextSelectedKeys, isOpen: true });
  }

  handleSubNavToggle(
    itemKey: ItemKey,
    isOpenKeysControlled: boolean,
    onOpenChange?: (data: OnOpenChangeData) => void,
  ): void {
    const { openKeys } = this.getState();
    const isOpen = !openKeys.includes(itemKey);
    const nextOpenKeys = isOpen ? addKey(openKeys, itemKey) : removeKey(openKeys, itemKey);

    if (!isOpenKeysControlled) {
      this.setState({ openKeys: nextOpenKeys });
    }
    onOpenChange?.({ itemKey, openKeys: nextOpenKeys, isOpen });
  }

  handleCollapseToggle(isCollapsedControlled: boolean, onCollapseChange?: (isCollapsed: boolean) => void): void {
    const nextCollapsed = !this.getState().isCollapsed;
    if (!isCollapsedControlled) {
      this.setState({ isCollapsed: nextCollapsed });
    }
    onCollapseChange?.(nextCollapsed);
  }
}
