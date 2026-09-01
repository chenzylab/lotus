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

  test('键盘无障碍：ArrowDown 打开面板并移动高亮（自动跳过 disabled 项），Enter 选中，Escape 关闭不改变已选值（回归防护：combobox 此前完全没有键盘导航实现，Class C 补齐）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 基本示例', { exact: true });

    await trigger.focus();
    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    const activeId = await trigger.getAttribute('aria-activedescendant');
    expect(activeId).toBeTruthy();
    await expect(page.locator(`#${activeId}`)).toHaveText('抖音');
    await expect(page.locator(`#${activeId}`)).toHaveClass(/lotus-select-option-active/);

    // 连续两次 ArrowDown：抖音(0) → 轻颜相机(1) → 跳过禁用的剪映(2) → 西瓜视频(3)
    await trigger.press('ArrowDown');
    await trigger.press('ArrowDown');
    const skippedActiveId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${skippedActiveId}`)).toHaveText('西瓜视频');

    await trigger.press('Enter');
    await expect(trigger).toHaveText('西瓜视频');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
    await trigger.press('Escape');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await expect(trigger).toHaveText('西瓜视频');
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
    const trigger = page.getByLabel('Select 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Select' });

    await expect(trigger).toHaveText('抖音');
    await toggleButton.click();
    await expect(trigger).toHaveText('西瓜视频');
    await toggleButton.click();
    await expect(trigger).toHaveText('抖音');
  });

  test('filter=true + searchPosition=trigger（默认）：搜索框叠加在触发器，输入内容过滤候选并高亮命中项，选中后搜索框清空恢复展示已选值', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select filter trigger 示例');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const input = trigger.locator('.lotus-select-trigger-input');
    await expect(input).toBeVisible();
    await input.fill('西瓜');

    const options = page.locator('.lotus-select-list li[role="option"]');
    await expect(options).toHaveCount(1);
    await expect(options.first()).toHaveText('西瓜视频');

    await options.first().click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await expect(trigger).toHaveText('西瓜视频');
  });

  test('filter=true + searchPosition=dropdown：搜索框固定在面板顶部，无匹配时展示空状态文案', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select filter dropdown 示例');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const input = page.locator('.lotus-select-search-input');
    await expect(input).toBeVisible();
    await input.fill('不存在的选项');

    await expect(page.locator('.lotus-select-empty')).toBeVisible();
    await expect(page.locator('.lotus-select-list li[role="option"]')).toHaveCount(0);
  });

  test('多选 + filter：输入框与已选 tags 共存，搜索过滤候选、选中后追加 tag 且搜索框清空', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 多选 filter 示例');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const input = trigger.locator('.lotus-select-trigger-input');
    await input.fill('轻颜');
    await page.getByRole('option', { name: '轻颜相机' }).click();

    await expect(trigger).toContainText('轻颜相机');
    await expect(input).toHaveValue('');
  });

  test('virtualize + filter：1万条选项搜索后虚拟滚动区间基于过滤结果重新计算', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 虚拟滚动示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const searchInput = trigger.locator('.lotus-select-trigger-input');
    await searchInput.fill('选项 9999');

    const options = page.locator('.lotus-select-list-virtual li[role="option"]');
    await expect(options).toHaveCount(1);
    await expect(options.first()).toHaveText('选项 9999');
  });

  test('virtualize：1万条选项只渲染可见区间，滚动后动态切换渲染内容，点击选项正常选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 虚拟滚动示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const list = page.locator('.lotus-select-list-virtual');
    await expect(list).toBeVisible();

    const options = list.locator('li[role="option"]');
    const renderedCount = await options.count();
    expect(renderedCount).toBeLessThan(30);
    expect(renderedCount).toBeGreaterThan(0);

    await expect(options.first()).toHaveText('选项 0');

    await list.evaluate((el) => { el.scrollTop = 5000; });
    await expect(options.first()).not.toHaveText('选项 0');

    await options.first().click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('打开面板默认高亮第一个可选项（defaultActiveFirstOption，对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 基本示例', { exact: true });

    await trigger.click();
    const activeId = await trigger.getAttribute('aria-activedescendant');
    expect(activeId).toBeTruthy();
    await expect(page.locator(`#${activeId}`)).toHaveText('抖音');
  });

  test('分组（optionList 数据驱动方式）：渲染组标题，组内选项可正常选中（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 分组 optionList 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await expect(page.locator('.lotus-select-group-label')).toHaveCount(2);
    await expect(page.locator('.lotus-select-group-label').first()).toHaveText('短视频');

    await page.getByRole('option', { name: '西瓜视频' }).click();
    await expect(trigger).toHaveText('西瓜视频');
  });

  test('分组（SelectOption/SelectOptGroup 组合式声明）：渲染组标题，组内选项可正常选中（对齐 Semi Select.Option/Select.OptGroup，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select 分组 JSX 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await expect(page.locator('.lotus-select-group-label')).toHaveCount(2);
    await expect(page.locator('.lotus-select-group-label').nth(1)).toHaveText('影像工具');

    await page.getByRole('option', { name: '轻颜相机' }).click();
    await expect(trigger).toHaveText('轻颜相机');
  });

  test('max：达上限后新增选中被拦截并触发 onExceed，取消选中后可再次选中（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select max 示例', { exact: true });
    const eventLog = page.locator('text=/^onSelect:|^onDeselect:|^onExceed:/');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await page.getByRole('option', { name: '选项 0' }).click();
    await page.getByRole('option', { name: '选项 1' }).click();
    await page.getByRole('option', { name: '选项 2' }).click();
    await expect(eventLog).toHaveText('onSelect: option-2');

    await page.getByRole('option', { name: '选项 3' }).click();
    await expect(eventLog).toHaveText('onExceed: 已达上限 3 项');

    await page.getByRole('option', { name: '选项 0' }).click();
    await expect(eventLog).toHaveText('onDeselect: option-0');

    await page.getByRole('option', { name: '选项 3' }).click();
    await expect(eventLog).toHaveText('onSelect: option-3');
  });

  test('maxTagCount：多选已选 tag 超出后折叠为 "+N"（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select maxTagCount 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();

    const tags = trigger.locator('.lotus-select-tag');
    await expect(tags).toHaveCount(3);
    await expect(trigger.locator('.lotus-select-tag-rest')).toHaveText('+2');
  });

  test('loading：渲染中显示 loading 指示，替代选项列表（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select loading 示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 loading' });
    await trigger.scrollIntoViewIfNeeded();

    await toggleButton.click();
    await trigger.click();
    await expect(page.locator('.lotus-select-loading')).toBeVisible();
    await expect(page.locator('.lotus-select-list')).toHaveCount(0);
  });

  test('emptyContent：自定义空状态内容替代默认纯文本（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Select emptyContent 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await expect(page.locator('.lotus-select-empty')).toHaveText('暂无可选业务线');
  });
});
