import { test, expect } from '@playwright/test';

test.describe('Empty', () => {
  test('无 image 时纯展示 title/description，图片容器仍渲染但内容为空', async ({ page }) => {
    await page.goto('/');
    const empty = page.getByLabel('纯文字 Empty（无 image）');
    await expect(empty.locator('.lotus-empty-content')).toContainText('暂无数据');
    await expect(empty.locator('.lotus-empty-content')).toContainText('换个筛选条件试试');
    // 没有 image 时容器仍渲染（对齐 Semi 行为），但内容为空、无实际渲染尺寸，
    // 因此断言"存在于 DOM"而非"可见"（toBeVisible 要求非零渲染尺寸）。
    await expect(empty.locator('.lotus-empty-image')).toBeAttached();
    await expect(empty.locator('.lotus-empty-image svg')).toHaveCount(0);
  });

  test('传入 image 时渲染插图', async ({ page }) => {
    await page.goto('/');
    const empty = page.getByLabel('带插图的 Empty');
    await expect(empty.locator('.lotus-empty-image svg')).toBeVisible();
    await expect(empty.locator('.lotus-empty-content')).toContainText('暂无内容');
  });

  test('children 渲染为底部操作区域', async ({ page }) => {
    await page.goto('/');
    const empty = page.getByLabel('带操作按钮的 Empty');
    const footer = empty.locator('.lotus-empty-footer');
    await expect(footer).toBeVisible();
    await expect(footer.getByRole('button', { name: '返回首页' })).toBeVisible();
  });

  test('layout=horizontal 时渲染横向布局 class', async ({ page }) => {
    await page.goto('/');
    const empty = page.getByLabel('horizontal 布局的 Empty');
    await expect(empty).toHaveClass(/lotus-empty-horizontal/);
    await expect(empty).not.toHaveClass(/lotus-empty-vertical/);
  });

  test('默认 layout 为 vertical', async ({ page }) => {
    await page.goto('/');
    const empty = page.getByLabel('纯文字 Empty（无 image）');
    await expect(empty).toHaveClass(/lotus-empty-vertical/);
  });
});
