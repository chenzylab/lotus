import { test, expect } from '@playwright/test';

test.describe('Timeline', () => {
  test('dataSource 渲染对应数量的节点，type 语义色正确映射', async ({ page }) => {
    await page.goto('/');
    const timeline = page.getByLabel('基础 Timeline');
    await expect(timeline.locator('.lotus-timeline-item')).toHaveCount(4);
    await expect(timeline.locator('.lotus-timeline-item-head').first()).toHaveClass(/lotus-timeline-item-head-success/);
    await expect(timeline).toContainText('创建服务现场');
    await expect(timeline).toContainText('2023-09-01 09:00');
  });

  test('最后一个节点不显示连接线', async ({ page }) => {
    await page.goto('/');
    const timeline = page.getByLabel('基础 Timeline');
    const lastTail = timeline.locator('.lotus-timeline-item').last().locator('.lotus-timeline-item-tail');
    await expect(lastTail).toBeHidden();
  });

  test('JSX children 用法：自定义 color 生效，extra 内容渲染，dot 自定义图标切换为 head-custom class', async ({ page }) => {
    await page.goto('/');
    const timeline = page.getByLabel('JSX Timeline');
    const firstDot = timeline.locator('.lotus-timeline-item-head').first();
    const bgColor = await firstDot.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(bgColor).toBe('rgb(114, 46, 209)');

    await expect(timeline).toContainText('附加说明信息');

    const customDot = timeline.locator('.lotus-timeline-item-head').nth(1);
    await expect(customDot).toHaveClass(/lotus-timeline-item-head-custom/);
  });

  test('mode=alternate 时节点按索引奇偶左右交替', async ({ page }) => {
    await page.goto('/');
    const timeline = page.getByLabel('alternate Timeline');
    const items = timeline.locator('.lotus-timeline-item');
    await expect(items.nth(0)).toHaveClass(/lotus-timeline-item-left/);
    await expect(items.nth(1)).toHaveClass(/lotus-timeline-item-right/);
    await expect(items.nth(2)).toHaveClass(/lotus-timeline-item-left/);
  });
});
