import { test, expect } from '@playwright/test';

test.describe('Dropdown', () => {
  test('click 触发：点击按钮后菜单展开，展示分组标题与菜单项', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: '点击展开菜单' });
    await trigger.click();

    const menu = page.locator('.lotus-dropdown-menu');
    await expect(menu).toBeVisible();
    await expect(menu.getByText('分组一')).toBeVisible();
    await expect(menu.getByRole('menuitem', { name: /选项 1/ })).toBeVisible();
  });

  test('disabled 项带 aria-disabled 且不可点击', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '点击展开菜单' }).click();

    const disabledItem = page.locator('.lotus-dropdown-menu').getByRole('menuitem', { name: /禁用项/ });
    await expect(disabledItem).toHaveAttribute('aria-disabled', 'true');
  });

  test('warning/danger 类型的菜单项带对应 class', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '点击展开菜单' }).click();

    const menu = page.locator('.lotus-dropdown-menu');
    await expect(menu.getByRole('menuitem', { name: '警告项' })).toHaveClass(/lotus-dropdown-item-warning/);
    await expect(menu.getByRole('menuitem', { name: '危险项' })).toHaveClass(/lotus-dropdown-item-danger/);
  });

  test('按 Esc 键关闭菜单后，焦点归还到触发元素（回归防护：a11y.spec.md 要求浮层关闭后焦点归还；Dropdown 内部即 Popover，继承其 Esc 关闭 + 焦点归还逻辑）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: '点击展开菜单' });
    await trigger.click();
    await expect(page.locator('.lotus-dropdown-menu')).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(page.locator('.lotus-dropdown-menu')).not.toBeVisible();
    await expect(trigger).toBeFocused();
  });

  test('点击菜单以外的区域自动关闭（Dropdown 复用 Popover 的点击外部关闭逻辑）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '点击展开菜单' }).click();
    await expect(page.locator('.lotus-dropdown-menu')).toBeVisible();

    await page.locator('body').click({ position: { x: 5, y: 5 } });
    await expect(page.locator('.lotus-dropdown-menu')).not.toBeVisible();
  });
});
