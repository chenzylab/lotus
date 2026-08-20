import { test, expect } from '@playwright/test';

test.describe('UserGuide', () => {
  test('popup 模式：点击开始按钮后渲染第一步的高亮框与卡片', async ({ page }) => {
    await page.goto('/');
    const dialog = page.getByLabel('popup UserGuide');
    await expect(dialog).toBeHidden();

    await page.getByRole('button', { name: '开始引导' }).click();
    await expect(dialog).toBeVisible();
    await expect(dialog).toContainText('第一步');
    await expect(dialog.locator('.lotus-user-guide-arrow')).toHaveCount(1);
    await expect(dialog.getByRole('button', { name: '跳过' })).toBeVisible();
    await expect(dialog.getByRole('button', { name: '下一步' })).toBeVisible();
    // 首步不显示"上一步"
    await expect(dialog.getByRole('button', { name: '上一步' })).toHaveCount(0);
  });

  test('连续点击下一步：能正确推进到第三步（回归防护：受控 state 未同步导致第二次推进卡住，踩坑 #73）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');

    await expect(dialog).toContainText('第一步');
    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toContainText('第二步');

    // 关键回归点：第二次点击"下一步"必须能从第二步推进到第三步，
    // 而不是卡在第二步（受控 state 未跟随外部 prop 同步会导致这里失败）。
    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toContainText('第三步');
    // 最后一步不显示"跳过"，按钮文案变为"完成"
    await expect(dialog.getByRole('button', { name: '跳过' })).toHaveCount(0);
    await expect(dialog.getByRole('button', { name: '完成' })).toBeVisible();
  });

  test('上一步：从第二步回退到第一步，事件日志记录 onPrev', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');
    const log = page.getByLabel('UserGuide 事件日志');

    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toContainText('第二步');

    await dialog.getByRole('button', { name: '上一步' }).click();
    await expect(dialog).toContainText('第一步');
    await expect(log).toContainText('onPrev -> 0');
  });

  test('点击完成：触发 onFinish，组件自动关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');
    const log = page.getByLabel('UserGuide 事件日志');

    await dialog.getByRole('button', { name: '下一步' }).click();
    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toContainText('第三步');

    await dialog.getByRole('button', { name: '完成' }).click();
    await expect(dialog).toBeHidden();
    await expect(log).toContainText('onFinish');
  });

  test('点击跳过：触发 onSkip，组件自动关闭，不改变 current', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');
    const log = page.getByLabel('UserGuide 事件日志');

    await dialog.getByRole('button', { name: '跳过' }).click();
    await expect(dialog).toBeHidden();
    await expect(log).toContainText('onSkip');
  });

  test('键盘 ArrowRight/ArrowLeft 切换步骤，Escape 触发跳过关闭', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');

    await expect(dialog).toContainText('第一步');
    await page.keyboard.press('ArrowRight');
    await expect(dialog).toContainText('第二步');
    await page.keyboard.press('ArrowLeft');
    await expect(dialog).toContainText('第一步');

    await page.keyboard.press('Escape');
    await expect(dialog).toBeHidden();
  });

  test('spotlightPadding=0 时高亮框与目标元素边界重合（对齐 Semi 修正 || 吞掉 0 的 bug）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');
    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toContainText('第二步');

    const target = page.getByRole('button', { name: '步骤二目标' });
    const targetBox = (await target.boundingBox())!;

    const spotlight = page.locator('.lotus-user-guide-spotlight rect[fill="black"]');
    const width = await spotlight.getAttribute('width');
    const height = await spotlight.getAttribute('height');
    // padding=0 时镂空矩形宽高应精确等于目标元素尺寸（无扩展）
    expect(Number(width)).toBeCloseTo(targetBox.width, 0);
    expect(Number(height)).toBeCloseTo(targetBox.height, 0);
  });

  test('theme=primary 覆盖第三步卡片主题', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '开始引导' }).click();
    const dialog = page.getByLabel('popup UserGuide');
    await dialog.getByRole('button', { name: '下一步' }).click();
    await dialog.getByRole('button', { name: '下一步' }).click();
    await expect(dialog).toHaveClass(/lotus-user-guide-card-theme-primary/);
  });

  test('modal 模式：居中弹窗轮播，圆点指示器随步骤同步', async ({ page }) => {
    await page.goto('/');
    const modal = page.getByLabel('modal UserGuide');
    await expect(modal).toBeHidden();

    await page.getByRole('button', { name: '打开 modal 引导' }).click();
    await expect(modal).toBeVisible();
    await expect(modal).toContainText('欢迎使用 lotus');

    const dots = modal.locator('.lotus-user-guide-modal-dot');
    await expect(dots).toHaveCount(3);
    await expect(dots.nth(0)).toHaveClass(/lotus-user-guide-modal-dot-active/);

    await modal.getByRole('button', { name: '下一步' }).click();
    await expect(modal).toContainText('功能强大');
    await expect(dots.nth(1)).toHaveClass(/lotus-user-guide-modal-dot-active/);
  });

  test('modal 模式：点击遮罩不关闭（maskClosable 硬编码 false，对齐 Semi）', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开 modal 引导' }).click();
    const modal = page.getByLabel('modal UserGuide');
    await expect(modal).toBeVisible();

    await page.locator('.lotus-modal-wrapper').click({ position: { x: 5, y: 5 } });
    await expect(modal).toBeVisible();
  });

  test('modal 模式：点击完成关闭弹窗', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('button', { name: '打开 modal 引导' }).click();
    const modal = page.getByLabel('modal UserGuide');

    await modal.getByRole('button', { name: '下一步' }).click();
    await modal.getByRole('button', { name: '下一步' }).click();
    await expect(modal).toContainText('开始使用');
    await modal.getByRole('button', { name: '完成' }).click();
    await expect(modal).toBeHidden();
  });
});
