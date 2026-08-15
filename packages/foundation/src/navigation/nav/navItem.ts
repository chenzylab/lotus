import type { ItemKey } from './constants.js';

/** Nav.items 数组里单个原始配置项——支持字符串简写，或完整对象（含嵌套 items 表示子导航）。 */
export type NavItemInput =
  | string
  | {
      itemKey: ItemKey;
      text?: unknown;
      icon?: unknown;
      link?: string;
      disabled?: boolean;
      indent?: boolean;
      items?: NavItemInput[];
      [key: string]: unknown;
    };

/** 规范化后的导航节点：字符串简写被展开为完整字段，itemKey 缺失时用 text 兜底。 */
export interface NormalizedNavItem {
  itemKey: ItemKey;
  text: unknown;
  icon: unknown;
  link?: string;
  disabled: boolean;
  indent: boolean;
  items: NormalizedNavItem[] | null;
  original: NavItemInput;
}

function normalizeOne(input: NavItemInput): NormalizedNavItem {
  if (typeof input === 'string') {
    return {
      itemKey: input,
      text: input,
      icon: undefined,
      link: undefined,
      disabled: false,
      indent: false,
      items: null,
      original: input,
    };
  }

  const items = Array.isArray(input.items) && input.items.length > 0 ? input.items.map(normalizeOne) : null;

  return {
    itemKey: input.itemKey,
    text: input.text ?? input.itemKey,
    icon: input.icon,
    link: input.link,
    disabled: !!input.disabled,
    indent: !!input.indent,
    items,
    original: input,
  };
}

/** 把 Nav.items 原始配置整体规范化为 NormalizedNavItem 树。 */
export function normalizeNavItems(items: NavItemInput[] = []): NormalizedNavItem[] {
  return items.map(normalizeOne);
}

/**
 * 递归构建 itemKey → 祖先 itemKey 路径（由外到内）的映射表，用于选中/展开某一项时
 * 级联联动其所有祖先 SubNav（对齐 Semi NavigationFoundation.buildItemKeysMap 的设计意图，
 * 用 lotus 习惯重新表达：不复用 Semi 的 children 兼容分支，只支持 items 嵌套）。
 */
export function buildItemKeysMap(
  items: NormalizedNavItem[],
  parentKeys: ItemKey[] = [],
  map: Record<ItemKey, ItemKey[]> = {},
): Record<ItemKey, ItemKey[]> {
  for (const item of items) {
    map[item.itemKey] = parentKeys;
    if (item.items) {
      buildItemKeysMap(item.items, [...parentKeys, item.itemKey], map);
    }
  }
  return map;
}
