import { test, expect } from '@playwright/test';

test.describe('Anchor', () => {
  test('渲染全部链接，初始未滚动时无高亮项', async ({ page }) => {
    await page.goto('/');
    const anchor = page.locator('[aria-label="锚点导航"]');
    const links = anchor.locator('.lotus-anchor-link');

    await expect(links).toHaveText(['第一节', '第二节', '第三节']);
    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveCount(0);
  });

  test('滚动容器时高亮随位置切换', async ({ page }) => {
    await page.goto('/');
    const container = page.locator('#anchor-scroll-container');
    const anchor = page.locator('[aria-label="锚点导航"]');

    await container.evaluate((el) => { el.scrollTop = 260; });
    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveText('第一节');

    await container.evaluate((el) => { el.scrollTop = 480; });
    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveText('第二节');
  });

  test('点击链接跳转到目标位置并高亮，触发 onChange', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const anchor = page.locator('[aria-label="锚点导航"]');
    const link3 = anchor.getByText('第三节', { exact: true });

    await link3.click();

    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveText('第三节', { timeout: 1000 });
    expect(logs.some((l) => l.includes('anchor changed'))).toBe(true);

    const container = page.locator('#anchor-scroll-container');
    const scrollTop = await container.evaluate((el) => el.scrollTop);
    expect(scrollTop).toBeGreaterThan(0);
  });

  test('点击跳转后短时间内保持目标高亮，不被滚动动画过程中的 scroll 事件打断', async ({ page }) => {
    await page.goto('/');
    const anchor = page.locator('[aria-label="锚点导航"]');
    const link1 = anchor.getByText('第一节', { exact: true });

    // 先滚到第三节区域
    const container = page.locator('#anchor-scroll-container');
    await container.evaluate((el) => { el.scrollTop = 520; });
    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveText('第三节');

    // 点击跳回第一节：动画滚动期间中途状态不应该被 scroll 事件计算出的"临时经过的锚点"打断
    await link1.click();
    await expect(anchor.locator('.lotus-anchor-link-active')).toHaveText('第一节', { timeout: 1000 });
  });
});
