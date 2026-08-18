import { test, expect } from '@playwright/test';

test.describe('Collapsible', () => {
  test('isOpen=false 且 keepDOM=false（默认）时，内容不渲染到 DOM', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    await expect(collapsible.locator('.lotus-collapsible-inner')).toHaveCount(0);
  });

  test('点击外部按钮切换 isOpen 后，内容动态挂载/卸载（非 keepDOM 场景）', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮');

    await button.click();
    await expect(collapsible.locator('.lotus-collapsible-inner')).toHaveCount(1);
    await expect(collapsible).toContainText('这是任意内容');

    await button.click();
    await expect(collapsible.locator('.lotus-collapsible-inner')).toHaveCount(0);
  });

  test('keepDOM=true 时，收起状态下内容仍在 DOM 中（不销毁重建）', async ({ page }) => {
    await page.goto('/');
    const keepDOM = page.getByLabel('keepDOM Collapsible');
    await expect(keepDOM.locator('.lotus-collapsible-inner')).toHaveCount(1);
    await expect(keepDOM).toContainText('收起后这段内容仍在 DOM 中');
  });

  test('isOpen 变化时 class 与 max-height 同步切换', async ({ page }) => {
    await page.goto('/');
    const keepDOM = page.getByLabel('keepDOM Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮');

    await expect(keepDOM).not.toHaveClass(/lotus-collapsible-open/);
    const collapsedHeight = await keepDOM.evaluate((el) => getComputedStyle(el).maxHeight);
    expect(collapsedHeight).toBe('0px');

    await button.click();
    await expect(keepDOM).toHaveClass(/lotus-collapsible-open/);
    const expandedHeight = await keepDOM.evaluate((el) => getComputedStyle(el).maxHeight);
    expect(expandedHeight).not.toBe('0px');
  });

  test('aria-hidden 随 isOpen 状态同步', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮');

    await expect(collapsible).toHaveAttribute('aria-hidden', 'true');
    await button.click();
    await expect(collapsible).toHaveAttribute('aria-hidden', 'false');
  });
});
