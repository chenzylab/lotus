import { test, expect } from '@playwright/test';

test.describe('PinCode', () => {
  test('基础用法：渲染出对应数量的格子，含 role=group 和位次 aria-label', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 基础', { exact: true });
    await expect(root).toHaveAttribute('role', 'group');
    const cells = root.locator('.lotus-pin-code-cell');
    await expect(cells).toHaveCount(6);
    await expect(root.getByLabel('第 1 位，共 6 位', { exact: true })).toBeVisible();
    await expect(root.getByLabel('第 6 位，共 6 位', { exact: true })).toBeVisible();
  });

  test('连续输入数字：自动跳格，写满后触发 onComplete', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 基础', { exact: true });
    const firstCell = root.getByLabel('第 1 位，共 6 位', { exact: true });
    await firstCell.click();
    await page.keyboard.type('123456');

    const cells = root.locator('.lotus-pin-code-cell');
    await expect(cells.nth(0)).toHaveValue('1');
    await expect(cells.nth(5)).toHaveValue('6');
    await expect(page.getByLabel('PinCode 完成日志', { exact: true })).toHaveText('完成：123456');
  });

  test('非法字符（format=number）：不写入，视觉回退', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 基础', { exact: true });
    const firstCell = root.getByLabel('第 1 位，共 6 位', { exact: true });
    await firstCell.click();
    await page.keyboard.press('a');
    await expect(firstCell).toHaveValue('');
  });

  test('Backspace：清空当前格并回退焦点到上一格', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 基础', { exact: true });
    const firstCell = root.getByLabel('第 1 位，共 6 位', { exact: true });
    await firstCell.click();
    await page.keyboard.type('12');

    const thirdCell = root.getByLabel('第 3 位，共 6 位', { exact: true });
    await expect(thirdCell).toBeFocused();
    // Backspace 对齐 Semi：无条件清空当前格（第 3 格，本身为空）并回退焦点，
    // 不判断当前格是否已空——不会清空第 2 格（它已写入的值保持不变）。
    await page.keyboard.press('Backspace');

    const secondCell = root.getByLabel('第 2 位，共 6 位', { exact: true });
    await expect(secondCell).toBeFocused();
    await expect(secondCell).toHaveValue('2');
    await expect(thirdCell).toHaveValue('');

    // 再按一次 Backspace：此时焦点在第 2 格，清空它并回退到第 1 格。
    await page.keyboard.press('Backspace');
    const firstCellAfter = root.getByLabel('第 1 位，共 6 位', { exact: true });
    await expect(firstCellAfter).toBeFocused();
    await expect(secondCell).toHaveValue('');
  });

  test('方向键：ArrowLeft/ArrowRight 移动焦点', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 基础', { exact: true });
    const thirdCell = root.getByLabel('第 3 位，共 6 位', { exact: true });
    await thirdCell.click();
    await page.keyboard.press('ArrowLeft');
    await expect(root.getByLabel('第 2 位，共 6 位', { exact: true })).toBeFocused();
    await page.keyboard.press('ArrowRight');
    await expect(root.getByLabel('第 3 位，共 6 位', { exact: true })).toBeFocused();
  });

  test('粘贴：多字符文本一次性分发到多个格子', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 混合格式', { exact: true });
    const firstCell = root.getByLabel('第 1 位，共 4 位', { exact: true });
    await firstCell.click();

    await firstCell.evaluate((el) => {
      const dataTransfer = new DataTransfer();
      dataTransfer.setData('text', 'aB3d');
      const event = new ClipboardEvent('paste', { bubbles: true, cancelable: true, clipboardData: dataTransfer });
      el.dispatchEvent(event);
    });

    const cells = root.locator('.lotus-pin-code-cell');
    await expect(cells.nth(0)).toHaveValue('a');
    await expect(cells.nth(1)).toHaveValue('B');
    await expect(cells.nth(2)).toHaveValue('3');
    await expect(cells.nth(3)).toHaveValue('d');
  });

  test('validateStatus=error：应用错误态样式类', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 错误态', { exact: true });
    await expect(root).toHaveClass(/lotus-pin-code-error/);
  });

  test('disabled：整体禁用时格子不可交互', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 禁用', { exact: true });
    const cells = root.locator('.lotus-pin-code-cell');
    await expect(cells.first()).toBeDisabled();
    await expect(cells.nth(0)).toHaveValue('1');
    await expect(cells.nth(5)).toHaveValue('6');
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 受控示例', { exact: true });
    const cells = root.locator('.lotus-pin-code-cell');
    await expect(cells.nth(0)).toHaveValue('1');
    await expect(cells.nth(2)).toHaveValue('3');

    const toggleButton = page.getByRole('button', { name: '切换 PinCode 值' });
    await toggleButton.click();
    await expect(cells.nth(0)).toHaveValue('');

    await toggleButton.click();
    await expect(cells.nth(0)).toHaveValue('9');
    await expect(cells.nth(3)).toHaveValue('6');
  });

  test('format 运行时动态切换后字符校验立即生效（回归防护：Foundation opts 固化会让字符校验永远沿用挂载时刻的旧 format，详见 specs 踩坑 #98/#102）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode format 动态切换示例', { exact: true });
    const firstCell = root.locator('.lotus-pin-code-cell').first();

    await firstCell.click();
    await firstCell.pressSequentially('a');
    await expect(firstCell).toHaveValue('');

    await page.getByRole('button', { name: /切换 PinCode format/ }).click();
    await firstCell.click();
    await firstCell.pressSequentially('a');
    await expect(firstCell).toHaveValue('a');
  });

  test('getPinCodeApi：命令式 focus(index)/blur(index) 聚焦与失焦指定格（对齐 Semi ref.current.focus/blur）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('PinCode 命令式聚焦示例', { exact: true });
    const thirdCell = root.getByLabel('第 3 位，共 4 位', { exact: true });

    await expect(thirdCell).not.toBeFocused();
    await page.getByRole('button', { name: '聚焦第 3 格' }).click();
    await expect(thirdCell).toBeFocused();

    await page.getByRole('button', { name: '失焦第 3 格' }).click();
    await expect(thirdCell).not.toBeFocused();
  });
});
