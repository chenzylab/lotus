import { test, expect } from '@playwright/test';

test.describe('DragMove', () => {
  test('基础用法：初始位置为 top:0,left:0，position 为 absolute', async ({ page }) => {
    await page.goto('/');
    const target = page.locator('.demo-drag-move-target');
    await expect(target).toBeVisible();
    await expect(target).toHaveCSS('position', 'absolute');
    await expect(target).toHaveCSS('left', '0px');
    await expect(target).toHaveCSS('top', '0px');
  });

  test('拖拽后元素跟随鼠标移动到新位置', async ({ page }) => {
    await page.goto('/');
    const target = page.locator('.demo-drag-move-target');
    await target.scrollIntoViewIfNeeded();
    const box = await target.boundingBox();
    if (!box) throw new Error('target bounding box not found');

    const startX = box.x + box.width / 2;
    const startY = box.y + box.height / 2;
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 100, startY + 50, { steps: 5 });
    await page.mouse.up();

    const newBox = await target.boundingBox();
    if (!newBox) throw new Error('target bounding box not found after drag');
    expect(newBox.x).toBeGreaterThan(box.x + 50);
    expect(newBox.y).toBeGreaterThan(box.y + 20);
  });

  test('拖拽超出约束容器边界时被钳制在容器内（constrainer="parent"）', async ({ page }) => {
    await page.goto('/');
    const target = page.locator('.demo-drag-move-target');
    const constrainer = page.locator('.demo-drag-move-constrainer');
    await target.scrollIntoViewIfNeeded();

    const box = await target.boundingBox();
    const constrainerBox = await constrainer.boundingBox();
    if (!box || !constrainerBox) throw new Error('bounding box not found');

    const startX = box.x + box.width / 2;
    const startY = box.y + box.height / 2;
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    // 拖到远超容器右下角边界之外
    await page.mouse.move(startX + 2000, startY + 2000, { steps: 5 });
    await page.mouse.up();

    const newBox = await target.boundingBox();
    if (!newBox) throw new Error('target bounding box not found after drag');
    expect(newBox.x + newBox.width).toBeLessThanOrEqual(constrainerBox.x + constrainerBox.width + 1);
    expect(newBox.y + newBox.height).toBeLessThanOrEqual(constrainerBox.y + constrainerBox.height + 1);
  });

  test('拖拽过程中容器带 lotus-drag-move-dragging class，松手后移除', async ({ page }) => {
    await page.goto('/');
    const target = page.locator('.demo-drag-move-target');
    await target.scrollIntoViewIfNeeded();
    const box = await target.boundingBox();
    if (!box) throw new Error('target bounding box not found');

    const startX = box.x + box.width / 2;
    const startY = box.y + box.height / 2;
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 30, startY + 30, { steps: 3 });
    await expect(target).toHaveClass(/lotus-drag-move-dragging/);
    await page.mouse.up();
    await expect(target).not.toHaveClass(/lotus-drag-move-dragging/);
  });

  test('拖拽起点不因中途布局变化产生跳变（连续多次小幅移动位移量线性可预测）', async ({ page }) => {
    await page.goto('/');
    const target = page.locator('.demo-drag-move-target');
    await target.scrollIntoViewIfNeeded();
    const box = await target.boundingBox();
    if (!box) throw new Error('target bounding box not found');

    const startX = box.x + box.width / 2;
    const startY = box.y + box.height / 2;
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 20, startY, { steps: 2 });
    const mid = await target.boundingBox();
    await page.mouse.move(startX + 40, startY, { steps: 2 });
    const end = await target.boundingBox();
    await page.mouse.up();

    if (!mid || !end) throw new Error('bounding box not found mid-drag');
    // 两段等距移动应该产生大致相等的位移增量（允许 clamp/精度误差）。
    const delta1 = mid.x - box.x;
    const delta2 = end.x - mid.x;
    expect(Math.abs(delta1 - delta2)).toBeLessThan(5);
  });
});
