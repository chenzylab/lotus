import { test, expect } from '@playwright/test';

test.describe('Select', () => {
  test('点击触发器展开下拉，点击选项后选中值更新且浮层收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 基本示例', { exact: true });

    await expect(trigger).toHaveText('抖音');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    // 回归防护：Popover 的浮层内容通过 Portal 渲染到 document.body，脱离了
    // Select 根节点所在的 DOM 子树。点击外部关闭下拉的逻辑如果只判断
    // "点击目标是否在根节点内"，会把"点击浮层内的选项"误判为"点击外部"，
    // mousedown 抢在选项自己的 click 之前关闭浮层并把选项从 DOM 上摘掉，
    // 导致选项的点击事件从未真正生效（值不更新，只是浮层关闭了）。详见
    // specs/cross-cutting/foundation-adapter-pattern.md 关于 Select 的踩坑记录。
    await page.getByRole('option', { name: '西瓜视频' }).click();
    await expect(trigger).toHaveText('西瓜视频');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('禁用项不可选中，disabled Select 整体不可点击', async ({ page }) => {
    await page.goto('/');
    const disabledTrigger = page.getByLabel('Select 禁用示例');

    await expect(disabledTrigger).toHaveAttribute('aria-disabled', 'true');
    await disabledTrigger.click({ force: true });
    await expect(disabledTrigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('validateStatus=error 时容器带对应 class', async ({ page }) => {
    await page.goto('/');
    const errorTrigger = page.getByLabel('Select 错误状态示例');
    const container = errorTrigger.locator('xpath=../..');

    await expect(container).toHaveClass(/lotus-select-status-error/);
  });

  test('showClear：有选中值时可点击清除按钮清空', async ({ page }) => {
    await page.goto('/');
    const clearableTrigger = page.getByLabel('Select 可清除示例');
    const clearButton = clearableTrigger.locator('.lotus-select-clear');

    await expect(clearableTrigger).toHaveText(/抖音/);
    await clearButton.click();
    await expect(clearableTrigger).not.toHaveText(/抖音/);
  });

  test('点击 Select 触发器/浮层以外的区域时下拉自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 基本示例', { exact: true });

    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('多选：点击选项后新增标签，浮层保持展开（不自动收起）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 多选示例');

    await expect(trigger).toContainText('抖音');
    await expect(trigger).toContainText('西瓜视频');

    await trigger.click();
    await page.getByRole('option', { name: '轻颜相机' }).click();

    await expect(trigger).toContainText('轻颜相机');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  });

  test('多选：点击标签上的删除按钮移除该项', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 多选示例');
    const tags = trigger.locator('.lotus-select-tag');

    await expect(tags).toHaveCount(2);
    await tags.first().locator('.lotus-select-tag-remove').click();
    await expect(tags).toHaveCount(1);
  });

  test('受控组件：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    // 回归防护：组件 props 若用普通 {} 解构而非 &{} 懒解构，外部独立触发源驱动的
    // 受控 prop 变化不会传导到组件视觉，详见
    // specs/cross-cutting/foundation-adapter-pattern.md 踩坑 #30。
    await page.goto('/');
    const trigger = page.getByLabel('Select 受控示例');
    const toggleButton = page.getByRole('button', { name: '切换 Select' });

    await expect(trigger).toHaveText('抖音');
    await toggleButton.click();
    await expect(trigger).toHaveText('西瓜视频');
    await toggleButton.click();
    await expect(trigger).toHaveText('抖音');
  });
});
