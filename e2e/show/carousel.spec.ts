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

  test('autoPlay 卸载时清理定时器，不留内存泄漏（回归防护：驱动 foundation.play 的 effect 此前没有返回清理函数，组件卸载后 setInterval 永不清理）', async ({ page }) => {
    // 只拦截调用栈里包含 carousel/foundation 的 setInterval/clearInterval——
    // 页面上还有 Vite HMR client（30s 心跳，页面级持久连接，不受任何组件
    // 卸载影响）和 Lottie demo（内部自己管理生命周期）各自的定时器，全局
    // 拦截会把这些无关定时器也算进"是否泄漏"的判断，产生假阳性。
    await page.addInitScript(() => {
      const created = new Set<number>();
      const cleared = new Set<number>();
      (window as any).__carouselIntervalCreated = created;
      (window as any).__carouselIntervalCleared = cleared;
      const originalSetInterval = window.setInterval;
      const originalClearInterval = window.clearInterval;
      const isFromCarouselFoundation = () => (new Error().stack ?? '').includes('carousel/foundation');
      window.setInterval = ((fn: TimerHandler, ms?: number, ...args: any[]) => {
        const handle = originalSetInterval(fn, ms, ...args);
        if (isFromCarouselFoundation()) created.add(handle as unknown as number);
        return handle;
      }) as typeof window.setInterval;
      window.clearInterval = ((handle?: number) => {
        if (handle !== undefined && created.has(handle)) cleared.add(handle);
        return originalClearInterval(handle);
      }) as typeof window.clearInterval;
    });

    await page.goto('/');
    const carousel = page.getByLabel('基础 Carousel');
    await carousel.scrollIntoViewIfNeeded();
    await expect(carousel).toBeVisible();

    const beforeUnmount = await page.evaluate(() => ({
      created: [...(window as any).__carouselIntervalCreated as Set<number>],
      cleared: [...(window as any).__carouselIntervalCleared as Set<number>],
    }));
    expect(beforeUnmount.created.length).toBeGreaterThan(0);
    expect(beforeUnmount.cleared.length).toBe(0);

    await page.getByRole('button', { name: '卸载 Carousel（验证 autoPlay 定时器清理）' }).click();
    await expect(carousel).not.toBeVisible();

    const afterUnmount = await page.evaluate(() => ({
      created: [...(window as any).__carouselIntervalCreated as Set<number>],
      cleared: [...(window as any).__carouselIntervalCleared as Set<number>],
    }));
    // 挂载期间创建的每一个 Carousel 定时器，卸载后都应该被清理。
    expect(afterUnmount.cleared).toEqual(afterUnmount.created);
  });
});
