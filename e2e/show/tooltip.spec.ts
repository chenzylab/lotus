import { test, expect } from '@playwright/test';

test.describe('Tooltip', () => {
  test('click 触发：点击后浮层出现并显示对应内容', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click bottom' });
    await trigger.click();

    const tooltip = page.getByRole('tooltip', { name: '点击触发' });
    await expect(tooltip).toBeVisible();
  });

  test('hover 触发：移入后延迟显示，浮层内容与 position 对应', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'hover top' });
    await trigger.hover();

    const tooltip = page.getByRole('tooltip', { name: 'hover 触发' });
    await expect(tooltip).toBeVisible();
  });

  test('condition=false 时 hover 不触发浮层', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'condition off' });
    await trigger.hover();
    await page.waitForTimeout(200);

    const tooltip = page.getByRole('tooltip', { name: 'condition=false 不响应' });
    await expect(tooltip).toHaveCount(0);
  });

  test('浮层通过 Portal 渲染在 document.body 下，不嵌套在触发按钮内部', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'click bottom' });
    await trigger.click();

    const tooltip = page.getByRole('tooltip', { name: '点击触发' });
    const isDirectBodyDescendant = await tooltip.evaluate((el) => {
      let node = el.parentElement;
      while (node) {
        if (node.classList.contains('lotus-tooltip-trigger')) return false;
        node = node.parentElement;
      }
      return true;
    });
    expect(isDirectBodyDescendant).toBe(true);
  });

  test('motion 默认开启：关闭后浮层带 leave 动画短暂保留在 DOM 中，动画结束后才移除（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'Tooltip motion 默认示例触发器' });
    await trigger.click();

    const tooltip = page.getByRole('tooltip', { name: '默认开启 motion' });
    await expect(tooltip).toHaveClass(/lotus-tooltip-enter/);

    await trigger.click();
    await expect(tooltip).toHaveClass(/lotus-tooltip-leave/);
    await expect(tooltip).toHaveCount(0, { timeout: 1000 });
  });

  test('motion=false：关闭后浮层立即从 DOM 移除，不经过 leave 动画阶段（对齐 Semi，此前 lotus 完全没有实现）', async ({ page }) => {
    await page.goto('/');
    const trigger = page.getByRole('button', { name: 'Tooltip motion 关闭示例触发器' });
    await trigger.click();

    const tooltip = page.getByRole('tooltip', { name: 'motion 关闭' });
    await expect(tooltip).toBeVisible();
    await expect(tooltip).not.toHaveClass(/lotus-tooltip-enter/);

    await trigger.click();
    await expect(tooltip).toHaveCount(0);
  });
});
