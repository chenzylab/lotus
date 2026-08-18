import { test, expect } from '@playwright/test';

test.describe('Card', () => {
  test('title 为字符串时渲染为 Typography 标题', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('基础 Card');
    await expect(card.locator('.lotus-card-header-main h6')).toHaveText('基础卡片');
  });

  test('headerExtraContent 出现在标题右侧', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('带 headerExtraContent 的 Card');
    await expect(card.locator('.lotus-card-header-extra')).toBeVisible();
    await expect(card.locator('.lotus-card-header-extra')).toContainText('更多');
  });

  test('bordered=false 时不带边框 class，shadows=hover 时 hover 触发阴影', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('无边框 hover 阴影 Card');
    await expect(card).not.toHaveClass(/lotus-card-bordered/);
    await expect(card).toHaveClass(/lotus-card-shadows-hover/);

    const before = await card.evaluate((el) => getComputedStyle(el).boxShadow);
    expect(before).toBe('none');

    await card.hover();
    await expect(async () => {
      const shadow = await card.evaluate((el) => getComputedStyle(el).boxShadow);
      expect(shadow).not.toBe('none');
    }).toPass({ timeout: 1000 });
  });

  test('cover 渲染在标题和内容区之间', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('带 cover 的 Card');
    await expect(card.locator('.lotus-card-cover')).toBeVisible();
  });

  test('actions 数组渲染为底部操作区', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('带 actions 的 Card');
    const actions = card.locator('.lotus-card-actions');
    await expect(actions).toContainText('编辑');
    await expect(actions).toContainText('删除');
  });

  test('footerLine 控制页脚分割线', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('带 footer 的 Card');
    await expect(card.locator('.lotus-card-footer')).toHaveClass(/lotus-card-footer-line/);
    await expect(card.locator('.lotus-card-footer')).toContainText('页脚内容');
  });

  test('loading 时内容区显示骨架屏，children 不可见，aria-busy 为 true', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('loading 中的 Card');
    await expect(card).toHaveAttribute('aria-busy', 'true');
    await expect(card.locator('.lotus-skeleton')).toBeVisible();
    await expect(card.locator('.lotus-card-body')).not.toContainText('这段内容在 loading 时不会显示');
  });

  test('Card.Meta 组合 avatar/title/description', async ({ page }) => {
    await page.goto('/');
    const card = page.getByLabel('带 Card.Meta 的 Card');
    const meta = card.locator('.lotus-card-meta');
    await expect(meta.locator('.lotus-card-meta-title')).toHaveText('语雀');
    await expect(meta.locator('.lotus-card-meta-description')).toHaveText('蚂蚁集团出品的专业云端知识库');
    await expect(meta.locator('.lotus-card-meta-avatar')).toBeVisible();
  });

  test('CardGroup 包裹多个 Card 且间距生效', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('CardGroup 示例');
    await expect(group.locator('.lotus-card')).toHaveCount(3);
    const gap = await group.evaluate((el) => getComputedStyle(el).gap);
    expect(gap).toContain('16px');
  });
});
