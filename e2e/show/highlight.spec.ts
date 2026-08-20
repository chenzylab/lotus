import { test, expect } from '@playwright/test';

test.describe('Highlight', () => {
  test('基础用法：单个关键词高亮为 mark 标签', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('基础 Highlight');
    await expect(highlight).toBeVisible();
    await expect(highlight.locator('mark')).toHaveText('fox');
    await expect(highlight).toHaveText('The quick brown fox jumps over the lazy dog');
  });

  test('多个关键词同时高亮', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('多关键词 Highlight');
    const marks = await highlight.locator('mark').allTextContents();
    expect(marks).toEqual(['quick', 'lazy', 'dog']);
  });

  test('重叠关键词合并为一段，不重复渲染（Foundation 算法核心行为）', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('重叠合并 Highlight');
    const marks = await highlight.locator('mark').allTextContents();
    expect(marks).toEqual(['abcd']);
  });

  test('caseSensitive=true 时只命中精确大小写', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('大小写敏感 Highlight');
    const marks = await highlight.locator('mark').allTextContents();
    expect(marks).toEqual(['Fox']);
  });

  test('autoEscape（默认）时正则特殊字符按字面量匹配', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('特殊字符转义 Highlight');
    const marks = await highlight.locator('mark').allTextContents();
    expect(marks).toEqual(['$9.99']);
  });

  test('ComplexSearchWord：不同关键词应用各自的样式', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('ComplexSearchWord Highlight');
    const marks = highlight.locator('mark');
    await expect(marks).toHaveCount(2);

    const errorMark = highlight.getByText('Error', { exact: true });
    const warningMark = highlight.getByText('Warning', { exact: true });
    const errorColor = await errorMark.evaluate((el) => getComputedStyle(el).color);
    const warningColor = await warningMark.evaluate((el) => getComputedStyle(el).color);
    expect(errorColor).not.toBe(warningColor);
  });

  test('component=span 时渲染 span 而非 mark 标签', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('span component Highlight');
    await expect(highlight.locator('mark')).toHaveCount(0);
    await expect(highlight.locator('span.lotus-highlight-tag')).toHaveCount(1);
  });

  test('关键词不存在时原样显示，无高亮标签', async ({ page }) => {
    await page.goto('/');
    const highlight = page.getByLabel('无匹配 Highlight');
    await expect(highlight).toHaveText('Nothing matches here');
    await expect(highlight.locator('mark')).toHaveCount(0);
  });
});
