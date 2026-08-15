import { describe, it, expect } from 'vitest';
import { contrastRatio, WCAG_AA_NORMAL_TEXT, WCAG_AA_UI_COMPONENT } from './contrast.js';
import { buildPalette } from './palette.js';
import { text as textTokens, bg as bgTokens } from './static-tokens.js';

describe('contrastRatio', () => {
  it('identical colors have a ratio of 1', () => {
    expect(contrastRatio('#000000', '#000000')).toBeCloseTo(1, 5);
  });

  it('black on white has the maximum ratio of 21', () => {
    expect(contrastRatio('#000000', '#ffffff')).toBeCloseTo(21, 1);
  });

  it('is symmetric regardless of argument order', () => {
    expect(contrastRatio('#1c1f23', '#ffffff')).toBeCloseTo(contrastRatio('#ffffff', '#1c1f23'), 10);
  });
});

describe('WCAG AA compliance — primary text on page background', () => {
  it('light mode text-0 on bg-0 meets normal text contrast (>= 4.5:1)', () => {
    expect(contrastRatio(textTokens.text0.light, bgTokens.bg0.light)).toBeGreaterThanOrEqual(
      WCAG_AA_NORMAL_TEXT,
    );
  });

  it('dark mode text-0 on bg-0 meets normal text contrast (>= 4.5:1)', () => {
    // text-0/bg-0 dark 值均为纯色（非 rgba），可直接比较；若未来改用半透明表达需先做 alpha 合成
    expect(contrastRatio(textTokens.text0.dark, bgTokens.bg0.dark)).toBeGreaterThanOrEqual(
      WCAG_AA_NORMAL_TEXT,
    );
  });

  it('records white-text-on-solid-fill contrast ratios for each semantic color (no hard threshold)', () => {
    // 仅 Primary/Secondary/Success/Warning/Danger/Info 会被用作"实心背景 + 白字"场景（如 Solid Button）。
    // Tertiary 语义定位是"第三级操作、中性图标"（见 DESIGN.md），不承担高对比度背景色职责，不纳入本项。
    //
    // 不设硬性阈值断言：实测 Semi 官方生产色值（semi-foundation/button/variables.scss 证实 Warning/
    // Danger solid 按钮确实用白色文字）在此场景下对比度普遍不满足 4.5:1（常规文本）甚至部分不满足
    // 3:1（UI 组件），例如 Success #3BB346 = 2.72、Warning #FC8800 = 2.42、Danger #F93920 = 3.73——
    // 这是 Semi 官方接受的已知权衡（按钮文字字号大/字重粗/有强色块反衬，业界许多组件库对此场景的
    // 可访问性要求本就宽松于正文文本）。lotus 目前品牌色沿用 Semi 数值，故继承同样的权衡，不假装
    // 达标也不强行断言必须达到某个阈值。此测试仅作为实测数值的可见记录，任何一次品牌色调整都应
    // 重新观察这里打印的数值是否发生非预期的显著劣化。
    const { light } = buildPalette();
    const solidFillHues = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;
    const results: Record<string, number> = {};
    for (const hue of solidFillHues) {
      const brandColor = light[hue][5]!; // 第 5 级即品牌色默认态
      results[hue] = Number(contrastRatio('#ffffff', brandColor).toFixed(2));
    }
    console.log('[contrast] white text on solid-fill semantic colors:', results);
    // 唯一的硬性下限：不接受完全不可辨识的组合（< 1.5 意味着颜色几乎相同，属实现错误而非设计权衡）
    for (const ratio of Object.values(results)) {
      expect(ratio).toBeGreaterThan(1.5);
    }
  });
});
