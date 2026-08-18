export type ProgressType = 'line' | 'circle';
export type ProgressDirection = 'horizontal' | 'vertical';
export type ProgressSize = 'default' | 'small' | 'large';
export type ProgressStrokeLinecap = 'round' | 'square';

export interface ProgressStrokeStop {
  percent: number;
  color: string;
}

/** 百分比 clamp 到 [0, 100]，负数/超界值/非数字均归一化。 */
export function clampPercent(percent: number): number {
  if (Number.isNaN(percent)) return 0;
  if (percent > 100) return 100;
  if (percent < 0) return 0;
  return percent;
}

/** 环形进度的 SVG 几何参数：半径、周长、描边偏移量。 */
export interface CircleGeometry {
  radius: number;
  circumference: number;
  strokeDashoffset: number;
  strokeDasharray: string;
}

export function calcCircleGeometry(width: number, strokeWidth: number, percent: number): CircleGeometry {
  const radius = (width - strokeWidth) / 2;
  const circumference = radius * 2 * Math.PI;
  const strokeDashoffset = (1 - clampPercent(percent) / 100) * circumference;
  return {
    radius,
    circumference,
    strokeDashoffset,
    strokeDasharray: `${circumference} ${circumference}`,
  };
}

/**
 * 多段渐变描边色：`stops` 是按 percent 升序/乱序均可的断点数组（内部会排序），
 * 在 percent 落入的两个断点之间做 RGB 线性插值。`gradient=false` 时不插值，
 * 直接取区间下界颜色（硬切换），对齐 Semi `generates.ts` 的算法结构。
 *
 * 仅支持标准 hex/rgb(a)/hsl(a) 颜色格式——Semi 原版还支持形如 'blue'/'red-5' 的
 * 调色板 token 语法糖，那是 Semi 专属调色板系统的引用方式，lotus 没有对应概念，
 * 属于要改写而非照搬的品牌痕迹，故不移植。
 */
export function resolveGradientStroke(stops: ProgressStrokeStop[], percent: number, gradient: boolean): string | undefined {
  if (stops.length === 0) return undefined;
  const sorted = [...stops].sort((a, b) => a.percent - b.percent);
  const clamped = clampPercent(percent);

  if (clamped <= sorted[0]!.percent) return normalizeColor(sorted[0]!.color);
  const last = sorted[sorted.length - 1]!;
  if (clamped >= last.percent) return normalizeColor(last.color);

  for (let i = 0; i < sorted.length; i++) {
    const stop = sorted[i]!;
    if (stop.percent === clamped) return normalizeColor(stop.color);
    if (clamped < stop.percent) {
      const prev = sorted[i - 1]!;
      if (!gradient) return normalizeColor(prev.color);
      const span = stop.percent - prev.percent;
      const ratio = span === 0 ? 0 : (clamped - prev.percent) / span;
      return interpolateColor(normalizeColor(prev.color), normalizeColor(stop.color), ratio);
    }
  }
  return normalizeColor(last.color);
}

const HEX_RE = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/;
const RGB_RE = /rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)/;
const HSL_RE = /hsla?\(\s*(\d+)\s*,\s*(\d+)%\s*,\s*(\d+)%\s*(?:,\s*([\d.]+)\s*)?\)/;

interface RgbColor {
  r: number;
  g: number;
  b: number;
  a: number;
}

function normalizeColor(color: string): string {
  return color.trim();
}

function parseColor(color: string): RgbColor {
  const hexMatch = HEX_RE.exec(color);
  if (hexMatch) {
    const hex = hexMatch[1]!;
    const full = hex.length === 3 ? hex.split('').map((c) => c + c).join('') : hex;
    return {
      r: parseInt(full.slice(0, 2), 16),
      g: parseInt(full.slice(2, 4), 16),
      b: parseInt(full.slice(4, 6), 16),
      a: 1,
    };
  }
  const rgbMatch = RGB_RE.exec(color);
  if (rgbMatch) {
    return {
      r: parseInt(rgbMatch[1]!, 10),
      g: parseInt(rgbMatch[2]!, 10),
      b: parseInt(rgbMatch[3]!, 10),
      a: rgbMatch[4] !== undefined ? parseFloat(rgbMatch[4]) : 1,
    };
  }
  const hslMatch = HSL_RE.exec(color);
  if (hslMatch) {
    const { r, g, b } = hslToRgb(parseInt(hslMatch[1]!, 10), parseInt(hslMatch[2]!, 10), parseInt(hslMatch[3]!, 10));
    return { r, g, b, a: hslMatch[4] !== undefined ? parseFloat(hslMatch[4]) : 1 };
  }
  // 未识别的格式（例如 CSS 具名色 'red'）：原样透传，插值时退化为直接返回该颜色本身。
  return { r: 0, g: 0, b: 0, a: -1 };
}

function hslToRgb(h: number, s: number, l: number): { r: number; g: number; b: number } {
  const sNorm = s / 100;
  const lNorm = l / 100;
  const c = (1 - Math.abs(2 * lNorm - 1)) * sNorm;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = lNorm - c / 2;
  let r = 0;
  let g = 0;
  let b = 0;
  if (h < 60) [r, g, b] = [c, x, 0];
  else if (h < 120) [r, g, b] = [x, c, 0];
  else if (h < 180) [r, g, b] = [0, c, x];
  else if (h < 240) [r, g, b] = [0, x, c];
  else if (h < 300) [r, g, b] = [x, 0, c];
  else [r, g, b] = [c, 0, x];
  return {
    r: Math.round((r + m) * 255),
    g: Math.round((g + m) * 255),
    b: Math.round((b + m) * 255),
  };
}

function interpolateColor(from: string, to: string, ratio: number): string {
  const a = parseColor(from);
  const b = parseColor(to);
  if (a.a === -1 || b.a === -1) return ratio < 0.5 ? from : to;
  const r = Math.round(a.r + (b.r - a.r) * ratio);
  const g = Math.round(a.g + (b.g - a.g) * ratio);
  const bl = Math.round(a.b + (b.b - a.b) * ratio);
  const alpha = a.a + (b.a - a.a) * ratio;
  return alpha < 1 ? `rgba(${r}, ${g}, ${bl}, ${alpha.toFixed(3)})` : `rgb(${r}, ${g}, ${bl})`;
}
