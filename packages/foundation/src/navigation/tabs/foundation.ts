import { Foundation, type Adapter } from '../../base/adapter.js';

export interface TabItemMeta {
  itemKey: string;
  tab?: string;
  disabled?: boolean;
  closable?: boolean;
  icon?: unknown;
}

export interface TabsState {
  activeKey: string;
  panes: TabItemMeta[];
}

/**
 * Tabs 的激活态状态机。设计参考 Semi TabsFoundation 的判定思路——受控模式下点击只上报
 * onChange（由外部通过 props.activeKey 决定下一次渲染的实际值），非受控模式下由 Foundation
 * 自己更新内部状态；isControlled 由 Adapter 侧根据 `props.activeKey !== undefined` 传入，
 * Foundation 本身不感知 props，保持框架无关。重新设计，不搬运 Semi 代码。
 */
export class TabsFoundation extends Foundation<TabsState> {
  /** 首个非 disabled 的 pane 作为默认激活项；全部 disabled 时退化为第一项。 */
  static resolveDefaultActiveKey(panes: TabItemMeta[]): string {
    const firstEnabled = panes.find((pane) => !pane.disabled);
    return (firstEnabled ?? panes[0])?.itemKey ?? '';
  }

  handleTabClick(itemKey: string, isControlled: boolean, onChange?: (activeKey: string) => void): void {
    const { activeKey, panes } = this.getState();
    const target = panes.find((pane) => pane.itemKey === itemKey);
    if (!target || target.disabled || itemKey === activeKey) return;

    if (!isControlled) {
      this.setState({ activeKey: itemKey });
    }
    onChange?.(itemKey);
  }

  /** 键盘方向导航：在非 disabled 的 pane 之间循环移动，返回下一个应激活的 itemKey。 */
  resolveArrowNavigation(currentKey: string, direction: 1 | -1): string {
    const { panes } = this.getState();
    const enabled = panes.filter((pane) => !pane.disabled);
    if (enabled.length === 0) return currentKey;

    const currentIndex = enabled.findIndex((pane) => pane.itemKey === currentKey);
    if (currentIndex === -1) return enabled[0]!.itemKey;

    const nextIndex = (currentIndex + direction + enabled.length) % enabled.length;
    return enabled[nextIndex]!.itemKey;
  }
}
