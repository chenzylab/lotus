import { test, expect } from '@playwright/test';

test.describe('Progress', () => {
  test('line 类型渲染正确的 aria-valuenow 与填充宽度', async ({ page }) => {
    await page.goto('/');
    const line = page.locator('.lotus-progress-line', { hasText: '30%' }).first();

    await expect(line).toHaveAttribute('aria-valuenow', '30');
    const inner = line.locator('.lotus-progress-track-inner');
    await expect(inner).toHaveCSS('width', /.*/);
  });

  test('circle 类型渲染 SVG 环形几何', async ({ page }) => {
    await page.goto('/');
    const circle = page.locator('.lotus-progress-circle').first();

    await expect(circle).toHaveAttribute('aria-valuenow', '70');
    const ring = circle.locator('.lotus-progress-circle-ring-inner');
    const dashoffset = await ring.getAttribute('stroke-dashoffset');
    expect(Number(dashoffset)).toBeGreaterThan(0);
  });

  test('点击按钮驱动受控 percent 变化，数值动画后收敛到目标值', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: '切换 Progress 百分比' });
    const controlledText = page.locator('.lotus-progress-line-text').nth(1);

    await expect(controlledText).toHaveText('30%');
    await button.click();

    await expect(controlledText).toHaveText('50%', { timeout: 2000 });
  });

  test('多段渐变 stroke 在不同百分比下渲染不同颜色', async ({ page }) => {
    await page.goto('/');
    const gradientTrack = page.locator('.lotus-progress-line-text').nth(1)
      .locator('xpath=preceding-sibling::div[contains(@class, "lotus-progress-track")]')
      .locator('.lotus-progress-track-inner');

    const colorAt30 = await gradientTrack.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(colorAt30).toBeTruthy();

    const button = page.getByRole('button', { name: '切换 Progress 百分比' });
    await button.click();
    await page.waitForTimeout(400);

    const colorAt50 = await gradientTrack.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(colorAt50).not.toBe(colorAt30);
  });

  test('自定义 format 文案跟随写入 aria-valuetext（回归防护：曾经只设置 aria-valuenow 原始百分比，自定义 format 文案不会被屏幕阅读器朗读）', async ({ page }) => {
    await page.goto('/');
    const custom = page.getByLabel('自定义 format 文案进度条（验证 aria-valuetext 跟随 format 而非原始百分比）');
    await expect(custom).toHaveAttribute('aria-valuenow', '30');
    await expect(custom).toHaveAttribute('aria-valuetext', '第 3 步，共 10 步');
  });

  test('默认 format 时 aria-valuetext 为百分比文案', async ({ page }) => {
    await page.goto('/');
    const line = page.getByLabel('line 基础进度条');
    await expect(line).toHaveAttribute('aria-valuetext', '30%');
  });

  test('数值变化由 CSS transition 驱动（回归防护：曾用 JS requestAnimationFrame 逐帧计算，违反 Phase 2 spec「不使用 JS 手动计算」要求，重构为纯 CSS transition 后需验证 transition 属性真实生效）', async ({ page }) => {
    await page.goto('/');
    const line = page.getByLabel('line 基础进度条');
    const inner = line.locator('.lotus-progress-track-inner');
    const transition = await inner.evaluate((el) => getComputedStyle(el).transitionProperty);
    expect(transition).toContain('width');

    const circle = page.getByLabel('circle 基础进度条');
    const ring = circle.locator('.lotus-progress-circle-ring-inner');
    const ringTransition = await ring.evaluate((el) => getComputedStyle(el).transitionProperty);
    expect(ringTransition).toContain('stroke-dashoffset');
  });

  test('motion=false 时禁用 CSS transition（aria-valuenow 立即反映目标值，且过渡时长为 0）', async ({ page }) => {
    await page.goto('/');
    const noMotion = page.getByLabel('禁用动画的进度条（验证 motion=false 时 CSS transition 被禁用）');
    const inner = noMotion.locator('.lotus-progress-track-inner');

    const duration = await inner.evaluate((el) => getComputedStyle(el).transitionDuration);
    expect(duration.split(',').every((d) => parseFloat(d) === 0)).toBe(true);

    await expect(noMotion).toHaveAttribute('aria-valuenow', '30');
    const button = page.getByRole('button', { name: '切换禁用动画的 Progress 百分比' });
    await button.click();
    await expect(noMotion).toHaveAttribute('aria-valuenow', '50');
  });

  test('id/aria-labelledby/aria-valuetext：全部正确透传到 progressbar 元素（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const progress = page.locator('#progress-id-demo');
    await expect(progress).toHaveAttribute('aria-labelledby', 'progress-labelledby-demo');
    await expect(progress).toHaveAttribute('aria-valuetext', '自定义覆盖文案');
  });
});
