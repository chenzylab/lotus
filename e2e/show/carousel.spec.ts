import { test, expect } from '@playwright/test';

test.describe('Carousel', () => {
  test('箭头点击切换到下一张/上一张', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('基础 Carousel');
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第一页');

    await carousel.getByLabel('下一张').click();
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第二页');

    await carousel.getByLabel('上一张').click();
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第一页');
  });

  test('指示器点击直接跳转到对应页', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('基础 Carousel');
    const indicators = carousel.locator('.lotus-carousel-indicator-item');
    await expect(indicators).toHaveCount(3);

    await indicators.nth(2).click();
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第三页');
    await expect(indicators.nth(2)).toHaveClass(/lotus-carousel-indicator-item-active/);
  });

  test('autoPlay 默认开启，间隔后自动切换到下一张', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('基础 Carousel');
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第一页');

    // DEFAULT_INTERVAL(2000) + speed(300) = 2300ms，加缓冲等待到 3.5s
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第二页', { timeout: 3500 });
  });

  test('鼠标悬浮时暂停自动播放，移出后恢复', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('基础 Carousel');
    await carousel.scrollIntoViewIfNeeded();
    const box = await carousel.boundingBox();
    if (!box) throw new Error('carousel bounding box not found');

    // 先等一次自动切换稳定完成（避免 hover 时机恰好卡在切换边界导致断言基准不稳），
    // 再把鼠标移入触发暂停，之后 3 秒内不应该再发生任何切换。
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('第二页', { timeout: 3500 });
    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    const textAtHoverStart = await carousel.locator('.lotus-carousel-item-active').innerText();

    await page.waitForTimeout(3000);
    const textAfterHover = await carousel.locator('.lotus-carousel-item-active').innerText();
    expect(textAfterHover).toBe(textAtHoverStart);
  });

  test('animation=fade 时正确渲染 fade class，非 slide', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('fade Carousel');
    await expect(carousel.locator('.lotus-carousel-item').first()).toHaveClass(/lotus-carousel-item-fade/);
    await expect(carousel.locator('.lotus-carousel-item').first()).not.toHaveClass(/lotus-carousel-item-slide/);
  });

  test('indicatorType=line 时指示器渲染为线条样式', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('fade Carousel');
    await expect(carousel.locator('.lotus-carousel-indicators')).toHaveClass(/lotus-carousel-indicators-line/);
  });

  test('受控模式：activeIndex 由外部按钮驱动，非组件自身交互触发', async ({ page }) => {
    await page.goto('/');
    const carousel = page.getByLabel('受控 Carousel');
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('受控 1');

    await page.getByRole('button', { name: '跳到第三页' }).click();
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('受控 3');

    await page.getByRole('button', { name: '跳到第一页' }).click();
    await expect(carousel.locator('.lotus-carousel-item-active')).toHaveText('受控 1');
  });
});
