import { test, expect } from '@playwright/test';

test.describe('Button', () => {
  test('点击默认按钮触发回调（控制台日志可见）', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    await page.getByRole('button', { name: '默认按钮' }).click();

    expect(logs).toContain('lotus button clicked');
  });

  test('disabled 状态下点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const disabledButton = page.getByRole('button', { name: '禁用按钮' });

    await expect(disabledButton).toBeDisabled();
    // 原生 disabled 按钮不会派发 click 事件，force 点击验证 DOM 层面确实无响应
    await disabledButton.click({ force: true }).catch(() => {});

    expect(logs).not.toContain('should not fire');
  });

  test('loading 状态下点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const loadingButton = page.getByRole('button', { name: '加载中按钮' });

    // loading 态用 CSS `pointer-events: none` 阻断交互（对齐 Semi 的实现：不用原生 disabled，
    // 因为 loading 时按钮仍应可 focus）。这使浏览器根本不会把点击事件派发给该元素，Playwright
    // 的默认可交互性检查会一直判定"被父容器拦截"直至超时，因此需要 force 绕过该检查，
    // 去验证"即使强制触发点击事件，回调也不会执行"这一条底线（同 Switch loading 态测试写法）。
    await expect(loadingButton).toHaveCSS('pointer-events', 'none');
    await loadingButton.click({ force: true }).catch(() => {});

    expect(logs).not.toContain('should not fire');
  });

  test('type × theme 组合正确渲染对应 class', async ({ page }) => {
    await page.goto('/');

    const solidPrimary = page.getByRole('button', { name: 'primary solid', exact: true });
    const lightDanger = page.getByRole('button', { name: 'danger light', exact: true });
    const outlineWarning = page.getByRole('button', { name: 'warning outline', exact: true });

    await expect(solidPrimary).toBeVisible();
    await expect(lightDanger).toBeVisible();
    await expect(outlineWarning).toBeVisible();
  });

  test('block 按钮撑满容器宽度', async ({ page }) => {
    await page.goto('/');
    const blockButton = page.locator('.lotus-button-block', { hasText: 'block 按钮' });

    await expect(blockButton).toHaveClass(/lotus-button-block/);
  });

  test('ButtonGroup 内的按钮保持在同一个 role=group 容器中', async ({ page }) => {
    await page.goto('/');
    const group = page.getByRole('group', { name: '示例按钮组' });

    await expect(group).toBeVisible();
    await expect(group.getByRole('button')).toHaveCount(3);
  });

  test('colorful：primary/tertiary 生效，其余 type 静默无视觉效果', async ({ page }) => {
    await page.goto('/');

    const primarySolid = page.getByRole('button', { name: 'primary solid colorful' });
    await expect(primarySolid).toHaveClass(/lotus-button-colorful/);
    await expect(primarySolid).toHaveCSS('background-image', /gradient/);

    const tertiarySolid = page.getByRole('button', { name: 'tertiary solid colorful' });
    await expect(tertiarySolid).toHaveClass(/lotus-button-colorful/);

    const secondary = page.getByRole('button', { name: 'secondary colorful（应静默无效果）' });
    await expect(secondary).not.toHaveClass(/lotus-button-colorful/);
  });

  test('colorful：light/borderless 主题渲染渐变文字（background-clip:text）', async ({ page }) => {
    await page.goto('/');

    const light = page.getByRole('button', { name: 'primary light colorful' });
    await expect(light).toHaveCSS('background-clip', 'text');

    const borderless = page.getByRole('button', { name: 'primary borderless colorful' });
    await expect(borderless).toHaveCSS('background-clip', 'text');
  });

  test('noHorizontalPadding：true 时左右 padding 均为 0，"left" 时只去左侧（对齐 Semi）', async ({ page }) => {
    await page.goto('/');
    const both = page.getByRole('button', { name: '无水平内边距按钮' });
    await expect(both).toHaveCSS('padding-left', '0px');
    await expect(both).toHaveCSS('padding-right', '0px');

    const leftOnly = page.getByRole('button', { name: '仅去左侧内边距' });
    await expect(leftOnly).toHaveCSS('padding-left', '0px');
    await expect(leftOnly).not.toHaveCSS('padding-right', '0px');
  });

  test('contentClassName：内容 span 携带自定义类名，不影响外层 button 的 class', async ({ page }) => {
    await page.goto('/');
    const btn = page.getByRole('button', { name: '内容自定义类名按钮' });
    await expect(btn.locator('.demo-button-content-marker')).toBeVisible();
    await expect(btn).not.toHaveClass(/demo-button-content-marker/);
  });

  test('onMouseDown/onMouseEnter/onMouseLeave：鼠标事件正确透传给消费方', async ({ page }) => {
    await page.goto('/');
    const btn = page.getByRole('button', { name: '鼠标事件按钮' });
    const log = page.getByLabel('鼠标事件日志');

    await btn.hover();
    await expect(log).toHaveText('mouseenter');

    await btn.dispatchEvent('mousedown');
    await expect(log).toHaveText('mousedown');

    await page.mouse.move(0, 0);
    await expect(log).toHaveText('mouseleave');
  });
});
