import { test, expect } from '@playwright/test';

test.describe('MarkdownRender', () => {
  test('标题渲染为对应的 h1 元素', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    await expect(root.locator('h1')).toHaveText('标题一');
  });

  test('加粗/斜体/链接渲染为 strong/em/a 元素', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    await expect(root.locator('strong')).toHaveText('加粗');
    await expect(root.locator('em')).toHaveText('斜体');
    const link = root.locator('a');
    await expect(link).toHaveText('链接');
    await expect(link).toHaveAttribute('href', 'https://example.com');
  });

  test('无序列表渲染为 ul > li', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    const items = await root.locator('ul > li').allTextContents();
    expect(items).toEqual(['列表项一', '列表项二']);
  });

  test('GFM 表格语法渲染为 table，含表头与两行数据', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    const table = root.locator('table');
    await expect(table).toBeVisible();
    await expect(table.locator('th').nth(0)).toHaveText('姓名');
    await expect(table.locator('th').nth(1)).toHaveText('年龄');
    const rows = table.locator('tbody tr');
    await expect(rows).toHaveCount(2);
    await expect(rows.nth(0).locator('td').nth(0)).toHaveText('张三');
  });

  test('围栏代码块复用 CodeHighlight 组件渲染语法高亮（含 language-* 类与 token）', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    const code = root.locator('.lotus-code-highlight pre > code');
    await expect(code).toHaveClass(/language-ts/);
    await expect(code).toContainText('function greet');
    const tokenCount = await code.locator('.token').count();
    expect(tokenCount).toBeGreaterThan(0);
  });

  test('行内代码渲染为 span.lotus-markdown-render-simple-code（不经过 CodeHighlight）', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    const inlineCode = root.locator('.lotus-markdown-render-simple-code');
    await expect(inlineCode).toHaveText('const a = 1');
  });

  test('引用块渲染为 blockquote', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    await expect(root.locator('blockquote')).toContainText('引用文本示例');
  });

  test('markdown 源码内嵌的 <script> 标签被架构级丢弃，不出现在 DOM 里也不执行（XSS 防护核心行为）', async ({ page }) => {
    const dialogs: string[] = [];
    page.on('dialog', (dialog) => {
      dialogs.push(dialog.message());
      void dialog.dismiss();
    });
    await page.goto('/');
    const root = page.locator('.demo-markdown-render');
    await expect(root.locator('h1')).toBeVisible();

    const scriptCount = await root.locator('script').count();
    expect(scriptCount).toBe(0);
    const html = await root.innerHTML();
    expect(html).not.toContain('<script');
    expect(html.toLowerCase()).not.toContain('alert(');
    expect(dialogs).toEqual([]);
  });
});
