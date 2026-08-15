import { test, expect } from '@playwright/test';

test.describe('Avatar', () => {
  test('图片头像成功加载后渲染 img 标签', async ({ page }) => {
    await page.goto('/');
    const img = page.locator('img[alt="avatar image"]');
    await expect(img).toBeVisible();
  });

  test('文字头像内容按 alt 生成 aria-label 供屏幕阅读器识别', async ({ page }) => {
    await page.goto('/');
    const label = page.getByRole('img', { name: 'Alice Swift' });
    await expect(label).toBeVisible();
    await expect(label).toHaveText('AS');
  });
});

test.describe('AvatarGroup', () => {
  test('超出 maxCount 的头像被折叠为 +N 更多标签', async ({ page }) => {
    await page.goto('/');
    const group = page.locator('.lotus-avatar-group');
    // 5 个真实头像，maxCount=3 → 可见 3 个真实头像 + 1 个 "+2" 聚合头像
    await expect(group.getByText('LL', { exact: true })).toBeVisible();
    await expect(group.getByText('CX', { exact: true })).toBeVisible();
    await expect(group.getByText('RM', { exact: true })).toBeVisible();
    await expect(group.getByText('+2', { exact: true })).toBeVisible();
    await expect(group.getByText('ZL', { exact: true })).not.toBeAttached();
  });
});
