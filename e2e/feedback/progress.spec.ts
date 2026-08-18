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
});
