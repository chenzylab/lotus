import { test, expect } from '@playwright/test';

test.describe('Badge', () => {
  test('数字徽标正常显示', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('Badge 数字 5');
    await expect(badge.locator('.lotus-badge-count')).toHaveText('5');
  });

  test('count=0 时仍然显示（不像部分组件库自动隐藏）', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('Badge 数字 0（不会自动隐藏）');
    await expect(badge.locator('.lotus-badge-count')).toHaveText('0');
    await expect(badge.locator('.lotus-badge-count')).toBeVisible();
  });

  test('超过 overflowCount 时显示为 "N+"', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('Badge 超出 overflowCount 显示 99+');
    await expect(badge.locator('.lotus-badge-count')).toHaveText('99+');
  });

  test('dot 模式只显示红点，不显示文字', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('Badge 红点模式');
    const count = badge.locator('.lotus-badge-count');
    await expect(count).toHaveClass(/lotus-badge-dot/);
    await expect(count).toHaveText('');
  });

  test('支持自定义字符串内容', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('Badge 自定义字符串内容');
    await expect(badge.locator('.lotus-badge-count')).toHaveText('VIP');
  });

  test('type 变体渲染对应 class', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByLabel('Badge type=primary').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-primary/);
    await expect(page.getByLabel('Badge type=danger').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-danger/);
    await expect(page.getByLabel('Badge type=warning').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-warning/);
    await expect(page.getByLabel('Badge type=success').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-success/);
  });

  test('theme 变体渲染对应 class', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByLabel('Badge theme=solid').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-solid/);
    await expect(page.getByLabel('Badge theme=light').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-light/);
    await expect(page.getByLabel('Badge theme=inverted').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-inverted/);
  });

  test('position 变体渲染对应 class', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByLabel('Badge position=leftTop').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-leftTop/);
    await expect(page.getByLabel('Badge position=rightBottom').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-rightBottom/);
    await expect(page.getByLabel('Badge position=leftBottom').locator('.lotus-badge-count')).toHaveClass(/lotus-badge-leftBottom/);
  });

  test('无 children 时独立展示，带 block class', async ({ page }) => {
    await page.goto('/');
    const badge = page.getByLabel('独立展示 Badge（无 children）');
    await expect(badge).toHaveClass(/lotus-badge-block/);
    await expect(badge.locator('.lotus-badge-count')).toHaveText('3');
  });

  test('点击触发 onClick 回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const badge = page.getByLabel('Badge onClick');
    await badge.click();

    expect(logs.some((l) => l.includes('badge clicked'))).toBe(true);
  });
});
