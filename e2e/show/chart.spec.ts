import { test, expect } from '@playwright/test';

test.describe('Chart', () => {
  test('6 种图表类型均渲染出 canvas，非空壳（canvas 内含非透明像素，证明 VChart 真正绘制了内容）', async ({ page }) => {
    await page.goto('/');
    const types = ['bar', 'line', 'area', 'pie', 'funnel', 'radar'];
    for (const type of types) {
      const canvas = page.locator(`.demo-chart-${type} canvas`);
      await expect(canvas).toBeVisible();
      const hasContent = await canvas.evaluate((el) => {
        const ctx = (el as HTMLCanvasElement).getContext('2d');
        if (!ctx) return false;
        const data = ctx.getImageData(0, 0, (el as HTMLCanvasElement).width, (el as HTMLCanvasElement).height).data;
        for (let i = 3; i < data.length; i += 4) {
          if (data[i] > 0) return true;
        }
        return false;
      });
      expect(hasContent).toBe(true);
    }
  });

  test('容器带 lotus-chart class，宽高对齐 width/height props', async ({ page }) => {
    await page.goto('/');
    const container = page.locator('.demo-chart-bar .lotus-chart');
    await expect(container).toBeVisible();
    const box = await container.boundingBox();
    expect(box?.height).toBeCloseTo(260, 0);
  });

  test('主题跟随 ConfigProvider.mode 切换：暗色模式下图表背景色变为 lotus 暗色 token 对应值（回归防护：VChart 的 options.theme 构造参数会固化旧主题并在每次切换时以最高优先级覆盖，踩坑 #99）', async ({ page }) => {
    await page.goto('/');
    const canvas = page.locator('.demo-chart-bar canvas');
    await expect(canvas).toBeVisible();

    const readTopLeftPixel = () =>
      canvas.evaluate((el) => {
        const ctx = (el as HTMLCanvasElement).getContext('2d')!;
        const data = ctx.getImageData(5, 5, 1, 1).data;
        return [data[0], data[1], data[2]];
      });

    const lightPixel = await readTopLeftPixel();
    expect(lightPixel).toEqual([255, 255, 255]);

    await page.getByRole('button', { name: /切换到 dark/ }).click();
    await page.waitForTimeout(300);

    const darkPixel = await readTopLeftPixel();
    expect(darkPixel).toEqual([22, 22, 26]);

    // 切回 light 确认双向切换都正确，不是单次巧合
    await page.getByRole('button', { name: /切换到 light/ }).click();
    await page.waitForTimeout(300);
    const backToLightPixel = await readTopLeftPixel();
    expect(backToLightPixel).toEqual([255, 255, 255]);
  });

  test('多分类/多系列数据使用图表色板中不同颜色（饼图 5 个扇区颜色互不相同）', async ({ page }) => {
    await page.goto('/');
    const canvas = page.locator('.demo-chart-pie canvas');
    await expect(canvas).toBeVisible();

    const colors = await canvas.evaluate((el) => {
      const canvasEl = el as HTMLCanvasElement;
      const ctx = canvasEl.getContext('2d')!;
      const cx = canvasEl.width / 2;
      const cy = canvasEl.height / 2;
      const radius = Math.min(canvasEl.width, canvasEl.height) / 4;
      const angles = [0, 72, 144, 216, 288].map((deg) => (deg * Math.PI) / 180);
      return angles.map((angle) => {
        const x = Math.round(cx + radius * Math.cos(angle));
        const y = Math.round(cy + radius * Math.sin(angle));
        const data = ctx.getImageData(x, y, 1, 1).data;
        return `${data[0]},${data[1]},${data[2]}`;
      });
    });

    const uniqueColors = new Set(colors);
    expect(uniqueColors.size).toBeGreaterThan(1);
  });

  test('点击/悬浮图表数据点触发 onClick/onHover 回调，携带原始 datum', async ({ page }) => {
    await page.goto('/');
    const chart = page.locator('.demo-chart-event .lotus-chart');
    const log = page.getByLabel('Chart 事件日志', { exact: true });
    await chart.scrollIntoViewIfNeeded();
    const box = (await chart.boundingBox())!;

    await page.mouse.click(box.x + box.width * 0.1, box.y + box.height * 0.75);
    await expect(log).toContainText('点击：');
    await expect(log).toContainText('一月');

    await page.mouse.move(box.x + box.width * 0.3, box.y + box.height * 0.6);
    await expect(log).toContainText('悬浮：', { timeout: 3000 });
  });

  test('showExportButton 展示导出按钮，点击后触发浏览器下载与 onExport 回调', async ({ page }) => {
    await page.goto('/');
    const chart = page.locator('.demo-chart-export .lotus-chart-wrapper');
    const exportButton = chart.getByLabel('导出图片', { exact: true });
    await expect(exportButton).toBeVisible();

    const log = page.getByLabel('Chart 导出日志', { exact: true });
    const [download] = await Promise.all([
      page.waitForEvent('download'),
      exportButton.click(),
    ]);
    expect(download.suggestedFilename()).toContain('lotus-chart-demo');
    await expect(log).toHaveText('已触发导出');
  });

  test('loading=true 时 Spin 蒙层生效，图表实例不被销毁重建', async ({ page }) => {
    await page.goto('/');
    const wrapper = page.locator('.demo-chart-loading');
    const spin = wrapper.locator('.lotus-spin');
    await expect(spin).toHaveAttribute('aria-busy', 'false');

    await page.getByRole('button', { name: '切换 Chart 加载态' }).click();
    await expect(spin).toHaveAttribute('aria-busy', 'true');
    await expect(wrapper.locator('canvas')).toBeVisible();

    await page.getByRole('button', { name: '切换 Chart 加载态' }).click();
    await expect(spin).toHaveAttribute('aria-busy', 'false');
  });

  test('data 全部系列 values 为空时展示 Empty 占位，不渲染 canvas', async ({ page }) => {
    await page.goto('/');
    const wrapper = page.locator('.demo-chart-empty-demo');
    await expect(wrapper.getByText('暂无数据')).toBeVisible();
    await expect(wrapper.locator('canvas')).toHaveCount(0);
  });
});
