import { test, expect } from '@playwright/test';

test.describe('Popover', () => {
  test('click 触发：点击后浮层出现，支持渲染任意 JSX 内容（不止文本）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click 打开卡片' });
    await trigger.click();

    const popover = page.locator('.lotus-popover');
    await expect(popover).toBeVisible();
    await expect(popover).toContainText('自定义卡片内容');
    // 验证嵌套的 Tag 组件真实渲染（证明内容不局限于纯文本）
    await expect(popover.locator('.lotus-tag')).toContainText('支持任意 JSX');
  });

  test('trigger=click 时浮层具有 dialog role（对齐 Semi 的 a11y 语义）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'click 打开卡片' }).click();

    const dialog = page.getByRole('dialog');
    await expect(dialog).toBeVisible();
  });

  test('按 Esc 键关闭浮层', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'click 打开卡片' }).click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(page.locator('.lotus-popover')).not.toBeVisible();
  });

  test('hover 触发 + showArrow 时浮层带箭头样式', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'hover + 箭头' });
    await trigger.hover();

    const popover = page.locator('.lotus-popover');
    await expect(popover).toBeVisible();
    await expect(popover.locator('.lotus-popover-arrow')).toBeVisible();
  });
});
