import { test, expect } from '@playwright/test';

test.describe('BackTop', () => {
  test('初始未滚动时不显示，滚动超过 visibilityHeight 后出现', async ({ page }) => {
    await page.goto('/');
    const backTop = page.locator('.lotus-back-top');

    await expect(backTop).toHaveCount(0);

    await page.evaluate(() => window.scrollTo(0, 500));
    await expect(backTop).toBeVisible();
  });

  test('滚动回到顶部以下（未超过阈值）后重新隐藏', async ({ page }) => {
    await page.goto('/');
    const backTop = page.locator('.lotus-back-top');

    await page.evaluate(() => window.scrollTo(0, 500));
    await expect(backTop).toBeVisible();

    await page.evaluate(() => window.scrollTo(0, 0));
    await expect(backTop).toHaveCount(0);
  });

  test('点击后触发数值动画滚动回顶部，且触发 onClick 回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const backTop = page.locator('.lotus-back-top');

    await page.evaluate(() => window.scrollTo(0, 800));
    await expect(backTop).toBeVisible();

    await backTop.click();

    // 动画时长 450ms（默认），留足够余量等待收敛到顶部
    await page.waitForFunction(() => window.scrollY === 0, { timeout: 2000 });
    expect(logs).toContain('back-top clicked');
  });
});
