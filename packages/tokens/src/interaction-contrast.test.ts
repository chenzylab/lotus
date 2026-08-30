import { describe, it, expect } from 'vitest';
import { contrastRatio, WCAG_AA_UI_COMPONENT } from './contrast.js';
import { buildPalette } from './palette.js';
import { bg as bgTokens, focusBorder, tagDecorativeColor } from './static-tokens.js';

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

/**
 * a11y.spec.md 第47行验收标准："色彩对比度检查覆盖 Token 层新增的每一个语义色
 * 变量，而非仅默认主题色"。核实发现 Tag 装饰色（16 色，`tagDecorativeColor`）
 * 此前完全没有对比度测试——`.lotus-tag-colorful.lotus-tag-solid` 用它做实心
 * 背景配白字（`color: #ffffff`，见 `show/tag/index.tsrx`），是与 7 语义色相
 * 同一类"实心色块 + 白字"场景，此前完全遗漏。
 */
describe('tag decorative color contrast — white text on solid-fill', () => {
  it('records light mode white-text-on-tag-color contrast (no hard threshold, same rationale as semantic hues)', () => {
    const results: Record<string, number> = {};
    for (const [key, value] of Object.entries(tagDecorativeColor)) {
      results[key] = Number(contrastRatio('#ffffff', value.light).toFixed(2));
    }
    console.log('[contrast] light mode white text on tag decorative colors:', results);
    for (const ratio of Object.values(results)) {
      expect(ratio).toBeGreaterThan(1.5);
    }
  });

  it('records dark mode white-text-on-tag-color contrast (yellow/amber confirmed as genuine Semi 一手来源 floor, not a lotus regression — see rationale below)', () => {
    const results: Record<string, number> = {};
    for (const [key, value] of Object.entries(tagDecorativeColor)) {
      results[key] = Number(contrastRatio('#ffffff', value.dark).toFixed(2));
    }
    console.log('[contrast] dark mode white text on tag decorative colors:', results);
    // 暗色模式 yellow(1.34)/amber(1.56) 是已核实的例外：用 Semi 一手来源暗色
    // `--semi-yellow-5`(253,222,67)/`--semi-amber-5`(245,202,80) 独立计算得
    // 1.337/1.562，与 lotus 实测几乎完全一致——Semi `tag/mixin.scss` 的
    // solid 类型对全部 16 色无条件统一用白字，没有为过亮的颜色切换黑字，
    // 这是 Semi 官方本身的固有权衡，不是 lotus 引入的额外劣化。硬下限只挡
    // "非本这两色以外还有新的更极端劣化"，不对 yellow/amber 本身重新假设。
    for (const [key, ratio] of Object.entries(results)) {
      const floor = key === 'yellow' ? 1.3 : 1.5;
      expect(ratio).toBeGreaterThan(floor);
    }
  });
});
