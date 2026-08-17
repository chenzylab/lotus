import { test, expect } from '@playwright/test';

test.describe('ConfigProvider', () => {
  test('默认 zh-CN：Form 校验错误文案是中文', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });

    await usernameInput.click();
    await usernameInput.blur();

    await expect(page.getByText('该字段不能为空')).toBeVisible();
  });

  test('切换 locale 后，已经显示的校验错误文案实时更新（不需要重新触发校验、不需要重新挂载组件）', async ({ page }) => {
    // 回归防护：Form 内部只在切换 locale 时对"当前已经有 error 的字段"重新
    // 跑一次校验，如果这个 effect 缺失，旧的中文错误信息会原样保留，直到
    // 用户下次 blur/submit 才会用上新 locale 的文案，不满足
    // specs/cross-cutting/i18n-locale.spec.md 的"实时更新"验收标准。
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });
    const switchButton = page.getByRole('button', { name: '切换到 English' });

    await usernameInput.click();
    await usernameInput.blur();
    await expect(page.getByText('该字段不能为空')).toBeVisible();

    await switchButton.click();

    await expect(page.getByText('This field is required')).toBeVisible();
    await expect(page.getByText('该字段不能为空')).not.toBeVisible();
  });

  test('切换回 zh-CN 后，Switch 按钮文案与校验错误文案都恢复中文', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });
    const toEnglishButton = page.getByRole('button', { name: '切换到 English' });

    await usernameInput.click();
    await usernameInput.blur();
    await toEnglishButton.click();
    await expect(page.getByText('This field is required')).toBeVisible();

    const toChineseButton = page.getByRole('button', { name: 'Switch to 中文' });
    await toChineseButton.click();

    await expect(page.getByText('该字段不能为空')).toBeVisible();
  });
});
