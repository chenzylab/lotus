import { test, expect } from '@playwright/test';

test.describe('AiChatDialogue', () => {
  test('渲染消息列表：用户消息气泡 + assistant 消息含 reasoning/tool_call/文本', async ({ page }) => {
    await page.goto('/');
    const dialogue = page.locator('.lotus-ai-chat-dialogue');
    await dialogue.scrollIntoViewIfNeeded();

    await expect(page.locator('.lotus-ai-dialogue-box')).toHaveCount(2);
    await expect(page.locator('.lotus-ai-reasoning')).toBeVisible();
    await expect(page.locator('.lotus-ai-tool-call')).toBeVisible();
  });

  test('展开 reasoning 折叠块显示思考内容', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    await page.locator('.lotus-ai-reasoning .lotus-collapse-header').click();
    await expect(page.locator('.lotus-ai-reasoning-content')).toBeVisible();
    await expect(page.locator('.lotus-ai-reasoning-content')).toContainText('天气工具');
  });

  test('展开工具调用块显示 JSON 格式化的参数与输出', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    await page.locator('.lotus-ai-tool-call .lotus-collapse-header').click();
    await expect(page.locator('.lotus-ai-tool-call-body')).toBeVisible();
    await expect(page.locator('.lotus-ai-tool-call-body')).toContainText('北京');
    await expect(page.locator('.lotus-ai-tool-call-body')).toContainText('call-1');
  });

  test('点击 hints 建议提示追加一条用户消息', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const countBefore = await page.locator('.lotus-ai-dialogue-box').count();
    await page.locator('.lotus-ai-chat-dialogue-hint', { hasText: '介绍一下 lotus 组件库' }).click();
    await expect(page.locator('.lotus-ai-dialogue-box')).toHaveCount(countBefore + 1);
  });

  test('编辑用户消息：点击编辑按钮进入编辑态，保存后更新内容', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const userBox = page.locator('.lotus-ai-dialogue-box-right').first();
    await userBox.locator('button[aria-label="编辑"]').click();
    await expect(page.locator('.lotus-ai-message-editor')).toBeVisible();

    const textarea = page.locator('.lotus-ai-message-editor textarea');
    await textarea.fill('修改后的内容');
    await page.locator('.lotus-ai-message-editor button', { hasText: '保存' }).click();

    await expect(page.locator('.lotus-ai-message-editor')).not.toBeVisible();
    await expect(userBox.locator('.lotus-ai-dialogue-content')).toContainText('修改后的内容');
  });

  test('取消编辑不改变原内容', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const userBox = page.locator('.lotus-ai-dialogue-box-right').first();
    const originalText = await userBox.locator('.lotus-ai-dialogue-content').textContent();

    await userBox.locator('button[aria-label="编辑"]').click();
    await page.locator('.lotus-ai-message-editor textarea').fill('不应该保存的内容');
    await page.locator('.lotus-ai-message-editor button', { hasText: '取消' }).click();

    await expect(page.locator('.lotus-ai-message-editor')).not.toBeVisible();
    await expect(userBox.locator('.lotus-ai-dialogue-content')).toHaveText(originalText ?? '');
  });

  test('点赞/点踩 assistant 消息互斥切换', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const assistantBox = page.locator('.lotus-ai-dialogue-box-left').first();
    const likeBtn = assistantBox.locator('button[aria-label="点赞"]');
    const dislikeBtn = assistantBox.locator('button[aria-label="点踩"]');

    await likeBtn.click();
    await expect(likeBtn).toHaveClass(/lotus-ai-dialogue-action-active/);

    await dislikeBtn.click();
    await expect(dislikeBtn).toHaveClass(/lotus-ai-dialogue-action-active/);
    await expect(likeBtn).not.toHaveClass(/lotus-ai-dialogue-action-active/);
  });

  test('删除消息后从列表中移除', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const countBefore = await page.locator('.lotus-ai-dialogue-box').count();
    await page.locator('.lotus-ai-dialogue-box-right').first().locator('button[aria-label="删除"]').click();
    await expect(page.locator('.lotus-ai-dialogue-box')).toHaveCount(countBefore - 1);
  });

  test('streaming 模拟：点击按钮追加流式消息并支持增量更新', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    const countBefore = await page.locator('.lotus-ai-dialogue-box').count();
    await page.locator('button', { hasText: '模拟流式回复开始' }).click();
    await expect(page.locator('.lotus-ai-dialogue-box')).toHaveCount(countBefore + 1);

    await page.locator('button', { hasText: '追加流式增量' }).click();
    await expect(page.locator('.demo-ai-streaming-log')).toHaveText('流式消息已追加增量');
  });

  test('滚动控制：scrollToTop/scrollToBottom 命令式 API 不抛异常', async ({ page }) => {
    await page.goto('/');
    await page.locator('.lotus-ai-chat-dialogue').scrollIntoViewIfNeeded();

    await page.locator('button', { hasText: '滚动到顶部' }).click();
    await page.locator('button', { hasText: '滚动到底部' }).click();
    await expect(page.locator('.lotus-ai-chat-dialogue')).toBeVisible();
  });
});
