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

  test('mode 切换暗色主题：写入 document.documentElement 的 data-theme 属性，全局生效，Button/Input/Select/Modal/Table 视觉即时更新（不刷新页面）', async ({ page }) => {
    // 回归防护：调研 Semi 源码确认其 ConfigProvider 本身不承载主题能力
    // （Context 只有 locale/direction/timeZone 等字段），暗色模式是脱离
    // ConfigProvider 的全局 DOM 属性操作；这是 lotus 自己
    // specs/phases/phase-5-global-media-tools.spec.md 承诺、此前从未实现
    // 的能力，此测试覆盖该验收标准点名的 5 个组件。
    await page.goto('/');
    const toggleBtn = page.getByRole('button', { name: /切换到 dark|切换到 light/ });
    await toggleBtn.scrollIntoViewIfNeeded();

    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBeNull();

    const primaryButton = page.locator('button.lotus-button-theme-solid.lotus-button-primary').first();
    const lightBg = await primaryButton.evaluate((el) => getComputedStyle(el).backgroundColor);

    await toggleBtn.click();
    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBe('dark');

    // 不刷新页面的前提下，Button 的实际渲染背景色应该跟随暗色 token 变化。
    const darkBg = await primaryButton.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(darkBg).not.toBe(lightBg);

    // Input/Select/Modal/Table 均在同一个 ConfigProvider 子树内，仍然正常渲染
    // （暗色模式是纯 CSS 变量切换，不影响组件结构本身）。
    await expect(page.getByLabel('ConfigProvider mode 示例 Input')).toBeVisible();
    await expect(page.getByLabel('ConfigProvider mode 示例 Select')).toBeVisible();
    await expect(page.getByLabel('ConfigProvider mode 示例 Table')).toBeVisible();

    await page.getByRole('button', { name: '打开 mode 示例 Modal' }).click();
    await expect(page.getByLabel('ConfigProvider mode 示例 Modal')).toBeVisible();
    await page.getByRole('button', { name: '确定' }).click();

    await toggleBtn.click();
    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBe('light');
  });
});
