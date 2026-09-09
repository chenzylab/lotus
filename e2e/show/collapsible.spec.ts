import { test, expect } from '@playwright/test';

test.describe('Collapsible', () => {
  test('isOpen=false 且 keepDOM=false（默认）时，内容不渲染到 DOM（.lotus-collapsible-inner 作为 ResizeObserver 测量点常驻，但不含子内容）', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    await expect(collapsible.locator('.lotus-collapsible-inner')).toBeEmpty();
  });

  test('点击外部按钮切换 isOpen 后，内容动态挂载/卸载（非 keepDOM 场景）', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮', { exact: true });

    await button.click();
    await expect(collapsible.locator('.lotus-collapsible-inner')).not.toBeEmpty();
    await expect(collapsible).toContainText('这是任意内容');

    await button.click();
    await expect(collapsible.locator('.lotus-collapsible-inner')).toBeEmpty({ timeout: 2000 });
  });

  test('keepDOM=true 时，收起状态下内容仍在 DOM 中（不销毁重建）', async ({ page }) => {
    await page.goto('/');
    const keepDOM = page.getByLabel('keepDOM Collapsible');
    await expect(keepDOM.locator('.lotus-collapsible-inner')).toHaveCount(1);
    await expect(keepDOM).toContainText('收起后这段内容仍在 DOM 中');
  });

  test('isOpen 变化时用真实测得的内容高度驱动 height 过渡（不是 max-height 近似值）', async ({ page }) => {
    await page.goto('/');
    const keepDOM = page.getByLabel('keepDOM Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮', { exact: true });

    const collapsedHeight = await keepDOM.evaluate((el) => getComputedStyle(el).height);
    expect(collapsedHeight).toBe('0px');

    await button.click();
    await expect(async () => {
      const expandedHeight = await keepDOM.evaluate((el) => getComputedStyle(el).height);
      expect(expandedHeight).not.toBe('0px');
    }).toPass();

    const innerHeight = await keepDOM.locator('.lotus-collapsible-inner').evaluate((el) => el.scrollHeight);
    const finalHeight = await keepDOM.evaluate((el) => parseFloat(getComputedStyle(el).height));
    expect(finalHeight).toBeCloseTo(innerHeight, 0);
  });

  test('collapseHeightAdaptive：内容真实高度小于声明的 collapseHeight 时，收起态用真实高度而非硬撑声明值', async ({ page }) => {
    await page.goto('/');
    const adaptive = page.getByLabel('collapseHeightAdaptive Collapsible');
    const innerHeight = await adaptive.locator('.lotus-collapsible-inner').evaluate((el) => el.scrollHeight);
    const collapsedHeight = await adaptive.evaluate((el) => parseFloat(getComputedStyle(el).height));
    expect(collapsedHeight).toBeCloseTo(innerHeight, 0);
  });

  test('lazyRender：首次收起态不渲染内容，展开一次后即使收起也保留 DOM', async ({ page }) => {
    await page.goto('/');
    const lazy = page.getByLabel('lazyRender Collapsible');
    const button = page.getByLabel('lazyRender Collapsible 触发按钮');

    await expect(lazy.locator('.lotus-collapsible-inner')).toBeEmpty();

    await button.click();
    await expect(lazy.locator('.lotus-collapsible-inner')).not.toBeEmpty();

    await button.click();
    await expect(lazy.locator('.lotus-collapsible-inner')).not.toBeEmpty();
  });

  test('aria-hidden 随 isOpen 状态同步', async ({ page }) => {
    await page.goto('/');
    const collapsible = page.getByLabel('基础 Collapsible');
    const button = page.getByLabel('Collapsible 触发按钮', { exact: true });

    await expect(collapsible).toHaveAttribute('aria-hidden', 'true');
    await button.click();
    await expect(collapsible).toHaveAttribute('aria-hidden', 'false');
  });
});
