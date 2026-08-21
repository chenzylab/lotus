import { test, expect } from '@playwright/test';

test.describe('ColorPicker', () => {
  test('基础用法：渲染出饱和度-明度矩形、色相条、透明度条、hex 输入框，初始值对齐默认色', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    await expect(root.locator('.lotus-color-picker-sv')).toBeVisible();
    await expect(root.locator('.lotus-color-picker-hue')).toBeVisible();
    await expect(root.locator('.lotus-color-picker-alpha')).toBeVisible();
    const hexInput = root.locator('.lotus-color-picker-input-hex');
    await expect(hexInput).toHaveValue(/^#[0-9a-f]{6}$/);
  });

  test('点击饱和度-明度矩形更新手柄位置与色值', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const sv = root.locator('.lotus-color-picker-sv');
    await sv.scrollIntoViewIfNeeded();
    const box = await sv.boundingBox();
    if (!box) throw new Error('no bounding box');

    await page.mouse.click(box.x + 5, box.y + 5);
    // 点击左上角（s≈0,v≈100）后色相不变、只有饱和度/明度趋近白色，
    // hex 应该是接近纯白但仍带一点原色相偏色的浅色调（不是纯 #ffffff）。
    const hexInput = root.locator('.lotus-color-picker-input-hex');
    await expect(hexInput).toHaveValue(/^#f[0-9a-f]f[0-9a-f]f[0-9a-f]$/i);
    await expect(page.getByLabel('ColorPicker 事件日志', { exact: true })).toContainText('变化：#f');
  });

  test('拖拽饱和度-明度手柄跟随鼠标移动', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const sv = root.locator('.lotus-color-picker-sv');
    await sv.scrollIntoViewIfNeeded();
    const box = await sv.boundingBox();
    if (!box) throw new Error('no bounding box');
    const handle = root.locator('.lotus-color-picker-sv-handle');
    const handleBox = await handle.boundingBox();
    if (!handleBox) throw new Error('no handle box');

    await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x + box.width, box.y + box.height);
    await page.mouse.up();

    const style = await handle.getAttribute('style');
    expect(style).toContain(`left: ${box.width}px`);
  });

  test('点击色相条更新色相角度', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const hue = root.locator('.lotus-color-picker-hue');
    await hue.scrollIntoViewIfNeeded();
    const box = await hue.boundingBox();
    if (!box) throw new Error('no bounding box');

    await page.mouse.click(box.x, box.y + box.height / 2);
    const hueHandle = hue.locator('.lotus-color-picker-bar-handle');
    await expect(hueHandle).toHaveAttribute('aria-valuenow', '0');
  });

  test('点击透明度条更新透明度并反映到色块', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const alphaBar = root.locator('.lotus-color-picker-alpha');
    await alphaBar.scrollIntoViewIfNeeded();
    const box = await alphaBar.boundingBox();
    if (!box) throw new Error('no bounding box');

    await page.mouse.click(box.x, box.y + box.height / 2);
    const alphaHandle = alphaBar.locator('.lotus-color-picker-bar-handle');
    await expect(alphaHandle).toHaveAttribute('aria-valuenow', '0');
  });

  test('键盘：饱和度-明度手柄方向键步进', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const sv = root.locator('.lotus-color-picker-sv');
    await sv.scrollIntoViewIfNeeded();
    const box = await sv.boundingBox();
    if (!box) throw new Error('no bounding box');
    // 先点到矩形中间，避开边界钳制，再用方向键验证相对移动。
    await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
    const handle = root.locator('.lotus-color-picker-sv-handle');
    await handle.focus();
    const before = await handle.boundingBox();
    if (!before) throw new Error('no handle box before');
    await handle.press('ArrowRight');
    const after = await handle.boundingBox();
    if (!after) throw new Error('no handle box after');
    expect(after.x).toBeGreaterThan(before.x);
  });

  test('键盘：色相条方向键步进色相角度', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const hueHandle = root.locator('.lotus-color-picker-hue .lotus-color-picker-bar-handle');
    await hueHandle.scrollIntoViewIfNeeded();
    await hueHandle.focus();
    const before = Number(await hueHandle.getAttribute('aria-valuenow'));
    await hueHandle.press('ArrowRight');
    await expect(hueHandle).toHaveAttribute('aria-valuenow', String(before + 1));
  });

  test('手动输入 hex 值更新色块与三态同步', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const hexInput = root.locator('.lotus-color-picker-input-hex');
    await hexInput.fill('#ff0000');
    await hexInput.blur();
    const swatch = root.locator('.lotus-color-picker-swatch').first();
    await expect(swatch).toHaveCSS('background-color', 'rgb(255, 0, 0)');
  });

  test('切换颜色格式按钮：hex → rgba → hsva 循环', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 基础', { exact: true });
    const toggleButton = root.getByLabel('切换颜色格式', { exact: true });

    await expect(root.locator('.lotus-color-picker-input-hex')).toBeVisible();
    await toggleButton.click();
    const channels = root.locator('.lotus-color-picker-channels');
    await expect(channels.locator('input')).toHaveCount(4);
    await toggleButton.click();
    await expect(channels.locator('input')).toHaveCount(4);
    await toggleButton.click();
    await expect(root.locator('.lotus-color-picker-input-hex')).toBeVisible();
  });

  test('alpha=false：不渲染透明度条，rgba 格式下只有 3 个通道输入框', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 无透明度', { exact: true });
    await expect(root.locator('.lotus-color-picker-alpha')).toHaveCount(0);

    const toggleButton = root.getByLabel('切换颜色格式', { exact: true });
    await toggleButton.click();
    await expect(root.locator('.lotus-color-picker-channels input')).toHaveCount(3);
  });

  test('usePopover：默认渲染色块触发器，点击展开面板，点击外部关闭', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 弹层', { exact: true });
    const trigger = root.locator('.lotus-color-picker-trigger');
    await expect(trigger.getByRole('button', { name: '点击选择颜色' })).toBeVisible();

    // Popover 面板经 Portal 渲染到 body 外层，不在 root 子树内，用"点击前后
    // 全局 panel 总数的差值"验证展开/收起，而不是绝对 count（其它非 popover
    // 模式的 demo 本身就常驻渲染 .lotus-color-picker-panel）。
    const before = await page.locator('.lotus-color-picker-panel').count();
    await trigger.click();
    await expect(page.locator('.lotus-color-picker-panel')).toHaveCount(before + 1);

    await page.locator('body').click({ position: { x: 5, y: 5 } });
    await expect(page.locator('.lotus-color-picker-panel')).toHaveCount(before);
  });

  test('受控：value+onChange 回路——初始值正确，操作后 value 经外部状态回灌仍保持同步', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('ColorPicker 无透明度', { exact: true });
    const swatch = root.locator('.lotus-color-picker-swatch').first();
    await expect(swatch).toHaveCSS('background-color', 'rgb(46, 184, 230)');

    const sv = root.locator('.lotus-color-picker-sv');
    await sv.scrollIntoViewIfNeeded();
    const box = await sv.boundingBox();
    if (!box) throw new Error('no bounding box');
    // 整数边界 box.x+box.width 可能落在矩形外一像素导致命中不到目标元素，
    // 内收 1px 保证点击落在矩形内部的右上角。
    await page.mouse.click(box.x + box.width - 1, box.y + 1);
    // 点击右上角（s=100,v=100）后 onChange 把新值写回外部 state，
    // 再作为 value 传回组件——受控回路要求这次回灌后色块与手柄位置都保持同步。
    await expect(swatch).not.toHaveCSS('background-color', 'rgb(46, 184, 230)');
    const handle = root.locator('.lotus-color-picker-sv-handle');
    const style = await handle.getAttribute('style');
    expect(style).toContain(`left: ${box.width}px`);
    expect(style).toContain('top: 0px');
  });
});
