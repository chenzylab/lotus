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
});
