import { test, expect } from '@playwright/test';

test.describe('OverflowList', () => {
  test('容器足够宽时全部项可见，无溢出提示', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('宽容器 OverflowList');
    await expect(list).toBeVisible();
    await expect(list.locator('.lotus-overflow-list-item')).toHaveCount(3);
    await expect(list.locator('.lotus-overflow-list-overflow')).toHaveCount(0);
  });

  test('窄容器：超出部分折叠为溢出提示（回归防护：ref 箭头函数包裹丢失清理函数导致测量数据被污染，踩坑 #69）', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('窄容器 OverflowList');
    await expect(list).toBeVisible();
    const visibleTexts = await list.locator('.lotus-overflow-list-item').allTextContents();
    expect(visibleTexts).toEqual(['标签一', '标签二', '标签三', '标签四']);
    await expect(list.locator('.lotus-overflow-list-overflow')).toHaveText('+2');
  });

  test('collapseFrom=start：折叠头部、保留尾部', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('collapseFrom start OverflowList');
    await expect(list).toBeVisible();
    const visibleTexts = await list.locator('.lotus-overflow-list-item').allTextContents();
    expect(visibleTexts).toEqual(['标签三', '标签四', '标签五', '标签六']);
    await expect(list.locator('.lotus-overflow-list-overflow')).toHaveText('+2');
  });

  test('minVisibleItems：即使容器极窄也至少保留指定数量的项', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('minVisibleItems OverflowList');
    await expect(list).toBeVisible();
    await expect(list.locator('.lotus-overflow-list-item')).toHaveCount(2);
  });

  test('容器 role=list，每项 role=listitem（基础无障碍语义）', async ({ page }) => {
    await page.goto('/');
    const list = page.getByLabel('窄容器 OverflowList');
    await expect(list).toHaveAttribute('role', 'list');
    const firstItem = list.locator('.lotus-overflow-list-item').first();
    await expect(firstItem).toHaveAttribute('role', 'listitem');
  });
});
