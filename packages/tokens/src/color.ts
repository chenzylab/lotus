export interface HSB {
  h: number;
  s: number;
  b: number;
}

export interface RGB {
  r: number;
  g: number;
  b: number;
}

export function hexToRgb(hex: string): RGB {
  const normalized = hex.replace('#', '');
  const value =
    normalized.length === 3
      ? normalized
          .split('')
          .map((c) => c + c)
          .join('')
      : normalized;
  const num = parseInt(value, 16);
  return {
    r: (num >> 16) & 255,
    g: (num >> 8) & 255,
    b: num & 255,
  };
}

export function rgbToHsb({ r, g, b }: RGB): HSB {
  const rf = r / 255;
  const gf = g / 255;
  const bf = b / 255;
  const max = Math.max(rf, gf, bf);
  const min = Math.min(rf, gf, bf);
  const delta = max - min;

  let h = 0;
  if (delta !== 0) {
    if (max === rf) h = ((gf - bf) / delta) % 6;
    else if (max === gf) h = (bf - rf) / delta + 2;
    else h = (rf - gf) / delta + 4;
    h *= 60;
    if (h < 0) h += 360;
  }

  const s = max === 0 ? 0 : delta / max;
  const brightness = max;

  return { h, s: s * 100, b: brightness * 100 };
}

export function hsbToRgb({ h, s, b }: HSB): RGB {
  const sf = s / 100;
  const bf = b / 100;
  const c = bf * sf;
  const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
  const m = bf - c;

  let rp = 0;
  let gp = 0;
  let bp = 0;

  if (h < 60) [rp, gp, bp] = [c, x, 0];
  else if (h < 120) [rp, gp, bp] = [x, c, 0];
  else if (h < 180) [rp, gp, bp] = [0, c, x];
  else if (h < 240) [rp, gp, bp] = [0, x, c];
  else if (h < 300) [rp, gp, bp] = [x, 0, c];
  else [rp, gp, bp] = [c, 0, x];

  return {
    r: Math.round((rp + m) * 255),
    g: Math.round((gp + m) * 255),
    b: Math.round((bp + m) * 255),
  };
}

export function rgbToHex({ r, g, b }: RGB): string {
  const toHex = (v: number) => Math.max(0, Math.min(255, v)).toString(16).padStart(2, '0');
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

/**
 * 从品牌色生成 0-9 十级色阶。
 * 简化版算法（非 Semi 的 Peak-Chroma 精细模型）：以品牌色为第 5 级锚点，
 * 向亮端（0-4）线性提升明度、降低饱和度，向暗端（6-9）线性降低明度、
 * 略微提升饱和度，模拟"越浅越淡、越深越浓"的直觉色阶观感。
 */
export function generateScale(brandHex: string): string[] {
  const base = rgbToHsb(hexToRgb(brandHex));
  const steps: string[] = [];

  for (let i = 0; i <= 9; i++) {
    const t = (i - 5) / 5; // -1 (最浅) .. 0 (品牌色) .. 0.8 (最深)
    let s: number;
    let b: number;

    if (t < 0) {
      // 更浅：明度升高、饱和度降低
      s = base.s * (1 + t * 0.85);
      b = base.b + (100 - base.b) * -t * 0.9;
    } else {
      // 更深：明度降低、饱和度略升
      s = Math.min(100, base.s * (1 + t * 0.2));
      b = base.b * (1 - t * 0.55);
    }

    steps.push(rgbToHex(hsbToRgb({ h: base.h, s: clamp(s, 0, 100), b: clamp(b, 0, 100) })));
  }

  return steps;
}

/**
 * 暗色模式变换：降饱和度、提明度，避免高饱和色在深色背景造成视觉疲劳。
 */
export function toDarkModeVariant(hex: string): string {
  const hsb = rgbToHsb(hexToRgb(hex));
  return rgbToHex(
    hsbToRgb({
      h: hsb.h,
      s: clamp(hsb.s * 0.82, 0, 100),
      b: clamp(hsb.b * 1.12 + 8, 0, 100),
    }),
  );
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}
