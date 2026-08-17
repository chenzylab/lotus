import { test, expect } from '@playwright/test';

test.describe('FloatButton', () => {
  test('点击悬浮按钮触发回调，且图标正确渲染为 svg', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const button = page.getByRole('button', { name: '悬浮设置' });

    await expect(button.locator('svg')).toBeVisible();

    await button.click();
    expect(logs).toContain('float button clicked');
  });

  test('disabled 状态下点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const disabledButton = page.getByRole('button', { name: '禁用悬浮按钮' });

    await expect(disabledButton).toBeDisabled();
    await disabledButton.click({ force: true }).catch(() => {});

    expect(logs).not.toContain('should not fire');
  });

  test('colorful=true 时背景使用 AI 渐变 token', async ({ page }) => {
    await page.goto('/');
    const aiButton = page.getByRole('button', { name: 'AI 悬浮按钮' });

    await expect(aiButton).toHaveClass(/lotus-float-button-colorful/);
    const backgroundImage = await aiButton.evaluate((el) => getComputedStyle(el).backgroundImage);
    expect(backgroundImage).toContain('linear-gradient');
  });

  test('shape=square 时圆角变小，size=small 时尺寸变小', async ({ page }) => {
    await page.goto('/');

    const squareButton = page.getByRole('button', { name: '方形悬浮按钮' });
    await expect(squareButton).toHaveClass(/lotus-float-button-shape-square/);

    const smallButton = page.getByRole('button', { name: '小号悬浮按钮' });
    const box = await smallButton.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBeLessThan(40);
  });
});
