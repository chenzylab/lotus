import { Context, type Tracked } from 'ripple';

/**
 * ImagePreview（多图批量预览容器）下发给内部 Image 子组件的共享状态：
 * 把每个 Image 的 src 注册进一个有序列表，点击任意一张触发预览时能
 * 定位到正确的 currentIndex，并支持左右切换到列表里的其它图。
 * 参考 Nav/Collapse/List/Timeline 的既有 Context 协调模式。
 */
export interface ImagePreviewContextValue {
  /** 注册一张图片进列表，返回它在列表中的序号；重复调用同一 src 幂等。 */
  register: (src: string) => number;
  openAt: (index: number) => void;
}

export const ImagePreviewGroupContext = new Context<Tracked<ImagePreviewContextValue>>();
