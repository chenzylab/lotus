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

  test('重复挂载/卸载 100 次无残留：触发+destroyAll 循环后 DOM 干净、挂载容器不累积（回归防护：同 Toast 一致的单例懒挂载设计，参照 e2e/feedback/toast.spec.ts 同名测试）', async ({ page }) => {
    await page.goto('/');
    const triggerBtn = page.getByRole('button', { name: '连续触发 2 条（topRight）', exact: true });
    const destroyBtn = page.getByRole('button', { name: 'Notification.destroyAll', exact: true });

    for (let i = 0; i < 100; i++) {
      await triggerBtn.click();
      await destroyBtn.click();
    }

    await expect(page.locator('.lotus-notification')).toHaveCount(0);
    await expect(page.locator('.lotus-notification-root')).toHaveCount(0);

    await triggerBtn.click();
    await expect(page.locator('.lotus-notification')).toHaveCount(2);
    await expect(page.locator('.lotus-notification-root')).toHaveCount(1);
    await destroyBtn.click();
  });

  test('theme=light：渲染出对应语义色的浅底 + 边框（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Notification（theme=light）', exact: true }).click();

    const notification = page.locator('.lotus-notification-theme-light');
    await expect(notification).toBeVisible();
    await expect(notification).toHaveCSS('border-color', 'rgb(0, 100, 250)');
  });

  test('onClick/onClose/onCloseClick：点击卡片本身触发 onClick，点击关闭按钮先触发 onCloseClick 再触发 onClose（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    await page.getByRole('button', { name: 'Notification（onClick/onClose/onCloseClick）', exact: true }).click();

    const notification = page.locator('.lotus-notification').first();
    await notification.click({ position: { x: 5, y: 5 } });
    expect(logs).toContain('notification onClick fired');
    expect(logs).not.toContain('notification onClose fired');

    await notification.getByRole('button', { name: '关闭' }).click();
    expect(logs.some((log) => log.startsWith('notification onCloseClick fired: lotus-notification-'))).toBe(true);
    expect(logs).toContain('notification onClose fired');
  });

  test('config：全局配置对已挂载的容器实时生效，无需 destroyAll 重新挂载（对齐 Semi 每次 render 都重新读配置的响应式行为）', async ({ page }) => {
    await page.goto('/');
    // 先触发一次普通 Notification，确保容器已挂载（非首次挂载场景）。
    await page.getByRole('button', { name: 'Notification.info（topRight）', exact: true }).click();
    await expect(page.locator('.lotus-notification')).toBeVisible();
    await page.getByRole('button', { name: 'Notification.destroyAll', exact: true }).click();

    await page.getByRole('button', { name: 'Notification.config（全局 position=bottomRight）', exact: true }).click();
    const notification = page.locator('.lotus-notification', { hasText: 'config 全局配置后触发' });
    await expect(notification).toBeVisible();
    await expect(page.locator('.lotus-notification-wrapper-bottomRight')).toContainText('config 全局配置后触发');
  });
});
