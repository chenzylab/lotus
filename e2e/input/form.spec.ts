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

  test('异步 validator 校验期间字段展示 loading 态（validating，Semi 自身没有这个状态，lotus 主动新增），完成后正确显示错误', async ({ page }) => {
    await page.goto('/');
    const usernameInput = page.getByLabel('用户名', { exact: true });
    const usernameField = page.locator('.lotus-form-field', { hasText: '用户名' });

    await usernameInput.fill('admin');
    await usernameInput.blur();

    // 异步 validator（600ms 延迟）执行期间应该显示 loading 图标（suffix）。
    await expect(usernameField.locator('svg')).toBeVisible();

    // 完成后错误信息出现，loading 图标消失。
    await expect(page.getByText('用户名已被占用')).toBeVisible({ timeout: 2000 });
    await expect(usernameField.locator('svg')).not.toBeVisible();
  });

  test('字段联动：Semi 无专门联动 API，监听 Form.onValueChange + formApi.setValue 驱动关联字段（选择性别后备注自动填充）', async ({ page }) => {
    await page.goto('/');
    const sexSelect = page.getByLabel('性别', { exact: true });
    const noteInput = page.getByLabel('备注', { exact: true });

    await expect(noteInput).toHaveValue('');
    await sexSelect.click();
    await page.getByRole('option', { name: '男' }).click();
    await expect(noteInput).toHaveValue('Hi male');

    await sexSelect.click();
    await page.getByRole('option', { name: '女' }).click();
    await expect(noteInput).toHaveValue('Hi female!');
  });

  test.describe('ArrayField', () => {
    const contactInput = (page: import('@playwright/test').Page, index: number) =>
      page.locator(`#contacts\\[${index}\\]`);
    const deleteButtonInRow = (page: import('@playwright/test').Page, index: number) =>
      page.locator(`[data-field="contacts\\[${index}\\]"]`).locator('..').getByRole('button', { name: '删除' });

    test('初始值正确渲染（回归：initValues 里的数组值曾因路径解析缺失渲染为空）', async ({ page }) => {
      await page.goto('/');
      await expect(contactInput(page, 0)).toHaveValue('张三');
    });

    test('新增一行后已有行的值保持不变（回归：render-prop 模式曾导致 arrayFields 传不到子级 Field，全部渲染出 undefined 的 field 名）', async ({ page }) => {
      await page.goto('/');
      await page.getByRole('button', { name: '新增联系人' }).click();

      await expect(contactInput(page, 0)).toHaveValue('张三');
      await expect(contactInput(page, 1)).toHaveValue('');
    });

    test('新增并预填：新行直接带初始值', async ({ page }) => {
      await page.goto('/');
      await page.getByRole('button', { name: '新增并预填' }).click();

      await expect(contactInput(page, 1)).toHaveValue('预填联系人');
    });

    test('删除中间行：其余行的值正确保留、不发生错位（回归：Ripple keyed @for 复用组件实例时 props 不会响应式更新，删除中间行后被复用实例的值曾停留在旧数据，界面上表现为其余行值被清空）', async ({ page }) => {
      await page.goto('/');
      await page.getByRole('button', { name: '新增联系人' }).click();
      await page.getByRole('button', { name: '新增联系人' }).click();
      await contactInput(page, 1).fill('B');
      await contactInput(page, 2).fill('C');

      await deleteButtonInRow(page, 1).click();

      await expect(contactInput(page, 0)).toHaveValue('张三');
      await expect(contactInput(page, 1)).toHaveValue('C');
      await expect(page.locator('input[id^="contacts["]')).toHaveCount(2);
    });

    test('删除首行：剩余行整体前移、值不丢失（回归：unregisterField 在 Field 卸载的 teardown 上下文里读到 Ripple old_values 锁定的过期 state 快照，曾把刚 setValue 写入的新数组值覆盖回旧值）', async ({ page }) => {
      await page.goto('/');
      await page.getByRole('button', { name: '新增联系人' }).click();
      await contactInput(page, 1).fill('B');

      await deleteButtonInRow(page, 0).click();

      await expect(page.locator('input[id^="contacts["]')).toHaveCount(1);
      await expect(contactInput(page, 0)).toHaveValue('B');
    });

    test('提交联系人：values 里的数组内容与界面一致', async ({ page }) => {
      await page.goto('/');
      await page.getByRole('button', { name: '新增联系人' }).click();
      await contactInput(page, 1).fill('李四');

      await page.getByRole('button', { name: '提交联系人' }).click();

      await expect(page.getByText('提交成功：{"contacts":["张三","李四"]}')).toBeVisible();
    });
  });

  test('Slot：不绑定字段名的纯布局占位，渲染 label 与内容但不参与表单状态', async ({ page }) => {
    await page.goto('/');
    const slot = page.locator('.lotus-form-field', { hasText: '说明' });

    await expect(slot.getByText('这是一段不属于任何字段的说明文字，但复用了 Field 的 label/控件两栏布局。')).toBeVisible();
  });

  test('extraText / validateStatus 覆盖 / layout：extraText 常驻显示，layout=horizontal 生效于 form 根元素', async ({ page }) => {
    await page.goto('/');
    const nicknameField = page.locator('.lotus-form-field', { hasText: '昵称' });

    await expect(nicknameField.getByText('昵称将展示给其他用户')).toBeVisible();
    await expect(nicknameField.locator('xpath=ancestor::form')).toHaveClass(/lotus-form-horizontal/);
  });

  test('trigger=mount：字段挂载后立即触发一次校验，无需等待 blur', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByText('挂载时已触发校验：业务线不能为空')).toBeVisible();
  });

  test('scrollToField / scrollToError：按钮驱动页面滚动到目标字段', async ({ page }) => {
    await page.goto('/');
    const ageInput = page.getByPlaceholder('滚动定位年龄示例');

    await expect(ageInput).not.toBeInViewport();
    await page.getByRole('button', { name: '滚动到年龄字段' }).click();
    await expect(ageInput).toBeInViewport();

    await page.getByRole('button', { name: '滚动到第一个错误字段' }).click();
    await expect(page.getByLabel('业务线（trigger=mount 示例）')).toBeInViewport();
  });
});
