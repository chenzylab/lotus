import { Foundation, type Adapter } from '../../base/adapter.js';

export * from './preview-math.js';
export * from './preview-foundation.js';

export type ImageLoadStatus = 'loading' | 'success' | 'error';

export interface ImageState {
  loadStatus: ImageLoadStatus;
}

export class ImageFoundation extends Foundation<ImageState> {
  constructor(adapter: Adapter<ImageState>) {
    super(adapter);
  }

  handleLoad(): void {
    this.setState({ loadStatus: 'success' });
  }

  handleError(): void {
    this.setState({ loadStatus: 'error' });
  }

  /** src 变化时重置为 loading（对齐 Semi：新图片开始加载前不能沿用旧的成功/失败态）。 */
  resetForNewSrc(): void {
    this.setState({ loadStatus: 'loading' });
  }
}
