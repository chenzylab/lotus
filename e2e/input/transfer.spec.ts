import { test, expect } from '@playwright/test';

test.describe('Transfer', () => {
  test('基础用法：渲染左右两栏，初始选中值正确回显', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    await expect(root.locator('.lotus-transfer-panel-left .lotus-transfer-source-item')).toHaveCount(5);
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(2);
    await expect(rightItems.nth(0)).toHaveText('苹果');
    await expect(rightItems.nth(1)).toHaveText('樱桃');
  });

  test('过滤器/列表容器的 aria-label 走本地化文案（回归防护：此前硬编码英文字面量 "Transfer filter"/"Option list"/"Selected list"，不随语言切换更新）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    await expect(root.locator('[role="search"]')).toHaveAttribute('aria-label', '过滤器');
    await expect(root.locator('.lotus-transfer-panel-left [role="list"]')).toHaveAttribute('aria-label', '可选列表');
    await expect(root.locator('.lotus-transfer-panel-right [role="list"]')).toHaveAttribute('aria-label', '已选列表');
  });

  test('左侧勾选：新增项出现在右侧已选列表', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    await root.locator('input[aria-label="香蕉"]').locator('xpath=..').click();
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(3);
    await expect(rightItems.filter({ hasText: '香蕉' })).toHaveCount(1);
  });

  test('右侧点击移除：项从已选列表移除，左侧对应勾选框取消', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    await root.getByLabel('移除 苹果', { exact: true }).click();
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(1);
    await expect(root.locator('input[aria-label="苹果"]')).not.toBeChecked();
  });

  test('搜索过滤：只显示匹配项，清空搜索恢复全部', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    await root.locator('input[placeholder="搜索"]').fill('果');
    await expect(root.locator('.lotus-transfer-panel-left .lotus-transfer-source-item')).toHaveCount(2);
    await root.locator('input[placeholder="搜索"]').fill('');
    await expect(root.locator('.lotus-transfer-panel-left .lotus-transfer-source-item')).toHaveCount(5);
  });

  test('全选：非 disabled 项全部选中，disabled 项不受影响；再次点击变为清空', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 基础', { exact: true });
    const allButton = root.getByRole('button', { name: '全选' });
    await allButton.click();
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(4);
    await expect(rightItems.filter({ hasText: '芒果' })).toHaveCount(0);

    const clearButton = root.getByRole('button', { name: '清空所选' });
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(rightItems).toHaveCount(0);
  });

  test('type=groupList：左侧渲染分组标题，跨组全选生效', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 分组', { exact: true });
    await expect(root.locator('.lotus-transfer-group-title')).toHaveCount(2);
    await expect(root.locator('.lotus-transfer-group-title').nth(0)).toHaveText('水果');
    await expect(root.locator('.lotus-transfer-group-title').nth(1)).toHaveText('蔬菜');

    await root.getByRole('button', { name: '全选' }).click();
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(3);
    await expect(rightItems.filter({ hasText: '黄瓜' })).toHaveCount(0);
  });

  test('type=treeList：父节点勾选级联选中全部子孙节点', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 树形', { exact: true });
    await root.locator('input[aria-label="研发部"]').locator('xpath=..').click();
    const rightItems = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(rightItems).toHaveCount(7);
    await expect(rightItems.filter({ hasText: '张三' })).toHaveCount(1);
    await expect(rightItems.filter({ hasText: '产品部' })).toHaveCount(0);
  });

  test('draggable：拖拽已选项调整顺序', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 拖拽', { exact: true });
    await root.getByRole('button', { name: '全选' }).click();

    const items = root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label');
    await expect(items).toHaveCount(4);
    await expect(items.nth(0)).toHaveText('苹果');

    const firstHandle = root.locator('.lotus-transfer-drag-handle').first();
    await firstHandle.scrollIntoViewIfNeeded();
    const handleBox = await firstHandle.boundingBox();
    const lastItem = root.locator('.lotus-transfer-selected-item').nth(3);
    const lastBox = await lastItem.boundingBox();
    if (!handleBox || !lastBox) throw new Error('no bounding box');

    await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(handleBox.x + handleBox.width / 2, lastBox.y + lastBox.height / 2 + 5, { steps: 5 });
    await page.mouse.up();

    await expect(items.nth(3)).toHaveText('苹果');
  });

  test('virtualize：全选后已选数量正确，但 DOM 只渲染可见区间；滚动后切换渲染内容', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 虚拟化', { exact: true });
    await root.getByRole('button', { name: '全选' }).click();
    await expect(root.locator('.lotus-transfer-panel-right .lotus-transfer-header-title')).toHaveText('60 项已选');

    const renderedCount = await root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item').count();
    expect(renderedCount).toBeLessThan(60);
    await expect(root.locator('.lotus-transfer-selected-item-label').first()).toHaveText('选项 1');

    const scroller = root.locator('.lotus-transfer-list-virtual');
    await scroller.evaluate((el) => {
      el.scrollTop = 800;
      el.dispatchEvent(new Event('scroll', { bubbles: true }));
    });
    await expect(root.locator('.lotus-transfer-selected-item-label').filter({ hasText: '选项 20' })).toHaveCount(1);
  });

  test('disabled：整体禁用时勾选框和搜索框均不可交互', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 禁用', { exact: true });
    await expect(root.locator('input[aria-label="香蕉"]')).toBeDisabled();
    await expect(root.locator('input[placeholder="搜索"]')).toBeDisabled();
    await expect(root.locator('.lotus-transfer-panel-right .lotus-transfer-selected-item-label')).toHaveCount(1);
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Transfer 选中值' });

    await expect(root.locator('.lotus-transfer-panel-right .lotus-transfer-header-title')).toHaveText('1 项已选');
    await toggleButton.click();
    await expect(root.locator('.lotus-transfer-panel-right .lotus-transfer-header-title')).toHaveText('0 项已选');
    await toggleButton.click();
    await expect(root.locator('.lotus-transfer-panel-right .lotus-transfer-header-title')).toHaveText('2 项已选');
  });

  test('renderSourceItem/renderSelectedItem：自定义渲染生效，onChange/onRemove/dragHandleOnMouseDown 回调可用（回归防护：@if/@else 分支体内单一插值这个 tsrx 编译器缺陷曾导致自定义渲染内容完全空白，改用三元表达式修复；同时 onChange/onRemove 是这次调研新补的真实缺口——此前 renderSourceItem 只接收 checked、renderSelectedItem 完全不接收任何回调，自定义渲染后彻底失去选中/移除能力）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer renderItem 自定义示例', { exact: true });
    const sourceItems = root.locator('.lotus-transfer-source-item');
    await expect(sourceItems.first()).toHaveText('★ 苹果');

    await sourceItems.first().locator('div').first().click();
    const selectedItems = root.locator('.lotus-transfer-selected-item');
    await expect(selectedItems).toHaveCount(1);
    await expect(selectedItems.first()).toContainText('◆ 苹果');
    await expect(root.getByLabel('拖拽手柄 苹果', { exact: true })).toBeVisible();

    await root.getByLabel('移除 苹果', { exact: true }).click();
    await expect(selectedItems).toHaveCount(0);
  });

  test('inputProps：透传给搜索框，maxLength 生效', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer inputProps 示例', { exact: true });
    const input = root.locator('input').first();
    await input.fill('12345678901234567890');
    await expect(input).toHaveValue('1234567890');
  });

  test('treeProps：透传给内部 Tree 组件，defaultExpandAll 生效', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer treeProps 示例', { exact: true });
    await expect(root.locator('[aria-expanded="true"]').first()).toBeVisible();
  });

  test('renderSourceHeader/renderSelectedHeader：自定义头部渲染，全选/清空回调正确触发', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Transfer renderHeader 自定义示例', { exact: true });
    const sourceHeader = root.getByLabel('自定义源头部', { exact: true });
    const selectedHeader = root.getByLabel('自定义已选头部', { exact: true });
    await expect(sourceHeader).toContainText('共 5 项');
    await expect(selectedHeader).toContainText('已选 0 项');

    await sourceHeader.getByRole('button', { name: '全选' }).click();
    await expect(selectedHeader).toContainText(/已选 [1-9]\d* 项/);
  });

  test('renderSourcePanel/renderSelectedPanel：完全自定义面板渲染，选中/移除回调正确触发', async ({ page }) => {
    await page.goto('/');
    const sourcePanel = page.getByLabel('自定义源面板', { exact: true });
    const selectedPanel = page.getByLabel('自定义已选面板', { exact: true });
    await expect(sourcePanel).toContainText('5 项可选');

    await sourcePanel.locator('div', { hasText: '苹果' }).last().click();
    await expect(selectedPanel).toContainText('已选 1 项');

    await selectedPanel.getByRole('button', { name: '×' }).click();
    await expect(selectedPanel).toContainText('已选 0 项');
  });
});
