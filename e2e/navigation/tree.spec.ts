import { test, expect } from '@playwright/test';

test.describe('Tree', () => {
  test('单选 Tree：默认展开第一层，展开子节点顺序正确', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="单选 Tree"]');

    await expect(tree.locator('.lotus-tree-node-label')).toHaveText(['研发部', '前端组', '后端组', '产品部']);

    await tree.locator('.lotus-tree-switcher').nth(1).click();
    await expect(tree.locator('.lotus-tree-node-label')).toHaveText([
      '研发部',
      '前端组',
      '张三',
      '李四',
      '后端组',
      '产品部',
    ]);
  });

  test('单选 Tree：点击节点选中，再次点击取消选中', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="单选 Tree"]');
    await tree.locator('.lotus-tree-switcher').nth(1).click();

    const zhangsan = tree.locator('.lotus-tree-node', { hasText: '张三' });
    await zhangsan.locator('.lotus-tree-node-content').click();
    await expect(zhangsan).toHaveClass(/lotus-tree-node-selected/);

    await zhangsan.locator('.lotus-tree-node-content').click();
    await expect(zhangsan).not.toHaveClass(/lotus-tree-node-selected/);
  });

  test('多选 Tree：三态级联，勾选全部子节点后父节点自动全选', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="多选 Tree（三态级联）"]');

    const zhangsan = tree.locator('.lotus-tree-node', { hasText: '张三' }).locator('label.lotus-checkbox');
    const lisi = tree.locator('.lotus-tree-node', { hasText: '李四' }).locator('label.lotus-checkbox');
    const qianduanCheckbox = tree
      .locator('.lotus-tree-node', { hasText: '前端组' })
      .first()
      .locator('input[type="checkbox"]');

    await zhangsan.click();
    await expect(qianduanCheckbox).not.toBeChecked();

    await lisi.click();
    await expect(qianduanCheckbox).toBeChecked();
  });

  test('多选 Tree：禁用节点不可勾选', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="多选 Tree（三态级联）"]');
    const zhaoliuCheckbox = tree.locator('.lotus-tree-node', { hasText: '赵六' }).locator('input[type="checkbox"]');

    await expect(zhaoliuCheckbox).toBeDisabled();
  });

  test('搜索过滤 Tree：仅展示匹配节点及其祖先链，清空后恢复', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="搜索过滤 Tree"]');
    const input = tree.locator('.lotus-tree-search-input');

    await input.fill('张三');
    await expect(tree.locator('.lotus-tree-node-label')).toHaveText(['研发部', '前端组', '张三']);

    await input.fill('不存在的关键字');
    await expect(tree.locator('.lotus-tree-empty')).toBeVisible();

    // 清空搜索词后 showFilteredOnly 不再限制显示范围，但搜索期间自动展开的祖先链
    // 不会被主动收起（Foundation 的 handleSearch 语义），所以恢复到"全部节点、
    // 之前搜索展开过的分支仍展开"的状态，而不是回到最初的折叠态。
    await tree.locator('[aria-label="清除搜索"]').click();
    await expect(input).toHaveValue('');
    await expect(tree.locator('.lotus-tree-node-label')).toHaveText([
      '研发部',
      '前端组',
      '张三',
      '李四',
      '后端组',
      '产品部',
    ]);
  });

  test('懒加载 Tree：展开时显示 loading，加载完成后正确插入子节点', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="懒加载 Tree"]');
    const firstSwitcher = tree.locator('.lotus-tree-switcher').first();

    await firstSwitcher.click();
    await expect(tree.locator('.lotus-tree-switcher-loading').first()).toBeVisible();

    await expect(tree.locator('.lotus-tree-node-label')).toHaveText([
      '懒加载节点 1',
      '懒加载节点 1 子节点 1',
      '懒加载节点 1 子节点 2',
      '懒加载节点 2',
    ]);
  });

  test('懒加载 Tree：二级懒加载同样保持正确顺序', async ({ page }) => {
    await page.goto('/');
    const tree = page.locator('[aria-label="懒加载 Tree"]');

    await tree.locator('.lotus-tree-switcher').first().click();
    await expect(tree.locator('.lotus-tree-node-label')).toHaveCount(4);

    await tree.locator('.lotus-tree-switcher').nth(1).click();
    await expect(tree.locator('.lotus-tree-node-label')).toHaveText([
      '懒加载节点 1',
      '懒加载节点 1 子节点 1',
      '懒加载节点 1 子节点 1 子节点 1',
      '懒加载节点 1 子节点 1 子节点 2',
      '懒加载节点 1 子节点 2',
      '懒加载节点 2',
    ]);
  });
});
