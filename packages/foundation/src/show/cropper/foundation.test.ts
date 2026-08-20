import { describe, it, expect } from 'vitest';
import {
  fitAspect,
  computeInitialImageState,
  computeInitialCropperBox,
  resizeImageState,
  resizeCropperBox,
  zoomAtPoint,
  nextWheelZoom,
  moveParamByDir,
  resizeCornerFree,
  rangeForAspectResize,
  resizeCornerAspect,
  flipCornerDir,
  moveCropperBox,
  moveImage,
  computeCropRegion,
  clampCropRegionToCanvas,
  type CropperImageState,
  type CropperBoxState,
} from './foundation.js';

describe('fitAspect', () => {
  it('宽高比超过目标 aspect 时收缩宽度', () => {
    expect(fitAspect(200, 100, 1)).toEqual({ width: 100, height: 100 });
  });

  it('宽高比小于目标 aspect 时收缩高度', () => {
    expect(fitAspect(100, 200, 1)).toEqual({ width: 100, height: 100 });
  });

  it('恰好等于 aspect 时不变', () => {
    expect(fitAspect(200, 100, 2)).toEqual({ width: 200, height: 100 });
  });
});

describe('computeInitialImageState', () => {
  it('图片更宽（相对容器）时以宽度适配，居中', () => {
    const { imgData, meta } = computeInitialImageState(2000, 1000, { width: 400, height: 400 });
    expect(imgData.width).toBe(400);
    expect(imgData.height).toBe(200);
    expect(imgData.centerPoint).toEqual({ x: 200, y: 200 });
    expect(meta).toEqual({ originalWidth: 2000, originalHeight: 1000, scale: 0.2 });
  });

  it('图片更高（相对容器）时以高度适配', () => {
    const { imgData, meta } = computeInitialImageState(1000, 2000, { width: 400, height: 400 });
    expect(imgData.height).toBe(400);
    expect(imgData.width).toBe(200);
    expect(meta.scale).toBe(0.2);
  });
});

describe('computeInitialCropperBox', () => {
  it('容器更宽时裁切框高度贴满容器', () => {
    const box = computeInitialCropperBox({ width: 400, height: 200 }, 1);
    expect(box).toEqual({ width: 200, height: 200, centerPoint: { x: 200, y: 100 } });
  });

  it('容器更高时裁切框宽度贴满容器', () => {
    const box = computeInitialCropperBox({ width: 200, height: 400 }, 1);
    expect(box).toEqual({ width: 200, height: 200, centerPoint: { x: 100, y: 200 } });
  });
});

describe('resizeImageState / resizeCropperBox', () => {
  it('图片按比例整体缩放', () => {
    const imgData: CropperImageState = { width: 100, height: 50, centerPoint: { x: 200, y: 100 } };
    const resized = resizeImageState(imgData, 2);
    expect(resized).toEqual({ width: 200, height: 100, centerPoint: { x: 400, y: 200 } });
  });

  it('裁切框缩放后未越界时保持比例位置', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const resized = resizeCropperBox(box, 1.5, { width: 400, height: 400 });
    expect(resized.width).toBeCloseTo(150);
    expect(resized.height).toBeCloseTo(150);
  });

  it('无 aspect 锁定时越界仅钳制到边界，不改变宽高比之外的约束', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 380, y: 100 } };
    const resized = resizeCropperBox(box, 1, { width: 400, height: 400 });
    expect(resized.width).toBe(100);
    expect(resized.centerPoint.x + resized.width / 2).toBeLessThanOrEqual(400);
  });

  it('有 aspect 锁定时越界会同步收缩另一维保持比例', () => {
    const box: CropperBoxState = { width: 200, height: 200, centerPoint: { x: 380, y: 100 } };
    const resized = resizeCropperBox(box, 1, { width: 400, height: 400 }, 1);
    expect(resized.width / resized.height).toBeCloseTo(1);
  });
});

describe('zoomAtPoint', () => {
  it('以锚点缩放后该点在屏幕上位置不变', () => {
    const imgData: CropperImageState = { width: 200, height: 100, centerPoint: { x: 100, y: 100 } };
    const anchor = { x: 150, y: 100 };
    const zoomed = zoomAtPoint(imgData, 1, 2, anchor);
    expect(zoomed.width).toBe(400);
    expect(zoomed.height).toBe(200);
    // anchor 相对图片中心的比例在缩放前后应保持一致
    const before = (anchor.x - imgData.centerPoint.x) / imgData.width;
    const after = (anchor.x - zoomed.centerPoint.x) / zoomed.width;
    expect(after).toBeCloseTo(before);
  });

  it('zoom=1 缩放到 1（无变化）时中心点和尺寸都不变', () => {
    const imgData: CropperImageState = { width: 200, height: 100, centerPoint: { x: 100, y: 100 } };
    const zoomed = zoomAtPoint(imgData, 1, 1, { x: 50, y: 50 });
    expect(zoomed).toEqual(imgData);
  });
});

describe('nextWheelZoom', () => {
  it('向上滚动（deltaY<0）放大一档', () => {
    expect(nextWheelZoom(1, -100, 0.1, 0.1, 3)).toBeCloseTo(1.1);
  });

  it('向下滚动（deltaY>0）缩小一档', () => {
    expect(nextWheelZoom(1, 100, 0.1, 0.1, 3)).toBeCloseTo(0.9);
  });

  it('已达 maxZoom 时继续放大返回 null', () => {
    expect(nextWheelZoom(3, -100, 0.1, 0.1, 3)).toBeNull();
  });

  it('已达 minZoom 时继续缩小返回 null', () => {
    expect(nextWheelZoom(0.1, 100, 0.1, 0.1, 3)).toBeNull();
  });

  it('deltaY=0 时不变化', () => {
    expect(nextWheelZoom(1, 0, 0.1, 0.1, 3)).toBeNull();
  });
});

describe('moveParamByDir', () => {
  it('8 个方向映射为正确的符号系数', () => {
    expect(moveParamByDir('tl')).toEqual({ paramX: -1, paramY: -1 });
    expect(moveParamByDir('tm')).toEqual({ paramX: 0, paramY: -1 });
    expect(moveParamByDir('tr')).toEqual({ paramX: 1, paramY: -1 });
    expect(moveParamByDir('ml')).toEqual({ paramX: -1, paramY: 0 });
    expect(moveParamByDir('mr')).toEqual({ paramX: 1, paramY: 0 });
    expect(moveParamByDir('bl')).toEqual({ paramX: -1, paramY: 1 });
    expect(moveParamByDir('bm')).toEqual({ paramX: 0, paramY: 1 });
    expect(moveParamByDir('br')).toEqual({ paramX: 1, paramY: 1 });
  });
});

describe('resizeCornerFree', () => {
  it('br 方向拖拽增大裁切框，左上角固定', () => {
    // box: 中心(100,100)，边长100 -> 左上角(50,50)，右下角(150,150)
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const param = moveParamByDir('br');
    const { box: next } = resizeCornerFree(box, param, { x: 200, y: 200 });
    // 右下角从(150,150)拖到(200,200)，新宽高=150
    expect(next.width).toBe(150);
    expect(next.height).toBe(150);
    // 左上角 (50,50) 固定
    expect(next.centerPoint.x - next.width / 2).toBeCloseTo(50);
    expect(next.centerPoint.y - next.height / 2).toBeCloseTo(50);
  });

  it('拖过对角线时宽度翻转为正值，且 param 符号翻转', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const param = moveParamByDir('br');
    // 拖到左上角固定点(50,50)以内，越过对角线
    const { box: next, param: nextParam } = resizeCornerFree(box, param, { x: 0, y: 0 });
    expect(next.width).toBeGreaterThan(0);
    expect(next.height).toBeGreaterThan(0);
    expect(nextParam.paramX).toBe(-1);
    expect(nextParam.paramY).toBe(-1);
  });

  it('tm 方向（paramX=0）不改变宽度和 x 中心', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const param = moveParamByDir('tm');
    const { box: next } = resizeCornerFree(box, param, { x: 999, y: 20 });
    expect(next.width).toBe(100);
    expect(next.centerPoint.x).toBe(100);
  });
});

describe('flipCornerDir', () => {
  it('对角互换：tl<->br, tr<->bl', () => {
    expect(flipCornerDir('tl')).toBe('br');
    expect(flipCornerDir('br')).toBe('tl');
    expect(flipCornerDir('tr')).toBe('bl');
    expect(flipCornerDir('bl')).toBe('tr');
  });

  it('边中点互换：tm<->bm, ml<->mr', () => {
    expect(flipCornerDir('tm')).toBe('bm');
    expect(flipCornerDir('bm')).toBe('tm');
    expect(flipCornerDir('ml')).toBe('mr');
    expect(flipCornerDir('mr')).toBe('ml');
  });
});

describe('rangeForAspectResize + resizeCornerAspect', () => {
  const container = { width: 400, height: 400 };

  it('br 方向锁定 aspect=1 时，range 受容器边界约束', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const range = rangeForAspectResize(box, container, 1, 'br');
    expect(range.rangeX[0]).toBeCloseTo(50);
    expect(range.rangeY[0]).toBeCloseTo(50);
    const next = resizeCornerAspect(box, 'br', 1, range, { x: 300, y: 300 });
    expect(next.width / next.height).toBeCloseTo(1);
    // 左上角固定
    expect(next.centerPoint.x - next.width / 2).toBeCloseTo(50);
    expect(next.centerPoint.y - next.height / 2).toBeCloseTo(50);
  });

  it('拖拽超出 range 上限时结果被钳制，不会超出容器', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 100, y: 100 } };
    const range = rangeForAspectResize(box, container, 1, 'br');
    const next = resizeCornerAspect(box, 'br', 1, range, { x: 9999, y: 9999 });
    expect(next.centerPoint.x + next.width / 2).toBeLessThanOrEqual(container.width + 1e-6);
    expect(next.centerPoint.y + next.height / 2).toBeLessThanOrEqual(container.height + 1e-6);
  });

  it('ml/mr 方向只用 rangeX（水平自由变量）', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 200, y: 200 } };
    const range = rangeForAspectResize(box, container, 1, 'mr');
    const next = resizeCornerAspect(box, 'mr', 1, range, { x: 300, y: 9999 });
    expect(next.centerPoint.y).toBe(200);
    expect(next.width / next.height).toBeCloseTo(1);
  });
});

describe('moveCropperBox', () => {
  it('平移在边界内时按增量移动', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 200, y: 200 } };
    const next = moveCropperBox(box, { x: 10, y: -10 }, { width: 400, height: 400 });
    expect(next.centerPoint).toEqual({ x: 210, y: 190 });
  });

  it('平移超出边界时钳制，裁切框不会被推出容器', () => {
    const box: CropperBoxState = { width: 100, height: 100, centerPoint: { x: 200, y: 200 } };
    const next = moveCropperBox(box, { x: 1000, y: 1000 }, { width: 400, height: 400 });
    expect(next.centerPoint.x + next.width / 2).toBeLessThanOrEqual(400);
    expect(next.centerPoint.y + next.height / 2).toBeLessThanOrEqual(400);
  });

  it('宽高不变，仅中心点变化', () => {
    const box: CropperBoxState = { width: 120, height: 80, centerPoint: { x: 200, y: 200 } };
    const next = moveCropperBox(box, { x: 5, y: 5 }, { width: 400, height: 400 });
    expect(next.width).toBe(120);
    expect(next.height).toBe(80);
  });
});

describe('moveImage', () => {
  it('无边界钳制，允许拖出容器', () => {
    const imgData: CropperImageState = { width: 100, height: 100, centerPoint: { x: 50, y: 50 } };
    const next = moveImage(imgData, { x: -1000, y: -1000 });
    expect(next.centerPoint).toEqual({ x: -950, y: -950 });
  });
});

describe('computeCropRegion + clampCropRegionToCanvas', () => {
  it('rotate=0、zoom=1 时裁切框与图片完全重合，裁切区域等于原图整体', () => {
    const imgMeta = { originalWidth: 200, originalHeight: 200, scale: 1 };
    const imgData: CropperImageState = { width: 200, height: 200, centerPoint: { x: 100, y: 100 } };
    const box: CropperBoxState = { width: 200, height: 200, centerPoint: { x: 100, y: 100 } };
    const region = computeCropRegion(imgData, box, imgMeta, 1, 0);
    expect(region.intersects).toBe(true);
    expect(region.cropLeft).toBeCloseTo(0);
    expect(region.cropTop).toBeCloseTo(0);
    expect(region.cropWidth).toBeCloseTo(200);
    expect(region.cropHeight).toBeCloseTo(200);
  });

  it('裁切框完全在图片区域内时是子区域', () => {
    const imgMeta = { originalWidth: 200, originalHeight: 200, scale: 1 };
    const imgData: CropperImageState = { width: 200, height: 200, centerPoint: { x: 100, y: 100 } };
    const box: CropperBoxState = { width: 50, height: 50, centerPoint: { x: 100, y: 100 } };
    const region = computeCropRegion(imgData, box, imgMeta, 1, 0);
    expect(region.cropLeft).toBeCloseTo(75);
    expect(region.cropTop).toBeCloseTo(75);
    expect(region.cropWidth).toBeCloseTo(50);
    expect(region.cropHeight).toBeCloseTo(50);
  });

  it('裁切框完全移出图片范围时 intersects=false', () => {
    const imgMeta = { originalWidth: 200, originalHeight: 200, scale: 1 };
    const imgData: CropperImageState = { width: 200, height: 200, centerPoint: { x: 100, y: 100 } };
    const box: CropperBoxState = { width: 50, height: 50, centerPoint: { x: 1000, y: 1000 } };
    const region = computeCropRegion(imgData, box, imgMeta, 1, 0);
    expect(region.intersects).toBe(false);
  });

  it('zoom 放大时裁切区域按 realZoom 缩小换算到原图坐标', () => {
    const imgMeta = { originalWidth: 200, originalHeight: 200, scale: 1 };
    const imgData: CropperImageState = { width: 400, height: 400, centerPoint: { x: 100, y: 100 } };
    const box: CropperBoxState = { width: 50, height: 50, centerPoint: { x: 100, y: 100 } };
    const region = computeCropRegion(imgData, box, imgMeta, 2, 0);
    // realZoom=2, 裁切框 50px 屏幕像素对应原图 25px
    expect(region.cropWidth).toBeCloseTo(25);
    expect(region.cropHeight).toBeCloseTo(25);
  });

  it('rotate=90 时外接矩形画布宽高互换', () => {
    const imgMeta = { originalWidth: 200, originalHeight: 100, scale: 1 };
    const imgData: CropperImageState = { width: 200, height: 100, centerPoint: { x: 100, y: 50 } };
    const box: CropperBoxState = { width: 50, height: 50, centerPoint: { x: 100, y: 50 } };
    const region = computeCropRegion(imgData, box, imgMeta, 1, 90);
    expect(region.canvasSize.width).toBeCloseTo(100);
    expect(region.canvasSize.height).toBeCloseTo(200);
  });

  it('clampCropRegionToCanvas 在完全越界的负坐标区域正确计算 paste 偏移', () => {
    const region = {
      canvasSize: { width: 200, height: 200 },
      cropLeft: -20,
      cropTop: -20,
      cropWidth: 50,
      cropHeight: 50,
      intersects: true,
    };
    const clamped = clampCropRegionToCanvas(region);
    expect(clamped.sourceX).toBe(0);
    expect(clamped.sourceY).toBe(0);
    expect(clamped.pasteX).toBe(20);
    expect(clamped.pasteY).toBe(20);
    expect(clamped.sourceWidth).toBeCloseTo(30);
    expect(clamped.sourceHeight).toBeCloseTo(30);
  });

  it('clampCropRegionToCanvas 在完全越界画布右下方时不产生负尺寸', () => {
    const region = {
      canvasSize: { width: 100, height: 100 },
      cropLeft: 80,
      cropTop: 80,
      cropWidth: 50,
      cropHeight: 50,
      intersects: true,
    };
    const clamped = clampCropRegionToCanvas(region);
    expect(clamped.sourceX).toBe(80);
    expect(clamped.sourceWidth).toBeCloseTo(20);
    expect(clamped.sourceHeight).toBeCloseTo(20);
    expect(clamped.pasteX).toBe(0);
    expect(clamped.pasteY).toBe(0);
  });

  it('未越界（完全在画布内）时 source 等于原始区域，paste 为 0', () => {
    const region = {
      canvasSize: { width: 200, height: 200 },
      cropLeft: 50,
      cropTop: 50,
      cropWidth: 50,
      cropHeight: 50,
      intersects: true,
    };
    const clamped = clampCropRegionToCanvas(region);
    expect(clamped.sourceX).toBe(50);
    expect(clamped.sourceY).toBe(50);
    expect(clamped.sourceWidth).toBe(50);
    expect(clamped.sourceHeight).toBe(50);
    expect(clamped.pasteX).toBe(0);
    expect(clamped.pasteY).toBe(0);
  });
});
