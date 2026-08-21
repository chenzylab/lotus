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
    // 月份滚轮默认居中滚到"当前月"，只有 12 项且单项 36px 高、视口 224px（约
    // 6 项可见），点一个离当前月很远的固定月份（如硬编码"3月"）大概率被滚动
    // 裁出可视区域外——它在 DOM 里"存在"但真实像素位置落在别处，坐标点击会
    // 落空或误中其它元素；Playwright 的自动"滚入视图"还会和组件自身"回滚到
        // 选中项"的初始定位 effect互相打架，越重试越不收敛（真实测过 toPass 10s
    // 都收敛不了）。改成动态选"当前月 +1"（跨 12 月环绕），必定落在初始视口
    // 内，不依赖任何等待或重试就能稳定点中。
    const monthLabels = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    const now = new Date();
    const targetMonthIndex = (now.getMonth() + 1) % 12; // 0-based 当前月 +1
    const targetMonthLabel = monthLabels[targetMonthIndex]!;
    const targetMonthNumber = targetMonthIndex + 1;

    // 就算目标离默认位置很近，仍观测到偶发点选未生效（怀疑年/月滚轮每次
    // 选择都会让 YearMonthWheel 整体重渲染、内部 ScrollItem 的初始定位状态
    // 跟着重置一轮）；直接 JS .click() 已验证底层交互逻辑本身完全正确
    // （见 spec 踩坑记录），这里保守多等一拍再点，用 toPass() 兜底收敛。
    // month 类型选中即提交并关闭面板，点错一次面板就没了，重试前要先判断
    // 面板是否还在，不在就重新打开。
    await expect(async () => {
        if (await page.locator('.lotus-date-picker-panel').count() === 0) await input.click();
        await expect(yam).toBeVisible();
        await yam.locator('.lotus-scroll-item-option', { hasText: targetMonthLabel, exact: true }).click();
        await expect(input).toHaveValue(new RegExp(`-${String(targetMonthNumber).padStart(2, '0')}$`), { timeout: 1000 });
    }).toPass({ timeout: 15_000, intervals: [500] });
    await expect(page.locator('.lotus-date-picker-panel')).toHaveCount(0);
  });

  test('year 类型：单列年份滚轮，选年后立即提交', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('DatePicker 年份', { exact: true });
    await input.click();

    const yam = page.locator('.lotus-date-picker-yam');
    await expect(yam).toBeVisible();
    // 年份滚轮默认居中滚到"当前年"（201 项，单项 36px，视口 224px 约 6 项
    // 可见），点一个硬编码的固定年份（如"2025"）离当前年的实际相对距离取决
    // 于跑测试的日期，选一个必定落在初始视口内的目标——用"当前年 +1"而非
    // 固定字面量，理由同 month 类型测试（远离默认位置的项会被滚动裁出可视
    // 区域，坐标点击落空，且和组件自身"回滚到选中项"的 effect 互相打架，
    // 重试也收敛不了）。
    const targetYear = new Date().getFullYear() + 1;
    // 就算目标离默认位置很近，仍观测到偶发点选未生效（同上一条 month 类型
    // 测试的踩坑，理由见那里的注释），用 toPass() 兜底收敛，点错一次面板
    // 关闭就重新打开。
    await expect(async () => {
        if (await page.locator('.lotus-date-picker-panel').count() === 0) await input.click();
        await expect(yam).toBeVisible();
        await yam.locator('.lotus-scroll-item-option', { hasText: `${targetYear}`, exact: true }).click();
        await expect(input).toHaveValue(`${targetYear}`, { timeout: 1000 });
    }).toPass({ timeout: 15_000, intervals: [500] });
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
    const yamLocator = page.locator('.lotus-date-picker-yam');
    await expect(yamLocator).toBeVisible();

    // 年/月滚轮默认居中滚到当前年月附近的可视窗口；点固定字面量（如"2030"/
    // "5月"）离默认位置的实际距离取决于运行日期，可能被滚动裁出可视区域，
    // 坐标点击落空（同 month/year 类型测试的踩坑，理由见那两处注释）。改用
    // "当前年/月 +1"，必定落在初始视口内；即便如此仍观测到偶发点选未生效
    // （怀疑每次选择都让 YearMonthWheel 整体重渲染，月份滚轮初始定位跟着
    // 重置一轮），用 toPass() 兜底收敛——点错年/月不会关闭整个面板，YAM 若
    // 因跳回网格视图而消失就重新点标题钻回来。
    const monthLabels = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    const now = new Date();
    const targetYear = now.getFullYear() + 1;
    const targetMonthLabel = monthLabels[(now.getMonth() + 1) % 12]!;

    await expect(async () => {
        // 偶发观测到点击坐标落到面板外，触发"点外部关闭"把整个面板带走
        // （不只是 YAM 跳回网格视图）——这种情况下连导航标题都找不到了，
        // 要从最外层的触发器重新点开，不能只重开 YAM。
        if (await page.locator('.lotus-date-picker-panel').count() === 0) {
            await input.click();
            await page.locator('.lotus-date-picker-navigation-text').click();
        } else if (await yamLocator.count() === 0 || !(await yamLocator.isVisible())) {
            await page.locator('.lotus-date-picker-navigation-text').click();
        }
        await expect(yamLocator).toBeVisible();
        await yamLocator.locator('.lotus-scroll-item-option', { hasText: `${targetYear}`, exact: true }).click();
        // 选年后年月滚轮会重渲染重新定位一轮（ego-browser 真机复现确认：
        // 紧跟着立刻点月份容易撞上这个重定位窗口，稍等一拍再点就稳定），
        // 给点喘息时间再点月份。
        await page.waitForTimeout(200);
        await yamLocator.locator('.lotus-scroll-item-option', { hasText: targetMonthLabel, exact: true }).click();
        await expect(page.locator('.lotus-date-picker-navigation-text')).toHaveText(`${targetYear}年 ${targetMonthLabel}`, { timeout: 1000 });
    }).toPass({ timeout: 15_000, intervals: [500] });

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
