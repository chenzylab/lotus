import { test, expect } from '@playwright/test';

test.describe('Grid', () => {
  test('响应式断点：Col 在 xs/md/lg 三档视口宽度下按对应 span 渲染不同百分比宽度（回归防护：此前 e2e 只测过 pull/push/span=0 静态场景，从未验证过任何响应式断点是否真的生效——Col 的 xs/md/lg 是直接写 inline style flexBasis/maxWidth 百分比，不是 CSS @media 断点，需要真实改变 viewport 后重新读取渲染宽度才能验证）', async ({ page }) => {
    // demo 配置：<Col span={24} md={12} lg={8}>（对齐 apps/playground demo，
    // 断点阈值来自 packages/foundation/src/base/responsive.ts 的 BREAKPOINTS：
    // md=768px、lg=992px）。
    const colA = page.getByText('Col A', { exact: true });

    // xs 档：视口宽度 < md(768)，只声明了 span=24，无 xs 覆盖，应回退到 span
    // 本身（24/24=100% 全宽）。
    await page.setViewportSize({ width: 600, height: 800 });
    await page.goto('/');
    await colA.scrollIntoViewIfNeeded();
    const rowXs = colA.locator('xpath=ancestor::div[contains(@class,"lotus-row")]');
    const colABoxXs = await colA.locator('xpath=..').boundingBox();
    const rowBoxXs = await rowXs.boundingBox();
    if (!colABoxXs || !rowBoxXs) throw new Error('no bounding box at xs');
    expect(colABoxXs.width / rowBoxXs.width).toBeCloseTo(1, 1);

    // md 档：768 <= 视口宽度 < 992，命中 md={12}（12/24=50%）。
    await page.setViewportSize({ width: 800, height: 800 });
    await colA.scrollIntoViewIfNeeded();
    const colABoxMd = await colA.locator('xpath=..').boundingBox();
    const rowBoxMd = await rowXs.boundingBox();
    if (!colABoxMd || !rowBoxMd) throw new Error('no bounding box at md');
    expect(colABoxMd.width / rowBoxMd.width).toBeCloseTo(0.5, 1);

    // lg 档：视口宽度 >= 992，命中 lg={8}（8/24 ≈ 33.3%）。
    await page.setViewportSize({ width: 1100, height: 800 });
    await colA.scrollIntoViewIfNeeded();
    const colABoxLg = await colA.locator('xpath=..').boundingBox();
    const rowBoxLg = await rowXs.boundingBox();
    if (!colABoxLg || !rowBoxLg) throw new Error('no bounding box at lg');
    expect(colABoxLg.width / rowBoxLg.width).toBeCloseTo(1 / 3, 1);
  });

  test('pull/push 让栅格发生水平位移但不改变 DOM 顺序', async ({ page }) => {
    await page.goto('/');

    const pushCol = page.getByText('col-18 push-6', { exact: true });
    const pullCol = page.getByText('col-6 pull-18', { exact: true });
    await expect(pushCol).toBeVisible();
    await expect(pullCol).toBeVisible();

    const pushBox = await pushCol.boundingBox();
    const pullBox = await pullCol.boundingBox();
    // DOM 顺序里 push 列在前、pull 列在后，但 push 向右移、pull 向左移，
    // 视觉上 pull 列（pull-18）应该出现在 push 列（push-6）左边。
    expect(pullBox!.x).toBeLessThan(pushBox!.x);
  });

  test('span 为 0 的 Col 不可见（display: none 语义）', async ({ page }) => {
    await page.goto('/');

    const hiddenCol = page.getByText('col-0（应隐藏）', { exact: true });
    await expect(hiddenCol).toBeHidden();
  });
});
