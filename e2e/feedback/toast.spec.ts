import { test, expect } from '@playwright/test';

test.describe('Toast', () => {
  test('点击按钮触发 Toast.info，渲染出对应内容', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.info' }).click();

    const toast = page.locator('.lotus-toast-info');
    await expect(toast).toBeVisible();
    await expect(toast.locator('.lotus-toast-content')).toHaveText('这是一条 info 提示');
  });

  test('showClose=true 时渲染关闭按钮，点击后立即移除', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.success（可关闭）' }).click();

    const toast = page.locator('.lotus-toast-success');
    await expect(toast).toBeVisible();

    await toast.getByRole('button', { name: '关闭' }).click();
    await expect(toast).not.toBeVisible();
  });

  test('duration 到期后自动移除（默认 3 秒）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.info' }).click();

    const toast = page.locator('.lotus-toast-info');
    await expect(toast).toBeVisible();
    await expect(toast).not.toBeVisible({ timeout: 4000 });
  });

  test('连续触发多条 Toast 时全部同时显示，各自独立', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 3 条' }).click();

    await expect(page.locator('.lotus-toast-warning')).toBeVisible();
    await expect(page.locator('.lotus-toast-error')).toBeVisible();
    await expect(page.locator('.lotus-toast-info')).toBeVisible();

    const count = await page.locator('.lotus-toast').count();
    expect(count).toBe(3);
  });

  test('destroyAll() 清空全部通知并卸载挂载容器', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 3 条' }).click();
    await expect(page.locator('.lotus-toast')).toHaveCount(3);

    await page.getByRole('button', { name: 'destroyAll' }).click();
    await expect(page.locator('.lotus-toast')).toHaveCount(0);
    await expect(page.locator('.lotus-toast-root')).toHaveCount(0);
  });
});
