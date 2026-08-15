import { Foundation, type Adapter } from '../../base/adapter.js';

export type TooltipTrigger = 'hover' | 'click' | 'focus' | 'custom' | 'contextMenu';

export interface TooltipState {
  visible: boolean;
}

/**
 * Tooltip 的显隐状态机：受控/非受控判定 + hover 触发的延迟显示/隐藏计时器管理。
 * 设计参考 Semi TooltipFoundation 的 mouseEnterDelay/mouseLeaveDelay 思路，
 * 重新实现，不搬运代码。`trigger='custom'` 时完全交由外部 `visible` prop 驱动，
 * Foundation 的 show/hide 方法不介入。
 */
export class TooltipFoundation extends Foundation<TooltipState> {
  private enterTimer: ReturnType<typeof setTimeout> | null = null;
  private leaveTimer: ReturnType<typeof setTimeout> | null = null;

  private clearTimers(): void {
    if (this.enterTimer != null) {
      clearTimeout(this.enterTimer);
      this.enterTimer = null;
    }
    if (this.leaveTimer != null) {
      clearTimeout(this.leaveTimer);
      this.leaveTimer = null;
    }
  }

  /** 立即显示（点击/聚焦触发不需要延迟）。受控模式下只通知，不改内部 state。 */
  show(isControlled: boolean, onVisibleChange?: (visible: boolean) => void): void {
    this.clearTimers();
    if (!isControlled) this.setState({ visible: true });
    onVisibleChange?.(true);
  }

  /** 立即隐藏。受控模式下只通知，不改内部 state。 */
  hide(isControlled: boolean, onVisibleChange?: (visible: boolean) => void): void {
    this.clearTimers();
    if (!isControlled) this.setState({ visible: false });
    onVisibleChange?.(false);
  }

  /** hover 移入：延迟 `delay` 毫秒后显示，移入过程中再次移出会被 `hide`/`clearTimers` 打断。 */
  scheduleShow(delay: number, isControlled: boolean, onVisibleChange?: (visible: boolean) => void): void {
    this.clearTimers();
    if (delay <= 0) {
      this.show(isControlled, onVisibleChange);
      return;
    }
    this.enterTimer = setTimeout(() => {
      this.enterTimer = null;
      if (!isControlled) this.setState({ visible: true });
      onVisibleChange?.(true);
    }, delay);
  }

  /** hover 移出：延迟 `delay` 毫秒后隐藏，便于用户把鼠标移到浮层本身上时不闪烁消失。 */
  scheduleHide(delay: number, isControlled: boolean, onVisibleChange?: (visible: boolean) => void): void {
    this.clearTimers();
    if (delay <= 0) {
      this.hide(isControlled, onVisibleChange);
      return;
    }
    this.leaveTimer = setTimeout(() => {
      this.leaveTimer = null;
      if (!isControlled) this.setState({ visible: false });
      onVisibleChange?.(false);
    }, delay);
  }

  toggle(isControlled: boolean, onVisibleChange?: (visible: boolean) => void): void {
    const { visible } = this.getState();
    if (visible) this.hide(isControlled, onVisibleChange);
    else this.show(isControlled, onVisibleChange);
  }

  destroy(): void {
    this.clearTimers();
  }
}
