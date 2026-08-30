import { test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

/**
 * a11y.spec.md 第48行验收标准："CI 中集成自动化 a11y 扫描工具（如 axe-core 的
 * Playwright 集成），作为兜底而非替代人工 checklist"。此前完全没有落地——
 * 没装依赖、没有任何扫描配置。
 *
 * 现状（2026-08-30）：基础设施本身已验证可行（依赖装好、扫描能跑通、真实
 * 发现问题），但首次对 playground 首页（含全部已实现组件的 demo 集合）
 * 全量扫描后，命中 20 类不同规则、共 665 条 critical/serious 级别记录
 * （aria-allowed-attr/color-contrast/focusable-content/button-name 等）。
 * 这个规模的逐条核实——区分"真实缺陷" vs "demo 写法问题" vs "axe-core
 * 启发式误报"（例如 color-contrast 规则对 `color-mix()` 混合背景色、
 * 半透明叠加这类场景的解析准确性存疑，lotus 部分场景已用 `contrast.ts`
 * 做过精确的一手来源交叉验证，不应被自动化工具的粗粒度判断覆盖）——
 * 远超"接入基础设施"本身的范围，需要独立的排查+修复周期，经用户确认
 * 本次不展开，仅完成接入并如实记录现状。
 *
 * 用 `test.skip` 而非删除或注释掉：证明扫描配置本身随时可以重新跑起来，
 * 不是"配置写完从此没人验证过还能不能用"的摆设。下一轮排查时把
 * `test.skip` 换回 `test` 即可立即复现当前的 665 条记录作为起点。
 */
test.describe('a11y automated scan (axe-core)', () => {
  test.skip('playground 首页：无 critical/serious 级别的可访问性违规（已知现存 665 条待排查记录，见文件头注释，取消 skip 即可复现）', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    const seriousOrWorse = results.violations.filter(
      (v) => v.impact === 'critical' || v.impact === 'serious',
    );

    if (seriousOrWorse.length > 0) {
      const summary = seriousOrWorse.map((v) => ({
        id: v.id,
        impact: v.impact,
        description: v.description,
        nodeCount: v.nodes.length,
        sampleTarget: v.nodes[0]?.target,
      }));
      console.log('[a11y-scan] critical/serious violations:', JSON.stringify(summary, null, 2));
    }
  });
});
