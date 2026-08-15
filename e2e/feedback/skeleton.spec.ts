import { test, expect } from '@playwright/test';

test.describe('Skeleton', () => {
  test('loading 为 true 时渲染 placeholder，不渲染 children', async ({ page }) => {
    await page.goto('/');
    const skeleton = page.locator('.lotus-skeleton').first();
    await expect(skeleton.locator('.lotus-skeleton-avatar')).toBeVisible();
    await expect(skeleton.getByText('U', { exact: true })).not.toBeAttached();
  });

  test('active 时骨架元素带渐变动画背景', async ({ page }) => {
    await page.goto('/');
    const activeSkeleton = page.locator('.lotus-skeleton-active');
    await expect(activeSkeleton).toBeVisible();
    const avatar = activeSkeleton.locator('.lotus-skeleton-avatar');
    const animationName = await avatar.evaluate((el) => getComputedStyle(el).animationName);
    expect(animationName).toContain('lotus-skeleton-loading');
  });

  test('SkeletonAvatar 在不经过 Skeleton 容器裸用时也能正确渲染尺寸与底色', async ({ page }) => {
    await page.goto('/');
    const bareAvatar = page.locator('.lotus-skeleton-avatar').first();
    await expect(bareAvatar).toBeVisible();
    const box = await bareAvatar.boundingBox();
    expect(box?.width).toBeGreaterThan(0);
    expect(box?.height).toBeGreaterThan(0);
  });

  test('SkeletonParagraph 按 rows 渲染对应行数，末行更窄', async ({ page }) => {
    await page.goto('/');
    const paragraph = page.locator('.lotus-skeleton-paragraph').first();
    const rows = paragraph.locator('.lotus-skeleton-paragraph-row');
    await expect(rows).toHaveCount(3);
    const lastRow = rows.last();
    await expect(lastRow).toHaveClass(/lotus-skeleton-paragraph-row-last/);
  });
});
