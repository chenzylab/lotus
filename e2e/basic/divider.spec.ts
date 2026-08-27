import { test, expect } from '@playwright/test';

test.describe('Divider', () => {
  test('dashed + 带文字组合：::before/::after 分割线渲染为虚线（回归防护：曾经写的 CSS 选择器 lotus-divider-with-text-dashed 是一个从未出现在 DOM 上的复合 class，虚线样式完全不生效）', async ({ page }) => {
    await page.goto('/');
    const divider = page.locator('.lotus-divider', { hasText: '左对齐虚线' });
    await expect(divider).toBeVisible();
    await expect(divider).toHaveClass(/lotus-divider-dashed/);
    await expect(divider).toHaveClass(/lotus-divider-with-text/);

    const beforeStyle = await divider.evaluate((el) => getComputedStyle(el, '::before').borderBottomStyle);
    expect(beforeStyle).toBe('dashed');
  });
});
