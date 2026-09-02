import { test, expect } from '@playwright/test';

test.describe('Breadcrumb', () => {
  test('基础渲染：路由项按顺序显示，自定义分隔符生效', async ({ page }) => {
    await page.goto('/');
    const basic = page.locator('.lotus-breadcrumb-list').first();
    await expect(basic).toContainText('首页');
    await expect(basic).toContainText('组件');
    await expect(basic).toContainText('导航');
    await expect(basic).toContainText('面包屑');
  });

  test('超出 maxItemCount 时自动折叠，中间项被替换为省略号', async ({ page }) => {
    await page.goto('/');
    const collapsedList = page.locator('.lotus-breadcrumb-list').nth(2);
    const items = await collapsedList.locator('.lotus-breadcrumb-item-wrap').allTextContents();

    // 7 级路由，maxItemCount=4：应显示 首页 / ••• / 上上一层 / 上一层 / 详情页，共 5 个节点
    expect(items.length).toBe(5);
    expect(items[0]).toContain('首页');
    expect(items[1]).toContain('•••');
    expect(items[items.length - 1]).toContain('详情页');
  });

  test('点击省略号展开后，全部路由项按原始顺序显示（回归防护：曾经出现过展开后顺序错乱、' +
    '折叠态可见项排前、新增项被追加到末尾的问题，详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #13）', async ({ page }) => {
    await page.goto('/');
    const collapsedList = page.locator('.lotus-breadcrumb-list').nth(2);
    await collapsedList.getByRole('button', { name: '展开面包屑省略项' }).click();

    const items = await collapsedList.locator('.lotus-breadcrumb-item-wrap').allTextContents();
    const names = items.map((text) => text.replace(/[/•]/g, '').trim());

    expect(names).toEqual(['首页', '当层级很多的时候', '又一层', '再一层', '上上一层', '上一层', '详情页']);
  });

  test('moreType=popover 时悬浮省略号展示折叠项列表', async ({ page }) => {
    await page.goto('/');
    const popoverList = page.locator('.lotus-breadcrumb-list').nth(3);
    const moreTrigger = popoverList.getByRole('button', { name: '展开面包屑省略项' });
    await moreTrigger.hover();

    const popover = page.locator('.lotus-breadcrumb-popover-list');
    await expect(popover).toBeVisible();
    await expect(popover).toContainText('当层级很多的时候');
  });

  test('点击路由项触发 onClick 回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const basic = page.locator('.lotus-breadcrumb-list').first();
    await basic.getByText('组件', { exact: true }).click();

    expect(logs).toContain('breadcrumb clicked 组件');
  });

  test('activeIndex：指定非最后一项为当前页，覆盖默认的"最后一项即当前页"语义', async ({ page }) => {
    await page.goto('/');
    const breadcrumb = page.locator('[aria-label="Breadcrumb activeIndex 示例"]');
    const items = breadcrumb.locator('.lotus-breadcrumb-item');

    await expect(items.nth(1)).toHaveAttribute('aria-current', 'page');
    await expect(items.nth(1)).toContainText('组件（当前页）');
    await expect(items.last()).not.toHaveAttribute('aria-current', 'page');
  });
});
