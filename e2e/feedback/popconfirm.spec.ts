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

  test('无障碍：确认/取消关闭后焦点均归还触发按钮（对齐 Semi 全路径归还的设计，不同于 Popover/Dropdown 只在 Esc 归还）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: '删除（同步回调）' });
    const popover = page.locator('.lotus-popconfirm-popover');

    await trigger.focus();
    await trigger.click();
    await expect(popover).toBeVisible();
    await popover.getByRole('button', { name: '确定' }).click();
    await expect(popover).not.toBeVisible();
    await expect(trigger).toBeFocused();

    await trigger.click();
    await expect(popover).toBeVisible();
    await popover.getByRole('button', { name: '取消' }).click();
    await expect(popover).not.toBeVisible();
    await expect(trigger).toBeFocused();
  });

  test('非受控模式下确认/取消关闭均触发 onVisibleChange（回归防护：曾经绕开 setVisible 直接改 Foundation state，onVisibleChange 完全不被调用）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: '带 onVisibleChange 日志' });
    const popover = page.locator('.lotus-popconfirm-popover');

    await trigger.click();
    expect(logs).toContain('popconfirm visible changed: true');

    await popover.getByRole('button', { name: '确定' }).click();
    await expect(popover).not.toBeVisible();
    expect(logs.filter((l) => l === 'popconfirm visible changed: false')).toHaveLength(1);

    await trigger.click();
    await popover.getByRole('button', { name: '取消' }).click();
    await expect(popover).not.toBeVisible();
    expect(logs.filter((l) => l === 'popconfirm visible changed: false')).toHaveLength(2);
  });

  test('Esc 键关闭浮层，触发 onVisibleChange 且焦点归还触发按钮（回归防护：Popover 固定用 trigger="custom" 导致 Esc 完全无法关闭）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: '带 onVisibleChange 日志' });
    const popover = page.locator('.lotus-popconfirm-popover');

    await trigger.focus();
    await trigger.click();
    await expect(popover).toBeVisible();

    await page.keyboard.press('Escape');

    await expect(popover).not.toBeVisible();
    await expect(trigger).toBeFocused();
    expect(logs).toContain('popconfirm visible changed: false');
  });
});
