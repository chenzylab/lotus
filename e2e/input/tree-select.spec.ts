import { test, expect } from '@playwright/test';

/** Checkbox 的原生 `<input>` 用 clip-rect 视觉隐藏且 `pointer-events:none`，
 * 真正可点击的是外层 `<label>`（对齐 Checkbox 自身 e2e 测试的既有模式）。 */
function checkboxClickTarget(input: import('@playwright/test').Locator) {
  return input.locator('xpath=..');
}

test.describe('TreeSelect', () => {
  test('单选：点击触发器展开面板，点击非叶子节点展开子级而非直接选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });

    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' })).toBeVisible();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  });

  test('单选：逐级展开点击叶子节点后选中生效，浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });
    await trigger.click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '张三' }).locator('.lotus-tree-select-node-content').click();

    await expect(trigger).toContainText('张三');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('键盘无障碍：ArrowDown 打开面板并移动高亮，ArrowRight 展开节点，Enter 选中，Escape 关闭不改变已选值（回归防护：combobox 此前完全没有键盘导航实现，Class C 补齐）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });

    await trigger.focus();
    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    let activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('研发部');

    await trigger.press('ArrowRight');
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' })).toBeVisible();

    await trigger.press('ArrowDown');
    activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('前端组');

    await trigger.press('ArrowRight');
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '张三' })).toBeVisible();

    await trigger.press('ArrowDown');
    activeId = await trigger.getAttribute('aria-activedescendant');
    await expect(page.locator(`#${activeId}`)).toHaveText('张三');

    await trigger.press('Enter');
    await expect(trigger).toHaveText('张三');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');

    await trigger.press('ArrowDown');
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
    await trigger.press('Escape');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await expect(trigger).toHaveText('张三');
  });

  test('禁用节点不可勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '后端组' }).locator('.lotus-tree-select-switcher').click();
    const zhaoliu = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '赵六' });
    await expect(zhaoliu).toHaveAttribute('aria-disabled', 'true');
    const checkbox = zhaoliu.locator('input[type="checkbox"]');
    await expect(checkbox).toBeDisabled();
  });

  test('多选：勾选父节点触发三态级联，子孙节点同步勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    const deptCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();
    await expect(deptCheckbox).toBeChecked();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    const feCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' }).locator('input[type="checkbox"]');
    await expect(feCheckbox).toBeChecked();
  });

  test('多选：autoMergeValue 默认合并子孙，onChange 只携带父 key', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    const deptCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();

    await expect(trigger).toContainText('研发部');
    const tags = trigger.locator('.lotus-tree-select-tag');
    await expect(tags).toHaveCount(1);
  });

  test('多选：maxTagCount 折叠，超出数量后展示 +N', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' }).locator('.lotus-tree-select-switcher').click();
    await checkboxClickTarget(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '张三' }).locator('input[type="checkbox"]')).click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '后端组' }).locator('.lotus-tree-select-switcher').click();
    await checkboxClickTarget(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '王五' }).locator('input[type="checkbox"]')).click();

    await checkboxClickTarget(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '产品部' }).locator('input[type="checkbox"]')).click();

    const restTag = trigger.locator('.lotus-tree-select-tag-rest');
    await expect(restTag).toBeVisible();
    await expect(restTag).toHaveText('+1');
  });

  test('多选：点击 tag 上的删除按钮取消勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();
    const deptCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();

    const tags = trigger.locator('.lotus-tree-select-tag');
    await expect(tags.first()).toBeVisible();
    await tags.first().locator('.lotus-tree-select-tag-remove').click();
    await expect(deptCheckbox).not.toBeChecked();
  });

  test('checkRelation=unRelated：勾选父节点不联动子节点', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect unRelated', { exact: true });
    await trigger.click();

    const deptCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();
    await expect(deptCheckbox).toBeChecked();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    const feCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' }).locator('input[type="checkbox"]');
    await expect(feCheckbox).not.toBeChecked();
  });

  test('搜索：输入关键词后自动展开匹配节点的祖先链', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 搜索', { exact: true });
    await trigger.click();

    const searchInput = page.locator('.lotus-tree-select-search-input');
    await searchInput.fill('张三');

    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' })).toBeVisible();
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' })).toBeVisible();
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '张三' })).toBeVisible();
  });

  test('搜索：点击匹配节点后选中生效', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 搜索', { exact: true });
    await trigger.click();
    await page.locator('.lotus-tree-select-search-input').fill('张三');

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '张三' }).locator('.lotus-tree-select-node-content').click();
    await expect(trigger).toContainText('张三');
  });

  test('懒加载：点击非叶子节点异步追加子节点，加载中显示 loading 态', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 懒加载', { exact: true });
    await trigger.click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '水果' }).locator('.lotus-tree-select-switcher').click();

    const fruitItem = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '水果' });
    await expect(fruitItem.locator('.lotus-tree-select-switcher-loading')).toBeVisible();

    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '苹果' })).toBeVisible();
    await expect(page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '香蕉' })).toBeVisible();
  });

  test('受控：外部按钮驱动 value 变化时同步更新（非本组件自身交互触发）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 受控示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 TreeSelect' });

    await expect(trigger).toContainText('张三');
    await toggleButton.click();
    await expect(trigger).toContainText('刘七');
    await toggleButton.click();
    await expect(trigger).toContainText('张三');
  });

  test('受控：onChange 拒绝更新时点击叶子节点/清除按钮都不会把 UI 带偏（回归防护：曾经受控模式下点击直接写本地 state，父组件拒绝更新后 UI 永久停留在点击产生的中间态，同一根因 bug 已在 Cascader/Rating 组件真机验证过，详见 specs 踩坑 #100）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 受控拒绝更新示例', { exact: true });
    await expect(trigger).toContainText('张三');

    await trigger.click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '前端组' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '李四' }).locator('.lotus-tree-select-node-content').click();

    await page.waitForTimeout(300);
    await expect(trigger).toContainText('张三');

    await trigger.locator('.lotus-tree-select-clear').click({ force: true });
    await page.waitForTimeout(300);
    await expect(trigger).toContainText('张三');
  });

  test('点击触发器/浮层以外区域时浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });
    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('virtualize：10000 个子节点只渲染可见区间，滚动后动态切换渲染内容，点击选项正常选中', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 虚拟滚动示例');
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const tree = page.locator('.lotus-tree-select-tree-virtual');
    await expect(tree).toBeVisible();

    const items = tree.locator('[role="treeitem"]');
    const renderedCount = await items.count();
    expect(renderedCount).toBeLessThan(30);
    expect(renderedCount).toBeGreaterThan(0);

    await expect(items.first()).toContainText('根节点');

    await tree.evaluate((el) => { el.scrollTop = 10000; });
    await expect(items.first()).not.toContainText('根节点');

    await items.first().click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('triggerRender：完全自定义触发器渲染，替换默认展示区域，open 状态随面板同步', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect triggerRender 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await expect(trigger).toHaveText(/收起/);

    await trigger.click();
    await expect(page.locator('.lotus-tree-select-panel')).toBeVisible();
    await expect(trigger).toHaveText(/展开/);
  });

  test('prefix：渲染在触发器内部；clearIcon：hover 后展示自定义清除图标', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect prefix 与 clearIcon 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await expect(trigger.locator('.lotus-tree-select-prefix')).toHaveText('部门');

    await trigger.hover();
    const clearButton = trigger.locator('.lotus-tree-select-clear');
    await expect(clearButton).toBeVisible();
    await expect(clearButton.locator('svg')).toBeVisible();
  });

  test('renderSelectedItem：自定义标签渲染生效，替换默认 tag 外观（回归防护：@for 循环体内单一插值表达式这个 tsrx 编译器缺陷曾导致自定义渲染内容完全空白，改用包裹容器元素修复）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect renderSelectedItem 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await expect(trigger.locator('.lotus-tag-content')).toHaveText('★ 张三');
  });

  test('showRestTagsPopover：hover 折叠气泡展示被折叠的标签', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect renderSelectedItem 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    const restTag = trigger.locator('.lotus-tree-select-tag-rest');
    await expect(restTag).toHaveText('+2');

    await restTag.hover();
    await expect(page.locator('.lotus-tree-select-rest-popover')).toBeVisible();
  });

  test('renderFullLabel：完全自定义整行渲染，勾选回调正确触发', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect renderFullLabel 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const checkbox = page.getByLabel('自定义节点 研发部', { exact: true });
    await expect(checkbox).toBeVisible();
    await checkbox.click();
    await expect(checkbox).toBeChecked();
  });

  test('disableStrictly：勾选父节点时排除 disabled 后代，disabled 节点不被联动选中（回归防护：Foundation calcCheckedKeysForChecked 曾未正确过滤 disabled 后代，dist 产物未重新构建导致源码修复未生效）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect disableStrictly 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '后端组' }).locator('.lotus-tree-select-switcher').click();

    const backendCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '后端组' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(backendCheckbox).click();

    await expect(backendCheckbox).toBeChecked();
    const wangwuCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '王五' }).locator('input[type="checkbox"]');
    await expect(wangwuCheckbox).toBeChecked();
    const zhaoliuCheckbox = page.locator('.lotus-tree-select-panel').getByRole('treeitem', { name: '赵六' }).locator('input[type="checkbox"]');
    await expect(zhaoliuCheckbox).not.toBeChecked();
  });

  test('expandAction=click：整行点击同时触发选中和展开（对齐 Semi 真实语义，不是"只展开不选中"）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect expandAction 与事件示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const panel = page.locator('.lotus-tree-select-panel');
    await panel.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-node-content').click();

    await expect(panel.getByRole('treeitem', { name: '前端组' })).toBeVisible();
    const deptCheckbox = panel.getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await expect(deptCheckbox).toBeChecked();
  });

  test('searchAutoFocus：面板打开后自动聚焦搜索框；showSearchClear：输入内容后展示清除按钮', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect expandAction 与事件示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const searchInput = page.locator('.lotus-tree-select-search-input');
    await expect(searchInput).toBeFocused();

    await searchInput.fill('研发');
    await expect(page.locator('.lotus-tree-select-search-clear')).toBeVisible();
  });

  test('onFocus/onBlur：原生焦点事件透传给外部回调', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect onFocus-onBlur 示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();
    await expect(page.getByLabel('TreeSelect focus/blur 日志', { exact: true })).toHaveText('聚焦');

    await trigger.blur();
    await expect(page.getByLabel('TreeSelect focus/blur 日志', { exact: true })).toHaveText('失焦');
  });

  test('zIndex：透传给浮层层级；stopPropagation：点击面板内部不冒泡触发外部关闭逻辑', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect expandAction 与事件示例', { exact: true });
    await trigger.scrollIntoViewIfNeeded();
    await trigger.click();

    const panel = page.locator('.lotus-tree-select-panel');
    await expect(panel).toBeVisible();
    const floatingDiv = panel.locator('xpath=ancestor::div[contains(@style,"z-index")][1]');
    await expect(floatingDiv).toHaveCSS('z-index', '2000');

    await panel.click();
    await expect(panel).toBeVisible();
  });
});
