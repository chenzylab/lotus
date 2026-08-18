import { Foundation, type Adapter } from '../../base/adapter.js';

export type BannerType = 'info' | 'success' | 'danger' | 'warning';

export interface BannerState {
  visible: boolean;
}

/**
 * Banner 的状态机极简（仅"关闭"一个动作），但仍拆 Foundation 保持与
 * Notification/Toast 等同分类组件的结构一致，未来若加自动消失定时器等
 * 交互不必重构（与 Button 先例同理——逻辑量小不是不拆 Foundation 的理由）。
 */
export class BannerFoundation extends Foundation<BannerState> {
  constructor(adapter: Adapter<BannerState>) {
    super(adapter);
  }

  close(onClose?: () => void): void {
    this.setState({ visible: false });
    onClose?.();
  }
}
