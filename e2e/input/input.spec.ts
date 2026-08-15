import { test, expect } from '@playwright/test';

test.describe('Input', () => {
  test('输入内容后触发 onChange，非受控模式下值同步显示', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const input = page.getByPlaceholder('请输入');
    await input.fill('hello lotus');

    await expect(input).toHaveValue('hello lotus');
    expect(logs.some((l) => l.includes('input changed'))).toBe(true);
  });

  test('disabled 状态下无法输入', async ({ page }) => {
    await page.goto('/');
    // 渲染顺序对齐 App.tsrx demo：基本/large/default/small/disabled
    const input = page.locator('.lotus-input-native').nth(4);
    await expect(input).toHaveValue('禁用状态');
    await expect(input).toBeDisabled();
  });

  test('showClear：hover 后出现清除按钮，点击后清空内容', async ({ page }) => {
    await page.goto('/');
    const clearableInput = page.locator('.lotus-input-native').nth(8);
    await expect(clearableInput).toHaveValue('hover 或 focus 时可清除');
    await clearableInput.hover();
    const clearButton = page.locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(clearableInput).toHaveValue('');
  });

  test('密码模式：点击眼睛图标切换 input type', async ({ page }) => {
    await page.goto('/');
    const passwordInput = page.locator('.lotus-input-native').nth(9);
    await expect(passwordInput).toHaveValue('secret123');
    await expect(passwordInput).toHaveAttribute('type', 'password');

    await page.locator('.lotus-input-eye').click();
    await expect(passwordInput).toHaveAttribute('type', 'text');
  });

  test('受控组件：外部 value 变化时输入框同步更新', async ({ page }) => {
    await page.goto('/');
    const controlledInput = page.locator('.lotus-input-native').nth(12);
    await expect(controlledInput).toHaveValue('受控初始值');
    await controlledInput.fill('受控新值');
    await expect(controlledInput).toHaveValue('受控新值');
  });

  test('校验状态：validateStatus=error 时容器带对应 class', async ({ page }) => {
    await page.goto('/');
    const errorInput = page.locator('.lotus-input-native').nth(11);
    await expect(errorInput).toHaveValue('错误状态');
    await expect(errorInput.locator('xpath=..')).toHaveClass(/lotus-input-status-error/);
  });
});
