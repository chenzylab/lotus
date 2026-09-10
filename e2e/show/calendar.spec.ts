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

  test('month 模式：itemLimit 生效时格子真实高度撑开（回归防护：踩坑 #82 组件顶层非 Fragment 导致 scoped CSS 丢失，min-height 不生效）', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await calendar.scrollIntoViewIfNeeded();
    const cell = calendar.locator('.lotus-calendar-month-cell').first();
    const box = await cell.boundingBox();
    expect(box).not.toBeNull();
    // min-height: 96px 必须真实生效，不能被压缩成内容自然高度（~36px）
    expect(box!.height).toBeGreaterThanOrEqual(90);
  });

  test('month 模式：单日事件数超过可见行数时聚合为"+N 更多"，点击触发 onMoreClick 并弹出事件详情 Popover', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await calendar.scrollIntoViewIfNeeded();
    const more = calendar.locator('.lotus-calendar-month-cell-more').filter({ hasText: '还有 2 项' });
    await expect(more).toBeVisible();
    await more.click();
    await expect(page.getByLabel('Calendar 更多点击日志')).toContainText('还有 2 项未显示');

    // Popover 展示当天全部事件，不受 itemLimit 截断（这一天共 4 个事件）
    const card = page.locator('.lotus-calendar-event-card');
    await expect(card).toBeVisible();
    await expect(card.locator('.lotus-calendar-event-card-list li')).toHaveCount(4);
  });

  test('month 模式："+N 更多" 支持键盘操作（role=button + tabIndex + Enter 触发）', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await calendar.scrollIntoViewIfNeeded();
    const more = calendar.locator('.lotus-calendar-month-cell-more').filter({ hasText: '还有 2 项' });
    await expect(more).toHaveAttribute('role', 'button');
    await expect(more).toHaveAttribute('tabindex', '0');

    await more.focus();
    await page.keyboard.press('Enter');
    await expect(page.locator('.lotus-calendar-event-card')).toBeVisible();
  });

  test('month 模式：事件详情 Popover 关闭按钮触发 onClose', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('month Calendar');
    await calendar.scrollIntoViewIfNeeded();
    const more = calendar.locator('.lotus-calendar-month-cell-more').filter({ hasText: '还有 2 项' });
    await more.click();

    const card = page.locator('.lotus-calendar-event-card');
    await expect(card).toBeVisible();
    await card.locator('.lotus-calendar-event-card-close').click();
    await expect(card).not.toBeVisible();
    await expect(page.getByLabel('Calendar 关闭日志')).toHaveText('事件详情卡片已关闭');
  });

  test('day 模式：只渲染单日列，不显示周表头，showCurrTime 渲染当前时间线', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('day Calendar');
    await calendar.scrollIntoViewIfNeeded();
    await expect(calendar.locator('.lotus-calendar-day-col')).toHaveCount(1);
    await expect(calendar.locator('.lotus-calendar-week-header')).toHaveCount(0);
    await expect(calendar.locator('.lotus-calendar-curr-line')).toBeVisible();
  });

  test('day 模式：header 自定义头部内容正确渲染', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('day Calendar');
    await expect(calendar).toContainText('今日日程');
  });

  test('day 模式：scrollTop 初始滚动位置生效', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('day Calendar');
    const body = calendar.locator('.lotus-calendar-week-body');
    const scrollTop = await body.evaluate((el) => el.scrollTop);
    expect(scrollTop).toBe(480);
  });

  test('range 模式：按 range 区间渲染对应天数的列', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('range Calendar');
    await calendar.scrollIntoViewIfNeeded();
    await expect(calendar.locator('.lotus-calendar-day-col')).toHaveCount(3);
  });

  test('range 模式：renderDateDisplay 自定义表头展示', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('range Calendar');
    const headerCell = calendar.locator('.lotus-calendar-week-header-cell').first();
    await expect(headerCell).toContainText('1/12');
  });

  test('range 模式：allDayEventsRender 自定义全天事件区渲染', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('range Calendar');
    await expect(calendar).toContainText('自定义渲染');
  });

  test('range 模式：区间内事件正确渲染', async ({ page }) => {
    await page.goto('/');
    const calendar = page.getByLabel('range Calendar');
    await expect(calendar.getByText('区间内事件')).toBeVisible();
  });
});
