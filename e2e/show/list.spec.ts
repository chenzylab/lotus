import { test, expect } from '@playwright/test';

test.describe('List', () => {
  test('dataSource + renderItem 渲染对应数量的 item', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('基础 List');
    await expect(list.locator('.lotus-list-item-wrapper')).toHaveCount(3);
    await expect(list).toContainText('第一条内容');
    await expect(list).toContainText('第三条内容');
  });

  test('ListItem 的 header/main/extra 各自渲染到对应位置，List 的 header/footer 正常显示', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('模板 List');
    await expect(list.locator('.lotus-list-header')).toHaveText('团队成员');
    await expect(list.locator('.lotus-list-footer')).toHaveText('共 2 人');

    const firstItem = list.locator('.lotus-list-item').first();
    await expect(firstItem.locator('.lotus-list-item-body-header')).toHaveText('张三');
    await expect(firstItem.locator('.lotus-list-item-body-main')).toHaveText('前端工程师');
    await expect(firstItem.locator('.lotus-list-item-extra')).toContainText('详情');
  });

  test('layout=horizontal 时渲染横向排列 class', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('horizontal List');
    await expect(list).toHaveClass(/lotus-list-horizontal/);
    await expect(list.locator('.lotus-list-item-wrapper')).toHaveCount(3);
  });

  test('grid 布局渲染响应式栅格，每个 item 被 Col 包裹', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('grid List');
    await expect(list.locator('.lotus-card')).toHaveCount(3);
    await expect(list).toContainText('卡片一');
    await expect(list).toContainText('卡片二');
  });

  test('loading 时显示 Spin 遮罩', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('loading List');
    await expect(list.locator('.lotus-spin')).toBeVisible();
  });

  test('dataSource 为空数组时显示默认空状态文案', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('empty List');
    await expect(list.locator('.lotus-list-empty')).toHaveText('暂无数据');
  });
});
