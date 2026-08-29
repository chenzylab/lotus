import { test, expect } from '@playwright/test';

test.describe('Modal', () => {
  test('基础用法：点击触发按钮打开，点击确定后关闭并触发 afterClose', async ({ page }) => {
    await page.goto('/');
    const modal = page.getByLabel('基础 Modal');
    await expect(modal).toBeHidden();

    await page.getByRole('button', { name: '打开基础 Modal' }).click();
    await expect(modal).toBeVisible();
    await expect(modal.getByText('这是 Modal 的内容区域。')).toBeVisible();

    await modal.getByRole('button', { name: '确定' }).click();
    await expect(modal).toBeHidden();
    await expect(page.getByText(/afterClose 触发于/)).toBeVisible();
  });

  test('body 滚动锁定：打开时锁定，关闭后恢复（回归防护：此前 Modal 完全没有接入 body 滚动锁定，背景内容在 Modal 打开期间仍可滚动）', async ({ page }) => {
    await page.goto('/');
    const bodyOverflow = () => page.evaluate(() => document.body.style.overflow);
    await expect.poll(bodyOverflow).not.toBe('hidden');

    await page.getByRole('button', { name: '打开基础 Modal' }).click();
    const modal = page.getByLabel('基础 Modal');
    await expect(modal).toBeVisible();
    await expect.poll(bodyOverflow).toBe('hidden');

    await modal.getByRole('button', { name: '确定' }).click();
    await expect(modal).toBeHidden();
    await expect.poll(bodyOverflow).not.toBe('hidden');
  });

  test('点击遮罩空白区域关闭，点击内容区域不会误触发关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开基础 Modal' }).click();
    const modal = page.getByLabel('基础 Modal');
    await expect(modal).toBeVisible();

    await modal.getByText('这是 Modal 的内容区域。').click();
    await expect(modal).toBeVisible();

    await page.mouse.click(20, 20);
    await expect(modal).toBeHidden();
  });

  test('按 ESC 关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开受控 Modal（居中，可按 ESC 关闭）' }).click();
    const modal = page.getByLabel('受控居中 Modal');
    await expect(modal).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(modal).toBeHidden();
  });

  test('自定义 footer 覆盖默认的确定/取消按钮', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开自定义 footer Modal' }).click();
    const modal = page.getByLabel('自定义 footer Modal');
    await expect(modal).toBeVisible();
    await expect(modal.getByRole('button', { name: '我知道了' })).toBeVisible();
    await expect(modal.getByRole('button', { name: '取消' })).toHaveCount(0);

    await modal.getByRole('button', { name: '我知道了' }).click();
    await expect(modal).toBeHidden();
  });

  test('onOk 返回 Promise 时按钮进入 loading 态，resolve 后自动关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开异步 Modal' }).click();
    const modal = page.getByLabel('异步 Modal');
    await expect(modal).toBeVisible();

    const okButton = modal.getByRole('button', { name: '确定' });
    await okButton.click();
    await expect(okButton).toHaveClass(/lotus-button-loading/);
    await expect(modal).toBeHidden({ timeout: 2000 });
  });

  test('fullScreen 模式下内容铺满视口', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开全屏 Modal' }).click();
    const modal = page.getByLabel('全屏 Modal');
    await expect(modal).toBeVisible();
    await expect(modal).toHaveClass(/lotus-modal-fullscreen/);

    await modal.getByRole('button', { name: '确定' }).click();
    await expect(modal).toBeHidden();
  });

  test('closable=false 时无关闭按钮，maskClosable=false 时点击遮罩不关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: /打开 large Modal/ }).click();
    const modal = page.getByLabel('large 无遮罩关闭 Modal');
    await expect(modal).toBeVisible();
    await expect(modal.locator('.lotus-modal-close')).toHaveCount(0);

    await page.mouse.click(20, 20);
    await expect(modal).toBeVisible();

    await modal.getByRole('button', { name: '取消' }).click();
    await expect(modal).toBeHidden();
  });

  test('无障碍：打开后焦点移入对话框，Tab 键在内部循环，关闭后焦点归还触发按钮', async ({ page }) => {
    await page.goto('/');
    const openBtn = page.getByRole('button', { name: '打开基础 Modal' });
    await openBtn.focus();
    await openBtn.click();

    const modal = page.getByLabel('基础 Modal');
    await expect(modal).toBeVisible();
    await expect(modal.evaluate((el) => el.contains(document.activeElement))).resolves.toBe(true);

    for (let i = 0; i < 6; i++) await page.keyboard.press('Tab');
    await expect(modal.evaluate((el) => el.contains(document.activeElement))).resolves.toBe(true);

    await modal.getByRole('button', { name: '确定' }).click();
    await expect(modal).toBeHidden();
    await expect(openBtn).toBeFocused();
  });
});
