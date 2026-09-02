import { test, expect } from '@playwright/test';

test.describe('Nav', () => {
  test('默认选中项高亮，点击其他项后选中态切换（回归防护：曾经出现过 class 静默不更新的问题，' +
    '详见 specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #19）', async ({ page }) => {
    await page.goto('/');
    const nav = page.locator('.lotus-nav-vertical').first();
    const homeItem = nav.getByRole('menuitem', { name: '首页' });
    await expect(homeItem).toHaveClass(/lotus-nav-item-selected/);

    await nav.getByRole('button', { name: '组件' }).click();
    const basicItem = nav.getByRole('menuitem', { name: '基础组件' });
    await basicItem.click();

    await expect(basicItem).toHaveClass(/lotus-nav-item-selected/);
    await expect(homeItem).not.toHaveClass(/lotus-nav-item-selected/);
  });

  test('点击 SubNav 标题展开/收起子级列表，多级嵌套均可展开', async ({ page }) => {
    await page.goto('/');
    const nav = page.locator('.lotus-nav-vertical').first();
    const componentsToggle = nav.getByRole('button', { name: '组件' });

    await expect(nav.getByRole('menuitem', { name: '基础组件' })).not.toBeVisible();
    await componentsToggle.click();
    await expect(nav.getByRole('menuitem', { name: '基础组件' })).toBeVisible();

    const nestedToggle = nav.getByRole('button', { name: '嵌套子导航' });
    await expect(nav.getByRole('menuitem', { name: '子项 A' })).not.toBeVisible();
    await nestedToggle.click();
    await expect(nav.getByRole('menuitem', { name: '子项 A' })).toBeVisible();
    await expect(nav.getByRole('menuitem', { name: '子项 B' })).toBeVisible();

    await componentsToggle.click();
    await expect(nav.getByRole('menuitem', { name: '基础组件' })).not.toBeVisible();
  });

  test('disabled 项不可点击且带 aria-disabled', async ({ page }) => {
    await page.goto('/');
    const nav = page.locator('.lotus-nav-vertical').first();
    const disabledItem = nav.getByRole('menuitem', { name: '禁用项' });

    await expect(disabledItem).toHaveAttribute('aria-disabled', 'true');
    await expect(disabledItem).not.toHaveClass(/lotus-nav-item-selected/);
    await disabledItem.click({ force: true }).catch(() => {});
    await expect(disabledItem).not.toHaveClass(/lotus-nav-item-selected/);
  });

  test('isCollapsed 时容器带 collapsed class', async ({ page }) => {
    await page.goto('/');
    const collapsedNav = page.locator('.lotus-nav-collapsed').first();
    await expect(collapsedNav).toBeVisible();
  });

  test('mode=horizontal 时容器带 horizontal class', async ({ page }) => {
    await page.goto('/');
    const horizontalNav = page.locator('.lotus-nav-horizontal');
    await expect(horizontalNav).toBeVisible();
  });

  test('JSX 写法（children 传入 NavHeader/NavItem/NavSub/NavFooter）能正确渲染并支持展开/选中', async ({ page }) => {
    await page.goto('/');
    const jsxNav = page.locator('.lotus-nav-vertical').filter({ hasText: 'Lotus 运营后台' });

    await expect(jsxNav.getByText('Lotus 运营后台')).toBeVisible();
    await expect(jsxNav.getByRole('menuitem', { name: '活动管理' })).toBeVisible();
    // defaultOpenKeys 让"用户管理"默认展开
    await expect(jsxNav.getByRole('menuitem', { name: '活跃用户', exact: true })).toBeVisible();

    await jsxNav.getByRole('button', { name: '用户管理' }).click();
    await expect(jsxNav.getByRole('menuitem', { name: '活跃用户', exact: true })).not.toBeVisible();
  });

  test('limitIndent=false 时嵌套层级越深的项左侧占位图标越多（缩进量随 level 递增）', async ({ page }) => {
    await page.goto('/');
    // defaultOpenKeys=['job', 'mission1'] 让"任务平台"和"任务1"默认展开，无需点击。
    const indentNav = page.locator('.lotus-nav-vertical').filter({ hasText: '任务平台' });

    const level1Item = indentNav.getByRole('menuitem', { name: '任务管理' });
    const level2Item = indentNav.getByRole('menuitem', { name: '任务2' });

    await expect(level1Item).toBeVisible();
    await expect(level2Item).toBeVisible();

    const level1IconCount = await level1Item.locator('.lotus-nav-item-icon').count();
    const level2IconCount = await level2Item.locator('.lotus-nav-item-icon').count();

    expect(level2IconCount).toBeGreaterThan(level1IconCount);
  });

  test('getPopupContainer：折叠态 SubNav 悬浮浮层挂载到指定容器；expandIcon：自定义展开图标生效', async ({ page }) => {
    await page.goto('/');
    const nav = page.locator('[aria-label="Nav 折叠态高级配置示例"]');
    const container = page.locator('#nav-popup-container');

    const componentsItem = nav.getByRole('button', { name: '组件' });
    await componentsItem.hover();

    const popover = container.locator('.lotus-nav-subnav-popover-list');
    await expect(popover).toBeVisible();
    await expect(popover).toContainText('基础组件');

    // 折叠态下二级子导航（嵌套子导航）箭头朝右且显示自定义 expandIcon。
    await expect(popover.getByLabel('自定义展开图标').first()).toBeVisible();
  });
});
