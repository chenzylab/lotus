import { test, expect } from '@playwright/test';

test.describe('Switch', () => {
  test('点击后视觉状态（aria-checked）与实际状态同步切换', async ({ page }) => {
    await page.goto('/');
    const uncontrolledSwitch = page.getByRole('switch').first();

    await expect(uncontrolledSwitch).toHaveAttribute('aria-checked', 'true');
    await uncontrolledSwitch.click();
    // 回归防护：曾经出现过 Foundation 逻辑正确执行（onChange 触发）但视觉不切换的问题
    // （classes 用普通 const 而非派生 track 导致），详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #7 的 Switch 案例。
    await expect(uncontrolledSwitch).toHaveAttribute('aria-checked', 'false');
    await uncontrolledSwitch.click();
    await expect(uncontrolledSwitch).toHaveAttribute('aria-checked', 'true');
  });

  test('disabled 状态下点击不改变状态', async ({ page }) => {
    await page.goto('/');
    const switches = page.getByRole('switch');
    const disabledSwitch = switches.nth(1);

    await expect(disabledSwitch).toBeDisabled();
    await expect(disabledSwitch).toHaveAttribute('aria-checked', 'false');
    await disabledSwitch.click({ force: true }).catch(() => {});
    await expect(disabledSwitch).toHaveAttribute('aria-checked', 'false');
  });

  test('loading 状态下点击不改变状态', async ({ page }) => {
    await page.goto('/');
    const switches = page.getByRole('switch');
    const loadingSwitch = switches.nth(2);

    // loading 态复用原生 disabled 属性（与 disabled 态视觉/交互一致），
    // 原生 disabled 按钮 Playwright 默认判定为不可点击，需要 force 绕过这层保护
    // 去验证"即使强制触发点击事件，状态也不会改变"这一条底线。
    await expect(loadingSwitch).toBeDisabled();
    await expect(loadingSwitch).toHaveAttribute('aria-checked', 'true');
    await loadingSwitch.click({ force: true }).catch(() => {});
    await expect(loadingSwitch).toHaveAttribute('aria-checked', 'true');
  });
});
