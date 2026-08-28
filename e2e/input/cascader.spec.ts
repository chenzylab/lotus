import { test, expect } from '@playwright/test';

/** Checkbox 的原生 `<input>` 用 clip-rect 视觉隐藏且 `pointer-events:none`，
 * 真正可点击的是外层 `<label>`（对齐 Checkbox 自身 e2e 测试的既有模式）。 */
function checkboxClickTarget(input: import('@playwright/test').Locator) {
  return input.locator('xpath=..');
}

test.describe('Cascader', () => {
  test('单选：点击触发器展开面板，点击非叶子节点展开下一列而非直接选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 单选', { exact: true });

    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.getByRole('menuitem', { name: '浙江' }).click();
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(2);
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  });

  test('单选：逐级点击到叶子节点后选中生效，浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 单选', { exact: true });
    await trigger.click();

    await page.getByRole('menuitem', { name: '浙江' }).click();
    await page.getByRole('menuitem', { name: '杭州' }).click();
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(3);

    await page.getByRole('menuitem', { name: '西湖区' }).click();
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('键盘无障碍：ArrowDown 打开面板并移动高亮，ArrowRight 展开进入下一列，ArrowLeft 回到上一列，Enter 选中，Escape 关闭不改变已选值（回归防护：combobox 此前完全没有键盘导航实现，Class C 补齐）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 单选', { exact: true });

    await trigger.focus();
    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    let activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('浙江');

    await trigger.press('ArrowRight');
    activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('杭州');
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(2);

    await trigger.press('ArrowRight');
    activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('西湖区');

    await trigger.press('ArrowLeft');
    activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('杭州');

    await trigger.press('ArrowRight');
    await trigger.press('Enter');
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
    await trigger.press('Escape');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
  });

  test('禁用节点不可点击展开/选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 单选', { exact: true });
    await trigger.click();

    const shanghai = page.getByRole('menuitem', { name: '上海' });
    await expect(shanghai).toHaveAttribute('aria-disabled', 'true');
    await shanghai.click({ force: true });
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(1);
  });

  test('多选：点击行文字只展开路径，不勾选（回归防护：checkbox 与行点击语义合并，踩坑 #75）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 多选', { exact: true });
    await trigger.click();

    await page.getByRole('menuitem', { name: '浙江' }).locator('.lotus-cascader-item-label').click();
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(2);
    const zhejiangCheckbox = page.getByRole('menuitem', { name: '浙江' }).locator('input[type="checkbox"]');
    await expect(zhejiangCheckbox).not.toBeChecked();
  });

  test('多选：点击 checkbox 触发三态级联勾选，子孙节点同步勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 多选', { exact: true });
    await trigger.click();

    const zhejiangCheckbox = page.getByRole('menuitem', { name: '浙江' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(zhejiangCheckbox).click();
    await expect(zhejiangCheckbox).toBeChecked();

    await page.getByRole('menuitem', { name: '浙江' }).locator('.lotus-cascader-item-label').click();
    const hangzhouCheckbox = page.getByRole('menuitem', { name: '杭州' }).locator('input[type="checkbox"]');
    await expect(hangzhouCheckbox).toBeChecked();
  });

  test('多选：autoMergeValue 默认合并子孙路径，onChange 只携带父路径', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 多选', { exact: true });
    await trigger.click();
    const zhejiangCheckbox = page.getByRole('menuitem', { name: '浙江' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(zhejiangCheckbox).click();

    await expect(trigger).toContainText('浙江');
    await expect(trigger).toContainText('杭州');
    await expect(trigger).toContainText('西湖区');
  });

  test('多选：取消勾选父节点后子孙 tag 一并移除', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 多选', { exact: true });
    await trigger.click();
    const zhejiangCheckbox = page.getByRole('menuitem', { name: '浙江' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(zhejiangCheckbox).click();
    await expect(trigger).toContainText('杭州');

    await checkboxClickTarget(zhejiangCheckbox).click();
    await expect(trigger).not.toContainText('杭州');
  });

  test('多选：点击 tag 上的删除按钮移除该项', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 多选', { exact: true });
    await trigger.click();
    const zhejiangCheckbox = page.getByRole('menuitem', { name: '浙江' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(zhejiangCheckbox).click();

    const tags = trigger.locator('.lotus-cascader-tag');
    await expect(tags.first()).toBeVisible();
    await tags.first().locator('.lotus-cascader-tag-remove').click();
    await expect(zhejiangCheckbox).not.toBeChecked();
  });

  test('搜索：输入关键词展示打平路径结果，默认仅叶子节点', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 搜索', { exact: true });
    await trigger.click();

    const searchInput = page.locator('.lotus-cascader-search-input');
    await searchInput.fill('西湖');
    const results = page.locator('.lotus-cascader-search-item');
    await expect(results).toHaveCount(1);
    await expect(results.first()).toHaveText('浙江 / 杭州 / 西湖区');
  });

  test('搜索：点击搜索结果后选中生效，浮层收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 搜索', { exact: true });
    await trigger.click();
    await page.locator('.lotus-cascader-search-input').fill('西湖');

    await page.locator('.lotus-cascader-search-item').first().click();
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('搜索：无匹配结果时展示空状态', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 搜索', { exact: true });
    await trigger.click();
    await page.locator('.lotus-cascader-search-input').fill('不存在的地区xyz');

    await expect(page.locator('.lotus-cascader-search-item')).toHaveCount(0);
    await expect(page.locator('.lotus-cascader-empty')).toBeVisible();
  });

  test('懒加载：点击非叶子节点异步追加子节点，加载中显示 loading 态', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 懒加载', { exact: true });
    await trigger.click();

    await page.getByRole('menuitem', { name: '水果' }).click();
    await expect(page.locator('.lotus-cascader-column')).toHaveCount(1);

    const fruitItem = page.getByRole('menuitem', { name: '水果' });
    await expect(fruitItem.locator('.lotus-spin')).toBeVisible();

    await expect(page.locator('.lotus-cascader-column')).toHaveCount(2);
    await expect(page.getByRole('menuitem', { name: '苹果' })).toBeVisible();
    await expect(page.getByRole('menuitem', { name: '香蕉' })).toBeVisible();
  });

  test('受控：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 Cascader' });

    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
    await toggleButton.click();
    await expect(trigger).toContainText('江苏 / 苏州 / 姑苏区');
    await toggleButton.click();
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
  });

  test('受控：onChange 拒绝更新时点击叶子节点/清除按钮都不会把 UI 带偏（回归防护：曾经受控模式下点击直接写本地 state，父组件拒绝更新后 UI 永久停留在点击产生的中间态，同一根因 bug 已在 Rating 组件真机验证过，详见 specs 踩坑 #100）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 受控拒绝更新示例', { exact: true });
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');

    await trigger.click();
    await page.getByRole('menuitem', { name: '江苏' }).click();
    await page.getByRole('menuitem', { name: '南京' }).click();
    await page.getByRole('menuitem', { name: '玄武区' }).click();

    await page.waitForTimeout(300);
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');

    await trigger.locator('.lotus-cascader-clear').click({ force: true });
    await page.waitForTimeout(300);
    await expect(trigger).toContainText('浙江 / 杭州 / 西湖区');
  });

  test('点击触发器/浮层以外区域时浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 单选', { exact: true });
    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('virtualize：单列 10000 个子节点只渲染可见区间，滚动后动态切换渲染内容，点击选项正常选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('Cascader 虚拟滚动示例');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await page.getByRole('menuitem', { name: /省份 1/ }).click();

    const column = page.locator('.lotus-cascader-column-virtual').last();
    await expect(column).toBeVisible();

    const items = column.locator('li[role="menuitem"]');
    const renderedCount = await items.count();
    expect(renderedCount).toBeLessThan(30);
    expect(renderedCount).toBeGreaterThan(0);

    await expect(items.first()).toContainText('城市 0');

    await column.evaluate((el) => { el.scrollTop = 10000; });
    await expect(items.first()).not.toContainText('城市 0');

    await items.first().click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });
});
