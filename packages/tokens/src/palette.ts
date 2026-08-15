import { generateScale, toDarkModeVariant } from './color.js';

/**
 * 七个语义色相的品牌色输入。数值参照 `~/i/semi-design/DESIGN.md` 的 Light 模式基准值
 * （AGENTS.md 明确该文档为色彩数值的一手参照来源）。Info 与 Primary 同色相（Semi 的约定，
 * 语义上"信息提示"与"主操作"共用蓝色系但作为独立语义变量存在，便于未来独立调整）。
 */
export interface BrandInput {
  primary: string;
  secondary: string;
  tertiary: string;
  success: string;
  warning: string;
  danger: string;
  info: string;
}

export const DEFAULT_BRAND: BrandInput = {
  primary: '#0064FA',
  secondary: '#0095EE',
  tertiary: '#6B7075',
  success: '#3BB346',
  warning: '#FC8800',
  danger: '#F93920',
  info: '#0064FA',
};

export type Hue = keyof BrandInput;

export interface PaletteResult {
  light: Record<Hue, string[]>;
  dark: Record<Hue, string[]>;
}

export function buildPalette(brand: BrandInput = DEFAULT_BRAND): PaletteResult {
  const light = {} as Record<Hue, string[]>;
  const dark = {} as Record<Hue, string[]>;

  for (const hue of Object.keys(brand) as Hue[]) {
    const lightScale = generateScale(brand[hue]);
    light[hue] = lightScale;
    dark[hue] = lightScale.map(toDarkModeVariant);
  }

  return { light, dark };
}
