import { test, expect } from '@playwright/test';

test.describe('Descriptions', () => {
  test('vertical 布局：每条数据独立一行', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('vertical Descriptions');
    await expect(descriptions.locator('.lotus-descriptions-row')).toHaveCount(3);
    await expect(descriptions).toContainText('姓名');
    await expect(descriptions).toContainText('张三');
  });

  test('horizontal 布局：按 column 分组，span 影响换行与占列', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('horizontal Descriptions');
    const rows = descriptions.locator('.lotus-descriptions-row');
    await expect(rows).toHaveCount(3);

    // 第一行：姓名/部门/职级 三个 span=1 的 item 累计到 column=3
    await expect(rows.nth(0)).toContainText('姓名');
    await expect(rows.nth(0)).toContainText('部门');
    await expect(rows.nth(0)).toContainText('职级');

    // 第二行：简介单独一行（span=3）
    await expect(rows.nth(1)).toContainText('简介');
    await expect(rows.nth(1)).not.toContainText('邮箱');

    // 第三行：邮箱(span=2) + 状态(span=1)
    await expect(rows.nth(2)).toContainText('邮箱');
    await expect(rows.nth(2)).toContainText('状态');
  });

  test('align=plain：key 后跟冒号，inline 展示', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('plain Descriptions');
    await expect(descriptions).toHaveClass(/lotus-descriptions-plain/);
    await expect(descriptions.locator('.lotus-descriptions-key').first()).toHaveText('姓名:');
  });

  test('row：双行/网格展示，class 带 lotus-descriptions-double', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('row Descriptions');
    await expect(descriptions).toHaveClass(/lotus-descriptions-double/);
    await expect(descriptions).toHaveClass(/lotus-descriptions-double-medium/);
  });

  test('hidden 条目不渲染，value 支持懒渲染函数', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('hidden 与懒渲染 Descriptions');
    await expect(descriptions).not.toContainText('内部字段');
    await expect(descriptions).not.toContainText('不应显示');
    await expect(descriptions).toContainText('懒渲染函数返回值');
  });

  test('vertical 布局下没有列重叠：key/value 各自独立单元格宽度', async ({ page }) => {
    await page.goto('/');
    const descriptions = page.getByLabel('vertical Descriptions');
    const firstRow = descriptions.locator('.lotus-descriptions-row').first();
    const keyBox = await firstRow.locator('.lotus-descriptions-key').boundingBox();
    const valueBox = await firstRow.locator('.lotus-descriptions-value').boundingBox();
    expect(keyBox).not.toBeNull();
    expect(valueBox).not.toBeNull();
    // value 的左边界应该在 key 右边界之后（不重叠）
    expect(valueBox!.x).toBeGreaterThanOrEqual(keyBox!.x + keyBox!.width);
  });
});
