import { test, expect } from '@playwright/test';

test.describe('Cropper', () => {
  test('图片加载完成后渲染裁切框与 8 个手柄', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('基础 Cropper');
    await expect(cropper).toBeVisible();
    await expect(cropper.locator('.lotus-cropper-box')).toBeVisible();
    await expect(cropper.locator('.lotus-cropper-corner')).toHaveCount(8);
  });

  test('拖拽裁切框内部平移，位置发生变化', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('基础 Cropper');
    const box = cropper.locator('.lotus-cropper-box');
    await box.scrollIntoViewIfNeeded();
    await box.waitFor({ state: 'visible' });

    const before = (await box.boundingBox())!;
    await page.mouse.move(before.x + before.width / 2, before.y + before.height / 2);
    await page.mouse.down();
    // 演示区容器与裁切框初始宽高比一致，裁切框高度已贴满容器高度（垂直方向无移动空间，
    // 会被 moveCropperBox 的边界钳制夹死在居中值），故只在水平方向拖拽验证平移生效。
    await page.mouse.move(before.x + before.width / 2 - 40, before.y + before.height / 2, { steps: 5 });
    await page.mouse.up();

    const after = (await box.boundingBox())!;
    expect(after.x).toBeLessThan(before.x);
    // 平移不改变裁切框尺寸
    expect(after.width).toBeCloseTo(before.width, 0);
    expect(after.height).toBeCloseTo(before.height, 0);
  });

  test('拖拽右下角手柄调整裁切框尺寸', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('基础 Cropper');
    const box = cropper.locator('.lotus-cropper-box');
    const corner = cropper.locator('.lotus-cropper-corner-br');
    await corner.scrollIntoViewIfNeeded();
    await corner.waitFor({ state: 'visible' });

    const beforeBox = (await box.boundingBox())!;
    const cornerBox = (await corner.boundingBox())!;
    await page.mouse.move(cornerBox.x + cornerBox.width / 2, cornerBox.y + cornerBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(cornerBox.x + 40, cornerBox.y + 40, { steps: 5 });
    await page.mouse.up();

    const afterBox = (await box.boundingBox())!;
    expect(afterBox.width).toBeGreaterThan(beforeBox.width);
    expect(afterBox.height).toBeGreaterThan(beforeBox.height);
  });

  test('aspectRatio 锁定时拖拽手柄始终保持宽高比', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('锁定比例 Cropper');
    const box = cropper.locator('.lotus-cropper-box');
    const corner = cropper.locator('.lotus-cropper-corner-br');
    await corner.scrollIntoViewIfNeeded();
    await corner.waitFor({ state: 'visible' });

    const cornerBox = (await corner.boundingBox())!;
    await page.mouse.move(cornerBox.x + cornerBox.width / 2, cornerBox.y + cornerBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(cornerBox.x - 60, cornerBox.y - 40, { steps: 5 });
    await page.mouse.up();

    const afterBox = (await box.boundingBox())!;
    expect(afterBox.width / afterBox.height).toBeCloseTo(16 / 9, 1);
  });

  test('shape=round 时裁切框渲染为圆形（border-radius 50%）', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('锁定比例 Cropper');
    const box = cropper.locator('.lotus-cropper-box');
    await box.waitFor({ state: 'visible' });
    const borderRadius = await box.evaluate((el) => getComputedStyle(el).borderRadius);
    expect(borderRadius).not.toBe('0px');
  });

  test('滚轮缩放：向上滚动放大图片', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('基础 Cropper');
    const img = cropper.locator('.lotus-cropper-img');
    await img.scrollIntoViewIfNeeded();
    await img.waitFor({ state: 'visible' });

    const before = (await img.boundingBox())!;
    const cropperBox = (await cropper.boundingBox())!;
    await page.mouse.move(cropperBox.x + cropperBox.width / 2, cropperBox.y + cropperBox.height / 2);
    await page.mouse.wheel(0, -300);
    await page.waitForTimeout(100);

    const after = (await img.boundingBox())!;
    expect(after.width).toBeGreaterThan(before.width);
  });

  test('受控 zoom + rotate：外部按钮驱动，图片旋转角度同步', async ({ page }) => {
    await page.goto('/');
    const section = page.getByText('受控 zoom + rotate（外部按钮驱动）');
    await section.scrollIntoViewIfNeeded();
    const cropper = page.getByLabel('受控 Cropper');
    const img = cropper.locator('.lotus-cropper-img');
    await img.waitFor({ state: 'visible' });

    const rotateButton = page.getByRole('button', { name: '旋转 90°' });
    await rotateButton.click();

    const transform = await img.evaluate((el) => getComputedStyle(el).transform);
    expect(transform).not.toBe('none');

    const zoomLabel = page.getByLabel('Cropper zoom 值');
    await expect(zoomLabel).toContainText('rotate: 90');
  });

  test('受控 zoom：放大按钮驱动 zoom 值增加', async ({ page }) => {
    await page.goto('/');
    const section = page.getByText('受控 zoom + rotate（外部按钮驱动）');
    await section.scrollIntoViewIfNeeded();

    const zoomLabel = page.getByLabel('Cropper zoom 值');
    await expect(zoomLabel).toContainText('zoom: 1.00');

    const zoomInButton = page.getByRole('button', { name: '放大' });
    await zoomInButton.click();
    await expect(zoomLabel).toContainText('zoom: 1.20');
  });

  test('getCropperApi 命令式获取裁切结果，渲染出导出预览图', async ({ page }) => {
    await page.goto('/');
    const section = page.getByText('getCropperApi 命令式获取裁切结果');
    await section.scrollIntoViewIfNeeded();

    const button = page.getByRole('button', { name: '获取裁切结果' });
    await button.click();

    const preview = page.getByLabel('命令式 Cropper 导出预览');
    await expect(preview).toBeVisible();
    const src = await preview.getAttribute('src');
    expect(src).toMatch(/^data:image\/png/);
  });

  test('onCrop：拖拽裁切框后自动回调，导出预览图实时更新', async ({ page }) => {
    await page.goto('/');
    const cropper = page.getByLabel('基础 Cropper');
    const box = cropper.locator('.lotus-cropper-box');
    await box.scrollIntoViewIfNeeded();
    await box.waitFor({ state: 'visible' });

    const before = (await box.boundingBox())!;
    await page.mouse.move(before.x + before.width / 2, before.y + before.height / 2);
    await page.mouse.down();
    await page.mouse.move(before.x + before.width / 2 + 20, before.y + before.height / 2 + 10, { steps: 5 });
    await page.mouse.up();

    const preview = page.getByLabel('Cropper 导出预览');
    await expect(preview).toBeVisible();
    const src = await preview.getAttribute('src');
    expect(src).toMatch(/^data:image\/png/);
  });
});
