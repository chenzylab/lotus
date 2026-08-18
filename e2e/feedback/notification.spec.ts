import { test, expect } from '@playwright/test';

test.describe('Notification', () => {
  test('点击按钮触发 Notification.info，渲染出对应内容与 title', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Notification.info（topRight）', exact: true }).click();

    const notification = page.locator('.lotus-notification-info');
    await expect(notification).toBeVisible();
    await expect(notification.locator('.lotus-notification-title')).toHaveText('通知标题');
    await expect(notification.locator('.lotus-notification-content')).toHaveText('这是通知内容');
  });

  test('不同 position 渲染到各自独立的定位容器', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Notification.info（topRight）', exact: true }).click();
    await page.getByRole('button', { name: 'Notification.success（bottomLeft）', exact: true }).click();

    await expect(page.locator('.lotus-notification-wrapper-topRight')).toBeVisible();
    await expect(page.locator('.lotus-notification-wrapper-bottomLeft')).toBeVisible();
    await expect(page.locator('.lotus-notification-wrapper-topLeft')).toHaveCount(0);
  });

  test('showClose 默认 true，点击关闭按钮后立即移除', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Notification.info（topRight）', exact: true }).click();

    const notification = page.locator('.lotus-notification-info');
    await expect(notification).toBeVisible();

    await notification.getByRole('button', { name: '关闭' }).click();
    await expect(notification).not.toBeVisible();
  });

  test('同一 position 下连续触发多条，最新的插入最前面（unshift）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 2 条（topRight）', exact: true }).click();

    const wrapper = page.locator('.lotus-notification-wrapper-topRight');
    const titles = wrapper.locator('.lotus-notification-title');

    await expect(titles).toHaveText(['错误二', '警告一']);
  });

  test('destroyAll() 清空全部通知并卸载挂载容器', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 2 条（topRight）', exact: true }).click();
    await expect(page.locator('.lotus-notification')).toHaveCount(2);

    await page.getByRole('button', { name: 'Notification.destroyAll', exact: true }).click();
    await expect(page.locator('.lotus-notification')).toHaveCount(0);
    await expect(page.locator('.lotus-notification-root')).toHaveCount(0);
  });
});
