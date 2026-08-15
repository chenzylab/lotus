import { test, expect } from '@playwright/test';

test.describe('Grid', () => {
  test('pull/push 让栅格发生水平位移但不改变 DOM 顺序', async ({ page }) => {
    await page.goto('/');

    const pushCol = page.getByText('col-18 push-6', { exact: true });
    const pullCol = page.getByText('col-6 pull-18', { exact: true });
    await expect(pushCol).toBeVisible();
    await expect(pullCol).toBeVisible();

    const pushBox = await pushCol.boundingBox();
    const pullBox = await pullCol.boundingBox();
    // DOM 顺序里 push 列在前、pull 列在后，但 push 向右移、pull 向左移，
    // 视觉上 pull 列（pull-18）应该出现在 push 列（push-6）左边。
    expect(pullBox!.x).toBeLessThan(pushBox!.x);
  });

  test('span 为 0 的 Col 不可见（display: none 语义）', async ({ page }) => {
    await page.goto('/');

    const hiddenCol = page.getByText('col-0（应隐藏）', { exact: true });
    await expect(hiddenCol).toBeHidden();
  });
});
