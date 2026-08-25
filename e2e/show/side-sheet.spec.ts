import { test, expect } from '@playwright/test';

test.describe('SideSheet', () => {
  test('基础用法：点击触发按钮打开，点击确定后关闭并触发 afterVisibleChange', async ({ page }) => {
    await page.goto('/');
    const sheet = page.getByLabel('右侧 SideSheet');
    await expect(sheet).toBeHidden();

    await page.getByRole('button', { name: '打开右侧 SideSheet' }).click();
    await expect(sheet).toBeVisible();
    await expect(sheet.getByText('这是 SideSheet 的内容区域。')).toBeVisible();

    await sheet.getByRole('button', { name: '确定' }).click();
    await expect(sheet).toBeHidden();
    await expect(page.getByText(/afterVisibleChange\(false\) 触发于/)).toBeVisible();
  });

  test('placement=left 从左侧滑入，右上角关闭按钮可关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开左侧 SideSheet' }).click();
    const sheet = page.getByLabel('左侧 SideSheet');
    await expect(sheet).toBeVisible();
    await expect(sheet).toHaveClass(/lotus-side-sheet-content-left/);

    await sheet.locator('.lotus-side-sheet-close').click();
    await expect(sheet).toBeHidden();
  });

  test('placement=top/bottom 分别从顶部/底部滑入', async ({ page }) => {
    await page.goto('/');

    await page.getByRole('button', { name: '打开顶部 SideSheet' }).click();
    const top = page.getByLabel('顶部 SideSheet');
    await expect(top).toBeVisible();
    await expect(top).toHaveClass(/lotus-side-sheet-content-top/);
    await top.locator('.lotus-side-sheet-close').click();
    await expect(top).toBeHidden();

    await page.getByRole('button', { name: '打开底部 SideSheet' }).click();
    const bottom = page.getByLabel('底部 SideSheet');
    await expect(bottom).toBeVisible();
    await expect(bottom).toHaveClass(/lotus-side-sheet-content-bottom/);
    await bottom.locator('.lotus-side-sheet-close').click();
    await expect(bottom).toBeHidden();
  });

  test('keepDOM：关闭后内容不从 DOM 卸载，只是 CSS 隐藏', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开 keepDOM SideSheet' }).click();
    const sheet = page.getByLabel('keepDOM SideSheet');
    await expect(sheet).toBeVisible();

    await sheet.locator('.lotus-side-sheet-close').click();
    await expect(sheet).toBeHidden();
    // 隐藏（display:none）但依然 attached，不是被卸载
    await expect(page.locator('.lotus-side-sheet-title', { hasText: 'keepDOM SideSheet' })).toBeAttached();
  });

  test('回归防护：其它 Portal 组件（Modal）开关一次后，仍能正常打开/关闭 keepDOM SideSheet', async ({ page }) => {
    // 这条测试对应一个真实的 Ripple 运行时 bug：多个 Portal 共享同一个
    // document.body 作为挂载 target 时，事件委托监听器没有做引用计数，
    // 任意一个 Portal 卸载都会把 document.body 上共享的委托监听器整体拆除，
    // 导致其它仍然打开的 Portal（如本例的 keepDOM SideSheet）彻底失去响应，
    // 且现象具有强烈误导性——DOM 节点、事件 handler 引用都还在，只是根节点
    // 事件委托被静默移除，点击不会有任何报错。已在 ripple 仓库修复
    // （handle_root_events 按 target 引用计数），此测试防止未来回归。
    await page.goto('/');

    await page.getByRole('button', { name: '打开基础 Modal' }).click();
    const modal = page.getByLabel('基础 Modal');
    await expect(modal).toBeVisible();
    await modal.getByRole('button', { name: '确定' }).click();
    await expect(modal).toBeHidden();

    await page.getByRole('button', { name: '打开 keepDOM SideSheet' }).click();
    const sheet = page.getByLabel('keepDOM SideSheet');
    await expect(sheet).toBeVisible();

    await sheet.locator('.lotus-side-sheet-close').click();
    await expect(sheet).toBeHidden();
  });

  test('size=large + closable=false + maskClosable=false', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: /打开 large SideSheet/ }).click();
    const sheet = page.getByLabel('large 无遮罩关闭 SideSheet');
    await expect(sheet).toBeVisible();
    await expect(sheet.locator('.lotus-side-sheet-close')).toHaveCount(0);

    await page.mouse.click(20, 20);
    await expect(sheet).toBeVisible();

    await sheet.getByRole('button', { name: '关闭' }).click();
    await expect(sheet).toBeHidden();
  });

  test('无障碍：打开后焦点移入面板，Tab 键在内部循环，关闭后焦点归还触发按钮（Semi 自身未实现，本次主动补齐对齐 Modal 水平）', async ({ page }) => {
    await page.goto('/');
    const openBtn = page.getByRole('button', { name: '打开右侧 SideSheet' });
    await openBtn.focus();
    await openBtn.click();

    const sheet = page.getByLabel('右侧 SideSheet');
    await expect(sheet).toBeVisible();
    await expect(sheet.evaluate((el) => el.contains(document.activeElement))).resolves.toBe(true);

    for (let i = 0; i < 6; i++) await page.keyboard.press('Tab');
    await expect(sheet.evaluate((el) => el.contains(document.activeElement))).resolves.toBe(true);

    await sheet.getByRole('button', { name: '确定' }).click();
    await expect(sheet).toBeHidden();
    await expect(openBtn).toBeFocused();
  });
});
