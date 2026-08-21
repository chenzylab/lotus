/**
 * 颜色空间转换纯函数，移植自 Semi semi-foundation/colorPicker/convert.ts 的算法
 * （对齐参考实现 chenzy.design 的颜色转换工具）。刻度约定：HsvaColor 的 h 是
 * 0-360，s/v 是 0-100（Semi 原生刻度，非 0-1），a 是 0-1；RgbaColor 的 r/g/b
 * 是 0-255，a 是 0-1。
 */

export interface HsvaColor {
  h: number;
  s: number;
  v: number;
  a: number;
}

export interface RgbaColor {
  r: number;
  g: number;
  b: number;
  a: number;
}

export interface HslaColor {
  h: number;
  s: number;
  l: number;
  a: number;
}

export interface ColorValue {
  hsva: HsvaColor;
  rgba: RgbaColor;
  hex: string;
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function round(value: number): number {
  return Math.round(value);
}

/** RGBA → HSVA（六区间查表法）。 */
export function rgbaToHsva(rgba: RgbaColor): HsvaColor {
  const r = rgba.r / 255;
  const g = rgba.g / 255;
  const b = rgba.b / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const delta = max - min;

  let h = 0;
  if (delta !== 0) {
    if (max === r) h = ((g - b) / delta) % 6;
    else if (max === g) h = (b - r) / delta + 2;
    else h = (r - g) / delta + 4;
    h *= 60;
    if (h < 0) h += 360;
  }

  const s = max === 0 ? 0 : delta / max;
  const v = max;

  return { h: round(h), s: round(s * 100), v: round(v * 100), a: rgba.a };
}

/** HSVA → RGBA（六区间查表法）。 */
export function hsvaToRgba(hsva: HsvaColor): RgbaColor {
  const h = ((hsva.h % 360) + 360) % 360;
  const s = clamp(hsva.s, 0, 100) / 100;
  const v = clamp(hsva.v, 0, 100) / 100;

  const c = v * s;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = v - c;

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
    r: round((r + m) * 255),
    g: round((g + m) * 255),
    b: round((b + m) * 255),
    a: hsva.a,
  };
}

function toHex2(n: number): string {
  return clamp(round(n), 0, 255).toString(16).padStart(2, '0');
}

/** RGBA → 十六进制字符串。a<1 时输出 8 位（含 alpha），否则输出 6 位。 */
export function rgbaToHex(rgba: RgbaColor): string {
  const base = `#${toHex2(rgba.r)}${toHex2(rgba.g)}${toHex2(rgba.b)}`;
  if (rgba.a >= 1) return base;
  return `${base}${toHex2(rgba.a * 255)}`;
}

/** 十六进制字符串 → RGBA。支持 #rgb / #rgba / #rrggbb / #rrggbbaa，非法输入返回 null。 */
export function hexToRgba(hex: string): RgbaColor | null {
  const raw = hex.trim().replace(/^#/, '');
  if (!/^[0-9a-fA-F]+$/.test(raw)) return null;

  if (raw.length === 3 || raw.length === 4) {
    const r = parseInt(raw[0]! + raw[0], 16);
    const g = parseInt(raw[1]! + raw[1], 16);
    const b = parseInt(raw[2]! + raw[2], 16);
    const a = raw.length === 4 ? parseInt(raw[3]! + raw[3], 16) / 255 : 1;
    return { r, g, b, a };
  }

  if (raw.length === 6 || raw.length === 8) {
    const r = parseInt(raw.slice(0, 2), 16);
    const g = parseInt(raw.slice(2, 4), 16);
    const b = parseInt(raw.slice(4, 6), 16);
    const a = raw.length === 8 ? parseInt(raw.slice(6, 8), 16) / 255 : 1;
    return { r, g, b, a };
  }

  return null;
}

/** HSVA → HSLA。 */
export function hsvaToHsla(hsva: HsvaColor): HslaColor {
  const s = hsva.s / 100;
  const v = hsva.v / 100;
  const l = v * (1 - s / 2);
  const sl = l === 0 || l === 1 ? 0 : (v - l) / Math.min(l, 1 - l);
  return { h: hsva.h, s: round(sl * 100), l: round(l * 100), a: hsva.a };
}

/** HSLA → HSVA。 */
export function hslaToHsva(hsla: HslaColor): HsvaColor {
  const s = hsla.s / 100;
  const l = hsla.l / 100;
  const v = l + s * Math.min(l, 1 - l);
  const sv = v === 0 ? 0 : 2 * (1 - l / v);
  return { h: hsla.h, s: round(sv * 100), v: round(v * 100), a: hsla.a };
}

/** 由任意一路颜色重新合成完整的三态 ColorValue。 */
export function fromHsva(hsva: HsvaColor): ColorValue {
  const rgba = hsvaToRgba(hsva);
  return { hsva, rgba, hex: rgbaToHex(rgba) };
}

export function fromRgba(rgba: RgbaColor): ColorValue {
  const hsva = rgbaToHsva(rgba);
  return { hsva, rgba, hex: rgbaToHex(rgba) };
}

/** 十六进制字符串 → 完整 ColorValue，非法输入返回 null。 */
export function fromHex(hex: string): ColorValue | null {
  const rgba = hexToRgba(hex);
  if (!rgba) return null;
  return fromRgba(rgba);
}
