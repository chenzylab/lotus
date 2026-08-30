import { describe, it, expect } from 'vitest';
import { contrastRatio } from './contrast.js';
import { aiColor } from './static-tokens.js';

/**
 * a11y.spec.md 第47行验收标准："色彩对比度检查覆盖 Token 层新增的每一个语义色
 * 变量，而非仅默认主题色"。核实发现 7 语义色相（primary/secondary/.../info）
 * 已被 contrast.test.ts/interaction-contrast.test.ts 覆盖，但 AI 渐变色
 * （aiColor）此前只在 theme-tokens.spec.md 第91行做过一次性手工计算记录
 * （"渐变起点 #e945ff 粉紫色与白字 default 态 3.11:1"），从未固化为自动化
 * 回归测试——未来若 aiColor 数值再变化，对比度劣化不会被任何测试捕获。
 *
 * general 是多 stop 渐变字符串，purple/backgroundTop/backgroundBottom 是
 * rgba() 格式，两者都不是 contrastRatio 支持的纯 hex 输入。渐变色只测试
 * 对比度最极端的两个端点色标（通常是起点与终点），与 theme-tokens.spec.md
 * 第91行手工计算时的取值方式一致；rgba 格式暂不纳入（需要先与实际背景做
 * alpha 合成，背景层数字色（AI 卡片场景）当前未标准化，留待后续需要时再
 * 补，不在本次范围内手写近似值）。
 */
function extractGradientEndpoints(gradient: string): [string, string] {
  const hexMatches = gradient.match(/#[0-9a-fA-F]{6}/g);
  if (!hexMatches || hexMatches.length < 2) {
    throw new Error(`Cannot extract gradient endpoints from: ${gradient}`);
  }
  return [hexMatches[0]!, hexMatches[hexMatches.length - 1]!];
}

describe('AI gradient color contrast — white text on ai-general (default/hover/active)', () => {
  const STATES = ['general', 'generalHover', 'generalActive'] as const;

  it('records light mode white-text-on-gradient-endpoints contrast (no hard 4.5/3.0 threshold, same rationale as solid-fill hues — only floor is not-indistinguishable < 1.5)', () => {
    const results: Record<string, { start: number; end: number }> = {};
    for (const state of STATES) {
      const [start, end] = extractGradientEndpoints(aiColor.light[state]);
      results[state] = {
        start: Number(contrastRatio('#ffffff', start).toFixed(2)),
        end: Number(contrastRatio('#ffffff', end).toFixed(2)),
      };
    }
    console.log('[contrast] light mode white text on ai-general gradient endpoints:', results);
    for (const { start, end } of Object.values(results)) {
      expect(start).toBeGreaterThan(1.5);
      expect(end).toBeGreaterThan(1.5);
    }
  });

  it('records dark mode white-text-on-gradient-endpoints contrast (no hard threshold)', () => {
    const results: Record<string, { start: number; end: number }> = {};
    for (const state of STATES) {
      const [start, end] = extractGradientEndpoints(aiColor.dark[state]);
      results[state] = {
        start: Number(contrastRatio('#ffffff', start).toFixed(2)),
        end: Number(contrastRatio('#ffffff', end).toFixed(2)),
      };
    }
    console.log('[contrast] dark mode white text on ai-general gradient endpoints:', results);
    for (const { start, end } of Object.values(results)) {
      expect(start).toBeGreaterThan(1.5);
      expect(end).toBeGreaterThan(1.5);
    }
  });
});
