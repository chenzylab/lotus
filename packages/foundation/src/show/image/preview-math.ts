/**
 * 预览大图的缩放/旋转/拖拽平移纯数学计算，移植自 Semi 的
 * previewImageFoundation.ts（calcBoundingRectSize/getExtremeTranslate/
 * getSafeTranslate），用 lotus 语言习惯重新表达为独立纯函数模块（不
 * 依赖 Foundation 基类，没有内部状态，方便单测）。
 *
 * 与 Semi 的明确简化差异：Semi 的 changeZoom 支持"以鼠标滚轮当前位置
 * 为锚点缩放"（区分旋转 0/90/180/270 四种偏移公式），本次简化为固定
 * 以图片中心为缩放锚点——多数用户点击放大后用拖拽调整位置已经够用，
 * 鼠标锚点缩放的数学复杂度与实际可用性提升不成正比，属于本次移植时
 * 主动裁剪的范围（非遗漏）。
 */

export interface BoundingRectSize {
  width: number;
  height: number;
}

export interface Translate {
  x: number;
  y: number;
}

/** 旋转 rotation 度后，图片实际占据的包围盒尺寸（旋转 90/270 度时宽高互换）。 */
export function calcBoundingRectSize(width: number, height: number, rotation: number): BoundingRectSize {
  const angleInRadians = (rotation * Math.PI) / 180;
  const sinTheta = Math.abs(Math.sin(angleInRadians));
  const cosTheta = Math.abs(Math.cos(angleInRadians));
  return {
    width: width * cosTheta + height * sinTheta,
    height: width * sinTheta + height * cosTheta,
  };
}

/** 缩放值钳制到 [min, max] 区间，非法输入（NaN/Infinity）回退到 min。 */
export function clampZoom(zoom: number, min: number, max: number): number {
  if (typeof zoom !== 'number' || !Number.isFinite(zoom)) return min;
  return Math.min(max, Math.max(min, zoom));
}

/** 某一轴上允许拖拽的最大偏移量：图片包围盒比容器大出来的那一半。 */
export function getExtremeTranslate(
  boundWidth: number,
  boundHeight: number,
  containerWidth: number,
  containerHeight: number,
): Translate {
  return {
    x: (boundWidth - containerWidth) / 2,
    y: (boundHeight - containerHeight) / 2,
  };
}

/**
 * 把拖拽产生的平移值钳制到合法范围：图片某一轴比容器小时该轴不允许
 * 拖拽（固定为 0，图片居中显示）；比容器大时限制在 [-extreme, extreme]
 * 区间内，防止把图片拖出可视区域。
 */
export function clampTranslate(
  boundWidth: number,
  boundHeight: number,
  containerWidth: number,
  containerHeight: number,
  translateX: number,
  translateY: number,
): Translate {
  const extreme = getExtremeTranslate(boundWidth, boundHeight, containerWidth, containerHeight);
  const canDragHorizontal = boundWidth > containerWidth;
  const canDragVertical = boundHeight > containerHeight;

  return {
    x: canDragHorizontal ? Math.min(Math.max(translateX, -extreme.x), extreme.x) : 0,
    y: canDragVertical ? Math.min(Math.max(translateY, -extreme.y), extreme.y) : 0,
  };
}

/**
 * 缩放变化时同步缩放平移量（保持图片中心位置不变的比例缩放），
 * 再钳制回合法范围。
 */
export function recalcTranslateOnZoom(
  prevZoom: number,
  nextZoom: number,
  prevTranslate: Translate,
  originalWidth: number,
  originalHeight: number,
  rotation: number,
  containerWidth: number,
  containerHeight: number,
): Translate {
  const scale = nextZoom / (prevZoom || 1);
  const nextBound = calcBoundingRectSize(originalWidth * nextZoom, originalHeight * nextZoom, rotation);
  return clampTranslate(
    nextBound.width,
    nextBound.height,
    containerWidth,
    containerHeight,
    prevTranslate.x * scale,
    prevTranslate.y * scale,
  );
}
