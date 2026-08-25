import { test, expect } from '@playwright/test';

test.describe('Sidebar', () => {
  test('打开主视图：显示标题、MCPConfigure 工具列表、Annotation 分组', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开主视图' }).click();

    await expect(page.locator('.lotus-sidebar-title')).toHaveText('AI 助手');
    await expect(page.locator('.lotus-sidebar-mcp-configure')).toBeVisible();
    await expect(page.locator('.lotus-sidebar-mcp-configure-item-label')).toHaveCount(2);
    await expect(page.locator('.lotus-sidebar-annotation')).toBeVisible();
  });

  test('点击关闭按钮后浮层退出可见态', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开主视图' }).click();
    await expect(page.locator('.lotus-sidebar-container')).toHaveClass(/lotus-sidebar-container-visible/);

    await page.locator('.lotus-sidebar-close').click();
    await expect(page.locator('.lotus-sidebar-container')).not.toHaveClass(/lotus-sidebar-container-visible/);
  });

  test('打开代码详情：显示返回按钮 + JsonViewer（isJson=true 的 CodeItem）', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开代码详情' }).click();

    await expect(page.locator('.lotus-sidebar-back')).toBeVisible();
    await expect(page.locator('.lotus-sidebar-container .lotus-json-viewer')).toBeVisible();
  });

  test('打开文件详情：显示返回按钮 + FileItem 富文本编辑器', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开文件详情' }).click();

    await expect(page.locator('.lotus-sidebar-back')).toBeVisible();
    await expect(page.locator('.lotus-sidebar-container .lotus-file-item')).toBeVisible();
  });

  test('详情视图点击返回按钮触发 onBackWard 回调，回到主视图', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开代码详情' }).click();
    await expect(page.locator('.lotus-sidebar-back')).toBeVisible();

    await page.locator('.lotus-sidebar-back').click();
    await expect(page.locator('.demo-sidebar-backward-log')).toHaveText('返回触发：code');
    await expect(page.locator('.lotus-sidebar-title')).toHaveText('AI 助手');
  });

  test('MCPConfigure：点击"自定义工具"切换 Radio 后展示自定义工具列表', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开主视图' }).click();

    await page.locator('.lotus-sidebar-mcp-configure .lotus-radio').nth(1).click();
    await expect(page.locator('.lotus-sidebar-mcp-configure-item-label')).toHaveText(['我的自定义工具']);
  });

  test('Annotation：点击分组标题展开引用列表', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开主视图' }).click();

    await page.locator('.lotus-sidebar-annotation .lotus-collapse-header', { hasText: '参考资料' }).click();
    await expect(page.locator('.lotus-sidebar-annotation-item')).toBeVisible();
    await expect(page.locator('.lotus-sidebar-annotation-title')).toHaveText('lotus 组件库文档');
  });

  test('Container 支持拖拽左侧手柄调整宽度', async ({ page }) => {
    await page.goto('/');
    await page.locator('button', { hasText: '打开主视图' }).click();

    const container = page.locator('.lotus-sidebar-container');
    const before = await container.evaluate((el) => el.getBoundingClientRect().width);

    const handle = page.locator('.lotus-sidebar-container-resize-handle');
    const box = await handle.boundingBox();
    if (!box) throw new Error('resize handle not found');

    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
    await page.mouse.down();
    await page.mouse.move(box.x - 60, box.y + box.height / 2);
    await page.mouse.up();

    const after = await container.evaluate((el) => el.getBoundingClientRect().width);
    expect(after).toBeGreaterThan(before);
  });
});
