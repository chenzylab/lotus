import { test, expect } from '@playwright/test';

test.describe('Popover', () => {
  test('click 触发：点击后浮层出现，支持渲染任意 JSX 内容（不止文本）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click 打开卡片' });
    await trigger.click();

    const popover = page.locator('.lotus-popover');
    await expect(popover).toBeVisible();
    await expect(popover).toContainText('自定义卡片内容');
    // 验证嵌套的 Tag 组件真实渲染（证明内容不局限于纯文本）
    await expect(popover.locator('.lotus-tag')).toContainText('支持任意 JSX');
  });

  test('trigger=click 时浮层具有 dialog role（对齐 Semi 的 a11y 语义）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'click 打开卡片' }).click();

    const dialog = page.getByRole('dialog');
    await expect(dialog).toBeVisible();
  });

  test('按 Esc 键关闭浮层', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: 'click 打开卡片' }).click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(page.locator('.lotus-popover')).not.toBeVisible();
  });

  test('按 Esc 键关闭浮层后，焦点归还到触发元素（回归防护：a11y.spec.md 要求浮层关闭后焦点归还）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click 打开卡片' });
    await trigger.click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(page.locator('.lotus-popover')).not.toBeVisible();
    await expect(trigger).toBeFocused();
  });

  test('click 触发：点击触发器和浮层以外的区域自动关闭（对齐 Semi trigger=click/contextMenu 默认行为，回归防护：此前完全没有点击外部关闭机制）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click 打开卡片' });
    await trigger.click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    // 点击浮层内部不应关闭
    await page.locator('.lotus-popover-content').click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    // 点击页面空白区域应关闭
    await page.locator('body').click({ position: { x: 5, y: 5 } });
    await expect(page.locator('.lotus-popover')).not.toBeVisible();
  });

  test('hover 触发 + showArrow 时浮层带箭头样式', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'hover + 箭头' });
    await trigger.hover();

    const popover = page.locator('.lotus-popover');
    await expect(popover).toBeVisible();
    await expect(popover.locator('.lotus-popover-arrow')).toBeVisible();
  });

  test('arrowPointAtCenter=false 时箭头挪离浮层中心（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');

    const centerTrigger = page.getByRole('button', { name: 'arrowPointAtCenter=true' });
    await centerTrigger.hover();
    const centerArrow = page.locator('.lotus-popover.lotus-popover-arrow-bottomLeft .lotus-popover-arrow');
    await expect(centerArrow).toBeVisible();
    const centerLeft = await centerArrow.evaluate((el) => getComputedStyle(el).left);

    await page.mouse.move(0, 0);
    await page.waitForTimeout(100);

    const offsetTrigger = page.getByRole('button', { name: 'arrowPointAtCenter=false' });
    await offsetTrigger.hover();
    const offsetArrow = page.locator('.lotus-popover.lotus-popover-arrow-bottom .lotus-popover-arrow');
    await expect(offsetArrow).toBeVisible();
    const offsetLeft = await offsetArrow.evaluate((el) => getComputedStyle(el).left);

    expect(offsetLeft).not.toBe(centerLeft);
  });

  test('onClickOutSide/onEscKeyDown：点击外部与按 Esc 都触发对应回调（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'onClickOutSide/onEscKeyDown' });
    await trigger.click();
    await expect(page.locator('.lotus-popover')).toBeVisible();

    await page.locator('body').click({ position: { x: 5, y: 5 } });
    expect(logs).toContain('popover onClickOutSide fired');

    await trigger.click();
    await page.keyboard.press('Escape');
    expect(logs).toContain('popover onEscKeyDown fired');
  });

  test('stopPropagation + clickToHide：点击浮层内容不冒泡到 body，且点击后自动关闭（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'clickToHide' });
    await trigger.click();

    const popover = page.locator('.lotus-popover', { hasText: '点我关闭' });
    await expect(popover).toBeVisible();

    await popover.getByText('点我关闭（clickToHide）').click();
    expect(logs).toContain('popover content clicked');
    await expect(popover).not.toBeVisible();
  });
});
