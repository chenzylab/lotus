import { test, expect } from '@playwright/test';

test.describe('Toast', () => {
  test('点击按钮触发 Toast.info，渲染出对应内容', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.info', exact: true }).click();

    const toast = page.locator('.lotus-toast-info');
    await expect(toast).toBeVisible();
    await expect(toast.locator('.lotus-toast-content')).toHaveText('这是一条 info 提示');
  });

  test('showClose=true 时渲染关闭按钮，点击后立即移除', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.success（可关闭）', exact: true }).click();

    const toast = page.locator('.lotus-toast-success');
    await expect(toast).toBeVisible();

    await toast.getByRole('button', { name: '关闭' }).click();
    await expect(toast).not.toBeVisible();
  });

  test('duration 到期后自动移除（默认 3 秒）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'Toast.info', exact: true }).click();

    const toast = page.locator('.lotus-toast-info');
    await expect(toast).toBeVisible();
    await expect(toast).not.toBeVisible({ timeout: 4000 });
  });

  test('连续触发多条 Toast 时全部同时显示，各自独立', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 3 条', exact: true }).click();

    await expect(page.locator('.lotus-toast-warning')).toBeVisible();
    await expect(page.locator('.lotus-toast-error')).toBeVisible();
    await expect(page.locator('.lotus-toast-info')).toBeVisible();

    const count = await page.locator('.lotus-toast').count();
    expect(count).toBe(3);
  });

  test('destroyAll() 清空全部通知并卸载挂载容器', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '连续触发 3 条', exact: true }).click();
    await expect(page.locator('.lotus-toast')).toHaveCount(3);

    await page.getByRole('button', { name: 'destroyAll', exact: true }).click();
    await expect(page.locator('.lotus-toast')).toHaveCount(0);
    await expect(page.locator('.lotus-toast-root')).toHaveCount(0);
  });

  test('重复挂载/卸载 100 次无残留：触发+destroyAll 循环后 DOM 干净、挂载容器不累积（回归防护：容器采用单例懒挂载设计——ensureMounted 只在首次调用时创建 div，后续 open() 复用同一容器，"挂载/卸载"的真实含义是 destroyAll 卸载单例容器 + 下次 open() 重新走 ensureMounted 创建新容器，不是每次 Toast 调用都新建/销毁一个容器）', async ({ page }) => {
    await page.goto('/');
    const triggerBtn = page.getByRole('button', { name: '连续触发 3 条', exact: true });
    const destroyBtn = page.getByRole('button', { name: 'destroyAll', exact: true });

    for (let i = 0; i < 100; i++) {
      await triggerBtn.click();
      await destroyBtn.click();
    }

    await expect(page.locator('.lotus-toast')).toHaveCount(0);
    // 每次 destroyAll 都应该把上一个容器彻底卸载，100 次循环后 DOM 里
    // 不应该残留任何一个旧容器——如果容器卸载逻辑有遗漏（比如 unmountFn
    // 调用失败但 mounted 标记仍被重置），会在 body 下越堆越多同名容器。
    await expect(page.locator('.lotus-toast-root')).toHaveCount(0);

    // 循环后再正常触发一次，验证容器仍能正确重新创建并渲染（不是"表面上
    // count 为 0，但实际底层状态已经损坏、后续调用不再生效"这种假阳性）。
    await triggerBtn.click();
    await expect(page.locator('.lotus-toast')).toHaveCount(3);
    await expect(page.locator('.lotus-toast-root')).toHaveCount(1);
    await destroyBtn.click();
  });
});
