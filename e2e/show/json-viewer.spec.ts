import { test, expect } from '@playwright/test';

test.describe('JsonViewer', () => {
  test('基础用法：默认只展开根节点，object/array/string/number/boolean/null 类型均正确渲染', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-default');
    await expect(root).toBeVisible();

    await expect(root.locator('.lotus-json-viewer-value-string').first()).toHaveText('"lotus"');
    await expect(root.locator('.lotus-json-viewer-value-boolean').first()).toHaveText('true');
    await expect(root.locator('.lotus-json-viewer-value-null').first()).toHaveText('null');

    // keywords（数组）与 author（对象）默认折叠，只显示摘要文案，不展示子节点内容。
    await expect(root.locator('.lotus-json-viewer-collapsed-summary').filter({ hasText: '3 项' })).toBeVisible();
    await expect(root.locator('.lotus-json-viewer-collapsed-summary').filter({ hasText: '2 个属性' })).toBeVisible();
  });

  test('数组元素不显示下标 key 前缀（只有 object 的成员才显示 key）', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-expanded');
    // defaultExpandDepth=Infinity，c 数组的三个元素应该全部展开可见，且不带 "0:"/"1:"/"2:" 前缀。
    const arrayValues = root.locator('.lotus-json-viewer-value-number');
    await expect(arrayValues).toHaveCount(3);
    await expect(arrayValues.nth(0)).toHaveText('1');
    await expect(arrayValues.nth(1)).toHaveText('2');
    await expect(arrayValues.nth(2)).toHaveText('3');
    const keys = await root.locator('.lotus-json-viewer-key').allTextContents();
    expect(keys).not.toContain('0');
    expect(keys).not.toContain('1');
    expect(keys).not.toContain('2');
  });

  test('defaultExpandDepth=Infinity 时全部容器节点默认展开，不显示折叠摘要', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-expanded');
    await expect(root.locator('.lotus-json-viewer-collapsed-summary')).toHaveCount(0);
    await expect(root.locator('.lotus-json-viewer-key').filter({ hasText: 'a' })).toBeVisible();
    await expect(root.locator('.lotus-json-viewer-key').filter({ hasText: 'b' })).toBeVisible();
    await expect(root.locator('.lotus-json-viewer-key').filter({ hasText: 'c' })).toBeVisible();
  });

  test('showCopy=false 时不渲染复制按钮', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-expanded');
    await expect(root.locator('.lotus-typography-copy')).toHaveCount(0);
  });

  test('点击容器节点的展开开关切换该节点的折叠状态，不影响其它兄弟节点', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-default');
    // 用 data-path 精确定位 author 节点自身（避免 hasText 子串匹配误命中，
    // 如 'homepage' 意外包含 'age' 子串这类陷阱）。
    const authorNode = root.locator('[data-path="root.author"]').first();
    const authorSwitcher = authorNode.locator('.lotus-json-viewer-switcher').first();

    await expect(root.locator('[data-path="root.author.name"]')).toHaveCount(0);
    await authorSwitcher.click();
    await expect(root.locator('[data-path="root.author.name"]')).toBeVisible();
    await expect(root.locator('[data-path="root.author.age"]')).toBeVisible();
    // keywords 仍保持折叠（未被误展开）。
    await expect(root.locator('[data-path="root.keywords"]').locator('.lotus-json-viewer-collapsed-summary')).toBeVisible();

    await authorSwitcher.click();
    await expect(root.locator('[data-path="root.author.name"]')).toHaveCount(0);
  });

  test('全部展开/全部折叠按钮控制整棵树的展开状态', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-default');
    const expandAllBtn = root.locator('.lotus-json-viewer-toolbar-btn').filter({ hasText: '全部展开' });
    const collapseAllBtn = root.locator('.lotus-json-viewer-toolbar-btn').filter({ hasText: '全部折叠' });

    await expandAllBtn.click();
    await expect(root.locator('.lotus-json-viewer-collapsed-summary')).toHaveCount(0);
    await expect(root.locator('[data-path="root.author.age"]')).toBeVisible();

    await collapseAllBtn.click();
    // 折叠到只剩根节点自身的摘要（根节点本身也被折叠）。
    await expect(root.locator('[data-path="root"]').first().locator('.lotus-json-viewer-collapsed-summary')).toHaveText('6 个属性');
  });

  test('复制按钮存在且可点击（对齐 Typography copyable 的既有 CopyableAction 组件）', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-json-viewer-default');
    const copyBtn = root.locator('.lotus-typography-copy');
    await expect(copyBtn).toBeVisible();
    await expect(copyBtn).toHaveAttribute('aria-label', '复制');
  });

  test('width/height：容器尺寸生效，超出滚动', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer width height');
    await expect(root).toHaveCSS('width', '300px');
    await expect(root).toHaveCSS('height', '150px');
    await expect(root).toHaveCSS('overflow', 'auto');
  });

  test('editable：点击叶子值进入编辑态，Enter 提交后触发 onChange', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer editable');
    await root.scrollIntoViewIfNeeded();

    const nameValue = root.locator('.lotus-json-viewer-value', { hasText: '"lotus"' });
    await nameValue.click();

    const input = root.locator('.lotus-json-viewer-edit-input');
    await expect(input).toBeVisible();
    await expect(input).toHaveValue('lotus');

    await input.fill('lotus-e2e');
    await input.press('Enter');

    await expect(root.locator('.lotus-json-viewer-edit-input')).toHaveCount(0);
    await expect(root).toContainText('lotus-e2e');
  });

  test('editable：Escape 取消编辑，不提交改动（回归防护：Escape 后紧跟的原生 blur 事件不应重复提交）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer editable');
    await root.scrollIntoViewIfNeeded();

    const countValue = root.locator('.lotus-json-viewer-value', { hasText: '42' });
    await countValue.click();

    const input = root.locator('.lotus-json-viewer-edit-input');
    await input.fill('999');
    await input.press('Escape');

    await expect(root.locator('.lotus-json-viewer-edit-input')).toHaveCount(0);
    await expect(root).toContainText('42');
    await expect(root).not.toContainText('999');
  });

  test('editable：失焦（点击别处）提交编辑', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer editable');
    await root.scrollIntoViewIfNeeded();

    const activeValue = root.locator('.lotus-json-viewer-value', { hasText: 'true' });
    await activeValue.click();

    const input = root.locator('.lotus-json-viewer-edit-input');
    await input.fill('false');
    await root.locator('.lotus-json-viewer-toolbar-btn').first().click();

    await expect(root.locator('.lotus-json-viewer-edit-input')).toHaveCount(0);
    await expect(root.locator('.lotus-json-viewer-value-boolean').filter({ hasText: 'false' })).toBeVisible();
  });

  test('showSearch：搜索命中 key/叶子值，自动展开祖先并高亮当前命中，计数正确', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer showSearch');
    await root.scrollIntoViewIfNeeded();

    const searchInput = root.locator('.lotus-json-viewer-search input');
    await searchInput.fill('role');

    await expect(root.locator('.lotus-json-viewer-search-count')).toHaveText('1/3');
    const active = root.locator('.lotus-json-viewer-node-active-match');
    await expect(active).toBeVisible();
    await expect(active).toContainText('role');
  });

  test('showSearch：点击下一个/上一个按钮在命中结果间循环跳转', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer showSearch');
    await root.scrollIntoViewIfNeeded();

    const searchInput = root.locator('.lotus-json-viewer-search input');
    await searchInput.fill('role');
    await expect(root.locator('.lotus-json-viewer-search-count')).toHaveText('1/3');

    const [prevBtn, nextBtn] = await root.locator('.lotus-json-viewer-search-btn').all();
    await nextBtn.click();
    await expect(root.locator('.lotus-json-viewer-search-count')).toHaveText('2/3');

    await prevBtn.click();
    await expect(root.locator('.lotus-json-viewer-search-count')).toHaveText('1/3');
  });

  test('showSearch：无匹配结果时显示提示文案', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('JsonViewer showSearch');
    await root.scrollIntoViewIfNeeded();

    const searchInput = root.locator('.lotus-json-viewer-search input');
    await searchInput.fill('nonexistent-xyz');

    await expect(root.locator('.lotus-json-viewer-search-count')).toHaveText('无匹配结果');
  });
});
