import { test, expect } from '@playwright/test';

test.describe('AiChatInput', () => {
  test('渲染编辑器、引用条、上传按钮与 MCP 配置区', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    await expect(input).toBeVisible();
    await expect(input.locator('.lotus-ai-input-editor-content')).toBeVisible();
    await expect(input.locator('.lotus-upload-trigger')).toBeVisible();
    await expect(input.locator('.lotus-ai-input-configure-mcp-trigger')).toBeVisible();
    await expect(page.locator('[class*="lotus-ai-input-reference"]').first()).toBeVisible();
  });

  test('输入文字后发送按钮可点击，点击后触发 onMessageSend 并清空编辑器', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    const sendBtn = input.locator('button[aria-label="发送"]');
    await expect(sendBtn).toBeDisabled();

    await editor.click();
    await page.keyboard.type('hello world');
    await expect(sendBtn).toBeEnabled();

    await sendBtn.click();
    await expect(page.locator('.demo-ai-input-sent-log')).toContainText('hello world');
    await expect(editor).toHaveText('');
    // 发送后 demo 受控切换到生成中状态，按钮变为“停止生成”。
    await expect(input.locator('.lotus-ai-chat-input-actions')).toContainText('停止生成');
  });

  test('按技能热键打开技能面板，选中后插入 chip 并显示模版按钮', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    await editor.click();
    await page.keyboard.type('/');
    const skillPanel = page.locator('.lotus-popover-content').last();
    await expect(skillPanel).toBeVisible();
    await expect(skillPanel).toContainText('翻译');

    await skillPanel.getByText('翻译', { exact: true }).click();
    await expect(input.locator('.lotus-ai-input-skill-slot-label')).toHaveText('翻译');
    await expect(input.locator('.lotus-ai-chat-input-template-trigger')).toBeVisible();
  });

  test('展开模版面板并点击模版内容插入编辑器', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    await editor.click();
    await page.keyboard.type('/');
    await page.locator('.lotus-popover-content').last().getByText('翻译', { exact: true }).click();

    await input.locator('.lotus-ai-chat-input-template-trigger').click();
    await page.locator('.lotus-popover-content').last().getByText('翻译模版').click();

    await expect(editor).toContainText('帮我把这段翻译成英文：');
  });

  test('聚焦空编辑器展示建议提示，点击建议项填充内容并隐藏面板', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    await editor.click();
    await expect(page.locator('.lotus-popover-content')).toContainText('介绍一下 lotus 组件库');

    await page.locator('.lotus-popover-content').getByText('介绍一下 lotus 组件库').click();
    await expect(editor).toContainText('介绍一下 lotus 组件库');
    await expect(page.locator('.lotus-popover-content')).toHaveCount(0);
  });

  test('输入内容后建议提示自动隐藏', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    await editor.click();
    await expect(page.locator('.lotus-popover-content')).toBeVisible();

    await page.keyboard.type('x');
    await expect(page.locator('.lotus-popover-content')).toHaveCount(0);
  });

  test('上传附件后渲染附件列表，可删除附件', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const fileChooserPromise = page.waitForEvent('filechooser');
    await input.locator('.lotus-upload-trigger').click();
    const fileChooser = await fileChooserPromise;
    await fileChooser.setFiles({ name: 'test.txt', mimeType: 'text/plain', buffer: Buffer.from('hello') });

    await expect(input).toContainText('test.txt');

    const removeBtn = input.locator('[class*="attachment"] button').first();
    await removeBtn.click();
    await expect(input).not.toContainText('test.txt');
  });

  test('引用条渲染引用项并支持删除', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    await expect(input).toContainText('design-doc.md');
    await input.locator('[class*="reference"] button').first().click();
    await expect(input).not.toContainText('design-doc.md');
  });

  test('打开 MCP 配置下拉并点击配置按钮', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    await input.locator('.lotus-ai-input-configure-mcp-trigger').click();
    const panel = page.locator('.lotus-ai-input-configure-mcp-panel');
    await expect(panel).toBeVisible();
    await expect(panel).toContainText('MCP · 1');

    const consoleLogs: string[] = [];
    page.on('console', (msg) => consoleLogs.push(msg.text()));
    await panel.getByRole('button', { name: '配置' }).click();
    await expect.poll(() => consoleLogs.some((t) => t.includes('mcp configure clicked'))).toBe(true);
  });

  test('Enter 发送快捷键：Shift+Enter 换行不发送，Enter 发送', async ({ page }) => {
    await page.goto('/');
    const input = page.locator('.lotus-ai-chat-input');
    await input.scrollIntoViewIfNeeded();

    const editor = input.locator('.lotus-ai-input-editor-content');
    await editor.click();
    await page.keyboard.type('line1');
    await page.keyboard.press('Shift+Enter');
    await page.keyboard.type('line2');
    await expect(editor).toContainText('line1');
    await expect(editor).toContainText('line2');

    await page.keyboard.press('Enter');
    await expect(page.locator('.demo-ai-input-sent-log')).toContainText('line1');
  });
});
