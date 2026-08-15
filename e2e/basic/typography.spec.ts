import { test, expect } from '@playwright/test';

test.describe('Typography', () => {
  test('Title 六级标题分别渲染为对应的 h1~h6 标签', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { level: 1, name: '一级标题' })).toBeVisible();
    await expect(page.getByRole('heading', { level: 6, name: '六级标题' })).toBeVisible();
  });

  test('Text copyable 点击复制图标后写入剪贴板，按钮切换为已复制状态', async ({ page, context }) => {
    await context.grantPermissions(['clipboard-read', 'clipboard-write']);
    await page.goto('/');

    const copyButton = page.locator('.lotus-typography-copy').first();
    await copyButton.click();

    const clipboardText = await page.evaluate(() => navigator.clipboard.readText());
    expect(clipboardText).toBe('点击右侧图标可复制这段文本');
    await expect(copyButton).toHaveAttribute('aria-label', '已复制');
  });

  test('ellipsis pos=middle 时 DOM 文本被 JS 精确截断为中间省略格式', async ({ page }) => {
    await page.goto('/');
    const middleEllipsis = page.locator('.lotus-typography', { hasText: '间省略效果' });
    const text = await middleEllipsis.first().textContent();
    expect(text).toContain('...');
    expect(text).not.toBe('这是一段很长很长很长很长很长很长的文本，用于测试中间省略效果');
  });

  test('ellipsis showTooltip 时 hover 触发浮层展示完整原文', async ({ page }) => {
    await page.goto('/');
    const trigger = page.locator('.lotus-tooltip-trigger', { hasText: '测试末尾省略效果' });
    await trigger.hover();
    await expect(page.getByRole('tooltip')).toContainText('这是一段很长很长很长很长很长很长的文本，用于测试末尾省略效果');
  });

  test('Paragraph expandable 多行截断：点击展开按钮后文案从"展开"切换为"收起"', async ({ page }) => {
    await page.goto('/');
    const expandButton = page.locator('.lotus-typography-expand-toggle');
    await expect(expandButton).toHaveText('展开');
    await expandButton.click();
    await expect(expandButton).toHaveText('收起');
  });
});
