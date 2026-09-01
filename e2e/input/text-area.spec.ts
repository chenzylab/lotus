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

  test('受控组件：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    // 回归防护：组件 props 若用普通 {} 解构而非 &{} 懒解构，外部独立触发源驱动的
    // 受控 prop 变化不会传导到组件视觉，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #30。
    await page.goto('/');
    const externalControlled = page.getByLabel('TextArea 外部受控示例');
    const appendButton = page.getByRole('button', { name: '追加一行' });

    await expect(externalControlled).toHaveValue('初始内容');
    await appendButton.click();
    await expect(externalControlled).toHaveValue('初始内容\n新增一行');
  });

  test('aria-*：describedby/required 正确透传（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const textarea = page.getByLabel('带完整 ARIA 属性的多行输入框');
    await expect(textarea).toHaveAttribute('aria-describedby', 'textarea-aria-hint');
    await expect(textarea).toHaveAttribute('aria-required', 'true');
  });

  test('getTextAreaApi：交出的 focus()/blur() 真实生效（对齐 Semi ref.current.focus()，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const textarea = page.getByLabel('getTextAreaApi 多行输入框');
    const group = textarea.locator('xpath=ancestor::*[contains(@class,"lotus-space")][1]');
    await group.getByRole('button', { name: '聚焦' }).click();
    await expect(textarea).toBeFocused();
    await group.getByRole('button', { name: '失焦' }).click();
    await expect(textarea).not.toBeFocused();
  });

  test('readonly：只读态阻止编辑但鼠标点击/聚焦仍可用（回归防护：readonly={readonly} 这个 JSX 属性名本身在 tsrx 编译器里有异常处理路径，与 Input 组件同一根因，曾完全不生效）', async ({ page }) => {
    await page.goto('/');
    const textarea = page.getByLabel('readonly 多行输入框');
    await expect(textarea).toHaveJSProperty('readOnly', true);
    await expect(textarea).toHaveValue('只读多行内容不可编辑');
    await textarea.click();
    await page.keyboard.type('追加内容');
    await expect(textarea).toHaveValue('只读多行内容不可编辑');
  });
});
