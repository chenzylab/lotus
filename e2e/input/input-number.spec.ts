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

  test('formatter/parser：展示千分位格式，聚焦态仍展示 formatter 结果，用户输入经 parser 转换回数字（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    // 对齐 Semi：formatter 在聚焦/失焦态都生效（doFormat 调用链无论是否聚焦都
    // 会应用 formatter，只有货币格式化/科学计数法转换才受聚焦态门控）；用户
    // 在编辑过程中输入的原始字符串经 parser 转换回可解析的数字字符串。
    await page.goto('/');
    const input = page.getByLabel('InputNumber formatter 千分位示例');

    await expect(input).toHaveValue('1,000');
    await input.fill('2000000');
    await input.blur();
    await expect(input).toHaveValue('2,000,000');
  });

  test('precision：失焦时按精度四舍五入（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber precision 示例');

    await input.fill('1.23456');
    await input.blur();
    await expect(input).toHaveValue('1.23');
  });

  test('shiftStep：按住 Shift 点击步进按钮使用 shiftStep 而非 step（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber shiftStep 示例');
    const increaseButton = input.locator('xpath=..').getByLabel('增加');

    await expect(input).toHaveValue('0');
    await page.keyboard.down('Shift');
    await increaseButton.click();
    await page.keyboard.up('Shift');
    await expect(input).toHaveValue('20');
  });

  test('innerButtons：步进按钮渲染在输入框内部（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber innerButtons 示例');
    const container = input.locator('xpath=..');

    await expect(container.locator('.lotus-input-number-buttons-inner')).toBeVisible();
    await container.getByLabel('增加').click();
    await expect(input).toHaveValue('1');
  });

  test('长按连续触发：按住增加按钮一段时间后连续多次递增（对齐 Semi pressTimeout/pressInterval，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 长按连续触发示例');
    const increaseButton = input.locator('xpath=..').getByLabel('增加');

    await expect(input).toHaveValue('0');
    // boundingBox() 返回相对文档的绝对坐标（含滚动偏移），page.mouse.move
    // 需要视口坐标——先 scrollIntoViewIfNeeded 让页面滚动到该元素可见，
    // 两者坐标系才能对齐，否则鼠标实际按在了页面上完全不同的位置。
    await increaseButton.scrollIntoViewIfNeeded();
    const box = await increaseButton.boundingBox();
    await page.mouse.move(box!.x + box!.width / 2, box!.y + box!.height / 2);
    await page.mouse.down();
    await page.waitForTimeout(500);
    await page.mouse.up();

    const finalValue = Number(await input.inputValue());
    expect(finalValue).toBeGreaterThan(1);
  });

  test('scientificNotation：失焦时超过阈值的数字用科学计数法展示，聚焦时展示完整数字（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 科学计数法示例');

    await expect(input).toHaveValue(/e\+/);
    await input.click();
    await expect(input).toHaveValue('123456789012345');
  });

  test('货币模式：按 currency/localeCode 展示带符号的格式化数值（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 货币示例');

    await expect(input).toHaveValue(/¥/);
    await expect(input).toHaveValue(/1,234.50/);
  });

  test('getInputNumberApi：交出的 focus()/blur() 真实生效（对齐 Semi ref.current.focus()，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('InputNumber 命令式 focus/blur 示例');
    const group = input.locator('xpath=ancestor::*[contains(@class,"lotus-space")][1]');

    await group.getByRole('button', { name: '聚焦' }).click();
    await expect(input).toBeFocused();
    await group.getByRole('button', { name: '失焦' }).click();
    await expect(input).not.toBeFocused();
  });
});
