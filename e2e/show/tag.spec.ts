import { test, expect } from '@playwright/test';

test.describe('Tag', () => {
  test('light/solid/ghost 三种主题均正确渲染对应 class', async ({ page }) => {
    await page.goto('/');

    const lightTag = page.locator('.lotus-tag-light', { hasText: 'blue' }).first();
    const solidTag = page.locator('.lotus-tag-solid', { hasText: 'blue' }).first();
    const ghostTag = page.locator('.lotus-tag-ghost', { hasText: 'blue' }).first();

    await expect(lightTag).toBeVisible();
    await expect(solidTag).toBeVisible();
    await expect(ghostTag).toBeVisible();
  });

  test('small/default/large 三种尺寸均正确渲染', async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('.lotus-tag-small', { hasText: 'small' })).toBeVisible();
    await expect(page.locator('.lotus-tag-default', { hasText: 'default' })).toBeVisible();
    await expect(page.locator('.lotus-tag-large', { hasText: 'large' })).toBeVisible();
  });

  test('closable 标签点击关闭按钮后从 DOM 中移除，并触发 onClose', async ({ page }) => {
    const consoleMessages: string[] = [];
    page.on('console', (msg) => consoleMessages.push(msg.text()));

    await page.goto('/');
    const closableTag = page.locator('.lotus-tag', { hasText: '可关闭标签' });
    await expect(closableTag).toBeVisible();

    await closableTag.locator('.lotus-tag-close').click();

    // 回归防护：Tag 的 visible 状态用派生 track 包装（吸取 Switch 踩坑 #7/#8 的教训），
    // 点击关闭必须让标签立即从 DOM 消失，而不是仅仅触发回调却视觉冻结。
    await expect(closableTag).not.toBeVisible();
    expect(consoleMessages).toContain('tag closed');
  });

  test('colorful：solid/light/ghost 均忽略 color 语义色，改用 AI 渐变色系', async ({ page }) => {
    await page.goto('/');

    const solidColorful = page.locator('.lotus-tag-colorful.lotus-tag-solid', { hasText: 'solid colorful' }).first();
    await expect(solidColorful).toBeVisible();
    await expect(solidColorful).not.toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');

    const lightColorful = page.locator('.lotus-tag-colorful.lotus-tag-light', { hasText: 'light colorful' }).first();
    await expect(lightColorful).toBeVisible();

    const ghostColorful = page.locator('.lotus-tag-colorful.lotus-tag-ghost', { hasText: 'ghost colorful' }).first();
    await expect(ghostColorful).toBeVisible();
  });

  test('colorful + gradient：三种 type 均改用渐变（solid 渐变背景，light/ghost 渐变文字裁切）', async ({ page }) => {
    await page.goto('/');

    const solidGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-solid').first();
    await expect(solidGradient).toHaveCSS('background-image', /gradient/);

    const lightGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-light').first();
    await expect(lightGradient).toHaveCSS('background-clip', 'text');

    const ghostGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-ghost').first();
    await expect(ghostGradient).toHaveCSS('background-clip', 'text');
  });
});
