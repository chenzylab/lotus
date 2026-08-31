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

test.describe('Resizable 单组件模式补齐的 Semi 缺口', () => {
  test('boundElement="parent" 限制调整范围不超出父容器；grid 生效使尺寸吸附到网格步长；handleStyle 应用到指定方向手柄', async ({ page }) => {
    await page.goto('/');
    const resizable = page.getByLabel('限制在父容器内、20px 网格吸附的可调整大小容器');
    await resizable.scrollIntoViewIfNeeded();

    const handler = resizable.locator('.lotus-resizable-handler-bottomRight');
    const bg = await handler.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(bg).not.toBe('rgba(0, 0, 0, 0)');

    const parentBox = (await resizable.locator('xpath=..').boundingBox())!;
    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;

    // 往超出父容器范围的方向大幅拖拽，验证 boundElement="parent" 生效。
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 1000, startY + 1000, { steps: 5 });
    await page.mouse.up();

    const box = await resizable.boundingBox();
    expect(box!.width).toBeLessThanOrEqual(parentBox.width + 1);
    expect(box!.height).toBeLessThanOrEqual(parentBox.height + 1);

    // grid=[20,20]：拖拽后的尺寸应该是 20 的整数倍（网格吸附，snapGap 默认 0 总是吸附）。
    expect(Math.round(box!.width) % 20).toBeLessThanOrEqual(1);
    expect(Math.round(box!.height) % 20).toBeLessThanOrEqual(1);
  });
});

test.describe('ResizeGroup（组合组件，对齐 Semi ResizeGroup/ResizeItem/ResizeHandler）', () => {
  test('JSX 写法：3 个 ResizeItem + 2 个 ResizeHandler 正确渲染，defaultSize 三态（%/flex 比例）按预期分配空间', async ({ page }) => {
    await page.goto('/');
    const group = page.locator('.lotus-resizable-group').first();
    await group.scrollIntoViewIfNeeded();

    const items = group.locator('.lotus-resizable-group-item');
    await expect(items).toHaveCount(3);
    await expect(group.locator('.lotus-resizable-group-handler')).toHaveCount(2);

    const groupBox = (await group.boundingBox())!;
    const widths = await items.evaluateAll((els) => els.map((el) => el.getBoundingClientRect().width));

    // 第一项 defaultSize="30%"，容器减去 2 个 6px handler 后的可用宽度的 30%。
    const available = groupBox.width - 12;
    expect(widths[0]).toBeCloseTo(available * 0.3, 0);
    // 第二、三项都是 flex=1，应均分剩余 70%。
    expect(widths[1]).toBeCloseTo(widths[2], 0);
  });

  test('拖拽 handler 只影响相邻两个 item，一个变大另一个等量变小，其余 item 不受影响（回归防护：此前 lotus 完全没有 Group 组合模式，对齐 Semi）', async ({ page }) => {
    await page.goto('/');
    const group = page.locator('.lotus-resizable-group').first();
    await group.scrollIntoViewIfNeeded();

    const items = group.locator('.lotus-resizable-group-item');
    const handler = group.locator('.lotus-resizable-group-handler').first();
    const before = await items.evaluateAll((els) => els.map((el) => el.getBoundingClientRect().width));

    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;
    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX + 60, startY, { steps: 5 });
    await page.mouse.up();

    const after = await items.evaluateAll((els) => els.map((el) => el.getBoundingClientRect().width));
    expect(after[0]).toBeGreaterThan(before[0]);
    expect(after[1]).toBeLessThan(before[1]);
    // 第三项不参与本次拖拽，允许几像素的重排浮点误差（百分比 -> px 换算精度），
    // 但变化量应远小于第一/二项的变化量（不应该被联动影响）。
    expect(Math.abs(after[2] - before[2])).toBeLessThan(5);
  });

  test('拖拽超出 min 约束时被夹住，不会继续缩小（对齐 Semi judgeConstraint/adjustNewSize）', async ({ page }) => {
    await page.goto('/');
    const group = page.locator('.lotus-resizable-group').first();
    await group.scrollIntoViewIfNeeded();

    const items = group.locator('.lotus-resizable-group-item');
    const handler = group.locator('.lotus-resizable-group-handler').first();
    const handlerBox = (await handler.boundingBox())!;
    const startX = handlerBox.x + handlerBox.width / 2;
    const startY = handlerBox.y + handlerBox.height / 2;

    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX - 400, startY, { steps: 5 });
    await page.mouse.up();

    const groupBox = (await group.boundingBox())!;
    const firstWidth = (await items.first().boundingBox())!.width;
    // 第一项 min="10%"，不应小于容器宽度的 10%（留一点误差空间）。
    expect(firstWidth).toBeGreaterThanOrEqual(groupBox.width * 0.1 - 2);
  });

  test('items 简化 API：无需手写 ResizeItem/ResizeHandler，直接渲染配置数组对应的面板', async ({ page }) => {
    await page.goto('/');
    const group = page.locator('.lotus-resizable-group').nth(1);
    await group.scrollIntoViewIfNeeded();

    const items = group.locator('.lotus-resizable-group-item');
    await expect(items).toHaveCount(2);
    await expect(items.first()).toContainText('items 面板一');
    await expect(items.nth(1)).toContainText('items 面板二');

    const widths = await items.evaluateAll((els) => els.map((el) => el.getBoundingClientRect().width));
    // 第一项 defaultSize='200px' 固定，第二项 flex=1 占满剩余空间。
    expect(widths[0]).toBeCloseTo(200, 0);
  });
});
