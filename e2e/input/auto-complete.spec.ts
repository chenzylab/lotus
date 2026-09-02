import { test, expect } from '@playwright/test';

test.describe('AutoComplete', () => {
  test('输入内容后触发 onSearch，候选列表随 data 变化更新（过滤逻辑完全由消费方控制）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });

    await input.fill('北');
    const options = page.locator('.lotus-auto-complete-option');
    await expect(options).toHaveCount(1);
    await expect(options.first()).toHaveText('北京');
  });

  test('点击候选项后选中生效，回填输入框，浮层自动关闭', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });
    await input.fill('北');

    await page.locator('.lotus-auto-complete-option').first().click();
    await expect(input).toHaveValue('北京');
    await expect(page.locator('.lotus-auto-complete-panel')).toHaveCount(0);
  });

  test('清除按钮：hover 后显示，点击清空输入框', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });
    await input.fill('北京');

    const wrapper = input.locator('xpath=ancestor::div[contains(@class,"lotus-input-wrapper")]');
    await wrapper.hover();
    const clearButton = wrapper.locator('.lotus-input-clear');
    await expect(clearButton).toBeVisible();
    await clearButton.click();
    await expect(input).toHaveValue('');
  });

  test('defaultActiveFirstOption：点击触发器打开面板即高亮第一项（无需额外按键）', async ({ page }) => {
    // 点击输入框会冒泡触发外层触发器的 toggle 打开逻辑（对齐 Cascader/
    // TreeSelect 的点击开关模式，Semi 源码 handleInputClick 同样如此），
    // open() 内部立即按 defaultActiveFirstOption 计算好初始高亮，不需要
    // 额外按一次方向键才出现高亮——用程序化 focus()（不冒泡 click）才会
    // 停留在"面板未开"状态，真实鼠标点击与之不同。
    await page.goto('/');
    const input = page.getByLabel('AutoComplete defaultActiveFirstOption', { exact: true });
    await input.click();

    const focused = page.locator('.lotus-auto-complete-option-focused');
    await expect(focused).toBeVisible();
    await expect(focused).toHaveText('北京');
  });

  test('键盘：ArrowDown 移动焦点，Enter 选中并回填', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete defaultActiveFirstOption', { exact: true });
    await input.click();
    // 点击已经打开面板并高亮第一项（北京），再按一次 ArrowDown 移动到第二项。
    await input.press('ArrowDown');

    const focused = page.locator('.lotus-auto-complete-option-focused');
    await expect(focused).toHaveText('上海');

    await input.press('Enter');
    await expect(input).toHaveValue('上海');
    await expect(page.locator('.lotus-auto-complete-panel')).toHaveCount(0);
  });

  test('键盘：Esc 关闭面板但不清空已输入内容（允许自由文本，不强制选择）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });
    await input.fill('北');
    await expect(page.locator('.lotus-auto-complete-panel')).toBeVisible();

    await input.press('Escape');
    await expect(page.locator('.lotus-auto-complete-panel')).toHaveCount(0);
    await expect(input).toHaveValue('北');
  });

  test('loading：搜索中显示 loading 态，完成后展示过滤结果', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete loading', { exact: true });
    await input.fill('海');

    await expect(page.locator('.lotus-auto-complete-loading')).toBeVisible();
    await expect(page.locator('.lotus-auto-complete-option')).toHaveCount(1, { timeout: 2000 });
    await expect(page.locator('.lotus-auto-complete-option').first()).toHaveText('上海');
  });

  test('受控：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 AutoComplete' });

    await expect(input).toHaveValue('北京');
    await toggleButton.click();
    await expect(input).toHaveValue('上海');
    await toggleButton.click();
    await expect(input).toHaveValue('北京');
  });

  test('面板打开后再次点击输入框内部（如移动光标）不应意外关闭面板', async ({ page }) => {
    // 触发器包裹了整个可编辑输入框，点击输入框内部本身可能是为了聚焦打字
    // 或移动光标，不代表用户想关闭面板——只有关闭态点击才应该打开，已打开
    // 时点击输入框内部不应触发关闭（关闭交给点击外部/Esc/选中候选项）。
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });
    await input.fill('北');
    await expect(page.locator('.lotus-auto-complete-panel')).toBeVisible();

    await input.click();
    await expect(page.locator('.lotus-auto-complete-panel')).toBeVisible();
  });

  test('点击触发器/浮层以外区域时浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 基础', { exact: true });
    await input.fill('北');
    await expect(page.locator('.lotus-auto-complete-panel')).toBeVisible();

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(page.locator('.lotus-auto-complete-panel')).toHaveCount(0);
  });

  test('renderSelectedItem + onSelectWithObject + dropdownMatchSelectWidth：自定义回填、事件携带全量对象、面板宽度对齐触发器', async ({ page }) => {
    await page.goto('/');
    const input = page.getByLabel('AutoComplete 高级示例', { exact: true });
    const log = page.getByLabel('AutoComplete 高级事件日志', { exact: true });

    await input.click();
    const panel = page.locator('.lotus-auto-complete-panel');
    const root = page.locator('.lotus-auto-complete').filter({ has: input });
    const rootBox = await root.boundingBox();
    const panelBox = await panel.boundingBox();
    expect(panelBox!.width).toBeCloseTo(rootBox!.width, 0);

    await panel.locator('.lotus-auto-complete-option').first().click();
    await expect(input).toHaveValue('已选：北京');
    await expect(log).toContainText('"value":"北京"');
    await expect(log).toContainText('"label":"北京"');
  });

  test('triggerRender：完全自定义触发器渲染，仍可打开面板并完成选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('AutoComplete triggerRender 示例', { exact: true });
    await expect(trigger).toContainText('收起');

    await trigger.click();
    await expect(trigger).toContainText('展开');
    const panel = page.locator('.lotus-auto-complete-panel').last();
    await expect(panel.locator('.lotus-auto-complete-option')).toHaveCount(10);

    await panel.locator('.lotus-auto-complete-option').first().click();
    await expect(trigger).toContainText('北京');
    await expect(trigger).toContainText('收起');
  });
});
