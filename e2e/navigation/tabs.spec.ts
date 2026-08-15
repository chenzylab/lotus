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
});
