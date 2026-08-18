import { test, expect } from '@playwright/test';

test.describe('Spin', () => {
  test('spinning=true 时渲染转圈指示器且 aria-busy 为 true', async ({ page }) => {
    await page.goto('/');
    const spin = page.locator('[aria-label="独立 Spin 指示器"]');

    await expect(spin).toHaveAttribute('aria-busy', 'true');
    await expect(spin.locator('svg.lotus-spin-icon')).toBeVisible();
  });

  test('包裹 children 的 Spin 同时渲染指示器与被包裹内容', async ({ page }) => {
    await page.goto('/');
    const spin = page.locator('[aria-label="包裹内容的 Spin"]');

    await expect(spin).toHaveClass(/lotus-spin-block/);
    await expect(spin.getByText('被包裹的内容区域')).toBeVisible();
  });

  test('点击按钮切换 spinning=false 后指示器隐藏、aria-busy 变为 false', async ({ page }) => {
    await page.goto('/');
    const spin = page.locator('[aria-label="包裹内容的 Spin"]');
    const button = page.getByRole('button', { name: '切换 Spin 加载态' });

    await expect(spin).toHaveAttribute('aria-busy', 'true');
    await button.click();

    await expect(spin).toHaveAttribute('aria-busy', 'false');
    await expect(spin).toHaveClass(/lotus-spin-hidden/);
  });

  test('delay>0 时最终会显示 loading 指示器（回归：Foundation 的 setTimeout 默认实现从 window 解构剥离 this 绑定，曾抛 Illegal invocation 导致这条渲染路径完全崩溃，见 specs 踩坑记录）', async ({ page }) => {
    await page.goto('/');
    const spin = page.locator('[aria-label="延迟显示的 Spin（delay=200ms）"]');

    await expect(spin).toHaveAttribute('aria-busy', 'true', { timeout: 1000 });
    await expect(spin.locator('svg.lotus-spin-icon')).toBeVisible();
  });
});
