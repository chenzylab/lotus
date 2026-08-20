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

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await expect(page.getByRole('treeitem', { name: '前端组' })).toBeVisible();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  });

  test('单选：逐级展开点击叶子节点后选中生效，浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });
    await trigger.click();

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.getByRole('treeitem', { name: '前端组' }).locator('.lotus-tree-select-switcher').click();
    await page.getByRole('treeitem', { name: '张三' }).locator('.lotus-tree-select-node-content').click();

    await expect(trigger).toContainText('张三');
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });

  test('禁用节点不可勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.getByRole('treeitem', { name: '后端组' }).locator('.lotus-tree-select-switcher').click();
    const zhaoliu = page.getByRole('treeitem', { name: '赵六' });
    await expect(zhaoliu).toHaveAttribute('aria-disabled', 'true');
    const checkbox = zhaoliu.locator('input[type="checkbox"]');
    await expect(checkbox).toBeDisabled();
  });

  test('多选：勾选父节点触发三态级联，子孙节点同步勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    const deptCheckbox = page.getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();
    await expect(deptCheckbox).toBeChecked();

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    const feCheckbox = page.getByRole('treeitem', { name: '前端组' }).locator('input[type="checkbox"]');
    await expect(feCheckbox).toBeChecked();
  });

  test('多选：autoMergeValue 默认合并子孙，onChange 只携带父 key', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    const deptCheckbox = page.getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();

    await expect(trigger).toContainText('研发部');
    const tags = trigger.locator('.lotus-tree-select-tag');
    await expect(tags).toHaveCount(1);
  });

  test('多选：maxTagCount 折叠，超出数量后展示 +N', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    await page.getByRole('treeitem', { name: '前端组' }).locator('.lotus-tree-select-switcher').click();
    await checkboxClickTarget(page.getByRole('treeitem', { name: '张三' }).locator('input[type="checkbox"]')).click();

    await page.getByRole('treeitem', { name: '后端组' }).locator('.lotus-tree-select-switcher').click();
    await checkboxClickTarget(page.getByRole('treeitem', { name: '王五' }).locator('input[type="checkbox"]')).click();

    await checkboxClickTarget(page.getByRole('treeitem', { name: '产品部' }).locator('input[type="checkbox"]')).click();

    const restTag = trigger.locator('.lotus-tree-select-tag-rest');
    await expect(restTag).toBeVisible();
    await expect(restTag).toHaveText('+1');
  });

  test('多选：点击 tag 上的删除按钮取消勾选', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 多选', { exact: true });
    await trigger.click();
    const deptCheckbox = page.getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
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

    const deptCheckbox = page.getByRole('treeitem', { name: '研发部' }).locator('input[type="checkbox"]');
    await checkboxClickTarget(deptCheckbox).click();
    await expect(deptCheckbox).toBeChecked();

    await page.getByRole('treeitem', { name: '研发部' }).locator('.lotus-tree-select-switcher').click();
    const feCheckbox = page.getByRole('treeitem', { name: '前端组' }).locator('input[type="checkbox"]');
    await expect(feCheckbox).not.toBeChecked();
  });

  test('搜索：输入关键词后自动展开匹配节点的祖先链', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 搜索', { exact: true });
    await trigger.click();

    const searchInput = page.locator('.lotus-tree-select-search-input');
    await searchInput.fill('张三');

    await expect(page.getByRole('treeitem', { name: '研发部' })).toBeVisible();
    await expect(page.getByRole('treeitem', { name: '前端组' })).toBeVisible();
    await expect(page.getByRole('treeitem', { name: '张三' })).toBeVisible();
  });

  test('搜索：点击匹配节点后选中生效', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 搜索', { exact: true });
    await trigger.click();
    await page.locator('.lotus-tree-select-search-input').fill('张三');

    await page.getByRole('treeitem', { name: '张三' }).locator('.lotus-tree-select-node-content').click();
    await expect(trigger).toContainText('张三');
  });

  test('懒加载：点击非叶子节点异步追加子节点，加载中显示 loading 态', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 懒加载', { exact: true });
    await trigger.click();

    await page.getByRole('treeitem', { name: '水果' }).locator('.lotus-tree-select-switcher').click();

    const fruitItem = page.getByRole('treeitem', { name: '水果' });
    await expect(fruitItem.locator('.lotus-tree-select-switcher-loading')).toBeVisible();

    await expect(page.getByRole('treeitem', { name: '苹果' })).toBeVisible();
    await expect(page.getByRole('treeitem', { name: '香蕉' })).toBeVisible();
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

  test('点击触发器/浮层以外区域时浮层自动收起', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByLabel('TreeSelect 单选', { exact: true });
    await trigger.click();
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');

    await page.locator('body').click({ position: { x: 10, y: 10 } });
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
  });
});
