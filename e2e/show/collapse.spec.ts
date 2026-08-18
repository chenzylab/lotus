import { test, expect } from '@playwright/test';

test.describe('Collapse', () => {
  test('defaultActiveKey 初始展开，点击 header 切换展开/收起状态', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('基础 Collapse');
    const panel1 = collapse.locator('.lotus-collapse-panel').nth(0);
    const panel2 = collapse.locator('.lotus-collapse-panel').nth(1);

    await expect(panel1).toHaveClass(/lotus-collapse-panel-active/);
    await expect(panel2).not.toHaveClass(/lotus-collapse-panel-active/);

    await collapse.locator('.lotus-collapse-header').nth(1).click();
    await expect(panel2).toHaveClass(/lotus-collapse-panel-active/);

    await collapse.locator('.lotus-collapse-header').nth(0).click();
    await expect(panel1).not.toHaveClass(/lotus-collapse-panel-active/);

    // 非 accordion 模式：panel1 收起后 panel2 应该仍保持展开（可同时展开多个）
    await expect(panel2).toHaveClass(/lotus-collapse-panel-active/);
  });

  test('disabled 面板点击 header 不会展开', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('基础 Collapse');
    const disabledPanel = collapse.locator('.lotus-collapse-panel').nth(2);
    const disabledHeader = collapse.locator('.lotus-collapse-header').nth(2);

    await expect(disabledHeader).toHaveAttribute('aria-disabled', 'true');
    await disabledHeader.click({ force: true });
    await expect(disabledPanel).not.toHaveClass(/lotus-collapse-panel-active/);
  });

  test('accordion 模式：展开一个面板自动收起其他已展开的面板', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('accordion Collapse');
    const panelA = collapse.locator('.lotus-collapse-panel').nth(0);
    const panelB = collapse.locator('.lotus-collapse-panel').nth(1);

    await expect(panelA).toHaveClass(/lotus-collapse-panel-active/);

    await collapse.locator('.lotus-collapse-header').nth(1).click();

    await expect(panelB).toHaveClass(/lotus-collapse-panel-active/);
    await expect(panelA).not.toHaveClass(/lotus-collapse-panel-active/);
    await expect(collapse.locator('.lotus-collapse-panel-active')).toHaveCount(1);
  });

  test('expandIconPosition=left 时图标渲染在 header 左侧，extra 内容出现在右侧', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('left 图标 Collapse');
    await expect(collapse.locator('.lotus-collapse-header')).toHaveClass(/lotus-collapse-header-icon-left/);
    await expect(collapse.locator('.lotus-collapse-header-extra')).toHaveText('额外信息');
  });

  test('受控模式：activeKey 由外部按钮驱动，非组件自身交互触发', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('受控 Collapse');
    await expect(collapse.locator('.lotus-collapse-panel-active')).toHaveCount(0);

    await page.getByRole('button', { name: '展开面板一' }).click();
    await expect(collapse.locator('.lotus-collapse-panel').nth(0)).toHaveClass(/lotus-collapse-panel-active/);

    await page.getByRole('button', { name: '全部收起' }).click();
    await expect(collapse.locator('.lotus-collapse-panel-active')).toHaveCount(0);
  });

  test('aria-expanded 随展开状态同步切换', async ({ page }) => {
    await page.goto('/');
    const collapse = page.getByLabel('基础 Collapse');
    const header1 = collapse.locator('.lotus-collapse-header').nth(0);

    await expect(header1).toHaveAttribute('aria-expanded', 'true');
    await header1.click();
    await expect(header1).toHaveAttribute('aria-expanded', 'false');
  });
});
