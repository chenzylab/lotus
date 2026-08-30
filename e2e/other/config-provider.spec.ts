import { test, expect } from '@playwright/test';

test.describe('ConfigProvider', () => {
  test('默认 zh-CN：Form 校验错误文案是中文', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });

    await usernameInput.click();
    await usernameInput.blur();

    await expect(page.getByText('该字段不能为空')).toBeVisible();
  });

  test('切换 locale 后，已经显示的校验错误文案实时更新（不需要重新触发校验、不需要重新挂载组件）', async ({ page }) => {
    // 回归防护：Form 内部只在切换 locale 时对"当前已经有 error 的字段"重新
    // 跑一次校验，如果这个 effect 缺失，旧的中文错误信息会原样保留，直到
    // 用户下次 blur/submit 才会用上新 locale 的文案，不满足
    // specs/cross-cutting/i18n-locale.spec.md 的"实时更新"验收标准。
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });
    const switchButton = page.getByRole('button', { name: '切换到 English' });

    await usernameInput.click();
    await usernameInput.blur();
    await expect(page.getByText('该字段不能为空')).toBeVisible();

    await switchButton.click();

    await expect(page.getByText('This field is required')).toBeVisible();
    await expect(page.getByText('该字段不能为空')).not.toBeVisible();
  });

  test('切换回 zh-CN 后，Switch 按钮文案与校验错误文案都恢复中文', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('Username / 用户名', { exact: true });
    const toEnglishButton = page.getByRole('button', { name: '切换到 English' });

    await usernameInput.click();
    await usernameInput.blur();
    await toEnglishButton.click();
    await expect(page.getByText('This field is required')).toBeVisible();

    const toChineseButton = page.getByRole('button', { name: 'Switch to 中文' });
    await toChineseButton.click();

    await expect(page.getByText('该字段不能为空')).toBeVisible();
  });

  test('DatePicker/TimePicker 的日期/时间格式化输出跟随 locale 切换（回归防护：Phase 4 spec 要求至少两种 locale 的对比测试，此前完全空白）', async ({ page }) => {
    // zh-CN monthText 是"2026年 8月"这种"年份在前+年月倒序"格式，en-US 是
    // "Aug 2026"这种"月份缩写在前"格式——顺序和格式完全不同，不是简单的
    // 文案翻译，足以验证真的走了 locale 的 monthText 函数而非硬编码英文。
    await page.goto('/');
    const dateTrigger = page.getByLabel('ConfigProvider DatePicker 示例', { exact: true });
    await dateTrigger.scrollIntoViewIfNeeded();
    await dateTrigger.click();

    const monthLabel = page.locator('.lotus-date-picker-navigation-text').first();
    await expect(monthLabel).toHaveText(/^\d{4}年 \d{1,2}月$/);
    await expect(page.locator('.lotus-date-picker-weekday').first()).toHaveText('周日');
    // 上/下月、上/下年导航按钮的 aria-label（回归防护：此前是硬编码中文
    // 字符串"上一年"/"上个月"/"下个月"/"下一年"，切到 en-US 后不会跟着变）。
    const navButtons = page.locator('.lotus-date-picker-navigation button[aria-label]');
    await expect(navButtons.nth(0)).toHaveAttribute('aria-label', '上一年');
    await expect(navButtons.nth(1)).toHaveAttribute('aria-label', '上个月');
    await expect(navButtons.nth(2)).toHaveAttribute('aria-label', '下个月');
    await expect(navButtons.nth(3)).toHaveAttribute('aria-label', '下一年');

    await page.keyboard.press('Escape');
    await page.getByRole('button', { name: '切换到 English' }).click();

    await dateTrigger.click();
    await expect(monthLabel).toHaveText(/^[A-Z][a-z]{2} \d{4}$/);
    await expect(page.locator('.lotus-date-picker-weekday').first()).toHaveText('Sun');
    await expect(navButtons.nth(0)).toHaveAttribute('aria-label', 'Previous year');
    await expect(navButtons.nth(1)).toHaveAttribute('aria-label', 'Previous month');
    await expect(navButtons.nth(2)).toHaveAttribute('aria-label', 'Next month');
    await expect(navButtons.nth(3)).toHaveAttribute('aria-label', 'Next year');
    await page.keyboard.press('Escape');

    // 小时选项文案：zh-CN 带"时"单位后缀（如"01时"），en-US 是纯数字（"01"），
    // 这是比 AM/PM（两种 locale 缩写恰好相同，无法证明真的切换生效）更有效的
    // locale 差异验证点。此时已切换到 English，先验证英文态。
    const timeTrigger = page.getByLabel('ConfigProvider TimePicker 示例', { exact: true });
    await timeTrigger.scrollIntoViewIfNeeded();
    await timeTrigger.click();
    await expect(page.locator('.lotus-time-picker-panel [role="option"]').filter({ hasText: /^01$/ }).first()).toBeVisible();
    await page.keyboard.press('Escape');

    await page.getByRole('button', { name: 'Switch to 中文' }).click();
    await timeTrigger.click();
    await expect(page.locator('.lotus-time-picker-panel [role="option"]').filter({ hasText: '01时' }).first()).toBeVisible();
    await page.keyboard.press('Escape');

    // Calendar 时间刻度格式（回归防护：此前 formatHour 在组件内部硬编码
    // `locale === 'zh-CN'` 分支判断 24 小时制/12 小时 AM-PM 制，违反"新增
    // 语言包不需要改组件代码"的架构要求；现改为 locale.Calendar.formatHour
    // 格式化函数，此时已切回中文，应为 24 小时制"14:00"）。
    const calendar = page.getByLabel('ConfigProvider Calendar 示例', { exact: true });
    await calendar.scrollIntoViewIfNeeded();
    await expect(calendar.locator('.lotus-calendar-time-gutter-cell').nth(14)).toHaveText('14:00');

    await page.getByRole('button', { name: '切换到 English' }).click();
    await expect(calendar.locator('.lotus-calendar-time-gutter-cell').nth(14)).toHaveText('2 PM');
    await page.getByRole('button', { name: 'Switch to 中文' }).click();
  });

  test('mode 切换暗色主题：写入 document.documentElement 的 data-theme 属性，全局生效，Button/Input/Select/Modal/Table 视觉即时更新（不刷新页面）', async ({ page }) => {
    // 回归防护：调研 Semi 源码确认其 ConfigProvider 本身不承载主题能力
    // （Context 只有 locale/direction/timeZone 等字段），暗色模式是脱离
    // ConfigProvider 的全局 DOM 属性操作；这是 lotus 自己
    // specs/phases/phase-5-global-media-tools.spec.md 承诺、此前从未实现
    // 的能力，此测试覆盖该验收标准点名的 5 个组件。
    await page.goto('/');
    const toggleBtn = page.getByRole('button', { name: /切换到 dark|切换到 light/ });
    await toggleBtn.scrollIntoViewIfNeeded();

    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBeNull();

    const primaryButton = page.locator('button.lotus-button-theme-solid.lotus-button-primary').first();
    const lightBg = await primaryButton.evaluate((el) => getComputedStyle(el).backgroundColor);

    await toggleBtn.click();
    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBe('dark');

    // 不刷新页面的前提下，Button 的实际渲染背景色应该跟随暗色 token 变化。
    const darkBg = await primaryButton.evaluate((el) => getComputedStyle(el).backgroundColor);
    expect(darkBg).not.toBe(lightBg);

    // Input/Select/Modal/Table 均在同一个 ConfigProvider 子树内，仍然正常渲染
    // （暗色模式是纯 CSS 变量切换，不影响组件结构本身）。
    await expect(page.getByLabel('ConfigProvider mode 示例 Input')).toBeVisible();
    await expect(page.getByLabel('ConfigProvider mode 示例 Select')).toBeVisible();
    await expect(page.getByLabel('ConfigProvider mode 示例 Table')).toBeVisible();

    await page.getByRole('button', { name: '打开 mode 示例 Modal' }).click();
    await expect(page.getByLabel('ConfigProvider mode 示例 Modal')).toBeVisible();
    await page.getByRole('button', { name: '确定' }).click();

    await toggleBtn.click();
    expect(await page.evaluate(() => document.documentElement.getAttribute('data-theme'))).toBe('light');
  });

  test('direction=rtl：方向性图标水平镜像（Pagination 上下页、DatePicker 上下月/年、Carousel 左右切换、AudioPlayer 上下曲、Sidebar 返回箭头），回归防护：此前 CSS 逻辑属性只处理了布局位置镜像，图标本身的视觉朝向从未处理——图标库只有 LTR 默认方向一套，SVG 形状不会因为父容器 dir=rtl 就自动翻转，需要组件层显式用 scaleX(-1)', async ({ page }) => {
    await page.goto('/');
    const toggleBtn = page.getByRole('button', { name: /切换到 rtl|切换到 ltr/ });
    await toggleBtn.scrollIntoViewIfNeeded();
    await toggleBtn.click();
    await expect.poll(() => page.evaluate(() => document.documentElement.getAttribute('dir'))).toBe('rtl');

    const rtlPagination = page.getByLabel('ConfigProvider direction 示例 Pagination');
    const pagerPrevIcon = rtlPagination.locator('.lotus-pagination-prev svg');
    const pagerNextIcon = rtlPagination.locator('.lotus-pagination-next svg');
    await expect(pagerPrevIcon).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    await expect(pagerNextIcon).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');

    await page.getByLabel('ConfigProvider direction 示例 DatePicker').click();
    const navIcons = page.locator('.lotus-date-picker-navigation svg');
    await expect(navIcons).toHaveCount(4);
    for (let i = 0; i < 4; i++) {
      await expect(navIcons.nth(i)).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    }
    await page.keyboard.press('Escape');

    const rtlCarousel = page.getByLabel('ConfigProvider direction 示例 Carousel');
    await expect(rtlCarousel.locator('.lotus-carousel-arrow-left svg')).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    await expect(rtlCarousel.locator('.lotus-carousel-arrow-right svg')).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    // 物理位置也应该跟随镜像：arrow-left 用 inset-inline-start，RTL 下应
    // 该渲染在视觉右侧而不是左侧。
    const carouselBox = await rtlCarousel.boundingBox();
    const leftArrowBox = await rtlCarousel.locator('.lotus-carousel-arrow-left').boundingBox();
    if (!carouselBox || !leftArrowBox) throw new Error('no bounding box');
    expect(leftArrowBox.x).toBeGreaterThan(carouselBox.x + carouselBox.width / 2);

    const rtlAudioPlayer = rtlCarousel.locator('xpath=ancestor::div[contains(@style,"border")]').locator('.lotus-audio-player');
    await expect(rtlAudioPlayer.locator('button[aria-label="上一曲"] svg')).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    await expect(rtlAudioPlayer.locator('button[aria-label="下一曲"] svg')).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');
    // 快退/快进是媒体控制通用符号，不应该跟随 RTL 镜像（对齐 Semi 一手
    // 来源 AudioPlayer 没有独立 rtl.scss 的既有行为）。
    await expect(rtlAudioPlayer.locator('button[aria-label="快退"] svg')).toHaveCSS('transform', 'none');
    await expect(rtlAudioPlayer.locator('button[aria-label="快进"] svg')).toHaveCSS('transform', 'none');

    await page.getByRole('button', { name: '打开 RTL 示例 Sidebar' }).click();
    await expect(page.locator('.lotus-sidebar-container')).toHaveClass(/lotus-sidebar-container-visible/);
    await page.getByRole('button', { name: '进入 RTL 详情视图' }).click();
    await expect(page.locator('.lotus-sidebar-back svg')).toHaveCSS('transform', 'matrix(-1, 0, 0, 1, 0, 0)');

    await toggleBtn.click();
  });
});
