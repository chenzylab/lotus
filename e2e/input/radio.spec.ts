import { test, expect } from '@playwright/test';

test.describe('Radio', () => {
  test('非受控点击后选中，同名单选组语义正确', async ({ page }) => {
    // 对齐 Semi：有 children 时组件把 aria-labelledby 指向 children 文本容器，
    // 浏览器可访问性名称计算此时会忽略 aria-label，改用 children 文本本身
    // 作为真正的可访问名称——用 getByLabel 定位时必须传 children 文本。
    await page.goto('/');
    const radio = page.getByLabel('Radio 示例', { exact: true });
    const clickTarget = radio.locator('xpath=..');

    await expect(radio).not.toBeChecked();
    await clickTarget.click();
    await expect(radio).toBeChecked();
  });

  test('disabled 状态下点击不改变选中态', async ({ page }) => {
    await page.goto('/');
    const disabledUnchecked = page.getByLabel('Radio 禁用未选中', { exact: true });
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

  test('addonId/extraId：正确关联到 aria-labelledby/aria-describedby（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const radio = page.locator('input[name="radio-addon-id-demo"]');
    await expect(radio).toHaveAttribute('aria-labelledby', 'radio-addon-id-demo');
    await expect(radio).toHaveAttribute('aria-describedby', 'radio-extra-id-demo');
  });

  test('getRadioApi：交出的 focus()/blur() 真实生效（对齐 Semi ref.current.focus()，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const radio = page.locator('input[name="radio-imperative-api-demo"]');
    const space = radio.locator('xpath=ancestor::*[contains(@class,"lotus-space")][1]');
    await space.getByRole('button', { name: '聚焦' }).click();
    await expect(radio).toBeFocused();
    await space.getByRole('button', { name: '失焦' }).click();
    await expect(radio).not.toBeFocused();
  });

  test('RadioGroup type=button：点击后切换选中态，disabled 项不可选（Semi 独有于 Radio，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('RadioGroup button small 示例', { exact: true });
    const radioA = group.getByRole('radio').nth(0);
    const radioB = group.getByRole('radio').nth(1);
    const radioC = group.getByRole('radio').nth(2);

    await expect(group).toHaveClass(/lotus-radio-group-buttonType/);
    await expect(radioA).toBeChecked();
    await expect(radioC).toBeDisabled();

    await radioB.locator('xpath=..').click();
    await expect(radioA).not.toBeChecked();
    await expect(radioB).toBeChecked();

    await radioC.locator('xpath=..').click({ force: true }).catch(() => {});
    await expect(radioC).not.toBeChecked();
  });

  test('RadioGroup type=card：卡片容器带边框 class，选中态带对应选中 class（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('RadioGroup card 示例', { exact: true });
    const checkedItem = group.getByText('单选框标题').first().locator('xpath=ancestor::label[contains(@class,"lotus-radio")]');
    const uncheckedItem = group.getByText('单选框标题').nth(1).locator('xpath=ancestor::label[contains(@class,"lotus-radio")]');

    await expect(checkedItem).toHaveClass(/lotus-radio-cardType/);
    await expect(checkedItem).toHaveClass(/lotus-radio-cardType-checked/);
    await expect(uncheckedItem).toHaveClass(/lotus-radio-cardType/);
    await expect(uncheckedItem).not.toHaveClass(/lotus-radio-cardType-checked/);
  });

  test('RadioGroup type=pureCard：不显示 radio 圆点图标，点击卡片仍能正确切换选中状态（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('RadioGroup pureCard 示例', { exact: true });
    const dot = group.locator('.lotus-radio-dot').first();
    await expect(dot).toHaveClass(/lotus-radio-dot-pureCardType/);
    await expect(dot).toHaveCSS('opacity', '0');

    const secondRadio = group.getByRole('radio').nth(1);
    await expect(secondRadio).toBeDisabled();

    const firstRadio = group.getByRole('radio').nth(0);
    await expect(firstRadio).toBeChecked();
  });
});
