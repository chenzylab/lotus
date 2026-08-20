import { test, expect } from '@playwright/test';

test.describe('DatePicker', () => {
  test('点击触发器打开面板，展示星期表头与本月全部日期', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();

    const panel = page.locator('.lotus-date-picker-panel');
    await expect(panel).toBeVisible();
    await expect(panel.locator('.lotus-date-picker-weekday')).toHaveCount(7);
  });

  test('点击日期后输入框回填、onChange 触发、面板自动关闭', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();

    await page.locator('.lotus-date-picker-panel .lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^5$/ }).first().click();
    await expect(input).toHaveValue(/-05$/);
    await expect(page.getByLabel('DatePicker 事件日志', { exact: true })).toContainText('变化：');
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('dateRange：双面板并排，各自独立点选后回填两端', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 范围', { exact: true });
    await input.click();

    const panels = page.locator('.lotus-date-picker-single-panel');
    await expect(panels).toHaveCount(2);

    await panels.nth(0).locator('.lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^10$/ }).first().click();
    await panels.nth(1).locator('.lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^20$/ }).first().click();

    await expect(page.getByLabel('DatePicker 范围事件日志', { exact: true })).toContainText('变化：');
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('dateRange：只选一端时不触发 onChange，面板保持打开', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 范围', { exact: true });
    await input.click();

    const panels = page.locator('.lotus-date-picker-single-panel');
    await panels.nth(0).locator('.lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^10$/ }).first().click();

    await expect(page.getByLabel('DatePicker 范围事件日志', { exact: true })).toHaveText('');
    await expect(page.locator('.lotus-date-picker-panel')).toBeVisible();
  });

  test('disabledDate：禁用日期不可点击，class 标记为 disabled', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 禁用周末', { exact: true });
    await input.click();

    const disabledDay = page.locator('.lotus-date-picker-panel .lotus-date-picker-day-disabled').first();
    await expect(disabledDay).toBeVisible();
    await disabledDay.click();
    await expect(input).toHaveValue('');
  });

  test('presets：点击快捷项直接提交值并关闭面板', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker presets', { exact: true });
    await input.click();

    await page.locator('.lotus-date-picker-presets', { hasText: '今天' }).getByRole('button', { name: '今天' }).click();
    await expect(input).not.toHaveValue('');
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('month 类型：走年月滚轮而非日历网格，选月后提交并关闭', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 月份', { exact: true });
    await input.click();

    const yam = page.locator('.lotus-date-picker-yam');
    await expect(yam).toBeVisible();
    await expect(page.locator('.lotus-date-picker-day')).toHaveCount(0);
    // ScrollItem 挂载后要等 ResizeObserver 首次触发才能测得容器高度、进而把
    // 选中项滚到视图内（对齐 TimePicker 已验证的踩坑 #77：ScrollList 高度链路
    // 需要一次布局结算）；这个结算比自动化点击的速度慢，真实用户操作不会
    // 撞上这个窗口，但脚本紧跟着点击可能会点到"尚未滚到位"时视觉上仍在原处
    // 的其它项。等一小段时间让初始滚动定位完成，再点目标项。
    await page.waitForTimeout(300);

    await yam.locator('.lotus-scroll-item-option', { hasText: '3月' }).click();
    await expect(input).toHaveValue(/-03$/);
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('year 类型：单列年份滚轮，选年后立即提交', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 年份', { exact: true });
    await input.click();

    const yam = page.locator('.lotus-date-picker-yam');
    await expect(yam).toBeVisible();
    await page.waitForTimeout(300);
    await yam.locator('.lotus-scroll-item-option', { hasText: '2025' }).click();
    await expect(input).toHaveValue('2025');
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('dateTime 类型：选中日期后面板不自动关闭，可点 Switch 切到时间列', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 日期时间', { exact: true });
    await input.click();

    await page.locator('.lotus-date-picker-panel .lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^10$/ }).first().click();
    await expect(input).toHaveValue(/-10 \d{2}:\d{2}:\d{2}$/);
    await expect(page.locator('.lotus-date-picker-panel')).toBeVisible();

    await page.locator('.lotus-date-picker-switch-item').nth(1).click();
    await expect(page.locator('.lotus-date-picker-panel .lotus-scroll-list')).toBeVisible();
  });

  test('清除按钮：hover 后显示，点击清空输入框', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();
    await page.locator('.lotus-date-picker-panel .lotus-date-picker-day:not(.lotus-date-picker-day-empty)', { hasText: /^5$/ }).first().click();
    await expect(input).not.toHaveValue('');

    const wrapper = input.locator('xpath=ancestor::div[contains(@class,"lotus-input-wrapper")]');
    await wrapper.hover();
    const clearButton = wrapper.locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(input).toHaveValue('');
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 DatePicker' });

    await expect(input).toHaveValue('2024-03-05');
    await toggleButton.click();
    await expect(input).toHaveValue('');
    await toggleButton.click();
    await expect(input).toHaveValue('2024-03-05');
  });

  test('点击触发器/面板以外区域时面板自动收起', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();
    await expect(page.locator('.lotus-date-picker-panel')).toBeVisible();

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('面板打开后再次点击输入框内部不应意外关闭面板', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();
    await expect(page.locator('.lotus-date-picker-panel')).toBeVisible();

    await input.click();
    await expect(page.locator('.lotus-date-picker-panel')).toBeVisible();
  });

  test('点击导航文字可 drill-down 到年月滚轮，选完年月跳回日历网格', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();

    await page.locator('.lotus-date-picker-navigation-text').click();
    await expect(page.locator('.lotus-date-picker-yam')).toBeVisible();
    await page.waitForTimeout(300);

    await page.locator('.lotus-date-picker-yam .lotus-scroll-item-option', { hasText: '2030' }).click();
    await page.waitForTimeout(300);
    await page.locator('.lotus-date-picker-yam .lotus-scroll-item-option', { hasText: '5月' }).click();

    await expect(page.locator('.lotus-date-picker-navigation-text')).toHaveText('2030年 5月');
    await expect(page.locator('.lotus-date-picker-day')).not.toHaveCount(0);
  });

  test('翻月/翻年导航按钮正确推进面板显示的年月', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 基础', { exact: true });
    await input.click();

    const navText = page.locator('.lotus-date-picker-navigation-text');
    const before = await navText.textContent();
    const buttons = page.locator('.lotus-date-picker-navigation button');
    await buttons.nth(3).click();
    await expect(navText).not.toHaveText(before ?? '');
  });
});
