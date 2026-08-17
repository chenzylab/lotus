import { test, expect } from '@playwright/test';

test.describe('IconButton', () => {
  test('点击图标按钮触发回调，且图标正确渲染为 svg', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const button = page.getByRole('button', { name: '设置', exact: true });

    // 对应 specs 踩坑 #41：@if/@else 两分支渲染同 class 容器时 @else 分支内容可能不显示，
    // 必须断言内部子元素（svg）真的存在，不能只看外层 button 是否可见。
    await expect(button.locator('svg')).toBeVisible();

    await button.click();
    expect(logs).toContain('icon button clicked');
  });

  test('disabled 状态下点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const disabledButton = page.getByRole('button', { name: '禁用图标按钮' });

    await expect(disabledButton).toBeDisabled();
    await disabledButton.click({ force: true }).catch(() => {});

    expect(logs).not.toContain('should not fire');
  });

  test('loading 状态下显示转圈图标且点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const loadingButton = page.getByRole('button', { name: '加载中图标按钮' });

    await expect(loadingButton).toHaveCSS('pointer-events', 'none');
    await expect(loadingButton.locator('.lotus-icon-button-spinner')).toBeVisible();

    await loadingButton.click({ force: true }).catch(() => {});
    expect(logs).not.toContain('should not fire');
  });

  test('size / type / theme 组合正确渲染对应 class', async ({ page }) => {
    await page.goto('/');

    const dangerSolid = page.locator('.lotus-icon-button-danger.lotus-icon-button-theme-solid');
    const outline = page.locator('.lotus-icon-button-theme-outline');
    const large = page.locator('.lotus-icon-button-size-large');
    const small = page.locator('.lotus-icon-button-size-small');

    await expect(dangerSolid).toBeVisible();
    await expect(outline).toBeVisible();
    await expect(large).toBeVisible();
    await expect(small).toBeVisible();
  });

  test('图标按钮为正方形（宽高相等）', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: '设置', exact: true });
    const box = await button.boundingBox();

    expect(box).not.toBeNull();
    expect(box!.width).toBeCloseTo(box!.height, 0);
  });
});
