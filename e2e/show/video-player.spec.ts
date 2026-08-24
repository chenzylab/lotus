import { test, expect, type Page } from '@playwright/test';

/**
 * 与 AudioPlayer 的 e2e 测试同一套环境限制（`e2e/show/audio-player.spec.ts`
 * 排查记录）：CI/沙箱环境的 headless Chromium 对合成媒体文件的解码支持
 * 不稳定，`currentTime` 在无真实媒体流的元素上赋值会被浏览器静默钳制且
 * 仍会触发 timeupdate/timeupdate 类事件覆盖乐观状态，因此这里同样对
 * `duration`/`volume`/`playbackRate`/`currentTime` 整体打桩，测的是组件
 * 对媒体事件的响应逻辑，不依赖真实视频解码能力。
 */
async function primeVideoState(page: Page, selector: string, duration: number) {
  await page.locator(selector).evaluate((el: HTMLVideoElement, dur: number) => {
    let currentTimeValue = 0;
    Object.defineProperty(el, 'duration', { value: dur, configurable: true });
    Object.defineProperty(el, 'playbackRate', { value: 1, configurable: true, writable: true });
    Object.defineProperty(el, 'currentTime', {
      configurable: true,
      get: () => currentTimeValue,
      set: (v: number) => {
        currentTimeValue = v;
        el.dispatchEvent(new Event('timeupdate'));
      },
    });
    el.dispatchEvent(new Event('durationchange'));
  }, duration);
}

test.describe('VideoPlayer', () => {
  test('基础用法：初始未播放时显示中央播放按钮', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await expect(player).toBeVisible();
    await expect(player.locator('.lotus-video-player-center-play')).toBeVisible();
    await expect(player.locator('[aria-label="播放"]').first()).toBeVisible();
  });

  test('模拟 play 事件后中央播放按钮消失，工具栏按钮切换为暂停', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await player.locator('video').evaluate((el: HTMLVideoElement) => el.dispatchEvent(new Event('play')));
    await expect(player.locator('.lotus-video-player-center-play')).toHaveCount(0);
    await expect(player.locator('.lotus-video-player-toolbar [aria-label="暂停"]')).toBeVisible();
  });

  test('模拟 pause 事件后恢复为播放态', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    const video = player.locator('video');
    await video.evaluate((el: HTMLVideoElement) => el.dispatchEvent(new Event('play')));
    await expect(player.locator('.lotus-video-player-toolbar [aria-label="暂停"]')).toBeVisible();
    await video.evaluate((el: HTMLVideoElement) => el.dispatchEvent(new Event('pause')));
    await expect(player.locator('.lotus-video-player-toolbar [aria-label="播放"]')).toBeVisible();
    await expect(player.locator('.lotus-video-player-center-play')).toBeVisible();
  });

  test('模拟 durationchange 后正确显示格式化的总时长', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await primeVideoState(page, '.demo-video-player video', 100);
    await expect(player.locator('.lotus-video-player-time')).toHaveText('0:00 / 1:40');
  });

  test('点击进度条跳转到对应百分比位置', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await primeVideoState(page, '.demo-video-player video', 100);

    const slider = player.locator('.lotus-video-player-progress .lotus-audio-slider');
    const box = await slider.boundingBox();
    if (!box) throw new Error('slider bounding box not found');
    await slider.click({ position: { x: box.width / 2, y: box.height / 2 } });

    await expect(player.locator('.lotus-video-player-time')).toHaveText('0:50 / 1:40');
  });

  test('点击静音按钮切换 aria-label，取消静音恢复', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await player.locator('[aria-label="静音"]').click();
    await expect(player.locator('[aria-label="取消静音"]')).toBeVisible();
    await player.locator('[aria-label="取消静音"]').click();
    await expect(player.locator('[aria-label="静音"]')).toBeVisible();
  });

  test('点击倍速按钮弹出降序菜单（含 1.25x，与 AudioPlayer 档位不同），选择后按钮文案更新且菜单关闭', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    await player.locator('[aria-label="播放速度"]').click();
    const menu = player.locator('.lotus-video-player-rate-menu');
    await expect(menu).toBeVisible();
    const items = menu.locator('.lotus-video-player-rate-item');
    await expect(items).toHaveCount(5);
    await expect(items.nth(0)).toHaveText('2.0x');
    await expect(items.nth(2)).toHaveText('1.25x');
    await expect(items.nth(4)).toHaveText('0.75x');

    await items.filter({ hasText: '1.25x' }).click();
    await expect(player.locator('[aria-label="播放速度"]')).toHaveText('1.25x');
    await expect(menu).toHaveCount(0);

    const rate = await player.locator('video').evaluate((el: HTMLVideoElement) => el.playbackRate);
    expect(rate).toBe(1.25);
  });

  test('点击全屏按钮不抛出异常（真实全屏受用户手势/环境限制，验证不崩溃）', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    const errors: string[] = [];
    page.on('pageerror', (err) => errors.push(err.message));
    await player.locator('[aria-label="全屏"]').click();
    await page.waitForTimeout(100);
    expect(errors).toEqual([]);
  });

  test('拖拽音量滑块调整真实 video 元素的 volume', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-video-player');
    const volumeSlider = player.locator('.lotus-video-player-volume .lotus-audio-slider');
    const box = await volumeSlider.boundingBox();
    if (!box) throw new Error('volume slider bounding box not found');
    await volumeSlider.click({ position: { x: box.width * 0.2, y: box.height / 2 } });

    const volume = await player.locator('video').evaluate((el: HTMLVideoElement) => el.volume);
    expect(volume).toBeLessThan(0.3);
  });
});
