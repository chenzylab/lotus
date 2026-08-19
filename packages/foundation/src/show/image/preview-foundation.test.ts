import { describe, it, expect } from 'vitest';
import { PreviewFoundation, initialPreviewState, type PreviewState } from './preview-foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createMockAdapter(initial: PreviewState): { adapter: Adapter<PreviewState>; getState: () => PreviewState } {
  let state = initial;
  return {
    adapter: {
      getState: () => state,
      setState: (patch) => { state = { ...state, ...patch }; },
    },
    getState: () => state,
  };
}

function loadedState(): PreviewState {
  return {
    ...initialPreviewState(),
    originalWidth: 100,
    originalHeight: 100,
    containerWidth: 100,
    containerHeight: 100,
  };
}

describe('PreviewFoundation', () => {
  it('zoomIn 按 zoomStep 增加缩放值', () => {
    const { adapter, getState } = createMockAdapter(loadedState());
    const foundation = new PreviewFoundation(adapter, { zoomStep: 0.5 });

    foundation.zoomIn();

    expect(getState().zoom).toBe(1.5);
  });

  it('zoomOut 按 zoomStep 减少缩放值，不会低于 minZoom', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), zoom: 0.2 });
    const foundation = new PreviewFoundation(adapter, { zoomStep: 0.5, minZoom: 0.1 });

    foundation.zoomOut();

    expect(getState().zoom).toBe(0.1);
  });

  it('zoomIn 不会超过 maxZoom', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), zoom: 4.8 });
    const foundation = new PreviewFoundation(adapter, { zoomStep: 0.5, maxZoom: 5 });

    foundation.zoomIn();

    expect(getState().zoom).toBe(5);
  });

  it('resetZoom 恢复 zoom=1、translate 归零，但保留 rotation', () => {
    const { adapter, getState } = createMockAdapter({
      ...loadedState(),
      zoom: 3,
      rotation: 90,
      translate: { x: 20, y: 20 },
    });
    const foundation = new PreviewFoundation(adapter);

    foundation.resetZoom();

    expect(getState().zoom).toBe(1);
    expect(getState().translate).toEqual({ x: 0, y: 0 });
    expect(getState().rotation).toBe(90);
  });

  it('rotateRight/rotateLeft 各自增减 90 度，可累积超过 360', () => {
    const { adapter, getState } = createMockAdapter(loadedState());
    const foundation = new PreviewFoundation(adapter);

    foundation.rotateRight();
    foundation.rotateRight();
    foundation.rotateRight();
    foundation.rotateRight();

    expect(getState().rotation).toBe(360);

    foundation.rotateLeft();
    expect(getState().rotation).toBe(270);
  });

  it('handleDrag 在图片小于容器时不产生位移（钳制为 0）', () => {
    const { adapter, getState } = createMockAdapter(loadedState());
    const foundation = new PreviewFoundation(adapter);

    foundation.handleDrag(50, 50);

    expect(getState().translate).toEqual({ x: 0, y: 0 });
  });

  it('handleDrag 在图片放大到大于容器后，可以在钳制范围内拖拽', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), zoom: 3 });
    const foundation = new PreviewFoundation(adapter);

    foundation.handleDrag(10, 10);

    expect(getState().translate.x).toBe(10);
    expect(getState().translate.y).toBe(10);
  });

  it('goTo 支持负数环形回绕到末尾', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), currentIndex: 0 });
    const foundation = new PreviewFoundation(adapter);

    foundation.goTo(-1, 3);

    expect(getState().currentIndex).toBe(2);
  });

  it('goTo 支持超出总数环形回绕到开头', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), currentIndex: 0 });
    const foundation = new PreviewFoundation(adapter);

    foundation.goTo(3, 3);

    expect(getState().currentIndex).toBe(0);
  });

  it('next/prev 切换图片时重置 zoom/rotation/translate', () => {
    const { adapter, getState } = createMockAdapter({
      ...loadedState(),
      currentIndex: 0,
      zoom: 3,
      rotation: 90,
      translate: { x: 20, y: 20 },
    });
    const foundation = new PreviewFoundation(adapter);

    foundation.next(3);

    expect(getState().currentIndex).toBe(1);
    expect(getState().zoom).toBe(1);
    expect(getState().rotation).toBe(0);
    expect(getState().translate).toEqual({ x: 0, y: 0 });
  });

  it('goTo total<=0 时不做任何变化', () => {
    const { adapter, getState } = createMockAdapter({ ...loadedState(), currentIndex: 0 });
    const foundation = new PreviewFoundation(adapter);

    foundation.goTo(1, 0);

    expect(getState().currentIndex).toBe(0);
  });
});
