import { test, expect } from '@playwright/test';

test.describe('TagInput', () => {
  test('基础用法：初始标签正确回显', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(2);
    await expect(tags.nth(0)).toHaveText('苹果');
    await expect(tags.nth(1)).toHaveText('香蕉');
  });

  test('Enter 新增标签', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });
    await input.fill('樱桃');
    await input.press('Enter');

    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(3);
    await expect(tags.nth(2)).toHaveText('樱桃');
    await expect(page.getByLabel('TagInput 事件日志', { exact: true })).toContainText('樱桃');
  });

  test('逗号分隔符：一次输入拆分为多个标签', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });
    await input.fill('葡萄,芒果');
    await input.press('Enter');

    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(4);
    await expect(tags.nth(2)).toHaveText('葡萄');
    await expect(tags.nth(3)).toHaveText('芒果');
  });

  test('Backspace：输入框为空时删除最后一个标签', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });
    await input.click();
    await input.press('Backspace');

    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(1);
    await expect(tags.nth(0)).toHaveText('苹果');
  });

  test('点击标签关闭按钮：移除对应标签', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    await root.locator('.lotus-tag-close').first().click();

    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(1);
    await expect(tags.nth(0)).toHaveText('香蕉');
  });

  test('maxTagCount：超出数量折叠为 +N，点击展开显示全部', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 折叠', { exact: true });
    await expect(root.locator('.lotus-tag-content')).toHaveCount(3);
    const restButton = root.locator('.lotus-tag-input-rest');
    await expect(restButton).toHaveText('+3');

    await restButton.click();
    await expect(root.locator('.lotus-tag-content')).toHaveCount(6);
  });

  test('draggable：拖拽手柄可见，拖拽后顺序改变', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 拖拽', { exact: true });
    await expect(root.locator('.lotus-tag-input-drag-handle')).toHaveCount(4);

    const tags = root.locator('.lotus-tag-content');
    await expect(tags.nth(0)).toHaveText('red');

    const handle = root.locator('.lotus-tag-input-drag-handle').first();
    const lastWrapper = root.locator('.lotus-tag-input-tag-wrapper').nth(3);
    await handle.scrollIntoViewIfNeeded();
    const handleBox = await handle.boundingBox();
    const lastBox = await lastWrapper.boundingBox();
    if (!handleBox || !lastBox) throw new Error('no bounding box');

    await page.mouse.move(handleBox.x + handleBox.width / 2, handleBox.y + handleBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(lastBox.x + lastBox.width + 10, lastBox.y + lastBox.height / 2, { steps: 5 });
    await page.mouse.up();

    await expect(tags.nth(3)).toHaveText('red');
  });

  test('showClear + allowDuplicates=false + max：去重生效、清除按钮清空全部、超出 max 拒绝新增', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 限制', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });

    await input.fill('x');
    await input.press('Enter');
    await expect(root.locator('.lotus-tag-content')).toHaveCount(1);

    await input.fill('a,b,c,d,e,f');
    await input.press('Enter');
    await expect(root.locator('.lotus-tag-content')).toHaveCount(5);

    await root.locator('.lotus-tag-input-clear').click();
    await expect(root.locator('.lotus-tag-content')).toHaveCount(0);
  });

  test('disabled：整体禁用时不渲染关闭按钮，输入框不可交互', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 禁用', { exact: true });
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
    await expect(root.locator('.lotus-tag-close')).toHaveCount(0);
    await expect(root.getByLabel('标签输入框', { exact: true })).toBeDisabled();
  });

  test('受控：外部按钮驱动 value 变化时同步更新', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 TagInput 选中值' });

    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
    await toggleButton.click();
    await expect(root.locator('.lotus-tag-content')).toHaveCount(0);
    await toggleButton.click();
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
  });

  test('受控：onChange 拒绝更新时点击关闭按钮/退格都不会把 UI 带偏（回归防护：与 Cascader/TreeSelect/Upload/Rating 同一根因 bug 的排查对照组——TagInput Foundation 从一开始就正确门控了 isControlled，这里确认真的没有回归，详见 specs 踩坑 #100）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 受控拒绝更新示例', { exact: true });
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);

    await root.locator('.lotus-tag-close').first().click();
    await page.waitForTimeout(300);
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);

    const input = root.getByLabel('标签输入框', { exact: true });
    await input.click();
    await input.press('Backspace');
    await page.waitForTimeout(300);
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
  });

  test('maxLength：单个标签片段超过最大字符数时该次输入被拒绝，触发 onInputExceed', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput maxLength 示例', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });

    await input.fill('abcd');
    await expect(input).toHaveValue('abcd');

    await input.fill('abcde');
    await expect(input).toHaveValue('abcd');
    await expect(page.getByLabel('TagInput maxLength 超限日志', { exact: true })).toHaveText('超限：abcde');
  });

  test('renderTagItem：自定义标签渲染生效，替换默认 Tag 外观', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput renderTagItem 示例', { exact: true });
    const tags = root.locator('.lotus-tag-content');
    await expect(tags.nth(0)).toHaveText('★ custom-a');
    await expect(tags.nth(1)).toHaveText('★ custom-b');
  });

  test('showContentTooltip=false：长标签内容完整显示，不省略不带 title', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput showContentTooltip 关闭示例', { exact: true });
    const text = root.locator('.lotus-tag-input-tag-text').first();
    await expect(text).toHaveText('这是一个很长很长的标签内容');
    await expect(text).not.toHaveAttribute('title');
    await expect(text).not.toHaveClass(/lotus-tag-input-tag-text-ellipsis/);
  });

  test('showContentTooltip 默认 true：标签内容带 title 属性，省略类生效', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput 基础', { exact: true });
    const text = root.locator('.lotus-tag-input-tag-text').first();
    await expect(text).toHaveAttribute('title', '苹果');
    await expect(text).toHaveClass(/lotus-tag-input-tag-text-ellipsis/);
  });

  test('clearIcon：自定义清除按钮图标覆盖默认 IconClear', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput clearIcon 与事件透传示例', { exact: true });
    const clearBtn = root.locator('.lotus-tag-input-clear');
    await expect(clearBtn).toBeVisible();
    await expect(clearBtn.locator('svg')).toBeVisible();
  });

  test('onKeyDown/onFocus/onBlur：原生事件透传给外部回调', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput clearIcon 与事件透传示例', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });

    await input.click();
    await expect(page.getByLabel('TagInput focus/blur 日志', { exact: true })).toHaveText('聚焦');

    await input.press('a');
    await expect(page.getByLabel('TagInput keydown 日志', { exact: true })).toHaveText('按键：a');

    await page.keyboard.press('Tab');
    await expect(page.getByLabel('TagInput focus/blur 日志', { exact: true })).toHaveText('失焦');
  });

  test('split：自定义拆分函数覆盖默认按 separator 拆分的逻辑（回归防护：此前 addTagsFromInput 硬编码用默认拆分，split 配置了却对提交结果不生效，产出空标签数组）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput split 自定义拆分示例', { exact: true });
    const input = root.getByLabel('标签输入框', { exact: true });

    await input.fill('foo bar baz');
    await input.press('Enter');

    const tags = root.locator('.lotus-tag-content');
    await expect(tags).toHaveCount(3);
    await expect(tags.nth(0)).toHaveText('foo');
    await expect(tags.nth(1)).toHaveText('bar');
    await expect(tags.nth(2)).toHaveText('baz');
  });

  test('expandRestTagsOnClick=false：点击折叠气泡不展开剩余标签', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('TagInput expandRestTagsOnClick 关闭示例', { exact: true });
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
    const restButton = root.locator('.lotus-tag-input-rest');
    await expect(restButton).toHaveText('+3');

    await restButton.click();
    await expect(root.locator('.lotus-tag-content')).toHaveCount(2);
    await expect(restButton).toHaveText('+3');
  });
});
