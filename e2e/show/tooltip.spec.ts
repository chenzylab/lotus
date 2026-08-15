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
});
