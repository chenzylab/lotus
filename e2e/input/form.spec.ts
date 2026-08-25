import { test, expect } from '@playwright/test';

test.describe('Form', () => {
  test('提交空表单时所有字段的校验错误都显示（回归：并发校验多个字段时，后完成的字段曾覆盖先完成字段的错误）', async ({ page }) => {
    await page.goto('/');
    const submitButton = page.getByRole('button', { name: '提交', exact: true });

    await submitButton.click();

    await expect(page.getByRole('alert').filter({ hasText: '用户名不能为空' })).toBeVisible();
    await expect(page.getByRole('alert').filter({ hasText: '年龄不能为空' })).toBeVisible();
    await expect(page.getByRole('alert').filter({ hasText: '请选择业务线' })).toBeVisible();
    await expect(page.getByRole('alert').filter({ hasText: '请先同意用户协议' })).toBeVisible();
  });

  test('blur 触发单字段校验，填写合法值后错误信息消失', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('用户名', { exact: true });

    await usernameInput.click();
    await usernameInput.blur();
    await expect(page.getByText('用户名不能为空')).toBeVisible();

    await usernameInput.fill('semi');
    await usernameInput.blur();
    await expect(page.getByText('用户名不能为空')).not.toBeVisible();
  });

  test('全部字段合法时提交成功，onSubmit 收到完整 values', async ({ page }) => {
    await page.goto('/');

    await page.getByLabel('用户名', { exact: true }).fill('semi');
    await page.getByPlaceholder('请输入年龄').fill('25');

    await page.getByLabel('业务线', { exact: true }).click();
    await page.getByRole('option', { name: '抖音' }).click();

    // Checkbox 原生 input 视觉隐藏（clip:rect），Playwright 点击命中不到，
    // 必须点击外层可见的 .lotus-checkbox label 容器，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #31。
    await page.locator('.lotus-checkbox').filter({ hasText: '我同意用户协议' }).click();

    await page.getByRole('button', { name: '提交', exact: true }).click();

    await expect(page.getByText('提交成功')).toBeVisible();
    await expect(page.getByText('"username":"semi"')).toBeVisible();
    await expect(page.getByText('"age":25')).toBeVisible();
    await expect(page.getByText('"businessLine":"douyin"')).toBeVisible();
    await expect(page.getByText('"agree":true')).toBeVisible();
  });

  test('重置：所有字段恢复到挂载时的初始值（回归：没有单独声明 initValue、只吃 Form 级 initValues 的字段曾在 reset 后不被清空）', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('用户名', { exact: true });
    const ageInput = page.getByPlaceholder('请输入年龄');
    const resetButton = page.getByRole('button', { name: '重置' });

    const agreeCheckboxLabel = page.locator('.lotus-checkbox').filter({ hasText: '我同意用户协议' });
    const agreeCheckboxInput = agreeCheckboxLabel.locator('input[type="checkbox"]');
    await usernameInput.fill('semi');
    await ageInput.fill('30');
    await agreeCheckboxLabel.click();
    await expect(agreeCheckboxInput).toBeChecked();

    await resetButton.click();

    await expect(usernameInput).toHaveValue('');
    await expect(ageInput).toHaveValue('');
    await expect(agreeCheckboxInput).not.toBeChecked();
  });

  test('formApi.setValue：外部按钮驱动字段值变化，同步更新到输入框', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('用户名', { exact: true });
    const externalButton = page.getByRole('button', { name: '外部设置用户名' });

    await expect(usernameInput).toHaveValue('');
    await externalButton.click();
    await expect(usernameInput).toHaveValue('预填用户名');
  });

  test('无障碍：label 的 for 真正关联到控件的原生 id（非仅靠 aria-label 兜底），点击 label 能聚焦控件', async ({ page }) => {
    await page.goto('/');
    const usernameLabel = page.locator('.lotus-form-field-label', { hasText: 'username' });
    const forAttr = await usernameLabel.getAttribute('for');
    expect(forAttr).toBeTruthy();

    const targetInput = page.locator(`#${forAttr}`);
    await expect(targetInput).toHaveCount(1);
    await expect(targetInput).toHaveJSProperty('tagName', 'INPUT');

    await usernameLabel.click();
    await expect(targetInput).toBeFocused();
  });
});
