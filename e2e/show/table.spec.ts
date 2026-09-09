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

  test('resizable：拖拽表头右边界调整列宽，resize=false 的列不渲染拖拽手柄', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table resizable', { exact: true });
    await root.scrollIntoViewIfNeeded();

    const handles = root.locator('.lotus-table-resize-handle');
    await expect(handles).toHaveCount(3);

    const nameHeader = root.locator('thead th.lotus-table-header-cell').first();
    const widthBefore = (await nameHeader.boundingBox())!.width;

    const handle = handles.first();
    const box = (await handle.boundingBox())!;
    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x + box.width / 2 + 80, box.y + box.height / 2);
    await page.mouse.up();

    const widthAfter = (await nameHeader.boundingBox())!.width;
    expect(widthAfter - widthBefore).toBeGreaterThan(50);
    await expect(page.getByLabel('Table resize 日志', { exact: true })).toContainText('resizeStop');
  });

  test('sticky：表头 position:sticky 生效，滚动内层容器后吸顶', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table sticky', { exact: true });
    await root.scrollIntoViewIfNeeded();

    const thead = root.locator('thead');
    await expect(thead).toHaveClass(/lotus-table-thead-sticky/);
    await expect(thead).toHaveCSS('position', 'sticky');
  });

  test('onHeaderRow：表头行注入自定义属性', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table onHeaderRow', { exact: true });
    await expect(root.locator('thead tr')).toHaveAttribute('data-testid', 'custom-header-row');
  });

  test('showHeader=false：不渲染可见表头', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table showHeader false', { exact: true });
    await expect(root.locator('thead')).toBeHidden();
  });

  test('indentSize：树形子行按自定义缩进值渲染', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table indentSize', { exact: true });
    const childCell = root.locator('.lotus-table-row-child .lotus-table-expand-cell').first();
    await expect(childCell).toHaveCSS('padding-left', '40px');
  });

  test('keepDOM：收起的子行/展开内容仍保留 DOM，只是视觉隐藏', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table keepDOM', { exact: true });
    const childRow = root.locator('.lotus-table-row-child').first();
    await expect(childRow).toBeAttached();
    await expect(childRow).toBeHidden();

    await root.locator('.lotus-table-expand-btn').first().click();
    await expect(childRow).toBeVisible();
  });

  test('rowSpan：column.render 返回 { children, props: { rowSpan } } 合并单元格', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table rowSpan', { exact: true });
    const rows = root.locator('tbody tr');
    await expect(rows).toHaveCount(3);

    const firstRowFirstCell = rows.nth(0).locator('td').first();
    await expect(firstRowFirstCell).toHaveAttribute('rowspan', '2');
    await expect(rows.nth(1).locator('td')).toHaveCount(2);
  });

  test('rowSpanHover：hover 合并单元格覆盖的行时联动高亮', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table rowSpan', { exact: true });
    const rows = root.locator('tbody tr');

    await rows.nth(0).hover();
    await expect(rows.nth(0)).toHaveClass(/lotus-table-row-hovered/);
    await expect(rows.nth(1)).toHaveClass(/lotus-table-row-hovered/);
    await expect(rows.nth(2)).not.toHaveClass(/lotus-table-row-hovered/);
  });

  test('groupBy：按字段分组渲染标题行，defaultExpandAllGroupRows 默认全展开', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table groupBy', { exact: true });
    const sections = root.locator('.lotus-table-row-section');
    await expect(sections).toHaveCount(4);
    await expect(sections.first()).toContainText('分组：研发');

    const dataRows = root.locator('tbody tr:not(.lotus-table-row-section)');
    await expect(dataRows).toHaveCount(5);
  });

  test('groupBy：clickGroupedRowToExpand 点击标题行整体触发收起/展开，onGroupedRow 注入自定义属性', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table groupBy', { exact: true });
    const firstSection = root.locator('.lotus-table-row-section').first();
    await expect(firstSection).toHaveAttribute('data-testid', 'group-row');

    const dataRowsBefore = await root.locator('tbody tr:not(.lotus-table-row-section)').count();
    await firstSection.click();
    const dataRowsAfter = await root.locator('tbody tr:not(.lotus-table-row-section)').count();
    expect(dataRowsAfter).toBeLessThan(dataRowsBefore);

    await firstSection.click();
    const dataRowsRestored = await root.locator('tbody tr:not(.lotus-table-row-section)').count();
    expect(dataRowsRestored).toBe(dataRowsBefore);
  });

  test('aria-expanded：分组标题行与可展开的树形父行携带正确的展开态，无展开能力的普通行不携带该属性', async ({ page }) => {
    await page.goto('/');

    const group = page.getByLabel('Table groupBy', { exact: true });
    const firstSection = group.locator('.lotus-table-row-section').first();
    await expect(firstSection).toHaveAttribute('aria-expanded', 'true');
    await firstSection.click();
    await expect(firstSection).toHaveAttribute('aria-expanded', 'false');

    const tree = page.getByLabel('Table indentSize', { exact: true });
    const parentRow = tree.locator('tbody tr').first();
    await expect(parentRow).toHaveAttribute('aria-expanded', 'true');

    const basic = page.getByLabel('Table 基础', { exact: true });
    await expect(basic.locator('tbody tr').first()).not.toHaveAttribute('aria-expanded');
  });

  test('groupBy + 分页组合：分页按打平后整体顺序切，跨页的组标题在两页各自重新出现', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table groupBy 分页', { exact: true });
    await root.scrollIntoViewIfNeeded();

    const sectionsPage1 = root.locator('.lotus-table-row-section');
    await expect(sectionsPage1).toHaveCount(2);
    await expect(sectionsPage1.nth(0)).toContainText('研发');
    await expect(sectionsPage1.nth(1)).toContainText('产品');
    await expect(root.locator('tbody tr:not(.lotus-table-row-section)')).toHaveCount(6);

    await root.getByLabel('第 2 页', { exact: true }).click();

    const sectionsPage2 = root.locator('.lotus-table-row-section');
    await expect(sectionsPage2).toHaveCount(2);
    await expect(sectionsPage2.nth(0)).toContainText('产品');
    await expect(sectionsPage2.nth(1)).toContainText('设计');
    await expect(root.locator('tbody tr:not(.lotus-table-row-section)')).toHaveCount(6);
  });

  test('getVirtualizedListRef：scrollToItem 把指定行滚动进可见区间（lotus 自研虚拟滚动的同语义句柄，非透传 react-window 实例）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Table 虚拟滚动示例', { exact: true });
    await root.scrollIntoViewIfNeeded();

    const firstCell = root.locator('tbody tr.lotus-table-row').first().locator('td').nth(1);
    await expect(firstCell).toContainText('用户 0');

    await page.getByLabel('Table 滚动到第5000行', { exact: true }).click();
    await expect(firstCell).toContainText('用户 4997', { timeout: 5000 });
  });
});
