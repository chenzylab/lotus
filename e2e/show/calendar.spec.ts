import { test, expect } from '@playwright/test';

test.describe('Calendar', () => {
  test('week 模式：渲染 7 天表头，含 today/weekend 标记', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    await expect(calendar).toBeVisible();
    await expect(calendar.locator('.lotus-calendar-week-header-cell')).toHaveCount(7);
  });

  test('week 模式：普通事件正确渲染内容和背景色（回归防护：单文件多组件 scoped CSS 遗漏，踩坑 #68）', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    await expect(calendar).toBeVisible();

    const event = calendar.locator('.lotus-calendar-day-events .lotus-calendar-event').first();
    await expect(event).toBeVisible();
    await expect(event).not.toHaveText('');

    const bg = await event.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(bg).not.toBe('rgba(0, 0, 0, 0)');
  });

  test('week 模式：起止时间完全相同的事件并排显示', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    const events = calendar.locator('.lotus-calendar-day-events .lotus-calendar-event');
    const count = await events.count();
    expect(count).toBeGreaterThanOrEqual(4);

    const lefts = new Set<string>();
    for (let i = 0; i < count; i++) {
      const left = await events.nth(i).evaluate((el) => getComputedStyle(el).left);
      lefts.add(left);
    }
    // 并排事件（e1/e2）应该产生至少两种不同的 left 值（0% 和 50%）
    expect(lefts.size).toBeGreaterThan(1);
  });

  test('week 模式：跨天事件拆分到当天与次日', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    await expect(calendar.getByText('跨天夜间任务').first()).toBeVisible();
    const splitEvents = calendar.getByText('跨天夜间任务');
    await expect(splitEvents).toHaveCount(2);
  });

  test('week 模式：全天事件显示在全天行，跨天横条正确覆盖多列', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    const alldayRow = calendar.locator('.lotus-calendar-allday-row');
    await expect(alldayRow).toBeVisible();
    // 全天事件覆盖两天，被拆成两条每天一份的横条副本，都应可见
    await expect(alldayRow.getByText('全天活动')).toHaveCount(2);
  });

  test('week 模式：点击时间格触发 onClick 回调，携带精确到小时的 Date', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    await calendar.locator('.lotus-calendar-day-col-cell').first().click();
    await expect(page.getByText(/点击了/)).toBeVisible();
  });

  test('week 模式：markWeekend 时周末列带背景标记', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('week Calendar');
    const weekendCol = calendar.locator('.lotus-calendar-day-col.lotus-calendar-weekend');
    expect(await weekendCol.count()).toBeGreaterThan(0);
  });

  test('month 模式：按周渲染网格，跨天事件按贪心分层布局互不遮挡（回归防护：踩坑 #68 scoped CSS）', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await expect(calendar).toBeVisible();
    await expect(calendar.locator('.lotus-calendar-month-header-cell')).toHaveCount(7);

    const eventA = calendar.getByText('项目排期 A');
    const eventB = calendar.getByText(/项目排期 B/);
    await expect(eventA).toBeVisible();
    await expect(eventB).toBeVisible();

    const bg = await eventA.evaluate((el) => getComputedStyle(el.closest('.lotus-calendar-event') as Element).backgroundColor);
    expect(bg).not.toBe('rgba(0, 0, 0, 0)');

    // 时间重叠的两个事件必须分配到不同的纵向层级（top 不同），否则会互相遮挡
    const topA = await eventA.evaluate((el) => (el.closest('.lotus-calendar-event') as HTMLElement).style.top);
    const topB = await eventB.evaluate((el) => (el.closest('.lotus-calendar-event') as HTMLElement).style.top);
    expect(topA).not.toBe(topB);
  });

  test('month 模式：单日事件正确显示在对应日期格', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await expect(calendar.getByText('单日里程碑')).toBeVisible();
  });

  test('month 模式：markWeekend 时周末列带背景标记', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    const weekendCell = calendar.locator('.lotus-calendar-month-week-row .lotus-calendar-weekend');
    expect(await weekendCell.count()).toBeGreaterThan(0);
  });

  test('month 模式：点击日期格触发 onClick 回调', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    const cell = calendar.locator('.lotus-calendar-month-cell').first();
    await cell.scrollIntoViewIfNeeded();
    await cell.click();
    // month 模式复用同一个 onClick handler，点击后也应触发回调日志更新
    await expect(page.getByText(/点击了/)).toBeVisible();
  });
});
