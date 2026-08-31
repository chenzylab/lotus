import { test, expect } from '@playwright/test';

test.describe('Checkbox', () => {
  test('非受控点击后切换选中态', async ({ page }) => {
    await page.goto('/');
    const checkbox = page.getByLabel('示例', { exact: true });
    const clickTarget = checkbox.locator('xpath=..');

    await expect(checkbox).not.toBeChecked();
    await clickTarget.click();
    await expect(checkbox).toBeChecked();
    await clickTarget.click();
    await expect(checkbox).not.toBeChecked();
  });

  test('disabled 状态下点击不改变选中态', async ({ page }) => {
    await page.goto('/');
    const disabledUnchecked = page.getByLabel('禁用未选中示例', { exact: true });
    const clickTarget = disabledUnchecked.locator('xpath=..');

    await expect(disabledUnchecked).toBeDisabled();
    await expect(disabledUnchecked).not.toBeChecked();
    await clickTarget.click({ force: true }).catch(() => {});
    await expect(disabledUnchecked).not.toBeChecked();
  });

  test('indeterminate 状态下带对应 class', async ({ page }) => {
    await page.goto('/');
    const indeterminate = page.getByLabel('indeterminate 示例', { exact: true });
    const label = indeterminate.locator('xpath=..');

    await expect(label).toHaveClass(/lotus-checkbox-indeterminate/);
  });

  test('受控组件：外部 checked 变化时视觉同步更新', async ({ page }) => {
    await page.goto('/');
    const controlled = page.getByLabel('受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换', exact: true });

    await expect(controlled).not.toBeChecked();
    await toggleButton.click();
    await expect(controlled).toBeChecked();
    await toggleButton.click();
    await expect(controlled).not.toBeChecked();
  });

  test('CheckboxGroup 数组方式：点击后选中集合正确更新', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('CheckboxGroup 数组方式示例', { exact: true });
    const checkboxA = group.getByRole('checkbox').nth(0);
    const checkboxB = group.getByRole('checkbox').nth(1);
    const checkboxC = group.getByRole('checkbox').nth(2);

    await expect(checkboxA).toBeChecked();
    await expect(checkboxB).toBeChecked();
    await expect(checkboxC).not.toBeChecked();
    await expect(checkboxC).toBeDisabled();

    await checkboxA.locator('xpath=..').click();
    await expect(checkboxA).not.toBeChecked();
    await expect(checkboxB).toBeChecked();
  });

  test('CheckboxGroup JSX 方式（受控）：点击后触发 onChange 且视觉同步更新', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('CheckboxGroup JSX 方式示例', { exact: true });
    const checkboxA = group.getByRole('checkbox').nth(0);
    const checkboxB = group.getByRole('checkbox').nth(1);
    const checkboxC = group.getByRole('checkbox').nth(2);

    await expect(checkboxA).toBeChecked();
    await expect(checkboxB).not.toBeChecked();
    await expect(checkboxC).not.toBeChecked();

    await checkboxB.locator('xpath=..').click();
    await expect(checkboxA).toBeChecked();
    await expect(checkboxB).toBeChecked();
    await expect(checkboxC).not.toBeChecked();

    await checkboxA.locator('xpath=..').click();
    await expect(checkboxA).not.toBeChecked();
    await expect(checkboxB).toBeChecked();
  });

  test('type=card：卡片容器带边框 class，选中态带对应选中 class（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('CheckboxGroup card 示例', { exact: true });
    // defaultValue=['1','3']：第一项（value='1'）选中，第二项（value='2'）未选中。
    const checkedItem = group.getByText('单选框标题').first().locator('xpath=ancestor::label[contains(@class,"lotus-checkbox")]');
    const uncheckedItem = group.getByText('单选框标题').nth(1).locator('xpath=ancestor::label[contains(@class,"lotus-checkbox")]');

    await expect(checkedItem).toHaveClass(/lotus-checkbox-cardType/);
    await expect(checkedItem).toHaveClass(/lotus-checkbox-cardType-checked/);
    await expect(uncheckedItem).toHaveClass(/lotus-checkbox-cardType/);
    await expect(uncheckedItem).not.toHaveClass(/lotus-checkbox-cardType-checked/);
  });

  test('type=pureCard：不显示 checkbox 方框图标，点击卡片仍能正确切换选中状态（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const group = page.getByLabel('CheckboxGroup pureCard 示例', { exact: true });
    const box = group.locator('.lotus-checkbox-box').first();
    await expect(box).toHaveClass(/lotus-checkbox-box-pureCardType/);
    await expect(box).toHaveCSS('opacity', '0');

    const thirdItem = group.getByText('单选框标题').nth(2).locator('xpath=ancestor::label[contains(@class,"lotus-checkbox")]');
    const thirdCheckbox = group.getByRole('checkbox').nth(2);
    await expect(thirdCheckbox).toBeChecked();
    await thirdItem.click();
    await expect(thirdCheckbox).not.toBeChecked();
  });
});
