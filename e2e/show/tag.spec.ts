import { test, expect } from '@playwright/test';

test.describe('Tag', () => {
  test('light/solid/ghost 三种主题均正确渲染对应 class', async ({ page }) => {
    await page.goto('/');

    const lightTag = page.locator('.lotus-tag-light', { hasText: 'blue' }).first();
    const solidTag = page.locator('.lotus-tag-solid', { hasText: 'blue' }).first();
    const ghostTag = page.locator('.lotus-tag-ghost', { hasText: 'blue' }).first();

    await expect(lightTag).toBeVisible();
    await expect(solidTag).toBeVisible();
    await expect(ghostTag).toBeVisible();
  });

  test('small/default/large 三种尺寸均正确渲染', async ({ page }) => {
    await page.goto('/');

    await expect(page.locator('.lotus-tag-small', { hasText: 'small' })).toBeVisible();
    await expect(page.locator('.lotus-tag-default', { hasText: 'default' })).toBeVisible();
    await expect(page.locator('.lotus-tag-large', { hasText: 'large' })).toBeVisible();
  });

  test('closable 标签点击关闭按钮后从 DOM 中移除，onClose 携带 children/event/tagKey', async ({ page }) => {
    await page.goto('/');
    const closableTag = page.getByLabel('可关闭 Tag');
    await expect(closableTag).toBeVisible();

    await closableTag.locator('.lotus-tag-close').click();

    // 回归防护：Tag 的 visible 状态用派生 track 包装（吸取 Switch 踩坑 #7/#8 的教训），
    // 点击关闭必须让标签立即从 DOM 消失，而不是仅仅触发回调却视觉冻结。
    await expect(closableTag).not.toBeVisible();
    await expect(page.getByLabel('Tag 关闭日志')).toHaveText('关闭了 tagKey=closable-demo');
  });

  test('colorful：solid/light/ghost 均忽略 color 语义色，改用 AI 渐变色系', async ({ page }) => {
    await page.goto('/');

    const solidColorful = page.locator('.lotus-tag-colorful.lotus-tag-solid', { hasText: 'solid colorful' }).first();
    await expect(solidColorful).toBeVisible();
    await expect(solidColorful).not.toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');

    const lightColorful = page.locator('.lotus-tag-colorful.lotus-tag-light', { hasText: 'light colorful' }).first();
    await expect(lightColorful).toBeVisible();

    const ghostColorful = page.locator('.lotus-tag-colorful.lotus-tag-ghost', { hasText: 'ghost colorful' }).first();
    await expect(ghostColorful).toBeVisible();
  });

  test('colorful + gradient：三种 type 均改用渐变（solid 渐变背景，light/ghost 渐变文字裁切）', async ({ page }) => {
    await page.goto('/');

    const solidGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-solid').first();
    await expect(solidGradient).toHaveCSS('background-image', /gradient/);

    const lightGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-light').first();
    await expect(lightGradient).toHaveCSS('background-clip', 'text');

    const ghostGradient = page.locator('.lotus-tag-colorful-gradient.lotus-tag-ghost').first();
    await expect(ghostGradient).toHaveCSS('background-clip', 'text');
  });

  test('shape=circle 时圆角为胶囊形，shape=square（默认）保持方角', async ({ page }) => {
    await page.goto('/');
    const circleTag = page.locator('.lotus-tag', { hasText: 'circle shape' });
    const squareTag = page.locator('.lotus-tag', { hasText: 'square shape（默认）' });

    const circleRadius = await circleTag.evaluate((el) => getComputedStyle(el).borderRadius);
    const squareRadius = await squareTag.evaluate((el) => getComputedStyle(el).borderRadius);
    expect(circleRadius).not.toBe(squareRadius);
  });

  test('avatarSrc：内嵌头像正确渲染 img', async ({ page }) => {
    await page.goto('/');
    const tag = page.locator('.lotus-tag', { hasText: '带头像标签' });
    await expect(tag.locator('.lotus-tag-avatar img')).toBeVisible();
  });

  test('键盘操作：closable + onClick 时携带 role=button/tabIndex，Enter 触发 onClick，Backspace 触发关闭', async ({ page }) => {
    await page.goto('/');
    const tag = page.getByLabel('键盘可操作 Tag');
    await expect(tag).toHaveAttribute('role', 'button');
    await expect(tag).toHaveAttribute('tabindex', '0');

    await tag.focus();
    await page.keyboard.press('Enter');
    await expect(page.getByLabel('Tag 关闭日志')).toHaveText('点击了可交互 Tag');

    await page.keyboard.press('Backspace');
    await expect(tag).not.toBeVisible();
    await expect(page.getByLabel('Tag 关闭日志')).toHaveText('键盘/点击关闭按钮关闭了 Tag');
  });
});

test.describe('TagGroup', () => {
  test('maxTagCount：超出数量的标签聚合为 "+N"', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('TagGroup maxTagCount');
    const tags = group.locator('.lotus-tag');
    await expect(tags).toHaveCount(3);
    await expect(tags.nth(0)).toHaveText('标签一');
    await expect(tags.nth(1)).toHaveText('标签二');
    await expect(tags.nth(2)).toHaveText('+3');
  });

  test('showPopover：hover "+N" 标签展示被折叠的完整标签列表', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('TagGroup showPopover');
    const plusTag = group.locator('.lotus-tag', { hasText: '+2' });
    await plusTag.hover();

    const popoverList = page.locator('.lotus-tag-group-rest-list');
    await expect(popoverList).toBeVisible();
    await expect(popoverList).toContainText('标签二');
    await expect(popoverList).toContainText('标签三');
  });

  test('onTagClose：点击 Tag 关闭按钮触发 group 级回调，携带 tagKey', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('TagGroup onTagClose');
    await group.locator('.lotus-tag-close').first().click();
    await expect(page.getByLabel('TagGroup 关闭日志')).toHaveText('TagGroup 关闭了 tagKey=g1');
  });
});

test.describe('SplitTagGroup', () => {
  test('首尾 Tag 保留圆角、中间 Tag 零圆角，视觉连成一体（回归防护：跨组件选择器需要 :global() 包裹，否则整条规则被裁剪）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('SplitTagGroup 示例');
    const tags = group.locator('.lotus-tag');
    await expect(tags).toHaveCount(3);

    const firstRadius = await tags.nth(0).evaluate((el) => ({
      topLeft: getComputedStyle(el).borderTopLeftRadius,
      topRight: getComputedStyle(el).borderTopRightRadius,
    }));
    expect(firstRadius.topLeft).not.toBe('0px');
    expect(firstRadius.topRight).toBe('0px');

    const middleRadius = await tags.nth(1).evaluate((el) => getComputedStyle(el).borderTopLeftRadius);
    expect(middleRadius).toBe('0px');

    const lastRadius = await tags.nth(2).evaluate((el) => ({
      topLeft: getComputedStyle(el).borderTopLeftRadius,
      topRight: getComputedStyle(el).borderTopRightRadius,
    }));
    expect(lastRadius.topLeft).toBe('0px');
    expect(lastRadius.topRight).not.toBe('0px');
  });
});
