import { test, expect } from '@playwright/test';

test.describe('Radio', () => {
  test('非受控点击后选中，同名单选组语义正确', async ({ page }) => {
    await page.goto('/');
    const radio = page.getByLabel('Radio 示例', { exact: true });
    const clickTarget = radio.locator('xpath=..');

    await expect(radio).not.toBeChecked();
    await clickTarget.click();
    await expect(radio).toBeChecked();
  });

  test('disabled 状态下点击不改变选中态', async ({ page }) => {
    await page.goto('/');
    const disabledUnchecked = page.getByLabel('Radio 禁用未选中示例', { exact: true });
    const clickTarget = disabledUnchecked.locator('xpath=..');

    await expect(disabledUnchecked).toBeDisabled();
    await expect(disabledUnchecked).not.toBeChecked();
    await clickTarget.click({ force: true }).catch(() => {});
    await expect(disabledUnchecked).not.toBeChecked();
  });

  test('受控组件：外部按钮驱动 checked 变化时视觉同步更新（非本组件自身交互触发）', async ({ page }) => {
    // 回归防护：组件 props 若用普通 {} 解构而非 &{} 懒解构，外部独立触发源驱动的
    // 受控 prop 变化不会传导到组件视觉，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #30。
    await page.goto('/');
    const controlled = page.getByLabel('Radio 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Radio' });

    await expect(controlled).not.toBeChecked();
    await toggleButton.click();
    await expect(controlled).toBeChecked();
  });

  test('RadioGroup 数组方式：点击后单选切换，disabled 项不可选', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('RadioGroup 数组方式示例', { exact: true });
    const radioA = group.getByRole('radio').nth(0);
    const radioB = group.getByRole('radio').nth(1);
    const radioC = group.getByRole('radio').nth(2);

    await expect(radioA).toBeChecked();
    await expect(radioB).not.toBeChecked();
    await expect(radioC).toBeDisabled();

    await radioB.locator('xpath=..').click();
    await expect(radioA).not.toBeChecked();
    await expect(radioB).toBeChecked();
  });

  test('RadioGroup JSX 方式（受控）：点击后触发 onChange 且视觉同步更新', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('RadioGroup JSX 方式示例', { exact: true });
    const radioA = group.getByRole('radio').nth(0);
    const radioB = group.getByRole('radio').nth(1);
    const radioC = group.getByRole('radio').nth(2);

    await expect(radioA).toBeChecked();
    await expect(radioB).not.toBeChecked();
    await expect(radioC).not.toBeChecked();

    await radioC.locator('xpath=..').click();
    await expect(radioA).not.toBeChecked();
    await expect(radioC).toBeChecked();

    await radioB.locator('xpath=..').click();
    await expect(radioC).not.toBeChecked();
    await expect(radioB).toBeChecked();
  });
});
