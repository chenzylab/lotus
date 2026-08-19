import { Foundation, type Adapter } from '../../base/adapter.js';
import { calcBoundingRectSize, clampZoom, clampTranslate, recalcTranslateOnZoom, type Translate } from './preview-math.js';

export interface PreviewState {
  currentIndex: number;
  zoom: number;
  rotation: number;
  translate: Translate;
  originalWidth: number;
  originalHeight: number;
  containerWidth: number;
  containerHeight: number;
}

export interface PreviewOptions {
  minZoom?: number;
  maxZoom?: number;
  zoomStep?: number;
}

const DEFAULT_MIN_ZOOM = 0.1;
const DEFAULT_MAX_ZOOM = 5;
const DEFAULT_ZOOM_STEP = 0.5;

export function initialPreviewState(currentIndex = 0): PreviewState {
  return {
    currentIndex,
    zoom: 1,
    rotation: 0,
    translate: { x: 0, y: 0 },
    originalWidth: 0,
    originalHeight: 0,
    containerWidth: 0,
    containerHeight: 0,
  };
}

export class PreviewFoundation extends Foundation<PreviewState> {
  private options: Required<PreviewOptions>;

  constructor(adapter: Adapter<PreviewState>, options: PreviewOptions = {}) {
    super(adapter);
    this.options = {
      minZoom: options.minZoom ?? DEFAULT_MIN_ZOOM,
      maxZoom: options.maxZoom ?? DEFAULT_MAX_ZOOM,
      zoomStep: options.zoomStep ?? DEFAULT_ZOOM_STEP,
    };
  }

  handleImageLoaded(naturalWidth: number, naturalHeight: number): void {
    this.setState({ originalWidth: naturalWidth, originalHeight: naturalHeight });
  }

  handleContainerResize(width: number, height: number): void {
    this.setState({ containerWidth: width, containerHeight: height });
  }

  private applyZoom(nextZoomRaw: number): void {
    const state = this.getState();
    const nextZoom = clampZoom(nextZoomRaw, this.options.minZoom, this.options.maxZoom);
    const translate = recalcTranslateOnZoom(
      state.zoom,
      nextZoom,
      state.translate,
      state.originalWidth,
      state.originalHeight,
      state.rotation,
      state.containerWidth,
      state.containerHeight,
    );
    this.setState({ zoom: nextZoom, translate });
  }

  zoomIn(): void {
    this.applyZoom(this.getState().zoom + this.options.zoomStep);
  }

  zoomOut(): void {
    this.applyZoom(this.getState().zoom - this.options.zoomStep);
  }

  handleWheel(deltaY: number): void {
    const step = deltaY > 0 ? -this.options.zoomStep / 2 : this.options.zoomStep / 2;
    this.applyZoom(this.getState().zoom + step);
  }

  resetZoom(): void {
    const state = this.getState();
    this.setState({ zoom: 1, translate: { x: 0, y: 0 }, rotation: state.rotation });
  }

  rotateLeft(): void {
    const state = this.getState();
    this.setState({ rotation: state.rotation - 90 });
  }

  rotateRight(): void {
    const state = this.getState();
    this.setState({ rotation: state.rotation + 90 });
  }

  /** 拖拽平移：传入鼠标位移增量（非绝对坐标），内部累加并钳制到合法范围。 */
  handleDrag(deltaX: number, deltaY: number): void {
    const state = this.getState();
    const bound = calcBoundingRectSize(
      state.originalWidth * state.zoom,
      state.originalHeight * state.zoom,
      state.rotation,
    );
    const translate = clampTranslate(
      bound.width,
      bound.height,
      state.containerWidth,
      state.containerHeight,
      state.translate.x + deltaX,
      state.translate.y + deltaY,
    );
    this.setState({ translate });
  }

  goTo(index: number, total: number): void {
    if (total <= 0) return;
    const next = ((index % total) + total) % total;
    this.setState({ currentIndex: next, zoom: 1, rotation: 0, translate: { x: 0, y: 0 } });
  }

  next(total: number): void {
    this.goTo(this.getState().currentIndex + 1, total);
  }

  prev(total: number): void {
    this.goTo(this.getState().currentIndex - 1, total);
  }
}
