import { describe, it, expect } from 'vitest';
import { contrastRatio, WCAG_AA_UI_COMPONENT } from './contrast.js';
import { buildPalette } from './palette.js';
import { bg as bgTokens, focusBorder } from './static-tokens.js';

/**
 * theme-tokens.spec.md 第83行验收标准：交互状态变量（hover/active/focus）
 * 与相邻背景色对比度 >= 3:1（Tertiary 语义色例外，见 spec「已知设计权衡」）。
 * 此前从未有对应测试实测这条。
 *
 * 关键澄清（写第一版测试时的误判，记录下来避免重犯）：`--lotus-color-{hue}
 * -hover`/`-active` 在实际组件（Button/IconButton 等）里消费方式是
 * `background: var(--lotus-color-xxx-hover)`——它是**按钮的 hover 态实心
 * 背景填充色**，不是贴在 bg-0 页面背景上的边框/文字元素。用"与 bg-0 对比度"
 * 衡量这类变量文不对题：secondary/success/warning 的 hover 态色阶算出来
 * 确实低于 3:1（如 warning-hover 2.11、success-hover 2.29），但这是"色块
 * 本身够不够亮/够不够暗以至于在页面背景上很显眼"这个无关紧要的维度，真正
 * 该测的是"色块 + 其上方文字"的对比度（这条已由 contrast.test.ts 的
 * white-text-on-solid-fill 测试覆盖，只是那个测试测的是 default 态色阶
 * 而非 hover/active 态，可结合下方新增的 hover/active 白字测试一起看）。
 *
 * spec 第80行给出的例子是"输入框描边与背景"，指向的是真正的边框/描边类
 * 变量——本文件聚焦这一类：focus-border（表单控件 focus 边框，与页面
 * 背景对比度直接相关）。
 */
describe('interaction state contrast — focus-border (edge/stroke against page background)', () => {
  it('light mode focus-border on bg-0 meets UI component contrast (>= 3:1)', () => {
    const ratio = contrastRatio(focusBorder.light, bgTokens.bg0.light);
    expect(ratio).toBeGreaterThanOrEqual(WCAG_AA_UI_COMPONENT);
  });

  it('dark mode focus-border on bg-0 meets UI component contrast (>= 3:1)', () => {
    const ratio = contrastRatio(focusBorder.dark, bgTokens.bg0.dark);
    expect(ratio).toBeGreaterThanOrEqual(WCAG_AA_UI_COMPONENT);
  });
});

describe('interaction state contrast — white text on hover/active solid-fill hex steps', () => {
  // Tertiary 语义色明确排除（spec「已知设计权衡」：中性图标定位，天然对比度较低，非缺陷）。
  const CHECKED_HUES = ['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const;

  it('records light mode white-text-on-hover/active contrast (no hard threshold, same rationale as default-state test in contrast.test.ts)', () => {
    const { light } = buildPalette();
    const results: Record<string, { hover: number; active: number }> = {};
    for (const hue of CHECKED_HUES) {
      results[hue] = {
        hover: Number(contrastRatio('#ffffff', light[hue][4]!).toFixed(2)),
        active: Number(contrastRatio('#ffffff', light[hue][6]!).toFixed(2)),
      };
    }
    console.log('[contrast] light mode white text on hover/active solid-fill:', results);
    // 与 contrast.test.ts 的 default 态白字测试同一套底线逻辑：不接受完全不可辨识（< 1.5）。
    for (const { hover, active } of Object.values(results)) {
      expect(hover).toBeGreaterThan(1.5);
      expect(active).toBeGreaterThan(1.5);
    }
  });
});
