import { test, expect } from '@playwright/test';

test.describe('Rating', () => {
  test('渲染出 role=radiogroup 与对应数量的星星', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 基础', { exact: true });
    await expect(group).toHaveAttribute('role', 'radiogroup');
    await expect(group.locator('.lotus-rating-star')).toHaveCount(5);
  });

  test('点击某颗星提交对应分值', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 基础', { exact: true });
    const star3 = group.locator('.lotus-rating-star').nth(2);
    await star3.click();
    await expect(page.getByLabel('Rating 事件日志', { exact: true })).toContainText('变化：3');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
  });

  test('allowClear：再次点击已选中的同一颗星清零', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 基础', { exact: true });
    const star3 = group.locator('.lotus-rating-star').nth(2);
    await star3.click();
    await expect(page.getByLabel('Rating 事件日志', { exact: true })).toContainText('变化：3');
    await star3.click();
    await expect(page.getByLabel('Rating 事件日志', { exact: true })).toContainText('变化：0');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(0);
  });

  test('allowClear=false：再次点击已选中的星不清零', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 不可清零', { exact: true });
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
    const star3 = group.locator('.lotus-rating-star').nth(2);
    await star3.click();
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
  });

  test('allowHalf：初始半星填充态正确渲染', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 半星', { exact: true });
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
    await expect(group.locator('.lotus-rating-star-half')).toHaveCount(1);
    await expect(group.locator('.lotus-rating-star-empty')).toHaveCount(6);
  });

  test('allowHalf：点击星星左半边提交半星分值', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 半星', { exact: true });
    const star2 = group.locator('.lotus-rating-star').nth(1);
    // page.mouse.click 用绝对视口坐标，不会像 locator.click() 那样自动把目标
    // 滚入视图（对齐 Slider 组件踩坑 #81），必须先显式滚动到位再取 boundingBox()。
    await star2.scrollIntoViewIfNeeded();
    const box = await star2.boundingBox();
    if (!box) throw new Error('no bounding box');
    await page.mouse.click(box.x + box.width * 0.25, box.y + box.height / 2);
    await expect(page.getByLabel('Rating 半星事件日志', { exact: true })).toContainText('变化：1.5');
  });

  test('hover 预览：鼠标悬停时星星填充跟随预览，移出后回落到已选值', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 基础', { exact: true });
    const star4 = group.locator('.lotus-rating-star').nth(3);
    await star4.hover();
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(4);

    await page.locator('body').hover({ position: { x: 10, y: 10 } });
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(0);
  });

  test('键盘：ArrowRight/ArrowLeft 按 1 递增递减', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 不可清零', { exact: true });
    await group.focus();
    await group.press('ArrowRight');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(4);
    await group.press('ArrowLeft');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
  });

  test('键盘：超过 count 环绕归零，低于 0 环绕跳到 count', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 基础', { exact: true });
    await group.focus();
    // count=5，从 0 开始：连续 5 次 ArrowRight 到 5，再按一次应归零。
    for (let i = 0; i < 5; i++) await group.press('ArrowRight');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(5);
    await group.press('ArrowRight');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(0);

    await group.press('ArrowLeft');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(5);
  });

  test('禁用态：不可聚焦，点击不触发变化', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 禁用', { exact: true });
    await expect(group).toHaveAttribute('tabindex', '-1');
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(2);

    const star4 = group.locator('.lotus-rating-star').nth(3);
    await star4.click({ force: true });
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(2);
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Rating' });

    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
    await toggleButton.click();
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(5);
    await toggleButton.click();
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
  });

  test('受控：onChange 拒绝更新时点击不会把 UI 带偏（回归防护：Foundation 曾无条件写内部 state，仅靠一个只在 value prop 变化时才重新调度的 effect 纠正，父组件拒绝更新时该 effect 永远不会重跑，UI 会永久停留在点击产生的中间态，真机验证确认过点击后 1 秒仍未被拉回）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('Rating 受控拒绝更新示例', { exact: true });
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);

    const star5 = group.locator('.lotus-rating-star').nth(4);
    await star5.click();

    // 点击后立即检查，且等待一小段时间确认不是异步纠正延迟，UI 应始终保持受控值 3。
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
    await page.waitForTimeout(300);
    await expect(group.locator('.lotus-rating-star-full')).toHaveCount(3);
  });
});
