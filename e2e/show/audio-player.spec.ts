import { test, expect, type Page } from '@playwright/test';

/**
 * CI/沙箱环境的 headless Chromium 对合成音频文件的媒体解码支持不稳定
 * （本地真机验证时也曾遇到 ego-browser 环境完全无法加载任何音频源，包括
 * 外部知名测试音频 URL——用裸 `<audio>` 元素单独测试同样卡在
 * readyState=0，与 lotus 组件代码无关，是环境限制）。因此这里不依赖
 * `loadedmetadata`/`ended` 真实触发，而是用 dispatchEvent 手动模拟这些
 * 媒体事件来驱动 Foundation 状态机，验证的是"组件对媒体事件的响应逻辑"
 * 而非"浏览器音频解码能力"，两者是正交的关注点。
 *
 * `currentTime` 也一并打补丁成真正可写属性：排查发现，在一个 loadedmetadata
 * 已伪造但 readyState 实际仍是 1（HAVE_METADATA，没有真实媒体数据可寻址）
 * 的 audio 元素上做 `el.currentTime = 50` 赋值，浏览器会静默把它钳制到别的
 * 内部值（读回来变成极小的数字），赋值动作本身又会派发一次 timeupdate 事件，
 * 组件的 onTimeUpdate 处理器读到这个被钳制的"真实"值后会覆盖掉 Foundation
 * 刚计算出的乐观更新值——这是标准的"乐观 UI 更新 + 媒体元素校正"架构在真实
 * 浏览器里完全正常（currentTime 赋值会真正生效，两次值一致感知不到覆盖），
 * 只有在这种伪造 metadata 但无真实媒体流的测试环境边界情况下才会暴露出来，
 * 不是组件的设计缺陷。打补丁让 currentTime 变成普通可读写属性，测的是组件
 * 逻辑本身，不需要靠浏览器真实媒体解码能力自证。
 */
async function simulateLoadedMetadata(page: Page, selector: string, duration: number) {
  await page.locator(selector).evaluate((el: HTMLAudioElement, dur: number) => {
    let currentTimeValue = 0;
    Object.defineProperty(el, 'duration', { value: dur, configurable: true });
    Object.defineProperty(el, 'volume', { value: 1, configurable: true });
    Object.defineProperty(el, 'playbackRate', { value: 1, configurable: true, writable: true });
    Object.defineProperty(el, 'currentTime', {
      configurable: true,
      get: () => currentTimeValue,
      set: (v: number) => {
        currentTimeValue = v;
        el.dispatchEvent(new Event('timeupdate'));
      },
    });
    el.dispatchEvent(new Event('loadedmetadata'));
  }, duration);
}

test.describe('AudioPlayer', () => {
  test('基础用法：单曲不显示上一曲/下一曲按钮', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await expect(player).toBeVisible();
    await expect(player.locator('[aria-label="上一曲"]')).toHaveCount(0);
    await expect(player.locator('[aria-label="下一曲"]')).toHaveCount(0);
    await expect(player.locator('[aria-label="播放"]')).toBeVisible();
  });

  test('多曲播放列表显示上一曲/下一曲按钮，且带曲目标题', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-playlist');
    await expect(player.locator('[aria-label="上一曲"]')).toBeVisible();
    await expect(player.locator('[aria-label="下一曲"]')).toBeVisible();
    await expect(player.locator('.lotus-audio-player-title')).toHaveText('演示曲目一');
  });

  test('点击播放按钮切换为暂停图标（aria-label 同步变化）', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    const playBtn = player.locator('[aria-label="播放"]');
    await playBtn.click();
    await expect(player.locator('[aria-label="暂停"]')).toBeVisible();
    await player.locator('[aria-label="暂停"]').click();
    await expect(player.locator('[aria-label="播放"]')).toBeVisible();
  });

  test('模拟 loadedmetadata 后正确显示格式化的总时长（mm:ss）', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await simulateLoadedMetadata(page, '.demo-audio-player-single audio', 125);
    const times = player.locator('.lotus-audio-player-time');
    await expect(times.nth(1)).toHaveText('2:05');
  });

  test('点击进度条跳转到对应百分比位置', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await simulateLoadedMetadata(page, '.demo-audio-player-single audio', 100);

    // playground demo 页面很长，AudioPlayer 区块在视口外——boundingBox() 返回
    // 的是文档坐标，page.mouse.move/down/up 用的却是视口坐标，不先滚动到可见
    // 区域会导致鼠标事件落在页面完全无关的位置（本例排查时曾测得 y 坐标是
    // 39000+ 的离谱值），必须先 scrollIntoViewIfNeeded() 再取 boundingBox。
    // click({position}) 让 Playwright 自己负责滚动可见 + 等待稳定 + 精确落点，
    // 比手动拆成 scrollIntoViewIfNeeded + boundingBox + mouse.move/down/up 三步
    // 更不容易在步骤之间插入时序竞态（后者在全量并行跑时曾偶发把 50% 位置点成
    // 2% 位置，单独跑该测试文件时complet不复现，是资源竞争下的时序敏感点）。
    const slider = player.locator('.lotus-audio-player-progress .lotus-audio-slider');
    const box = await slider.boundingBox();
    if (!box) throw new Error('slider bounding box not found');
    await slider.click({ position: { x: box.width / 2, y: box.height / 2 } });

    await expect(player.locator('.lotus-audio-player-time').first()).toHaveText('0:50');
  });

  test('点击倍速按钮弹出菜单，选择后按钮文案更新且菜单关闭', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await player.locator('[aria-label="播放速度"]').click();
    const menu = player.locator('.lotus-audio-player-rate-menu');
    await expect(menu).toBeVisible();
    await expect(menu.locator('.lotus-audio-player-rate-item')).toHaveCount(5);

    await menu.locator('.lotus-audio-player-rate-item', { hasText: '2.0x' }).click();
    await expect(player.locator('[aria-label="播放速度"]')).toHaveText('2.0x');
    await expect(menu).toHaveCount(0);
  });

  test('点击音量按钮弹出音量滑块面板', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await player.locator('[aria-label="音量"]').click();
    await expect(page.locator('.lotus-audio-player-volume-popover')).toBeVisible();
  });

  test('拖拽音量滑块调整真实 audio 元素的 volume', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await player.locator('[aria-label="音量"]').click();
    const volumeSlider = page.locator('.lotus-audio-player-volume-popover .lotus-audio-slider');
    const box = await volumeSlider.boundingBox();
    if (!box) throw new Error('volume slider bounding box not found');

    // 垂直滑块：点击顶部代表满音量，点击底部代表 0。click({position}) 比手动
    // mouse.move/down/up 更不容易在并行全量跑时踩中时序竞态（见上一个测试的
    // 注释说明）。
    await volumeSlider.click({ position: { x: box.width / 2, y: box.height * 0.1 } });

    const volume = await player.locator('audio').evaluate((el: HTMLAudioElement) => el.volume);
    expect(volume).toBeGreaterThan(0.8);
  });

  test('多曲切换：点击下一曲更新曲目标题与 audio.src，取模循环回到首曲', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-playlist');
    const nextBtn = player.locator('[aria-label="下一曲"]');

    await expect(player.locator('.lotus-audio-player-title')).toHaveText('演示曲目一');
    await nextBtn.click();
    await expect(player.locator('.lotus-audio-player-title')).toHaveText('演示曲目二');
    const src = await player.locator('audio').evaluate((el: HTMLAudioElement) => el.src);
    expect(src).toContain('demo-track-2.mp3');

    await nextBtn.click();
    await expect(player.locator('.lotus-audio-player-title')).toHaveText('演示曲目一');
  });

  test('点击重播按钮：非出错态时进度归零', async ({ page }) => {
    await page.goto('/');
    const player = page.locator('.demo-audio-player-single');
    await simulateLoadedMetadata(page, '.demo-audio-player-single audio', 100);
    const slider = player.locator('.lotus-audio-player-progress .lotus-audio-slider');
    const box = await slider.boundingBox();
    if (!box) throw new Error('slider bounding box not found');
    await slider.click({ position: { x: box.width / 2, y: box.height / 2 } });
    await expect(player.locator('.lotus-audio-player-time').first()).toHaveText('0:50');

    await player.locator('[aria-label="重播"]').click();
    await expect(player.locator('.lotus-audio-player-time').first()).toHaveText('0:00');
  });
});
