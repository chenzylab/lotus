import { test, expect } from '@playwright/test';

test.describe('Chat', () => {
  test('基础用法：消息按 role 分左右渲染，头像与角色名正确显示', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    await expect(chat).toBeVisible();

    const assistantMsg = chat.locator('.lotus-chat-message[data-role="assistant"]').first();
    await expect(assistantMsg).toHaveClass(/lotus-chat-message-left/);
    await expect(assistantMsg.locator('.lotus-chat-message-name')).toHaveText('lotus 助手');
    await expect(assistantMsg.locator('.lotus-chat-message-text')).toHaveText('你好，我可以帮你做什么？');

    const userMsg = chat.locator('.lotus-chat-message[data-role="user"]').first();
    await expect(userMsg).toHaveClass(/lotus-chat-message-right/);
    await expect(userMsg.locator('.lotus-chat-message-name')).toHaveText('我');
  });

  test('user 消息只有复制/删除操作，没有点赞/点踩', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const userMsg = chat.locator('.lotus-chat-message[data-role="user"]').first();
    await expect(userMsg.locator('[aria-label="复制"]')).toBeVisible();
    await expect(userMsg.locator('[aria-label="删除"]')).toBeVisible();
    await expect(userMsg.locator('[aria-label="点赞"]')).toHaveCount(0);
    await expect(userMsg.locator('[aria-label="点踩"]')).toHaveCount(0);
  });

  test('assistant 消息带完整的复制/点赞/点踩/删除操作', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const assistantMsg = chat.locator('.lotus-chat-message[data-role="assistant"]').first();
    await expect(assistantMsg.locator('[aria-label="复制"]')).toBeVisible();
    await expect(assistantMsg.locator('[aria-label="点赞"]')).toBeVisible();
    await expect(assistantMsg.locator('[aria-label="点踩"]')).toBeVisible();
    await expect(assistantMsg.locator('[aria-label="删除"]')).toBeVisible();
  });

  test('点击快捷提示按钮把文案填入输入框', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    await chat.locator('.lotus-chat-hint').filter({ hasText: '介绍一下组件库' }).click();
    await expect(chat.locator('[aria-label="聊天输入框"]')).toHaveValue('介绍一下组件库');
  });

  test('输入内容后点击发送，新消息追加到列表末尾，输入框清空', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const before = await chat.locator('.lotus-chat-message').count();

    await chat.locator('[aria-label="聊天输入框"]').fill('测试发送消息');
    await chat.locator('[aria-label="发送消息"]').click();

    await expect(chat.locator('.lotus-chat-message')).toHaveCount(before + 1);
    const lastMsg = chat.locator('.lotus-chat-message').last();
    await expect(lastMsg.locator('.lotus-chat-message-text')).toHaveText('测试发送消息');
    await expect(chat.locator('[aria-label="聊天输入框"]')).toHaveValue('');
  });

  test('空白输入时发送按钮为禁用态，无法发送', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    await expect(chat.locator('[aria-label="发送消息"]')).toBeDisabled();

    const before = await chat.locator('.lotus-chat-message').count();
    await chat.locator('[aria-label="聊天输入框"]').fill('   ');
    await expect(chat.locator('[aria-label="发送消息"]')).toBeDisabled();
    expect(await chat.locator('.lotus-chat-message').count()).toBe(before);
  });

  test('按 Enter 键发送（默认 sendHotKey=enter）', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const before = await chat.locator('.lotus-chat-message').count();

    const textarea = chat.locator('[aria-label="聊天输入框"]');
    await textarea.fill('回车发送测试');
    await textarea.press('Enter');

    await expect(chat.locator('.lotus-chat-message')).toHaveCount(before + 1);
  });

  test('点击点赞按钮切换 active 态', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const likeBtn = chat.locator('.lotus-chat-message[data-role="assistant"]').first().locator('[aria-label="点赞"]');
    await expect(likeBtn).toHaveAttribute('aria-pressed', 'false');
    await likeBtn.click();
    await expect(likeBtn).toHaveAttribute('aria-pressed', 'true');
    await expect(likeBtn).toHaveClass(/lotus-chat-message-action-active/);
  });

  test('点击删除按钮移除对应消息，不影响其它消息', async ({ page }) => {
    await page.goto('/');
    const chat = page.locator('.demo-chat');
    const before = await chat.locator('.lotus-chat-message').count();

    const userMsg = chat.locator('.lotus-chat-message[data-role="user"]').first();
    await userMsg.locator('[aria-label="删除"]').click();

    await expect(chat.locator('.lotus-chat-message')).toHaveCount(before - 1);
    await expect(chat.locator('.lotus-chat-message[data-role="assistant"]').first()).toBeVisible();
  });
});
