import { test, expect } from '@playwright/test';

test.describe('Input', () => {
  test('输入内容后触发 onChange，非受控模式下值同步显示', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const input = page.getByPlaceholder('请输入', { exact: true });
    await input.fill('hello lotus');

    await expect(input).toHaveValue('hello lotus');
    expect(logs.some((l) => l.includes('input changed'))).toBe(true);
  });

  test('disabled 状态下无法输入', async ({ page }) => {
    await page.goto('/');
    // 渲染顺序对齐 App.tsrx demo：基本/large/default/small/disabled
    const input = page.locator('.lotus-input-native').nth(4);
    await expect(input).toHaveValue('禁用状态');
    await expect(input).toBeDisabled();
  });

  test('showClear：hover 后出现清除按钮，点击后清空内容', async ({ page }) => {
    await page.goto('/');
    const clearableInput = page.locator('.lotus-input-native').nth(8);
    await expect(clearableInput).toHaveValue('hover 或 focus 时可清除');
    await clearableInput.hover();
    const clearButton = page.locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(clearableInput).toHaveValue('');
  });

  test('密码模式：点击眼睛图标切换 input type', async ({ page }) => {
    await page.goto('/');
    const passwordInput = page.locator('.lotus-input-native').nth(9);
    await expect(passwordInput).toHaveValue('secret123');
    await expect(passwordInput).toHaveAttribute('type', 'password');

    await page.locator('.lotus-input-eye').click();
    await expect(passwordInput).toHaveAttribute('type', 'text');
  });

  test('受控组件：外部 value 变化时输入框同步更新', async ({ page }) => {
    await page.goto('/');
    const controlledInput = page.locator('.lotus-input-native').nth(12);
    await expect(controlledInput).toHaveValue('受控初始值');
    await controlledInput.fill('受控新值');
    await expect(controlledInput).toHaveValue('受控新值');
  });

  test('受控组件：外部按钮驱动 value 变化时输入框同步更新（非本组件自身交互触发）', async ({ page }) => {
    // 回归防护：组件 props 若用普通 {} 解构而非 &{} 懒解构，外部独立触发源驱动的
    // 受控 prop 变化不会传导到组件视觉，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #30。上面那条"受控组件"
    // 用例是在这个 input 自身 fill 触发的，走的是原生输入事件路径，不能验证这个场景。
    await page.goto('/');
    const externalControlled = page.getByLabel('Input 外部受控示例');
    const appendButton = page.getByRole('button', { name: '追加感叹号' });

    await expect(externalControlled).toHaveValue('初始值');
    await appendButton.click();
    await expect(externalControlled).toHaveValue('初始值!');
    await appendButton.click();
    await expect(externalControlled).toHaveValue('初始值!!');
  });

  test('校验状态：validateStatus=error 时容器带对应 class', async ({ page }) => {
    await page.goto('/');
    const errorInput = page.locator('.lotus-input-native').nth(11);
    await expect(errorInput).toHaveValue('错误状态');
    await expect(errorInput.locator('xpath=..')).toHaveClass(/lotus-input-status-error/);
  });

  test('aria-*：describedby/labelledby/required/invalid 全部正确透传（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('带完整 ARIA 属性的输入框');
    await expect(input).toHaveAttribute('aria-describedby', 'input-aria-hint');
    await expect(input).toHaveAttribute('aria-labelledby', 'input-aria-label-el');
    await expect(input).toHaveAttribute('aria-required', 'true');
    await expect(input).toHaveAttribute('aria-invalid', 'true');
  });

  test('clearIcon：自定义清除按钮图标替换默认图标（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('自定义清除图标输入框');
    await input.click();
    const clearButton = input.locator('xpath=..').locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await expect(clearButton.locator('svg')).toBeVisible();
  });

  test('getValueLength：按自定义计算逻辑判断 maxLength 截断（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('getValueLength 输入框');
    await input.fill('abcdefgh');
    await expect(input).toHaveValue('abcde');
  });

  test('readOnly：只读态阻止编辑但鼠标点击/聚焦仍可用（对齐 Semi readonly，回归防护：readonly={readOnly} 这个 JSX 属性名本身在 tsrx 编译器里有异常处理路径，曾完全不生效——用 ref+effect 手动赋值 readOnly property 绕过）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('readOnly 输入框');
    await expect(input).toHaveJSProperty('readOnly', true);
    await expect(input).toHaveValue('只读内容不可编辑');
    await input.click();
    await page.keyboard.type('追加内容');
    await expect(input).toHaveValue('只读内容不可编辑');
  });

  test('getInputApi：交出的 focus()/blur() 真实生效（对齐 Semi ref.current.focus()，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('getInputApi 输入框');
    const group = input.locator('xpath=ancestor::*[contains(@class,"lotus-space")][1]');
    await group.getByRole('button', { name: '聚焦' }).click();
    await expect(input).toBeFocused();
    await group.getByRole('button', { name: '失焦' }).click();
    await expect(input).not.toBeFocused();
  });
});
