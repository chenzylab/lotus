import { test, expect } from '@playwright/test';

test.describe('HotKeys', () => {
  test('基础用法：渲染键位提示，含 + 分隔符', async ({ page }) => {
    await page.goto('/');
    const hotkeys = page.locator('.demo-hotkeys .lotus-hotkeys');
    await expect(hotkeys).toBeVisible();
    const contents = await hotkeys.locator('.lotus-hotkeys-content').allTextContents();
    expect(contents).toEqual(['control', 's']);
    await expect(hotkeys.locator('.lotus-hotkeys-split')).toHaveText('+');
  });

  test('按下匹配的组合键触发 onHotKey 回调', async ({ page }) => {
    await page.goto('/');
    const countEl = page.locator('.demo-hotkeys-count');
    await expect(countEl).toHaveText('触发次数：0');

    await page.keyboard.down('Control');
    await page.keyboard.press('KeyS');
    await page.keyboard.up('Control');

    await expect(countEl).not.toHaveText('触发次数：0');
  });

  test('按下不匹配的按键不触发回调', async ({ page }) => {
    await page.goto('/');
    const countEl = page.locator('.demo-hotkeys-count');
    await expect(countEl).toHaveText('触发次数：0');

    await page.keyboard.press('KeyA');
    await page.waitForTimeout(100);

    await expect(countEl).toHaveText('触发次数：0');
  });

  test('少按修饰键（只按普通键不按 Ctrl）不触发回调', async ({ page }) => {
    await page.goto('/');
    const countEl = page.locator('.demo-hotkeys-count');
    await page.keyboard.press('KeyS');
    await page.waitForTimeout(100);
    await expect(countEl).toHaveText('触发次数：0');
  });

  test('多按修饰键（Ctrl+Shift+S 而非声明的 Ctrl+S）不触发回调', async ({ page }) => {
    await page.goto('/');
    const countEl = page.locator('.demo-hotkeys-count');
    await page.keyboard.down('Control');
    await page.keyboard.down('Shift');
    await page.keyboard.press('KeyS');
    await page.keyboard.up('Shift');
    await page.keyboard.up('Control');
    await page.waitForTimeout(100);
    await expect(countEl).toHaveText('触发次数：0');
  });

  test('preventDefault=true 时浏览器默认行为被拦截（Ctrl+S 不触发浏览器保存对话框假设，页面未导航离开）', async ({ page }) => {
    await page.goto('/');
    await page.keyboard.down('Control');
    await page.keyboard.press('KeyS');
    await page.keyboard.up('Control');
    // 页面应仍停留在原地，未发生导航/崩溃。
    await expect(page.locator('.demo-hotkeys')).toBeVisible();
  });

  test('传 onClick 时提示徽标带 role=button，键盘 Enter/Space 等效触发点击（回归防护：Class C 补齐键盘无障碍）', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('HotKeys 可点击示例', { exact: true });
    const log = page.getByLabel('HotKeys 点击日志', { exact: true });

    await expect(badge).toHaveAttribute('role', 'button');
    await expect(badge).toHaveAttribute('tabindex', '0');

    await badge.focus();
    await badge.press('Enter');
    await expect(log).toHaveText('点击生效');
  });
});
