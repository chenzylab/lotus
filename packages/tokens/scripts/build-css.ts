import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildPalette, DEFAULT_BRAND, type Hue } from '../dist/palette.js';
import {
  bg,
  fill,
  text,
  border,
  shadowBorder,
  overlayBg,
  focusBorder,
  disabled,
  link,
  highlight,
  elevation,
  radius,
  spacing,
  controlHeight,
  borderWidth,
  zIndex,
  fontFamily,
  fontWeight,
  typography,
  iconSize,
  aiColor,
  tagDecorativeColor,
  type ModeValue,
} from '../dist/static-tokens.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const outFile = resolve(__dirname, '../dist/tokens.css');

function paletteLines(scale: Record<Hue, string[]>): string[] {
  const lines: string[] = [];
  for (const hue of Object.keys(scale) as Hue[]) {
    scale[hue].forEach((hex, i) => {
      lines.push(`  --lotus-palette-${hue}-${i}: ${hex};`);
    });
  }
  return lines;
}

/**
 * 语义色完整状态集：default/hover/active/disabled（取色阶第 5/4/6/2 级）
 * + 浅版三态 light-default/light-hover/light-active，用于按钮/标签的浅色背景场景。
 *
 * 亮色模式：浅版直接取色阶最浅端（第 0/1/2 级），与 Semi 源码一致。
 * 暗色模式：Semi 源码用同一基准色叠加渐增的 alpha（.2/.3/.4）而非取色阶，
 * 因为暗色背景下取浅端色阶会导致对比度不足，改用半透明叠加更符合暗色场景的视觉层次。
 */
function semanticLines(scale: Record<Hue, string[]>, mode: 'light' | 'dark'): string[] {
  const lines: string[] = [];
  for (const hue of Object.keys(scale) as Hue[]) {
    const s = scale[hue];
    lines.push(`  --lotus-color-${hue}: ${s[5]};`);
    lines.push(`  --lotus-color-${hue}-hover: ${s[4]};`);
    lines.push(`  --lotus-color-${hue}-active: ${s[6]};`);
    lines.push(`  --lotus-color-${hue}-disabled: ${s[2]};`);

    if (mode === 'light') {
      lines.push(`  --lotus-color-${hue}-light-default: ${s[0]};`);
      lines.push(`  --lotus-color-${hue}-light-hover: ${s[1]};`);
      lines.push(`  --lotus-color-${hue}-light-active: ${s[2]};`);
    } else {
      const base = hexToRgbTriplet(s[5]!);
      lines.push(`  --lotus-color-${hue}-light-default: rgba(${base}, 0.2);`);
      lines.push(`  --lotus-color-${hue}-light-hover: rgba(${base}, 0.3);`);
      lines.push(`  --lotus-color-${hue}-light-active: rgba(${base}, 0.4);`);
    }
  }
  return lines;
}

function hexToRgbTriplet(hex: string): string {
  const n = parseInt(hex.replace('#', ''), 16);
  return `${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}`;
}

function modeValue(name: string, v: ModeValue, mode: 'light' | 'dark'): string {
  return `  --lotus-${name}: ${mode === 'light' ? v.light : v.dark};`;
}

function surfaceLines(mode: 'light' | 'dark'): string[] {
  return [
    modeValue('color-bg-0', bg.bg0, mode),
    modeValue('color-bg-1', bg.bg1, mode),
    modeValue('color-bg-2', bg.bg2, mode),
    modeValue('color-bg-3', bg.bg3, mode),
    modeValue('color-bg-4', bg.bg4, mode),
    modeValue('color-fill-0', fill.fill0, mode),
    modeValue('color-fill-1', fill.fill1, mode),
    modeValue('color-fill-2', fill.fill2, mode),
    modeValue('color-text-0', text.text0, mode),
    modeValue('color-text-1', text.text1, mode),
    modeValue('color-text-2', text.text2, mode),
    modeValue('color-text-3', text.text3, mode),
    modeValue('color-border', border, mode),
    modeValue('color-shadow-border', shadowBorder, mode),
    modeValue('color-overlay-bg', overlayBg, mode),
    modeValue('color-focus-border', focusBorder, mode),
    modeValue('color-disabled-bg', disabled.bg, mode),
    modeValue('color-disabled-text', disabled.text, mode),
    modeValue('color-disabled-border', disabled.border, mode),
    modeValue('color-disabled-fill', disabled.fill, mode),
    modeValue('color-link', link.default, mode),
    modeValue('color-link-hover', link.hover, mode),
    modeValue('color-link-active', link.active, mode),
    modeValue('color-link-visited', link.visited, mode),
    modeValue('color-highlight-bg', highlight.bg, mode),
    modeValue('color-highlight', highlight.text, mode),
    modeValue('shadow-elevated', elevation, mode),
  ];
}

function staticLines(): string[] {
  const lines: string[] = [];
  for (const [key, value] of Object.entries(radius)) {
    lines.push(`  --lotus-border-radius-${kebab(key)}: ${value};`);
  }
  for (const [key, value] of Object.entries(spacing)) {
    lines.push(`  --lotus-spacing-${kebab(key)}: ${value};`);
  }
  for (const [key, value] of Object.entries(controlHeight)) {
    lines.push(`  --lotus-height-control-${kebab(key)}: ${value};`);
  }
  for (const [key, value] of Object.entries(borderWidth)) {
    lines.push(`  --lotus-border-width-${kebab(key)}: ${value};`);
  }
  for (const [key, value] of Object.entries(zIndex)) {
    lines.push(`  --lotus-z-${kebab(key)}: ${value};`);
  }
  for (const [key, value] of Object.entries(iconSize)) {
    lines.push(`  --lotus-icon-size-${kebab(key)}: ${value};`);
  }
  lines.push(`  --lotus-font-family: ${fontFamily};`);
  for (const [key, value] of Object.entries(fontWeight)) {
    lines.push(`  --lotus-font-weight-${kebab(key)}: ${value};`);
  }
  for (const [key, scale] of Object.entries(typography)) {
    lines.push(`  --lotus-font-${key}-size: ${scale.fontSize};`);
    lines.push(`  --lotus-font-${key}-line-height: ${scale.lineHeight};`);
    lines.push(`  --lotus-font-${key}-weight: ${scale.fontWeight};`);
  }
  return lines;
}

function aiLines(mode: 'light' | 'dark'): string[] {
  const purple = mode === 'light' ? aiColor.purpleLight : aiColor.purpleDark;
  const bgTop = mode === 'light' ? aiColor.backgroundTopLight : aiColor.backgroundTopDark;
  const bgBottom = mode === 'light' ? aiColor.backgroundBottomLight : aiColor.backgroundBottomDark;
  return [
    `  --lotus-color-ai-general: ${aiColor.general};`,
    `  --lotus-color-ai-purple: ${purple};`,
    `  --lotus-color-ai-purple-hover: ${withAlpha(purple, 0.85)};`,
    `  --lotus-color-ai-purple-active: ${withAlpha(purple, 0.7)};`,
    `  --lotus-color-ai-purple-disabled: ${withAlpha(purple, 0.35)};`,
    `  --lotus-color-ai-background-top: ${bgTop};`,
    `  --lotus-color-ai-background-top-hover: ${bgTop};`,
    `  --lotus-color-ai-background-top-active: ${bgTop};`,
    `  --lotus-color-ai-background-top-disabled: ${withAlpha(bgTop, 0.5)};`,
    `  --lotus-color-ai-background-bottom: ${bgBottom};`,
    `  --lotus-color-ai-background-bottom-hover: ${bgBottom};`,
    `  --lotus-color-ai-background-bottom-active: ${bgBottom};`,
    `  --lotus-color-ai-background-bottom-disabled: ${withAlpha(bgBottom, 0.5)};`,
  ];
}

function tagDecorativeLines(mode: 'light' | 'dark'): string[] {
  const lines: string[] = [];
  for (const [key, value] of Object.entries(tagDecorativeColor)) {
    lines.push(`  --lotus-color-tag-${kebab(key)}: ${mode === 'light' ? value.light : value.dark};`);
  }
  return lines;
}

/** 对 `rgba(r, g, b, a)` 字符串替换透明度分量，用于派生 AI 色的交互态变体。 */
function withAlpha(rgba: string, alpha: number): string {
  const match = rgba.match(/rgba?\(([^)]+)\)/);
  if (!match) return rgba;
  const parts = match[1]!.split(',').map((p) => p.trim());
  const [r, g, b] = parts;
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function kebab(s: string): string {
  return s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
}

function build(): string {
  const { light, dark } = buildPalette(DEFAULT_BRAND);

  const lightBlock = [
    ':root {',
    ...paletteLines(light),
    ...semanticLines(light, 'light'),
    ...surfaceLines('light'),
    ...staticLines(),
    ...aiLines('light'),
    ...tagDecorativeLines('light'),
    '}',
  ].join('\n');

  const darkBlock = [
    ':root[data-theme="dark"] {',
    ...paletteLines(dark),
    ...semanticLines(dark, 'dark'),
    ...surfaceLines('dark'),
    ...aiLines('dark'),
    ...tagDecorativeLines('dark'),
    '}',
  ].join('\n');

  return `@layer lotus-tokens {\n${lightBlock}\n\n${darkBlock}\n}\n`;
}

mkdirSync(dirname(outFile), { recursive: true });
writeFileSync(outFile, build(), 'utf-8');
console.log(`[tokens] wrote ${outFile}`);
