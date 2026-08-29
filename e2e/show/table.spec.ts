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

  test('固定列：左右固定列真实生效——渲染 position:sticky，滚动容器后固定列保持原位、非固定列跟随滚动（回归防护：column.fixed 此前是从未消费的死 prop，此测试此前只断言过表头文字，未验证任何 sticky 定位样式）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 固定列', { exact: true });
    await root.scrollIntoViewIfNeeded();

    const nameHeader = root.locator('thead th.lotus-table-header-cell').first();
    const actionHeader = root.locator('thead th.lotus-table-header-cell').last();
    const ageHeader = root.locator('thead th.lotus-table-header-cell').nth(1);

    await expect(nameHeader).toHaveText('姓名');
    await expect(nameHeader).toHaveCSS('position', 'sticky');
    await expect(nameHeader).toHaveCSS('left', '0px');
    await expect(nameHeader).toHaveClass(/lotus-table-cell-fixed-left-last/);

    await expect(actionHeader).toHaveText('操作');
    await expect(actionHeader).toHaveCSS('position', 'sticky');
    await expect(actionHeader).toHaveCSS('right', '0px');
    await expect(actionHeader).toHaveClass(/lotus-table-cell-fixed-right-first/);

    const scrollEl = root.locator('.lotus-table-scroll');
    const nameBefore = await nameHeader.boundingBox();
    const actionBefore = await actionHeader.boundingBox();
    const ageBefore = await ageHeader.boundingBox();
    if (!nameBefore || !actionBefore || !ageBefore) throw new Error('no bounding box before scroll');

    await scrollEl.evaluate((el) => { el.scrollLeft = 200; });

    const nameAfter = await nameHeader.boundingBox();
    const actionAfter = await actionHeader.boundingBox();
    const ageAfter = await ageHeader.boundingBox();
    if (!nameAfter || !actionAfter || !ageAfter) throw new Error('no bounding box after scroll');

    expect(Math.abs(nameAfter.x - nameBefore.x)).toBeLessThan(1);
    expect(Math.abs(actionAfter.x - actionBefore.x)).toBeLessThan(1);
    expect(ageBefore.x - ageAfter.x).toBeCloseTo(200, 0);

    // 数据行的固定列单元格同样要 sticky（不止表头），否则纵向滚动时表头和
    // 数据行的固定列会视觉错位。
    const firstBodyRow = root.locator('tbody tr.lotus-table-row').first();
    const nameBodyCell = firstBodyRow.locator('td.lotus-table-cell-fixed').first();
    await expect(nameBodyCell).toHaveCSS('position', 'sticky');
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

  test('virtualize：1万行数据只渲染可见区间，滚动后动态切换渲染内容，勾选状态不受虚拟化裁剪影响', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 虚拟滚动示例');
    await root.scrollIntoViewIfNeeded();

    const rows = root.locator('tbody tr.lotus-table-row');
    const renderedCount = await rows.count();
    expect(renderedCount).toBeLessThan(30);
    expect(renderedCount).toBeGreaterThan(0);

    await expect(rows.first().locator('td').nth(1)).toContainText('用户 0');

    const firstRowCheckbox = rows.first().locator('input[type="checkbox"]');
    await firstRowCheckbox.locator('xpath=..').click();
    await expect(page.getByLabel('Table 虚拟滚动选中日志')).toHaveText('已选：1 条');

    const scrollDiv = root.locator('.lotus-table-scroll');
    await scrollDiv.evaluate((el) => { el.scrollTop = 5000; });
    await expect(rows.first().locator('td').nth(1)).not.toContainText('用户 0');

    await scrollDiv.evaluate((el) => { el.scrollTop = 0; });
    await expect(rows.first().locator('td').nth(1)).toContainText('用户 0');
    await expect(rows.first().locator('input[type="checkbox"]')).toBeChecked();
    await expect(page.getByLabel('Table 虚拟滚动选中日志')).toHaveText('已选：1 条');
  });
});
