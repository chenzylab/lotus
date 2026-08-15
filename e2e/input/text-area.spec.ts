import { test, expect } from '@playwright/test';

test.describe('TextArea', () => {
  test('多行输入内容后触发 onChange', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const textarea = page.locator('.lotus-textarea-native').first();
    await textarea.fill('第一行\n第二行');

    await expect(textarea).toHaveValue('第一行\n第二行');
    expect(logs.some((l) => l.includes('textarea changed'))).toBe(true);
  });

  test('autosize：输入多行内容后高度自动增长', async ({ page }) => {
    await page.goto('/');
    const autoTextarea = page.locator('.lotus-textarea-native').nth(1);
    const before = await autoTextarea.evaluate((el) => (el as HTMLTextAreaElement).style.height);

    await autoTextarea.fill('第一行\n第二行\n第三行\n第四行\n第五行');
    await page.waitForTimeout(200);

    const after = await autoTextarea.evaluate((el) => (el as HTMLTextAreaElement).style.height);
    expect(after).not.toBe('');
    expect(after).not.toBe(before);
  });

  test('maxCount：字数统计随内容变化更新', async ({ page }) => {
    await page.goto('/');
    const countedTextarea = page.locator('.lotus-textarea-native').nth(2);
    await expect(page.locator('.lotus-textarea-count')).toHaveText('9/50');

    await countedTextarea.fill('新内容');
    await expect(page.locator('.lotus-textarea-count')).toHaveText('3/50');
  });

  test('showClear：hover 后出现清除按钮，点击后清空内容', async ({ page }) => {
    await page.goto('/');
    const countedTextarea = page.locator('.lotus-textarea-native').nth(2);
    await countedTextarea.hover();
    const clearButton = page.locator('.lotus-textarea-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(countedTextarea).toHaveValue('');
  });
});
