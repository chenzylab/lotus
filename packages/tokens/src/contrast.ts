import { hexToRgb } from './color.js';

/** WCAG 相对亮度计算（sRGB 分量做 gamma 校正后加权求和）。 */
function relativeLuminance(hex: string): number {
  const { r, g, b } = hexToRgb(hex);
  const [rs, gs, bs] = [r, g, b].map((c) => {
    const channel = c / 255;
    return channel <= 0.03928 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4);
  }) as [number, number, number];
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

/**
 * 计算两个十六进制颜色的 WCAG 对比度比值（1-21）。仅支持不含 alpha 通道的 hex 输入；
 * 半透明色（rgba）需要先与实际背景做 alpha 合成得到等效 hex 再传入，本函数不做合成。
 */
export function contrastRatio(hexA: string, hexB: string): number {
  const lA = relativeLuminance(hexA);
  const lB = relativeLuminance(hexB);
  const [lighter, darker] = lA > lB ? [lA, lB] : [lB, lA];
  return (lighter + 0.05) / (darker + 0.05);
}

export const WCAG_AA_NORMAL_TEXT = 4.5;
export const WCAG_AA_LARGE_TEXT = 3.0;
export const WCAG_AA_UI_COMPONENT = 3.0;
