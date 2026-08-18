import { test, expect } from '@playwright/test';

test.describe('Popconfirm', () => {
  test('点击触发按钮后浮层出现，展示 title/description', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: '删除（同步回调）' });

    await trigger.click();

    const popover = page.locator('.lotus-popconfirm-popover');
    await expect(popover).toBeVisible();
    await expect(popover.locator('.lotus-popconfirm-title')).toHaveText('确认删除？');
    await expect(popover.locator('.lotus-popconfirm-description')).toHaveText('删除后无法恢复');
  });

  test('同步回调：点击确认按钮后浮层关闭并触发 onConfirm', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: '删除（同步回调）' });
    await trigger.click();

    const popover = page.locator('.lotus-popconfirm-popover');
    await popover.getByRole('button', { name: '确定' }).click();

    await expect(popover).not.toBeVisible();
    expect(logs).toContain('popconfirm confirmed');
  });

  test('点击取消按钮后浮层关闭并触发 onCancel', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: '删除（同步回调）' });
    await trigger.click();

    const popover = page.locator('.lotus-popconfirm-popover');
    await popover.getByRole('button', { name: '取消' }).click();

    await expect(popover).not.toBeVisible();
    expect(logs).toContain('popconfirm cancelled');
  });

  test('异步 onConfirm 返回 Promise 期间确认按钮显示 loading，浮层保持打开', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: '提交（异步回调，600ms）' });
    await trigger.click();

    const popover = page.locator('.lotus-popconfirm-popover');
    const confirmButton = popover.getByRole('button', { name: '确定' });
    await confirmButton.click();

    // Promise 尚未 resolve 期间，浮层应保持打开、按钮显示 loading class
    await expect(popover).toBeVisible();
    await expect(confirmButton).toHaveClass(/lotus-button-loading/);

    // 600ms 后 Promise resolve，浮层关闭
    await expect(popover).not.toBeVisible({ timeout: 2000 });
  });
});
