import { test, expect } from '@playwright/test';

test.describe('Pagination', () => {
  test('总条数 95、页大小 10 时省略号正确截断，当前页高亮', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="基础分页器（受控）"]');
    // 排除上一页/下一页按钮——它们也带 .lotus-pagination-item class，只是额外
    // 带 .lotus-pagination-prev/.lotus-pagination-next 修饰符区分。
    const items = pagination.locator('.lotus-pagination-item:not(.lotus-pagination-prev):not(.lotus-pagination-next)');

    await expect(items).toHaveText(['1', '2', '3', '4', '...', '9', '10']);
    await expect(pagination.getByRole('button', { name: '第 3 页' })).toHaveClass(/lotus-pagination-item-active/);
  });

  test('点击页码触发 onPageChange，切换当前页高亮', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const pagination = page.locator('[aria-label="基础分页器（受控）"]');

    await pagination.getByRole('button', { name: '第 4 页' }).click();

    await expect(pagination.getByRole('button', { name: '第 4 页' })).toHaveClass(/lotus-pagination-item-active/);
    expect(logs.some((l) => l.includes('pagination page changed'))).toBe(true);
  });

  test('点击下一页/上一页按钮正确翻页', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="基础分页器（受控）"]');

    await pagination.getByRole('button', { name: '下一页' }).click();
    await expect(pagination.getByRole('button', { name: '第 4 页' })).toHaveClass(/lotus-pagination-item-active/);

    await pagination.getByRole('button', { name: '上一页' }).click();
    await pagination.getByRole('button', { name: '上一页' }).click();
    await expect(pagination.getByRole('button', { name: '第 2 页' })).toHaveClass(/lotus-pagination-item-active/);
  });

  test('showTotal 显示总条数文案', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="基础分页器（受控）"]');

    await expect(pagination.locator('.lotus-pagination-total')).toHaveText('共 95 条');
  });

  test('quick jumper 输入页码回车后跳转', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="基础分页器（受控）"]');
    const jumpInput = pagination.locator('.lotus-pagination-quick-jumper-input');

    await jumpInput.fill('7');
    await jumpInput.press('Enter');

    await expect(pagination.getByRole('button', { name: '第 7 页' })).toHaveClass(/lotus-pagination-item-active/);
  });

  test('total=500 时中间态截断（前后各一个省略号）', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="小尺寸分页器（省略号截断）"]');
    const items = pagination.locator('.lotus-pagination-item:not(.lotus-pagination-prev):not(.lotus-pagination-next)');

    await expect(items).toHaveText(['1', '...', '9', '10', '11', '...', '50']);
    await expect(pagination).toHaveClass(/lotus-pagination-size-small/);
  });

  test('省略号 hover 展开完整页码 Popover 列表，点击其中一项跳转', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="小尺寸分页器（省略号截断）"]');
    const leftEllipsis = pagination.locator('.lotus-pagination-ellipsis').first();

    await leftEllipsis.hover();
    const restList = page.locator('.lotus-pagination-rest-list');
    await expect(restList).toBeVisible();
    await expect(restList.locator('.lotus-pagination-rest-item').first()).toHaveText('2');
    await expect(restList.locator('.lotus-pagination-rest-item').last()).toHaveText('8');

    await restList.getByText('5', { exact: true }).click();
    await expect(pagination.getByRole('button', { name: '第 5 页' })).toHaveClass(/lotus-pagination-item-active/);
  });

  test('prevText/nextText：自定义上一页/下一页按钮文案替换默认图标', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="Pagination prevText/nextText/popoverPosition 示例"]');

    await expect(pagination.locator('.lotus-pagination-prev')).toHaveText('上一页');
    await expect(pagination.locator('.lotus-pagination-next')).toHaveText('下一页');
  });

  test('hideOnSinglePage：只有一页时整个组件不渲染，多页时正常渲染', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('[aria-label="Pagination hideOnSinglePage 多页示例"]')).toBeVisible();
    await expect(page.locator('[aria-label="Pagination hideOnSinglePage 单页隐藏示例"]')).toHaveCount(0);
  });

  test('hoverShowPageSelect：size=small 紧凑布局显示"当前页/总页数"，hover 弹出全部页码', async ({ page }) => {
    await page.goto('/');
    const pagination = page.locator('[aria-label="Pagination hoverShowPageSelect 紧凑布局示例"]');
    const compact = pagination.locator('.lotus-pagination-item-small');

    await expect(compact).toHaveText('10/50');
    await expect(pagination.locator('.lotus-pagination-item:not(.lotus-pagination-prev):not(.lotus-pagination-next):not(.lotus-pagination-item-small)')).toHaveCount(0);

    await compact.hover();
    const restList = page.locator('.lotus-pagination-rest-list');
    await expect(restList).toBeVisible();
    await expect(restList.locator('.lotus-pagination-rest-item')).toHaveCount(50);

    await restList.getByText('42', { exact: true }).click();
    await expect(compact).toHaveText('42/50');
  });
});
