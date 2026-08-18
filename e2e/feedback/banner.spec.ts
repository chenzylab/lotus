import { test, expect } from '@playwright/test';

test.describe('Banner', () => {
  test('4 种类型均正确渲染对应 class 与默认图标', async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('.lotus-banner-info')).toBeVisible();
    await expect(page.locator('.lotus-banner-success')).toBeVisible();
    await expect(page.locator('.lotus-banner-warning')).toBeVisible();
    await expect(page.locator('.lotus-banner-danger')).toBeVisible();
  });

  test('title 和 description 正确渲染', async ({ page }) => {
    await page.goto('/');
    const infoBanner = page.locator('.lotus-banner-info');

    await expect(infoBanner.locator('.lotus-banner-title')).toHaveText('信息提示');
    await expect(infoBanner.locator('.lotus-banner-description')).toHaveText('这是一条 info 类型的通栏提示');
  });

  test('点击关闭按钮后 Banner 从 DOM 中移除，并触发 onClose', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const infoBanner = page.locator('.lotus-banner-info');
    await expect(infoBanner).toBeVisible();

    await infoBanner.locator('.lotus-banner-close').click();

    await expect(infoBanner).not.toBeAttached();
    expect(logs).toContain('banner info closed');
  });

  test('closeIcon=null 时不渲染关闭按钮', async ({ page }) => {
    await page.goto('/');
    const dangerBanner = page.locator('.lotus-banner-danger');

    await expect(dangerBanner.locator('.lotus-banner-close')).toHaveCount(0);
  });

  test('fullMode=false 时使用卡片模式 class', async ({ page }) => {
    await page.goto('/');
    const successBanner = page.locator('.lotus-banner-success');

    await expect(successBanner).toHaveClass(/lotus-banner-in-container/);
    await expect(successBanner).toHaveClass(/lotus-banner-bordered/);
  });
});
