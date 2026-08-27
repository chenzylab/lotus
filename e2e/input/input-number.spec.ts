import { test, expect } from '@playwright/test';

test.describe('InputNumber', () => {
  test('点击步进器增加/减少按钮后数值同步更新', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 基本示例');
    const container = input.locator('xpath=..');
    const increaseButton = container.getByLabel('增加');
    const decreaseButton = container.getByLabel('减少');

    await expect(input).toHaveValue('0');
    await increaseButton.click();
    await expect(input).toHaveValue('1');
    await increaseButton.click();
    await expect(input).toHaveValue('2');
    await decreaseButton.click();
    await expect(input).toHaveValue('1');
  });

  test('键盘 ArrowUp/ArrowDown 等价于点击步进按钮（回归防护：自定义控件不像原生 <input type="number"> 自带方向键步进，Class C 补齐键盘无障碍）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 基本示例');

    await expect(input).toHaveValue('0');
    await input.focus();
    await input.press('ArrowUp');
    await expect(input).toHaveValue('1');
    await input.press('ArrowUp');
    await expect(input).toHaveValue('2');
    await input.press('ArrowDown');
    await expect(input).toHaveValue('1');
  });

  test('边界：超出 max 的输入在失焦时被 clamp', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 边界示例');

    await expect(input).toHaveValue('1');
    await input.fill('999');
    await input.blur();
    await expect(input).toHaveValue('10');
  });

  test('边界：低于 min 的输入在失焦时被 clamp', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 边界示例');

    await input.fill('-5');
    await input.blur();
    await expect(input).toHaveValue('1');
  });

  test('step：步进器按 step 值增减', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 步进示例');
    const container = input.locator('xpath=..');
    const increaseButton = container.getByLabel('增加');

    await expect(input).toHaveValue('0');
    await increaseButton.click();
    await expect(input).toHaveValue('5');
  });

  test('disabled 状态下步进器不可点击，输入框不可编辑', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 禁用示例');
    const container = input.locator('xpath=..');
    const increaseButton = container.getByLabel('增加');

    await expect(input).toBeDisabled();
    await expect(increaseButton).toBeDisabled();
  });

  test('showClear：有内容时可点击清除按钮清空', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 无步进器可清除示例');
    const clearButton = page.locator('.lotus-input-number-clear');

    await expect(input).toHaveValue('5');
    await clearButton.click();
    await expect(input).toHaveValue('');
  });

  test('受控组件：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    // 回归防护：组件 props 若用普通 {} 解构而非 &{} 懒解构，外部独立触发源驱动的
    // 受控 prop 变化不会传导到组件视觉，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #30。
    await page.goto('/');
    const input = page.getByLabel('InputNumber 受控示例');
    const addButton = page.getByRole('button', { name: '加 10' });

    await expect(input).toHaveValue('0');
    await addButton.click();
    await expect(input).toHaveValue('10');
    await addButton.click();
    await expect(input).toHaveValue('20');
  });
});
