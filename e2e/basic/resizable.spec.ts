import { test, expect } from '@playwright/test';

test.describe('Resizable', () => {
  test('初始尺寸对应 defaultWidth/defaultHeight，8 个方向手柄均渲染', async ({ page }) => {
    await page.goto('/');
    const resizable = page.locator('.lotus-resizable', { hasText: '拖拽边缘或角落调整大小' });

    const box = await resizable.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBe(240);
    expect(box!.height).toBe(120);

    const handlerCount = await resizable.locator('.lotus-resizable-handler').count();
    expect(handlerCount).toBe(8);
  });

  test('拖拽 bottomRight 手柄增大容器，触发 onChange/onResizeEnd 回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const resizable = page.locator('.lotus-resizable', { hasText: '拖拽边缘或角落调整大小' });
    const handler = resizable.locator('.lotus-resizable-handler-bottomRight');
    // Resizable 位于页面靠下位置，boundingBox() 取到的坐标必须基于滚动稳定后的视口，
    // 否则鼠标操作时页面可能仍处于滚动过程中，坐标与实际点击位置不一致导致 mousedown
    // 落空（不会触发 onMouseDown，resizing 态不会进入）。
    await handler.scrollIntoViewIfNeeded();

    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;

    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 50, startY + 30, { steps: 5 });
    await page.mouse.up();

    const box = await resizable.boundingBox();
    expect(box!.width).toBe(290);
    expect(box!.height).toBe(150);

    expect(logs.some((l) => l.includes('resizable changed'))).toBe(true);
    expect(logs.some((l) => l.includes('resizable resize end'))).toBe(true);
  });

  test('拖拽超出 maxWidth/maxHeight 时尺寸被夹在上限', async ({ page }) => {
    await page.goto('/');
    const resizable = page.locator('.lotus-resizable', { hasText: '拖拽边缘或角落调整大小' });
    const handler = resizable.locator('.lotus-resizable-handler-bottomRight');
    await handler.scrollIntoViewIfNeeded();

    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;

    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 500, startY + 500, { steps: 5 });
    await page.mouse.up();

    const box = await resizable.boundingBox();
    expect(box!.width).toBe(480);
    expect(box!.height).toBe(320);
  });

  test('键盘：聚焦手柄后按方向键以固定步长调整尺寸（回归防护：手柄此前纯靠 onMouseDown 触发，键盘用户完全无法调整大小，Class C 补齐键盘无障碍）', async ({ page }) => {
    await page.goto('/');
    const resizable = page.locator('.lotus-resizable', { hasText: '拖拽边缘或角落调整大小' });
    const handler = resizable.locator('.lotus-resizable-handler-bottomRight');
    await handler.scrollIntoViewIfNeeded();

    await expect(handler).toHaveAttribute('role', 'button');
    await expect(handler).toHaveAttribute('aria-label', /.+/);

    const before = (await resizable.boundingBox())!;
    await handler.focus();
    await handler.press('ArrowRight');
    await handler.press('ArrowDown');

    const after = await resizable.boundingBox();
    expect(after!.width).toBe(before.width + 10);
    expect(after!.height).toBe(before.height + 10);
  });

  test('拖拽 left 手柄向外移动时宽度增加，高度不变', async ({ page }) => {
    await page.goto('/');
    const resizable = page.locator('.lotus-resizable', { hasText: '拖拽边缘或角落调整大小' });
    const handler = resizable.locator('.lotus-resizable-handler-left');
    await handler.scrollIntoViewIfNeeded();

    const before = (await resizable.boundingBox())!;
    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;

    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX - 20, startY, { steps: 5 });
    await page.mouse.up();

    const after = await resizable.boundingBox();
    expect(after!.width).toBe(before.width + 20);
    expect(after!.height).toBe(before.height);
  });
});
