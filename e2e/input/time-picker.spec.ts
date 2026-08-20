import { test, expect } from '@playwright/test';

test.describe('TimePicker', () => {
  test('点击触发器打开面板，展示时/分/秒三列', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.click();

    const panel = page.locator('.lotus-time-picker-panel');
    await expect(panel).toBeVisible();
    const options = panel.locator('.lotus-scroll-item-option');
    await expect(options).toHaveCount(24 + 60 + 60);
    await expect(options.first()).toHaveText('00时');
  });

  test('点击时间列选项后输入框和 onChange 同步更新', async ({ page }) => {
    // 选靠近列表顶部的项（无值时默认展示今天 00 点，靠顶部项始终在可视区域内，
    // 不依赖滚动定位——ScrollItem 是真实可滚动列表，测试只验证点击选中的交互契约）。
    // 断言输入框自身值（组件用固定 HH:mm:ss 格式化，不依赖浏览器 locale），
    // 不断言 demo 日志文本——日志里的 toLocaleTimeString() 输出格式随浏览器 locale 漂移。
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.click();

    await page.locator('.lotus-scroll-item-option', { hasText: '01时' }).click();
    await expect(input).toHaveValue(/^01:\d{2}:\d{2}$/);
    await expect(page.getByLabel('TimePicker 事件日志', { exact: true })).toContainText('变化：');
  });

  test('手输时间串失焦后解析提交', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.fill('09:15:00');
    await input.blur();
    await expect(input).toHaveValue('09:15:00');
  });

  test('手输非法时间串失焦后不提交，回退展示上一次已提交值', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.fill('09:15:00');
    await input.blur();
    await input.fill('not-a-time');
    await input.blur();
    await expect(input).toHaveValue('09:15:00');
  });

  test('清除按钮：hover 后显示，点击清空输入框', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.fill('09:15:00');
    await input.blur();

    const wrapper = input.locator('xpath=ancestor::div[contains(@class,"lotus-input-wrapper")]');
    await wrapper.hover();
    const clearButton = wrapper.locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(input).toHaveValue('');
  });

  test('12 小时制：面板显示上午/下午列，小时从 01 开始', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 12小时制', { exact: true });
    await input.click();

    const panel = page.locator('.lotus-time-picker-panel');
    await expect(panel).toBeVisible();
    const firstOptions = panel.locator('.lotus-scroll-item-option');
    await expect(firstOptions.first()).toHaveText('上午');
    await expect(firstOptions.nth(1)).toHaveText('下午');
    await expect(firstOptions.nth(2)).toHaveText('01时');
  });

  test('timeRange：左右双列并排，各自独立选择', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 范围', { exact: true });
    await input.click();

    const lists = page.locator('.lotus-time-picker-lists .lotus-scroll-list');
    await expect(lists).toHaveCount(2);

    await page.locator('.lotus-time-picker-list-left .lotus-scroll-item-option', { hasText: '02时' }).click();
    await page.locator('.lotus-time-picker-list-right .lotus-scroll-item-option', { hasText: '03时' }).click();

    // 断言输入框自身值：组件固定 HH:mm:ss 格式化，不受 demo 日志里 toLocaleTimeString() 的 locale 影响。
    await expect(input).toHaveValue(/^02:\d{2}:\d{2} ~ 03:\d{2}:\d{2}$/);
  });

  test('禁用小时/分钟且隐藏禁用项：禁用范围不出现在列表中', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 禁用项', { exact: true });
    await input.click();

    const panel = page.locator('.lotus-time-picker-panel');
    await expect(panel).toBeVisible();
    await expect(panel.locator('.lotus-scroll-item-option', { hasText: '00时' })).toHaveCount(0);
    await expect(panel.locator('.lotus-scroll-item-option', { hasText: '06时' })).toHaveCount(1);
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 TimePicker' });

    await expect(input).toHaveValue('');
    await toggleButton.click();
    await expect(input).toHaveValue('14:30:00');
    await toggleButton.click();
    await expect(input).toHaveValue('');
  });

  test('点击触发器/面板以外区域时面板自动收起', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.click();
    await expect(page.locator('.lotus-time-picker-panel')).toBeVisible();

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(page.locator('.lotus-time-picker-panel')).toHaveCount(0);
  });

  test('面板打开后再次点击输入框内部不应意外关闭面板', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.click();
    await expect(page.locator('.lotus-time-picker-panel')).toBeVisible();

    await input.click();
    await expect(page.locator('.lotus-time-picker-panel')).toBeVisible();
  });

  test('Escape 键关闭面板', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('TimePicker 基础', { exact: true });
    await input.click();
    await expect(page.locator('.lotus-time-picker-panel')).toBeVisible();

    await input.press('Escape');
    await expect(page.locator('.lotus-time-picker-panel')).toHaveCount(0);
  });
});
