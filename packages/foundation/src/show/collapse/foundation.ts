import { Foundation, type Adapter } from '../../base/adapter.js';

export interface CollapseState {
  activeKeys: Set<string>;
}

/**
 * 初始化展开状态：activeKey（受控）优先于 defaultActiveKey。accordion 模式下
 * 只允许一个展开项——若传入数组，只取第一个（对齐 Semi：手风琴 + 多 key 初值时
 * 静默只生效第一个，不报错）。
 */
export function initActiveKeys(
  activeKeyOrDefault: string | string[] | undefined,
  accordion: boolean,
): Set<string> {
  if (activeKeyOrDefault === undefined) return new Set();
  const keys = Array.isArray(activeKeyOrDefault) ? activeKeyOrDefault : [activeKeyOrDefault];
  if (keys.length === 0) return new Set();
  return accordion ? new Set([keys[0]!]) : new Set(keys);
}

/**
 * 点击某个 panel 的 header 后计算出的下一个展开集合：
 * - 已展开 → 收起（无论是否 accordion，都允许点击当前展开项使其收起）
 * - 未展开 + accordion → 整体替换成只含这一个 key（自动收起其他 panel）
 * - 未展开 + 非 accordion → 追加进集合
 */
export function toggleActiveKey(
  currentKeys: Set<string>,
  key: string,
  accordion: boolean,
): Set<string> {
  const next = new Set(currentKeys);
  if (next.has(key)) {
    next.delete(key);
    return next;
  }
  if (accordion) return new Set([key]);
  next.add(key);
  return next;
}

export class CollapseFoundation extends Foundation<CollapseState> {
  constructor(adapter: Adapter<CollapseState>) {
    super(adapter);
  }

  handleToggle(key: string, accordion: boolean): Set<string> {
    const { activeKeys } = this.getState();
    const next = toggleActiveKey(activeKeys, key, accordion);
    this.setState({ activeKeys: next });
    return next;
  }
}
