import { test, expect } from '@playwright/test';

test.describe('Layout', () => {
  test('三行布局默认纵向堆叠（flex-direction: column）', async ({ page }) => {
    await page.goto('/');
    const threeRowLayout = page.locator('.lotus-layout:not(.lotus-layout-has-sider)').filter({ hasText: 'Header' }).first();
    await expect(threeRowLayout).toHaveCSS('flex-direction', 'column');
  });

  test('hasSider 布局横向排列（flex-direction: row），Sider 与内容并排', async ({ page }) => {
    await page.goto('/');
    const siderLayout = page.locator('.lotus-layout-has-sider');
    await expect(siderLayout).toHaveCSS('flex-direction', 'row');

    const sider = page.locator('.lotus-layout-sider');
    await expect(sider).toBeVisible();
    await expect(sider).toContainText('Sider');
  });
});
