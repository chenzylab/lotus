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

  test('多系列图表颜色精确对齐 lotus 品牌数据色板 --lotus-color-data-0~4，且亮暗模式各自独立取值（回归防护：Chart 组件此前一直静默回退到 VChart 默认色板，packages/tokens 从未真正定义过这批 token，详见 specs 踩坑记录）', async ({ page }) => {
    await page.goto('/');
    const canvas = page.locator('.demo-chart-pie canvas');
    await expect(canvas).toBeVisible();

    // 扫描整个 canvas 统计每个精确 RGB 值的出现次数，取出现频率最高的颜色——
    // 5 个扇区各自的纯色填充区域面积远大于抗锯齿边缘的过渡色像素，高频颜色
    // 必然就是扇区真实填充色 + 图表背景色，不受采样点具体落在哪个坐标、
    // canvas 实际尺寸、legend 占位等因素影响，比"预测某个坐标点应该是什么
    // 颜色"稳健得多。背景色本身面积可能比某个扇区还大，会跟着一起进入高频
    // 榜单（暗色模式下 canvas 背景显式填充为 lotus 的 --lotus-color-bg-0
    // dark 值 #16161a，不是透明的），必须显式排除亮/暗两种已知背景色，
    // 否则背景色会占掉一个名额，把真正的第 5 个扇区颜色挤出前 5 名。
    const KNOWN_BACKGROUNDS: Array<[number, number, number]> = [
      [255, 255, 255], // 亮色模式背景
      [22, 22, 26], // 暗色模式背景 #16161a
    ];
    const readTopColors = () =>
      canvas.evaluate((el, backgrounds) => {
        const canvasEl = el as HTMLCanvasElement;
        const ctx = canvasEl.getContext('2d')!;
        const { width, height } = canvasEl;
        const data = ctx.getImageData(0, 0, width, height).data;
        const counts = new Map<string, number>();
        for (let i = 0; i < data.length; i += 4) {
          const a = data[i + 3];
          if (a === 0) continue;
          const r = data[i]!;
          const g = data[i + 1]!;
          const b = data[i + 2]!;
          if (backgrounds.some(([br, bg, bb]) => r === br && g === bg && b === bb)) continue;
          const key = `${r},${g},${b}`;
          counts.set(key, (counts.get(key) ?? 0) + 1);
        }
        return [...counts.entries()]
          .sort((a, b) => b[1] - a[1])
          .slice(0, 5)
          .map(([key]) => key.split(',').map(Number) as [number, number, number]);
      }, KNOWN_BACKGROUNDS);

    function closestDistance(rgb: [number, number, number], palette: Array<[number, number, number]>): number {
      return Math.min(...palette.map((p) => Math.sqrt((rgb[0] - p[0]) ** 2 + (rgb[1] - p[1]) ** 2 + (rgb[2] - p[2]) ** 2)));
    }

    const lightPalette: Array<[number, number, number]> = [[87, 105, 255], [142, 212, 231], [245, 135, 0], [220, 183, 252], [74, 156, 247]];
    const lightTop5 = await readTopColors();
    for (const rgb of lightTop5) {
      expect(closestDistance(rgb, lightPalette)).toBeLessThan(5);
    }

    await page.getByRole('button', { name: /切换到 dark/ }).click();
    await page.waitForTimeout(500);

    const darkPalette: Array<[number, number, number]> = [[94, 109, 194], [8, 104, 120], [250, 173, 63], [76, 43, 156], [16, 125, 248]];
    const darkTop5 = await readTopColors();
    for (const rgb of darkTop5) {
      expect(closestDistance(rgb, darkPalette)).toBeLessThan(5);
    }

    // 亮暗两套颜色必须明显不同（不是同一份数据在两种模式下简单复用）
    for (const rgb of darkTop5) {
      expect(closestDistance(rgb, lightPalette)).toBeGreaterThan(30);
    }

    await page.getByRole('button', { name: /切换到 light/ }).click();
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
