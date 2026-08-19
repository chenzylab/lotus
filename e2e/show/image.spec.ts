import { test, expect } from '@playwright/test';

test.describe('Image', () => {
  test('图片加载成功后正确显示，未成功前 placeholder/skeleton 占位', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('基础 Image');
    await expect(image.locator('.lotus-image-img')).toBeVisible();
    const opacity = await image.locator('.lotus-image-img').evaluate((el) => getComputedStyle(el).opacity);
    expect(opacity).toBe('1');
  });

  test('加载失败时显示错误占位图标', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('加载失败 Image');
    await expect(image.locator('.lotus-image-error')).toBeVisible({ timeout: 5000 });
  });

  test('点击图片打开全屏预览层，ESC 关闭', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('基础 Image');
    await image.click();

    const mask = page.locator('.lotus-image-preview-mask');
    await expect(mask).toBeVisible();
    await expect(page.locator('.lotus-image-preview-img')).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(mask).not.toBeVisible();
  });

  test('点击遮罩空白处关闭预览，点击图片本身不关闭', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('基础 Image');
    await image.click();

    const mask = page.locator('.lotus-image-preview-mask');
    await expect(mask).toBeVisible();

    await page.locator('.lotus-image-preview-img').click();
    await expect(mask).toBeVisible();

    await page.mouse.click(20, 20);
    await expect(mask).not.toBeVisible();
  });

  test('放大/缩小/旋转按钮正确更新 transform', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('基础 Image');
    await image.click();

    const previewImg = page.locator('.lotus-image-preview-img');
    const getTransform = () => previewImg.evaluate((el) => (el as HTMLElement).style.transform);

    await page.getByLabel('放大').click();
    await expect.poll(getTransform).toContain('scale(1.5)');

    await page.getByLabel('旋转').click();
    await expect.poll(getTransform).toContain('rotate(90deg)');

    await page.getByLabel('缩小').click();
    await expect.poll(getTransform).toContain('scale(1)');
  });

  test('ImagePreviewGroup：点击任意一张定位到正确 index，支持左右切换与循环', async ({ page }) => {
    await page.goto('/');
    const second = page.getByLabel('Group 图片二');
    await second.click();

    const indicator = page.locator('.lotus-image-preview-indicator');
    await expect(indicator).toHaveText('2 / 3');

    await page.getByLabel('下一张').click();
    await expect(indicator).toHaveText('3 / 3');

    await page.getByLabel('下一张').click();
    await expect(indicator).toHaveText('1 / 3');

    await page.keyboard.press('ArrowLeft');
    await expect(indicator).toHaveText('3 / 3');
  });
});
