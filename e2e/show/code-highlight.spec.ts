import { test, expect } from '@playwright/test';

test.describe('CodeHighlight', () => {
  test('基础用法：渲染 div > pre > code 结构，code 带 language-* 类', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-code-highlight-ts');
    await expect(root).toBeVisible();
    const code = root.locator('pre > code');
    await expect(code).toHaveClass(/language-typescript/);
    await expect(code).toContainText("function greet(name: string): string");
  });

  test('默认 lineNumber=true 时 pre 带 line-numbers 类并渲染行号', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-code-highlight-ts');
    await expect(root.locator('pre')).toHaveClass(/line-numbers/);
    await expect(root.locator('.line-numbers-rows')).toBeVisible();
  });

  test('lineNumber=false 时不带 line-numbers 类，不渲染行号', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-code-highlight-css');
    const pre = root.locator('pre');
    await expect(pre).not.toHaveClass(/line-numbers/);
    await expect(root.locator('.line-numbers-rows')).toHaveCount(0);
    const code = root.locator('pre > code');
    await expect(code).toHaveClass(/language-css/);
  });

  test('defaultTheme=false 时根节点不带 defaultTheme 类', async ({ page }) => {
    await page.goto('/');
    const root = page.locator('.demo-code-highlight-json');
    await expect(root).toHaveClass(/lotus-code-highlight(?!.*defaultTheme)/);
    await expect(root).not.toHaveClass(/lotus-code-highlight-defaultTheme/);
    await expect(root.locator('pre > code')).toHaveClass(/language-json/);
  });

  test('Prism 语法高亮真实生效：token 被拆分成带 .token 类的 span', async ({ page }) => {
    await page.goto('/');
    const code = page.locator('.demo-code-highlight-ts pre > code');
    const tokenCount = await code.locator('.token').count();
    expect(tokenCount).toBeGreaterThan(0);
    await expect(code.locator('.token.keyword').first()).toBeVisible();
  });

  test('代码内容只写为纯文本节点，不解析成 HTML 标签（XSS 防护）', async ({ page }) => {
    await page.goto('/');
    const code = page.locator('.demo-code-highlight-json pre > code');
    await expect(code).toContainText('"name": "lotus"');
    // JSON 高亮下不应该出现真实 <script>/<img> 等注入标签——只应有 Prism 自己生成的
    // .token span（语法高亮）和 line-numbers 插件生成的 .line-numbers-rows 容器
    // （内含若干无 class 的空 <span> 作为行号占位符，是插件的合法结构，不是注入内容）。
    const foreignTags = await code.evaluate((el) =>
      [...el.querySelectorAll('*')].filter((n) => {
        if (n.closest('.line-numbers-rows')) return false;
        return !n.className || !String(n.className).includes('token');
      }).length,
    );
    expect(foreignTags).toBe(0);
  });
});
