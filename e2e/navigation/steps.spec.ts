import { test, expect } from '@playwright/test';

test.describe('Steps', () => {
  test('current 之前的步骤状态为 finish，current 对应的步骤为 process+active', async ({ page }) => {
    await page.goto('/');
    const steps = page.locator('[aria-label="fill 类型步骤条"]');
    const items = steps.locator('.lotus-steps-item');

    await expect(items.nth(0)).toHaveClass(/lotus-steps-item-finish/);
    await expect(items.nth(1)).toHaveClass(/lotus-steps-item-process/);
    await expect(items.nth(1)).toHaveClass(/lotus-steps-item-active/);
    await expect(items.nth(2)).toHaveClass(/lotus-steps-item-wait/);
  });

  test('点击"下一步"按钮驱动 current 变化，步骤状态随之更新', async ({ page }) => {
    await page.goto('/');
    const steps = page.locator('[aria-label="fill 类型步骤条"]');
    const items = steps.locator('.lotus-steps-item');
    const nextButton = page.getByRole('button', { name: '下一步' });

    await nextButton.click();

    await expect(items.nth(1)).toHaveClass(/lotus-steps-item-finish/);
    await expect(items.nth(2)).toHaveClass(/lotus-steps-item-process/);
    await expect(items.nth(2)).toHaveClass(/lotus-steps-item-active/);
  });

  test('finish 状态的步骤图标渲染为 svg（对勾），wait/process 显示数字', async ({ page }) => {
    await page.goto('/');
    const steps = page.locator('[aria-label="fill 类型步骤条"]');
    const items = steps.locator('.lotus-steps-item');

    await expect(items.nth(0).locator('.lotus-steps-item-icon svg')).toBeVisible();
    await expect(items.nth(1).locator('.lotus-steps-item-number')).toHaveText('2');
    await expect(items.nth(2).locator('.lotus-steps-item-number')).toHaveText('3');
  });

  test('status=error 时当前步为 error，前一步带 pre-error class（连接线标红）', async ({ page }) => {
    await page.goto('/');
    const steps = page.locator('[aria-label="basic 类型垂直步骤条（error 状态）"]');
    const items = steps.locator('.lotus-steps-item');

    await expect(items.nth(0)).toHaveClass(/lotus-steps-item-pre-error/);
    await expect(items.nth(1)).toHaveClass(/lotus-steps-item-error/);
    await expect(steps).toHaveClass(/lotus-steps-vertical/);
    await expect(steps).toHaveClass(/lotus-steps-basic/);
  });
});
