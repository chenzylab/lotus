import { Foundation, type Adapter } from '../../base/adapter.js';

export interface AvatarState {
  /** 图片是否加载成功；`src` 存在但加载失败时降级为文字/占位内容。 */
  imgLoaded: boolean;
}

/**
 * Avatar 的图片加载态与自适应字符缩放算法。设计参考 Semi AvatarFoundation 的思路
 * （changeScale 用真实 DOM 测量而非估算字号），重新实现，不搬运代码。
 */
export class AvatarFoundation extends Foundation<AvatarState> {
  handleImgError(onError?: () => boolean | void): void {
    const result = onError?.();
    // onError 显式返回 false 时保留组件默认的降级行为之外的处理——对齐 Semi 语义：
    // "返回 false 会关闭组件默认的 fallback 行为"，即不切换到文字/占位内容。
    if (result === false) return;
    this.setState({ imgLoaded: false });
  }

  /**
   * 计算文字内容的缩放比例：测量容器宽度与文字实际宽度，若文字超出容器（减去两侧 gap）
   * 则按比例缩小，否则保持 1（不放大，只做防溢出收缩）。
   */
  static computeTextScale(containerWidth: number, textWidth: number, gap: number): number {
    if (containerWidth === 0 || textWidth === 0 || gap * 2 >= containerWidth) return 1;
    const available = containerWidth - gap * 2;
    return available > textWidth ? 1 : available / textWidth;
  }
}
