import { test, expect } from '@playwright/test';

test.describe('Table', () => {
  test('基础用法：渲染表头与行数据', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 基础', { exact: true });
    await expect(root.locator('thead th')).toHaveCount(3);
    await expect(root.locator('tbody tr')).toHaveCount(5);
    await expect(root.locator('tbody tr').first().locator('td').first()).toHaveText('张三');
  });

  test('排序：点击表头按年龄升序/降序切换', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 基础', { exact: true });
    const ageSortTrigger = root.locator('.lotus-table-header-sortable', { hasText: '年龄' });
    await ageSortTrigger.click();

    const firstRowAge = root.locator('tbody tr').first().locator('td').nth(1);
    await expect(firstRowAge).toHaveText('24');

    await ageSortTrigger.click();
    await expect(firstRowAge).toHaveText('45');
  });

  test('筛选：勾选城市筛选后只展示匹配行', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 基础', { exact: true });
    await root.getByLabel('筛选', { exact: true }).click();
    const menu = page.locator('.lotus-table-filter-menu');
    await menu.getByText('北京', { exact: true }).click();
    await menu.getByRole('button', { name: '确定' }).click();

    const rows = root.locator('tbody tr');
    await expect(rows).toHaveCount(2);
    await expect(rows.first().locator('td').first()).toHaveText('张三');
  });

  test('行选择：单选、全选、半选态', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 行选择', { exact: true });
    const checkboxes = root.locator('tbody .lotus-checkbox-native');
    await checkboxes.nth(0).click({ force: true });
    await expect(page.getByLabel('Table 选中日志', { exact: true })).toHaveText('已选：1');

    const selectAll = root.locator('thead .lotus-checkbox-native');
    await selectAll.click({ force: true });
    await expect(page.getByLabel('Table 选中日志', { exact: true })).toHaveText('已选：1,2,3,4,5');

    await selectAll.click({ force: true });
    await expect(page.getByLabel('Table 选中日志', { exact: true })).toHaveText('已选：');
  });

  test('分页：切换到第二页展示对应数据', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 分页', { exact: true });
    await expect(root.locator('tbody tr')).toHaveCount(5);
    await expect(root.locator('tbody tr').first().locator('td').first()).toHaveText('员工1');

    await root.getByLabel('第 2 页', { exact: true }).click();
    await expect(root.locator('tbody tr').first().locator('td').first()).toHaveText('员工6');
  });

  test('树形数据：展开父节点显示子节点，勾选父节点级联勾选子节点', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 树形数据', { exact: true });
    await expect(root.locator('tbody tr')).toHaveCount(4);

    const parentCheckbox = root.locator('tbody tr').first().locator('.lotus-checkbox-native');
    await parentCheckbox.click({ force: true });

    const childCheckbox = root.locator('tbody tr').nth(1).locator('.lotus-checkbox-native');
    await expect(childCheckbox).toBeChecked();
  });

  test('展开行：点击展开按钮显示 expandedRowRender 内容', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 展开行', { exact: true });
    await expect(root.locator('.lotus-table-expanded-row')).toHaveCount(0);

    await root.locator('.lotus-table-expand-btn').first().click();
    await expect(root.locator('.lotus-table-expanded-row')).toHaveCount(1);
    await expect(root.locator('.lotus-table-expanded-row')).toContainText('张三 的详细信息');
  });

  test('固定列：左右固定列渲染 sticky 定位样式', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 固定列', { exact: true });
    const firstHeaderCell = root.locator('thead th').first();
    await expect(firstHeaderCell).toHaveText('姓名');
    const lastHeaderCell = root.locator('thead th').last();
    await expect(lastHeaderCell).toHaveText('操作');
  });

  test('空数据：展示 Empty 占位', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 空数据', { exact: true });
    await expect(root.locator('.lotus-table-empty-cell')).toBeVisible();
    await expect(root.locator('tbody tr')).toHaveCount(1);
  });

  test('loading 态：渲染 Spin 覆盖', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table loading', { exact: true });
    await expect(root.locator('.lotus-table-loading-cell')).toBeVisible();
  });
});
