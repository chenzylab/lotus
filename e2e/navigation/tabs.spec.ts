import { test, expect } from '@playwright/test';

test.describe('Tabs', () => {
  test('点击标签切换激活态并触发 onChange', async ({ page }) => {
    const consoleMessages: string[] = [];
    page.on('console', (msg) => consoleMessages.push(msg.text()));

    await page.goto('/');
    const lineTabs = page.locator('.lotus-tabs-line').first();
    const tabTwo = lineTabs.getByRole('tab', { name: '标签二' });

    await expect(lineTabs.getByRole('tab', { name: '标签一' })).toHaveAttribute('aria-selected', 'true');
    await tabTwo.click();

    await expect(tabTwo).toHaveAttribute('aria-selected', 'true');
    expect(consoleMessages).toContain('line tab changed 2');
  });

  test('disabled 标签点击后激活态不变', async ({ page }) => {
    await page.goto('/');
    const lineTabs = page.locator('.lotus-tabs-line').first();
    const disabledTab = lineTabs.getByRole('tab', { name: '禁用标签' });

    await expect(disabledTab).toHaveAttribute('aria-disabled', 'true');
    await disabledTab.click({ force: true }).catch(() => {});

    await expect(lineTabs.getByRole('tab', { name: '标签一' })).toHaveAttribute('aria-selected', 'true');
  });

  test('closable 标签点击关闭按钮触发 onTabClose 但不切换激活态', async ({ page }) => {
    const consoleMessages: string[] = [];
    page.on('console', (msg) => consoleMessages.push(msg.text()));

    await page.goto('/');
    const closableTabs = page.getByRole('tablist').filter({ hasText: '可关闭 A' });
    const tabA = closableTabs.getByRole('tab', { name: /可关闭 A/ });

    await expect(tabA).toHaveAttribute('aria-selected', 'true');
    await tabA.getByLabel('关闭标签页').click();

    expect(consoleMessages).toContain('tab closed a');
    // 关闭是纯回调通知，不代表数据源已移除该项——组件本身不感知业务层是否真的删除了 tabList
    // 条目，因此关闭后原激活标签仍在（对齐 Semi「不自动删除，由外部业务代码控制」的设计）。
    await expect(tabA).toHaveAttribute('aria-selected', 'true');
  });

  test('键盘方向键在启用的标签间循环导航，跳过 disabled 项', async ({ page }) => {
    await page.goto('/');
    const lineTabs = page.locator('.lotus-tabs-line').first();
    const tabOne = lineTabs.getByRole('tab', { name: '标签一' });
    const tabFour = lineTabs.getByRole('tab', { name: '标签四' });

    await tabOne.focus();
    await page.keyboard.press('ArrowRight');
    await expect(lineTabs.getByRole('tab', { name: '标签二' })).toHaveAttribute('aria-selected', 'true');

    await page.keyboard.press('ArrowRight');
    // 从标签二继续向右应跳过 disabled 的「禁用标签」直达标签四
    await expect(tabFour).toHaveAttribute('aria-selected', 'true');
  });

  test('TabPane 声明式写法：正确渲染 tab 元数据并支持切换（对齐 Anchor AnchorLink 的 Context 注册模式）', async ({ page }) => {
    await page.goto('/');
    const tabs = page.locator('[aria-label="Tabs TabPane 声明式示例"]');
    const tabList = tabs.getByRole('tab');

    await expect(tabList).toHaveText(['标签一', '标签二', '禁用标签']);
    await expect(tabs.getByRole('tab', { name: '标签二' })).toHaveAttribute('aria-selected', 'true');
    await expect(tabs).toContainText('内容二');

    await tabs.getByRole('tab', { name: '标签一' }).click();
    await expect(tabs).toContainText('内容一');
  });

  test('contentStyle/tabBarStyle/tabBarClassName/tabBarExtraContent 均正确应用', async ({ page }) => {
    await page.goto('/');
    const tabs = page.locator('[aria-label="Tabs 样式定制示例"]');

    await expect(tabs.locator('.lotus-tabs-content')).toHaveCSS('padding', '12px');
    await expect(tabs.locator('.lotus-tabs-bar')).toHaveClass(/playground-tabs-bar-demo/);
    await expect(tabs.locator('.lotus-tabs-bar-extra')).toContainText('额外按钮');
  });

  test('collapsible + arrowPosition=both：tab 栏可横向滚动，两侧箭头按需禁用/可用', async ({ page }) => {
    await page.goto('/');
    const tabs = page.locator('[aria-label="Tabs collapsible 示例"]');
    const scroller = tabs.locator('.lotus-tabs-bar-scroller');
    const startArrow = tabs.locator('.lotus-tabs-arrow-start');
    const endArrow = tabs.locator('.lotus-tabs-arrow-end');

    await expect(startArrow).toBeDisabled();
    await expect(endArrow).toBeEnabled();

    const before = await scroller.evaluate((el) => el.scrollLeft);
    await endArrow.click();
    await page.waitForTimeout(500);
    const after = await scroller.evaluate((el) => el.scrollLeft);
    expect(after).toBeGreaterThan(before);
  });

  test('more：强制收起末尾 N 个 tab 到下拉菜单，点击可选中', async ({ page }) => {
    await page.goto('/');
    const tabs = page.locator('[aria-label="Tabs more 示例"]');
    const moreTrigger = tabs.locator('.lotus-tabs-more-trigger');

    await expect(moreTrigger).toBeVisible();
    await moreTrigger.click();

    const menu = page.locator('[role="menu"]').filter({ hasText: '标签 10' });
    await expect(menu).toBeVisible();
    await menu.getByText('标签 8', { exact: true }).click();

    await expect(tabs.getByRole('tab', { name: '标签 8' })).toHaveAttribute('aria-selected', 'true');
  });
});
