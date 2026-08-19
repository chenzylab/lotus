import { test, expect } from '@playwright/test';

test.describe('Image', () => {
  test('图片加载成功后正确显示，未成功前 placeholder/skeleton 占位', async ({ page }) => {
    await page.goto('/');
    const image = page.getByLabel('基础 Image');
    await expect(image.locator('.lotus-image-img')).toBeVisible();
    // opacity 由图片 onLoad 事件异步驱动，toBeVisible() 只保证元素在 DOM 里有
    // 非零尺寸，不代表资源已经加载完——用 expect.poll 等待真正的加载完成态，
    // 不能读取一次就断言（外部图片资源加载时间不确定，读太早会偶发失败）。
    await expect.poll(() =>
      image.locator('.lotus-image-img').evaluate((el) => getComputedStyle(el).opacity),
    { timeout: 10000 }).toBe('1');
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

    const previewDialog = page.getByRole('dialog');
    const previewImg = page.locator('.lotus-image-preview-img');
    const getTransform = () => previewImg.evaluate((el) => (el as HTMLElement).style.transform);

    await previewDialog.getByLabel('放大').click();
    await expect.poll(getTransform).toContain('scale(1.5)');

    await previewDialog.getByLabel('旋转').click();
    await expect.poll(getTransform).toContain('rotate(90deg)');

    await previewDialog.getByLabel('缩小').click();
    await expect.poll(getTransform).toContain('scale(1)');
  });

  test('ImagePreviewGroup：点击任意一张定位到正确 index，支持左右切换与循环', async ({ page }) => {
    await page.goto('/');
    const second = page.getByLabel('Group 图片二');
    await second.click();

    // 用 role=dialog 限定范围——Image 预览层和 Carousel 的箭头按钮都叫"下一张"，
    // 页面级裸选择器会命中多个元素触发 Playwright 严格模式报错（踩坑 #46 同族）。
    const previewDialog = page.getByRole('dialog');
    const indicator = previewDialog.locator('.lotus-image-preview-indicator');
    await expect(indicator).toHaveText('2 / 3');

    await previewDialog.getByLabel('下一张').click();
    await expect(indicator).toHaveText('3 / 3');

    await previewDialog.getByLabel('下一张').click();
    await expect(indicator).toHaveText('1 / 3');

    await page.keyboard.press('ArrowLeft');
    await expect(indicator).toHaveText('3 / 3');
  });
});
