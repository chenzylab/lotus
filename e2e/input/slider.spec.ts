import { test, expect } from '@playwright/test';

test.describe('Slider', () => {
  test('渲染出 role=slider 的手柄，初始值对齐 defaultValue', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 基础', { exact: true });
    await expect(handle).toHaveAttribute('role', 'slider');
    await expect(handle).toHaveAttribute('aria-valuenow', '0');
  });

  test('点击轨道跳转到点击位置对应的值', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 基础', { exact: true });
    const wrapper = handle.locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    // page.mouse.* 系列 API 用绝对视口坐标、不会像 locator.click() 那样自动
    // 把目标滚入视图，必须先显式 scrollIntoViewIfNeeded() 再取 boundingBox()，
    // 否则量到的坐标可能是元素滚动到位前的旧位置。
    await wrapper.scrollIntoViewIfNeeded();
    const box = await wrapper.boundingBox();
    if (!box) throw new Error('no bounding box');
    await page.mouse.click(box.x + box.width * 0.75, box.y + box.height / 2);
    await expect(handle).toHaveAttribute('aria-valuenow', '75');
    await expect(page.getByLabel('Slider 事件日志', { exact: true })).toContainText('变化：75');
  });

  test('拖拽手柄到轨道指定位置后值同步更新', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 基础', { exact: true });
    const wrapper = handle.locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    await wrapper.scrollIntoViewIfNeeded();
    const box = await wrapper.boundingBox();
    if (!box) throw new Error('no bounding box');
    const handleBox = await handle.boundingBox();
    if (!handleBox) throw new Error('no handle box');

    await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x + box.width * 0.3, box.y + box.height / 2);
    await page.mouse.up();

    await expect(handle).toHaveAttribute('aria-valuenow', '30');
  });

  test('键盘方向键：ArrowRight/ArrowLeft 按 step 步进', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 基础', { exact: true });
    await handle.focus();
    await handle.press('ArrowRight');
    await expect(handle).toHaveAttribute('aria-valuenow', '1');
    await handle.press('ArrowRight');
    await expect(handle).toHaveAttribute('aria-valuenow', '2');
    await handle.press('ArrowLeft');
    await expect(handle).toHaveAttribute('aria-valuenow', '1');
  });

  test('键盘 Home/End 跳到边界值', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 基础', { exact: true });
    await handle.focus();
    await handle.press('End');
    await expect(handle).toHaveAttribute('aria-valuenow', '100');
    await handle.press('Home');
    await expect(handle).toHaveAttribute('aria-valuenow', '0');
  });

  test('range：渲染两个手柄，初始值对齐 defaultValue 两端', async ({ page }) => {
    await page.goto('/');
    const wrapper = page.getByLabel('Slider 范围', { exact: true }).locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    const handles = wrapper.locator('.lotus-slider-handle');
    await expect(handles).toHaveCount(2);
    await expect(handles.nth(0)).toHaveAttribute('aria-valuenow', '20');
    await expect(handles.nth(1)).toHaveAttribute('aria-valuenow', '80');
  });

  test('range：拖拽 min 手柄不能越过 max 手柄（收缩贴住而非穿越）', async ({ page }) => {
    await page.goto('/');
    const wrapper = page.getByLabel('Slider 范围', { exact: true }).locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    const handles = wrapper.locator('.lotus-slider-handle');
    const minHandle = handles.nth(0);
    await wrapper.scrollIntoViewIfNeeded();
    const box = await wrapper.boundingBox();
    const handleBox = await minHandle.boundingBox();
    if (!box || !handleBox) throw new Error('no bounding box');

    await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x + box.width * 0.95, box.y + box.height / 2);
    await page.mouse.up();

    await expect(minHandle).toHaveAttribute('aria-valuenow', '80');
    await expect(handles.nth(1)).toHaveAttribute('aria-valuenow', '80');
  });

  test('marks：渲染刻度点和文案标签', async ({ page }) => {
    await page.goto('/');
    const wrapper = page.getByLabel('Slider 刻度', { exact: true }).locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    await expect(wrapper.locator('.lotus-slider-dot')).toHaveCount(6);
    await expect(wrapper.locator('.lotus-slider-mark')).toHaveCount(6);
    await expect(wrapper.locator('.lotus-slider-mark').first()).toHaveText('0°C');
  });

  test('禁用态：点击轨道不触发值变化，aria-disabled=true', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 禁用', { exact: true });
    await expect(handle).toHaveAttribute('aria-disabled', 'true');
    await expect(handle).toHaveAttribute('aria-valuenow', '40');

    const wrapper = handle.locator('xpath=ancestor::div[contains(@class,"lotus-slider-rail-wrapper")]');
    const box = await wrapper.boundingBox();
    if (!box) throw new Error('no bounding box');
    await page.mouse.click(box.x + box.width * 0.9, box.y + box.height / 2);
    await expect(handle).toHaveAttribute('aria-valuenow', '40');
  });

  test('vertical：垂直方向渲染对应 class', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 垂直', { exact: true });
    // "lotus-slider-rail-wrapper" 是 "lotus-slider" 的子串，contains() 匹配会先撞上它；
    // 用精确的空格边界匹配根节点自身的 class（前后各补一个空格再比对，兼容 class 属性
    // 里其它 class 排在前后的情况）。
    const root = handle.locator('xpath=ancestor::div[contains(concat(" ", normalize-space(@class), " "), " lotus-slider ")]');
    await expect(root).toHaveClass(/lotus-slider-vertical/);
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const handle = page.getByLabel('Slider 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Slider' });

    await expect(handle).toHaveAttribute('aria-valuenow', '30');
    await toggleButton.click();
    await expect(handle).toHaveAttribute('aria-valuenow', '70');
    await toggleButton.click();
    await expect(handle).toHaveAttribute('aria-valuenow', '30');
  });
});
