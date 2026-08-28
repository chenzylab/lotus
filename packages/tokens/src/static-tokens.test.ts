import { describe, it, expect } from 'vitest';
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
  fontWeight,
  typography,
  iconSize,
  chartDataColor,
} from './static-tokens.js';

describe('static tokens completeness', () => {
  it('defines light and dark values for every mode-aware token', () => {
    const modeAwareGroups = [bg, fill, text, link];
    for (const group of modeAwareGroups) {
      for (const value of Object.values(group)) {
        expect(value.light).toBeTruthy();
        expect(value.dark).toBeTruthy();
      }
    }
    expect(border.light).not.toBe(border.dark);
    expect(shadowBorder.light).toBeTruthy();
    expect(overlayBg.light).toBeTruthy();
    expect(focusBorder.light).not.toBe(focusBorder.dark);
    expect(elevation.light).not.toBe(elevation.dark);
    expect(highlight.bg.light).not.toBe(highlight.bg.dark);
  });

  it('defines a five-level bg hierarchy (bg0-bg4) that visually converges in light mode but diverges in dark mode', () => {
    expect(Object.keys(bg)).toHaveLength(5);
    // 亮色模式下 5 层背景色数值可以相同（靠阴影/边框区分层级），暗色模式必须逐级不同
    const darkValues = Object.values(bg).map((v) => v.dark);
    expect(new Set(darkValues).size).toBe(5);
  });

  it('defines four text levels (text0-text3), with text3 equal to disabled text', () => {
    expect(Object.keys(text)).toHaveLength(4);
    expect(disabled.text).toEqual(text.text3);
  });

  it('defines all four disabled state values (bg/text/border/fill) with both modes', () => {
    expect(Object.keys(disabled)).toHaveLength(4);
    for (const value of Object.values(disabled)) {
      expect(value.light).toBeTruthy();
      expect(value.dark).toBeTruthy();
    }
  });

  it('defines a complete border-radius hierarchy including circle and full', () => {
    expect(Object.keys(radius).sort()).toEqual(
      ['circle', 'extraSmall', 'full', 'large', 'medium', 'small'].sort(),
    );
  });

  it('defines the full 9-level spacing scale (none through superLoose)', () => {
    expect(Object.values(spacing)).toEqual([
      '0px', '2px', '4px', '8px', '12px', '16px', '20px', '24px', '32px', '40px',
    ]);
  });

  it('defines a three-tier control height scale', () => {
    expect(Object.values(controlHeight)).toEqual(['24px', '32px', '40px']);
  });

  it('defines border width tiers including a zero/none value', () => {
    expect(borderWidth.none).toBe('0');
    expect(borderWidth.control).toBe('1px');
  });

  it('defines a z-index scale covering common overlay stacking conflicts', () => {
    // modal 必须低于 toast/notification/popover/dropdown/tooltip，这是浮层组件不互相遮挡的关键约束
    expect(zIndex.modal).toBeLessThan(zIndex.toast);
    expect(zIndex.toast).toBeLessThanOrEqual(zIndex.popover);
    expect(zIndex.popover).toBeLessThan(zIndex.dropdown);
    expect(zIndex.dropdown).toBeLessThan(zIndex.tooltip);
  });

  it('defines five font-weight tiers', () => {
    expect(fontWeight).toEqual({
      light: '200',
      regular: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
    });
  });

  it('defines a complete typography scale from h1 to h6 plus body and label', () => {
    expect(Object.keys(typography).sort()).toEqual(
      ['body', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'label'].sort(),
    );
    for (const scale of Object.values(typography)) {
      expect(scale.fontSize).toBeTruthy();
      expect(scale.lineHeight).toBeTruthy();
      expect(scale.fontWeight).toBeTruthy();
    }
    // 标题字重应为 semibold，正文/标签应为 regular，这是排印层级的语义正确性检查
    expect(typography.h1.fontWeight).toBe(fontWeight.semibold);
    expect(typography.body.fontWeight).toBe(fontWeight.regular);
  });

  it('defines a full icon size scale', () => {
    expect(Object.keys(iconSize)).toHaveLength(5);
  });

  it('defines 20 chart data colors for both light and dark modes, independently (not shared)', () => {
    expect(chartDataColor.light).toHaveLength(20);
    expect(chartDataColor.dark).toHaveLength(20);
    for (const hex of [...chartDataColor.light, ...chartDataColor.dark]) {
      expect(hex).toMatch(/^#[0-9a-f]{6}$/);
    }
    // light/dark 是完全不同的两套取值（对齐一手来源 global.scss 的真实行为），
    // 不能像早期误从 VChart 主题包取值时那样简单复用同一份数组——一旦两组
    // 完全相同大概率是回归到了那次错误实现。
    expect(chartDataColor.light).not.toEqual(chartDataColor.dark);
  });
});
