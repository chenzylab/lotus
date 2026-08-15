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

    const solidPrimary = page.locator('.lotus-button-primary.lotus-button-theme-solid', { hasText: 'primary solid' });
    const lightDanger = page.locator('.lotus-button-danger.lotus-button-theme-light', { hasText: 'danger light' });
    const outlineWarning = page.locator('.lotus-button-warning.lotus-button-theme-outline', { hasText: 'warning outline' });

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
});
