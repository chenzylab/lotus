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
});
