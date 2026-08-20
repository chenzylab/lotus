export interface Point {
  x: number;
  y: number;
}

export interface Size {
  width: number;
  height: number;
}

/** 图片在容器内的显示状态：centerPoint 是容器内绝对像素坐标（非左上角），
 * width/height 是屏幕显示尺寸（已叠加 zoom，未旋转）。对齐 Semi ImageDataState。 */
export interface CropperImageState {
  width: number;
  height: number;
  centerPoint: Point;
}

/** 图片原始像素尺寸 + 首次适配容器时算出的基础缩放系数。
 * realZoom = scale * zoom 才是屏幕像素到原图像素的总缩放系数。 */
export interface CropperImageMeta {
  originalWidth: number;
  originalHeight: number;
  scale: number;
}

/** 裁切框状态：centerPoint 同样是容器内绝对像素坐标。 */
export interface CropperBoxState {
  width: number;
  height: number;
  centerPoint: Point;
}

export type CropperCornerDir = 'tl' | 'tm' | 'tr' | 'ml' | 'mr' | 'bl' | 'bm' | 'br';

/** 显式状态机，比 Semi 隐式的"字段是否为 null"判断更利于单测和状态可读性（主动偏离 Semi）。 */
export type CropperInteractionMode =
  | 'idle'
  | 'moving-box'
  | 'resizing-corner'
  | 'resizing-corner-aspect'
  | 'moving-image';

export interface CropperState {
  mode: CropperInteractionMode;
  imgData: CropperImageState;
  cropperBox: CropperBoxState;
  zoom: number;
  rotate: number;
  loaded: boolean;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

/** 在给定宽高比下，把 (width, height) 收缩为满足 aspect 的最大内接尺寸。 */
export function fitAspect(width: number, height: number, aspect: number): Size {
  if (width / height > aspect) {
    return { width: height * aspect, height };
  }
  return { width, height: width / aspect };
}

/** 图片首次加载完成后，算出适配容器的初始显示状态（居中、等比缩放到容器内）。 */
export function computeInitialImageState(
  naturalWidth: number,
  naturalHeight: number,
  container: Size,
): { imgData: CropperImageState; meta: CropperImageMeta } {
  let scale: number;
  let width: number;
  let height: number;
  if (naturalWidth / container.width > naturalHeight / container.height) {
    scale = container.width / naturalWidth;
    width = container.width;
    height = naturalHeight * scale;
  } else {
    scale = container.height / naturalHeight;
    width = naturalWidth * scale;
    height = container.height;
  }
  return {
    imgData: {
      width,
      height,
      centerPoint: { x: container.width / 2, y: container.height / 2 },
    },
    meta: { originalWidth: naturalWidth, originalHeight: naturalHeight, scale },
  };
}

/** 图片加载完成后，算出裁切框的初始状态：居中，按 aspect 内接容器。 */
export function computeInitialCropperBox(container: Size, aspect: number): CropperBoxState {
  let width: number;
  let height: number;
  if (container.width / container.height > aspect) {
    height = container.height;
    width = container.height * aspect;
  } else {
    width = container.width;
    height = container.width / aspect;
  }
  return {
    width,
    height,
    centerPoint: { x: container.width / 2, y: container.height / 2 },
  };
}

/** 容器尺寸变化（如窗口 resize）时，图片和裁切框按同一比例整体缩放。 */
export function resizeImageState(imgData: CropperImageState, ratio: number): CropperImageState {
  return {
    width: imgData.width * ratio,
    height: imgData.height * ratio,
    centerPoint: { x: imgData.centerPoint.x * ratio, y: imgData.centerPoint.y * ratio },
  };
}

/** 容器尺寸变化时，裁切框按比例缩放后再钳制回新容器边界内（含 aspect 锁定场景）。 */
export function resizeCropperBox(
  cropperBox: CropperBoxState,
  ratio: number,
  newContainer: Size,
  aspectRatio?: number,
): CropperBoxState {
  const scaled = {
    width: cropperBox.width * ratio,
    height: cropperBox.height * ratio,
    centerPoint: { x: cropperBox.centerPoint.x * ratio, y: cropperBox.centerPoint.y * ratio },
  };
  let xMin = scaled.centerPoint.x - scaled.width / 2;
  let xMax = scaled.centerPoint.x + scaled.width / 2;
  let yMin = scaled.centerPoint.y - scaled.height / 2;
  let yMax = scaled.centerPoint.y + scaled.height / 2;

  if (aspectRatio) {
    if (xMax > newContainer.width) {
      xMax = newContainer.width;
      xMin = scaled.width > newContainer.width ? 0 : newContainer.width - scaled.width;
      scaled.width = xMax - xMin;
      scaled.height = scaled.width / aspectRatio;
      yMax = yMin + scaled.height;
    }
    if (yMax > newContainer.height) {
      yMax = newContainer.height;
      yMin = scaled.height > newContainer.height ? 0 : newContainer.height - scaled.height;
      scaled.height = yMax - yMin;
      scaled.width = scaled.height * aspectRatio;
      xMax = xMin + scaled.width;
    }
  } else {
    if (xMax > newContainer.width) {
      xMax = newContainer.width;
      xMin = scaled.width > newContainer.width ? 0 : newContainer.width - scaled.width;
    }
    if (yMax > newContainer.height) {
      yMax = newContainer.height;
      yMin = scaled.height > newContainer.height ? 0 : newContainer.height - scaled.height;
    }
  }

  return {
    width: xMax - xMin,
    height: yMax - yMin,
    centerPoint: { x: (xMax + xMin) / 2, y: (yMax + yMin) / 2 },
  };
}

/** 滚轮缩放：以鼠标位置（容器内坐标）为锚点的标准缩放公式，缩放后该点在屏幕上位置不变。 */
export function zoomAtPoint(
  imgData: CropperImageState,
  currentZoom: number,
  nextZoom: number,
  anchor: Point,
): CropperImageState {
  const newCenterPoint = {
    x: (imgData.centerPoint.x - anchor.x) / currentZoom * nextZoom + anchor.x,
    y: (imgData.centerPoint.y - anchor.y) / currentZoom * nextZoom + anchor.y,
  };
  return {
    width: (imgData.width / currentZoom) * nextZoom,
    height: (imgData.height / currentZoom) * nextZoom,
    centerPoint: newCenterPoint,
  };
}

/** 根据 zoomStep/min/maxZoom 算出滚轮的下一档 zoom 值；越界或方向为 0 时返回 null（不变化）。 */
export function nextWheelZoom(
  currentZoom: number,
  deltaY: number,
  zoomStep: number,
  minZoom: number,
  maxZoom: number,
): number | null {
  if (deltaY < 0) {
    const next = currentZoom + zoomStep;
    return next <= maxZoom ? Number(next.toFixed(2)) : null;
  }
  if (deltaY > 0) {
    const next = currentZoom - zoomStep;
    return next >= minZoom ? Number(next.toFixed(2)) : null;
  }
  return null;
}

/** 8 个拖拽方向映射为符号系数，统一代数式处理裁切框缩放（无 aspect 锁定场景）。 */
export function moveParamByDir(dir: CropperCornerDir): { paramX: number; paramY: number } {
  switch (dir) {
    case 'tl':
      return { paramX: -1, paramY: -1 };
    case 'tm':
      return { paramX: 0, paramY: -1 };
    case 'tr':
      return { paramX: 1, paramY: -1 };
    case 'ml':
      return { paramX: -1, paramY: 0 };
    case 'mr':
      return { paramX: 1, paramY: 0 };
    case 'bl':
      return { paramX: -1, paramY: 1 };
    case 'bm':
      return { paramX: 0, paramY: 1 };
    case 'br':
      return { paramX: 1, paramY: 1 };
    default:
      return { paramX: 0, paramY: 0 };
  }
}

/** 拖角调整裁切框（无 aspect 锁定）：offset 是鼠标在容器内的当前坐标。
 * paramX/paramY 可能因"拖过对角线"而翻转，返回值带上翻转后的新 param。 */
export function resizeCornerFree(
  cropperBox: CropperBoxState,
  param: { paramX: number; paramY: number },
  offset: Point,
): { box: CropperBoxState; param: { paramX: number; paramY: number } } {
  const box = {
    width: cropperBox.width,
    height: cropperBox.height,
    centerPoint: { x: cropperBox.centerPoint.x, y: cropperBox.centerPoint.y },
  };
  let paramX = param.paramX;
  let paramY = param.paramY;

  if (paramX) {
    const x = cropperBox.centerPoint.x + (paramX * cropperBox.width) / 2;
    box.width = cropperBox.width + paramX * (offset.x - x);
    if (box.width < 0) {
      box.width = -box.width;
      paramX = -paramX;
    }
    box.centerPoint.x = offset.x - (paramX * box.width) / 2;
  }
  if (paramY) {
    const y = cropperBox.centerPoint.y + (paramY * cropperBox.height) / 2;
    box.height = cropperBox.height + paramY * (offset.y - y);
    if (box.height < 0) {
      box.height = -box.height;
      paramY = -paramY;
    }
    box.centerPoint.y = offset.y - (paramY * box.height) / 2;
  }

  return { box, param: { paramX, paramY } };
}

/** aspect 锁定拖角前，预计算该方向允许的移动范围（mousedown 时调用一次）。 */
export function rangeForAspectResize(
  cropperBox: CropperBoxState,
  container: Size,
  aspectRatio: number,
  dir: CropperCornerDir,
): { rangeX: [number, number]; rangeY: [number, number] } {
  const xMin = cropperBox.centerPoint.x - cropperBox.width / 2;
  const xMax = cropperBox.centerPoint.x + cropperBox.width / 2;
  const yMin = cropperBox.centerPoint.y - cropperBox.height / 2;
  const yMax = cropperBox.centerPoint.y + cropperBox.height / 2;

  let width: number;
  let height: number;

  switch (dir) {
    case 'tl': {
      ({ width, height } = fitAspect(xMax, yMax, aspectRatio));
      return { rangeX: [xMax - width, xMax], rangeY: [yMax - height, yMax] };
    }
    case 'tm': {
      const half = Math.min(cropperBox.centerPoint.x, container.width - cropperBox.centerPoint.x);
      ({ width, height } = fitAspect(2 * half, yMax, aspectRatio));
      return {
        rangeX: [cropperBox.centerPoint.x - width / 2, cropperBox.centerPoint.x + width / 2],
        rangeY: [yMax - height, yMax],
      };
    }
    case 'tr': {
      ({ width, height } = fitAspect(container.width - xMin, yMax, aspectRatio));
      return { rangeX: [xMin, xMin + width], rangeY: [yMax - height, yMax] };
    }
    case 'ml': {
      const half = Math.min(cropperBox.centerPoint.y, container.height - cropperBox.centerPoint.y);
      ({ width, height } = fitAspect(xMax, 2 * half, aspectRatio));
      return {
        rangeX: [xMax - width, xMax],
        rangeY: [cropperBox.centerPoint.y - height / 2, cropperBox.centerPoint.y + height / 2],
      };
    }
    case 'mr': {
      const half = Math.min(cropperBox.centerPoint.y, container.height - cropperBox.centerPoint.y);
      ({ width, height } = fitAspect(container.width - xMin, 2 * half, aspectRatio));
      return {
        rangeX: [xMin, xMin + width],
        rangeY: [cropperBox.centerPoint.y - height / 2, cropperBox.centerPoint.y + height / 2],
      };
    }
    case 'bl': {
      ({ width, height } = fitAspect(xMax, container.height - yMin, aspectRatio));
      return { rangeX: [xMax - width, xMax], rangeY: [yMin, yMin + height] };
    }
    case 'bm': {
      const half = Math.min(cropperBox.centerPoint.x, container.width - cropperBox.centerPoint.x);
      ({ width, height } = fitAspect(2 * half, container.height - yMin, aspectRatio));
      return {
        rangeX: [cropperBox.centerPoint.x - width / 2, cropperBox.centerPoint.x + width / 2],
        rangeY: [yMin, yMin + height],
      };
    }
    case 'br':
    default: {
      ({ width, height } = fitAspect(container.width - xMin, container.height - yMin, aspectRatio));
      return { rangeX: [xMin, xMin + width], rangeY: [yMin, yMin + height] };
    }
  }
}

/** aspect 锁定拖角调整：一个自由变量（offsetX 或 offsetY，取决于方向）反推另一边，钳制在预计算好的 range 内。 */
export function resizeCornerAspect(
  cropperBox: CropperBoxState,
  dir: CropperCornerDir,
  aspectRatio: number,
  range: { rangeX: [number, number]; rangeY: [number, number] },
  pointer: Point,
): CropperBoxState {
  const box = {
    width: cropperBox.width,
    height: cropperBox.height,
    centerPoint: { x: cropperBox.centerPoint.x, y: cropperBox.centerPoint.y },
  };

  if (dir === 'ml' || dir === 'mr') {
    const offsetX = clamp(pointer.x, range.rangeX[0], range.rangeX[1]);
    if (dir === 'ml') {
      box.width = range.rangeX[1] - offsetX;
      box.height = box.width / aspectRatio;
      box.centerPoint = { x: range.rangeX[1] - box.width / 2, y: cropperBox.centerPoint.y };
    } else {
      box.width = offsetX - range.rangeX[0];
      box.height = box.width / aspectRatio;
      box.centerPoint = { x: range.rangeX[0] + box.width / 2, y: cropperBox.centerPoint.y };
    }
    return box;
  }

  const offsetY = clamp(pointer.y, range.rangeY[0], range.rangeY[1]);
  switch (dir) {
    case 'tl':
      box.height = range.rangeY[1] - offsetY;
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: range.rangeX[1] - box.width / 2, y: range.rangeY[1] - box.height / 2 };
      break;
    case 'tm':
      box.height = range.rangeY[1] - offsetY;
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: cropperBox.centerPoint.x, y: range.rangeY[1] - box.height / 2 };
      break;
    case 'tr':
      box.height = range.rangeY[1] - offsetY;
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: range.rangeX[0] + box.width / 2, y: range.rangeY[1] - box.height / 2 };
      break;
    case 'bl':
      box.height = offsetY - range.rangeY[0];
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: range.rangeX[1] - box.width / 2, y: range.rangeY[0] + box.height / 2 };
      break;
    case 'bm':
      box.height = offsetY - range.rangeY[0];
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: cropperBox.centerPoint.x, y: range.rangeY[0] + box.height / 2 };
      break;
    case 'br':
    default:
      box.height = offsetY - range.rangeY[0];
      box.width = box.height * aspectRatio;
      box.centerPoint = { x: range.rangeX[0] + box.width / 2, y: range.rangeY[0] + box.height / 2 };
      break;
  }
  return box;
}

/** 拖角调整过程中裁切框收缩到 0 时，方向需要翻转（tl<->br, tm<->bm 等），继续从对角方向拖拽。 */
export function flipCornerDir(dir: CropperCornerDir): CropperCornerDir {
  let next = dir as string;
  if (next.includes('t')) next = next.replace('t', 'b');
  else if (next.includes('b')) next = next.replace('b', 't');
  if (next.includes('l')) next = next.replace('l', 'r');
  else if (next.includes('r')) next = next.replace('r', 'l');
  return next as CropperCornerDir;
}

/** 平移裁切框：增量法 + 边界钳制，裁切框中心点不能移出容器（框本身不会被推出边界）。 */
export function moveCropperBox(cropperBox: CropperBoxState, delta: Point, container: Size): CropperBoxState {
  const xMin = cropperBox.width / 2;
  const xMax = container.width - cropperBox.width / 2;
  const yMin = cropperBox.height / 2;
  const yMax = container.height - cropperBox.height / 2;
  return {
    width: cropperBox.width,
    height: cropperBox.height,
    centerPoint: {
      x: clamp(cropperBox.centerPoint.x + delta.x, xMin, xMax),
      y: clamp(cropperBox.centerPoint.y + delta.y, yMin, yMax),
    },
  };
}

/** 平移图片：增量法，无边界钳制（允许图片被拖出裁切框之外，对齐 Semi 行为）。 */
export function moveImage(imgData: CropperImageState, delta: Point): CropperImageState {
  return {
    width: imgData.width,
    height: imgData.height,
    centerPoint: { x: imgData.centerPoint.x + delta.x, y: imgData.centerPoint.y + delta.y },
  };
}

export interface CropRegion {
  /** 旋转后外接矩形画布的宽高（原图真实像素，未缩放） */
  canvasSize: Size;
  /** 裁切区域相对该画布的位置与尺寸（真实像素，未钳制到画布边界） */
  cropLeft: number;
  cropTop: number;
  cropWidth: number;
  cropHeight: number;
  /** 裁切区域与画布是否存在交集；false 时应直接返回空白图（fill 色）画布 */
  intersects: boolean;
}

/** 计算导出裁切所需的原图坐标系裁切区域。屏幕坐标 -> 原图真实像素坐标的换算核心。
 * realZoom = zoom * imgMeta.scale 是屏幕像素与原图真实像素之间的总缩放系数。 */
export function computeCropRegion(
  imgData: CropperImageState,
  cropperBox: CropperBoxState,
  imgMeta: CropperImageMeta,
  zoom: number,
  rotate: number,
): CropRegion {
  const angle = (rotate * Math.PI) / 180;
  const sine = Math.abs(Math.sin(angle));
  const cosine = Math.abs(Math.cos(angle));
  const canvasWidth = imgMeta.originalWidth * cosine + imgMeta.originalHeight * sine;
  const canvasHeight = imgMeta.originalHeight * cosine + imgMeta.originalWidth * sine;

  const realZoom = zoom * imgMeta.scale;
  const containerWidth = canvasWidth * realZoom;
  const containerHeight = canvasHeight * realZoom;
  const containerTop = imgData.centerPoint.y - containerHeight / 2;
  const containerLeft = imgData.centerPoint.x - containerWidth / 2;

  const boxLeft = cropperBox.centerPoint.x - cropperBox.width / 2;
  const boxTop = cropperBox.centerPoint.y - cropperBox.height / 2;

  const cropLeft = (boxLeft - containerLeft) / realZoom;
  const cropTop = (boxTop - containerTop) / realZoom;
  const cropWidth = cropperBox.width / realZoom;
  const cropHeight = cropperBox.height / realZoom;
  const cropRight = cropLeft + cropWidth;
  const cropBottom = cropTop + cropHeight;

  const intersects = !(cropRight < 0 || cropBottom < 0 || cropLeft > canvasWidth || cropTop > canvasHeight);

  return {
    canvasSize: { width: canvasWidth, height: canvasHeight },
    cropLeft,
    cropTop,
    cropWidth,
    cropHeight,
    intersects,
  };
}

/** 把 computeCropRegion 算出的（可能越界的）裁切区域钳制到画布内，供 getImageData 使用。
 * 返回的 pasteX/pasteY 是钳制后结果贴回目标画布时的偏移（越界部分保持 fill 色）。 */
export function clampCropRegionToCanvas(region: CropRegion): {
  sourceX: number;
  sourceY: number;
  sourceWidth: number;
  sourceHeight: number;
  pasteX: number;
  pasteY: number;
} {
  const { canvasSize, cropLeft, cropTop, cropWidth, cropHeight } = region;
  const cropRight = cropLeft + cropWidth;
  const cropBottom = cropTop + cropHeight;

  const sourceX = cropLeft < 0 ? 0 : cropLeft;
  const sourceY = cropTop < 0 ? 0 : cropTop;

  let sourceWidth = cropWidth;
  if (cropRight > canvasSize.width) {
    sourceWidth = canvasSize.width - sourceX;
  } else if (cropLeft < 0) {
    sourceWidth = cropRight;
  }

  let sourceHeight = cropHeight;
  if (cropBottom > canvasSize.height) {
    sourceHeight = canvasSize.height - sourceY;
  } else if (cropTop < 0) {
    sourceHeight = cropBottom;
  }

  return {
    sourceX,
    sourceY,
    sourceWidth,
    sourceHeight,
    pasteX: cropLeft < 0 ? -cropLeft : 0,
    pasteY: cropTop < 0 ? -cropTop : 0,
  };
}
