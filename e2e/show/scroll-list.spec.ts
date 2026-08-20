import { test, expect } from '@playwright/test';

test.describe('ScrollList', () => {
  test('wheel + cycled 模式：初始渲染正确的选中项', async ({ page }) => {
    await page.goto('/');
    const hourList = page.getByLabel('小时选择');
    await expect(hourList).toBeVisible();
    await expect(hourList.locator('.lotus-scroll-item-option-selected').first()).toHaveText('03');
    const hourWrapper = hourList.locator('xpath=ancestor::div[contains(concat(" ", normalize-space(@class), " "), " lotus-scroll-item ")][1]');
    await expect(hourWrapper.locator('.lotus-scroll-item-selector')).toBeVisible();
  });

  test('cycled 模式：渲染出多组循环副本（回归防护：flex:1 无高度约束导致的正反馈死循环，踩坑 #70）', async ({ page }) => {
    await page.goto('/');
    const hourList = page.getByLabel('小时选择');
    await expect(hourList).toBeVisible();
    const optionCount = await hourList.locator('.lotus-scroll-item-option').count();
    // 24 项数据，cycled 模式渲染若干组完整副本，数量应在合理范围（不应失控增长到成千上万）
    expect(optionCount).toBeGreaterThan(24);
    expect(optionCount).toBeLessThan(300);
  });

  test('normal 模式：点击直接选中，无中心选择框', async ({ page }) => {
    await page.goto('/');
    const fruitList = page.getByLabel('水果选择');
    await expect(fruitList).toBeVisible();
    await expect(fruitList.locator('.lotus-scroll-item-selector')).toHaveCount(0);
    await expect(fruitList.locator('.lotus-scroll-item-option')).toHaveCount(5);

    const banana = fruitList.getByText('香蕉');
    await banana.click();
    await expect(banana).toHaveClass(/lotus-scroll-item-option-selected/);
  });

  test('disabled 项不可点击选中', async ({ page }) => {
    await page.goto('/');
    const disabledList = page.getByLabel('含禁用项选择');
    await expect(disabledList).toBeVisible();
    const disabledOption = disabledList.getByText('选项二（禁用）');
    await expect(disabledOption).toHaveClass(/lotus-scroll-item-option-disabled/);

    await disabledOption.click({ force: true });
    await expect(disabledOption).not.toHaveClass(/lotus-scroll-item-option-selected/);
  });

  test('受控用法：外部按钮驱动 selectedIndex 正确同步（回归防护：content-box padding 坐标系偏移，踩坑 #71）', async ({ page }) => {
    await page.goto('/');
    const controlledList = page.getByLabel('受控选择');
    await expect(controlledList).toBeVisible();
    await expect(controlledList.locator('.lotus-scroll-item-option-selected').first()).toHaveText('C');

    await page.getByRole('button', { name: '跳到第一项' }).click();
    await expect(controlledList.locator('.lotus-scroll-item-option-selected').first()).toHaveText('A', { timeout: 3000 });

    await page.getByRole('button', { name: '跳到第五项' }).click();
    await expect(controlledList.locator('.lotus-scroll-item-option-selected').first()).toHaveText('E', { timeout: 3000 });
  });

  test('ScrollList header 正确渲染', async ({ page }) => {
    await page.goto('/');
    const hourList = page.getByLabel('小时选择');
    const scrollList = hourList.locator('xpath=ancestor::div[contains(concat(" ", normalize-space(@class), " "), " lotus-scroll-list ")][1]');
    await expect(scrollList.locator('.lotus-scroll-list-header')).toBeVisible();
    await expect(scrollList.locator('.lotus-scroll-list-header')).toContainText('时');
    await expect(scrollList.locator('.lotus-scroll-list-header')).toContainText('分');
  });
});
