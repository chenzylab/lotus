import { test, expect } from '@playwright/test';

test.describe('IconButton', () => {
  test('点击图标按钮触发回调，且图标正确渲染为 svg', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const button = page.getByRole('button', { name: '设置', exact: true });

    // 对应 specs 踩坑 #41：@if/@else 两分支渲染同 class 容器时 @else 分支内容可能不显示，
    // 必须断言内部子元素（svg）真的存在，不能只看外层 button 是否可见。
    await expect(button.locator('svg')).toBeVisible();

    await button.click();
    expect(logs).toContain('icon button clicked');
  });

  test('disabled 状态下点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const disabledButton = page.getByRole('button', { name: '禁用图标按钮' });

    await expect(disabledButton).toBeDisabled();
    await disabledButton.click({ force: true }).catch(() => {});

    expect(logs).not.toContain('should not fire');
  });

  test('loading 状态下显示转圈图标且点击不触发回调', async ({ page }) => {
    const logs: string[] = [];
    page.on('console', (msg) => logs.push(msg.text()));

    await page.goto('/');
    const loadingButton = page.getByRole('button', { name: '加载中图标按钮' });

    await expect(loadingButton).toHaveCSS('pointer-events', 'none');
    await expect(loadingButton.locator('.lotus-icon-button-spinner')).toBeVisible();

    await loadingButton.click({ force: true }).catch(() => {});
    expect(logs).not.toContain('should not fire');
  });

  test('disabled 运行时动态切换为 false 后点击回调正确触发（回归防护：非函数字面量 track() 固化挂载时快照会让 disabled 变化后点击永远被拦截，详见 specs 踩坑 #94）', async ({ page }) => {
    await page.goto('/');
    const button = page.getByLabel('IconButton 动态禁用示例', { exact: true });
    const toggleButton = page.getByRole('button', { name: '切换 IconButton 禁用态' });
    const log = page.getByLabel('IconButton 动态禁用日志', { exact: true });

    await expect(button).toBeDisabled();
    await toggleButton.click();
    await expect(button).toBeEnabled();

    await button.click();
    await expect(log).toHaveText('点击生效');
  });

  test('size / type / theme 组合正确渲染对应 class', async ({ page }) => {
    await page.goto('/');

    // 用具体 aria-label 定位到 playground 里的 IconButton 演示实例，不用泛化的
    // class 选择器——Banner 的关闭按钮内部也复用了 IconButton（size="small"
    // 默认值，且同样用"关闭"作为 aria-label），泛化选择器/重名 label 都会命中
    // 多个元素触发 Playwright 严格模式报错，这里用 theme-solid 组合限定范围。
    const dangerSolid = page.locator('button.lotus-icon-button-theme-solid[aria-label="关闭"]');
    const outline = page.getByRole('button', { name: '搜索', exact: true });
    const large = page.getByRole('button', { name: '新增（large）', exact: true });
    const small = page.getByRole('button', { name: '确认（small）', exact: true });

    await expect(dangerSolid).toHaveClass(/lotus-icon-button-danger/);
    await expect(dangerSolid).toHaveClass(/lotus-icon-button-theme-solid/);
    await expect(outline).toHaveClass(/lotus-icon-button-theme-outline/);
    await expect(large).toHaveClass(/lotus-icon-button-size-large/);
    await expect(small).toHaveClass(/lotus-icon-button-size-small/);
  });

  test('图标按钮为正方形（宽高相等）', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: '设置', exact: true });
    const box = await button.boundingBox();

    expect(box).not.toBeNull();
    expect(box!.width).toBeCloseTo(box!.height, 0);
  });

  test('children：传入文本后不再是恒定正方形，iconPosition 控制图标相对文本的位置（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');

    const leftIcon = page.getByRole('button', { name: '图标在左' });
    const box = await leftIcon.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBeGreaterThan(box!.height * 1.5);

    const children = await leftIcon.evaluate((el) => Array.from(el.children).map((c) => c.className));
    expect(children[0]).toContain('lotus-icon-button-icon');
    expect(children[1]).toContain('lotus-icon-button-content');

    const rightIcon = page.getByRole('button', { name: '图标在右' });
    const rightChildren = await rightIcon.evaluate((el) => Array.from(el.children).map((c) => c.className));
    expect(rightChildren[0]).toContain('lotus-icon-button-content');
    expect(rightChildren[1]).toContain('lotus-icon-button-icon');
  });

  test('noHorizontalPadding：指定方向的内边距被清零（对齐 Semi，回归防护：与 Button 同一实现路径）', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: '无左侧内边距' });
    await expect(button).toHaveCSS('padding-left', '0px');
  });

  test('contentClassName：透传给文本内容包裹层（对齐 Semi）', async ({ page }) => {
    await page.goto('/');
    const button = page.getByRole('button', { name: '自定义内容类名' });
    const content = button.locator('.lotus-icon-button-content');
    await expect(content).toHaveClass(/icon-button-custom-content/);
  });
});
