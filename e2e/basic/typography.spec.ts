import { test, expect } from '@playwright/test';

test.describe('Typography', () => {
  test('Title 六级标题分别渲染为对应的 h1~h6 标签', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { level: 1, name: '一级标题' })).toBeVisible();
    await expect(page.getByRole('heading', { level: 6, name: '六级标题' })).toBeVisible();
  });

  test('component prop：Text/Title/Paragraph 均可覆盖默认渲染标签（对齐 Semi，回归防护：此前 lotus 完全没有实现，Title 固定 h1~h6、Text 固定 span、Paragraph 固定 p）', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByLabel('Text 渲染为 div')).toHaveJSProperty('tagName', 'DIV');
    await expect(page.getByLabel('Title 渲染为 div')).toHaveJSProperty('tagName', 'DIV');
    await expect(page.getByLabel('Paragraph 渲染为 span')).toHaveJSProperty('tagName', 'SPAN');
  });

  test('Numeral：数值格式化对齐 Semi 算法（回归防护：此前 lotus 完全没有 Typography.Numeral 组件）', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByLabel('百分比格式化')).toHaveText('45.67%');
    await expect(page.getByLabel('字节格式化（十进制）')).toHaveText('1.50 MB');
    await expect(page.getByLabel('科学计数法格式化')).toHaveText('Total revenue: $ 1.99e+3');
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
