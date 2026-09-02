import { test, expect } from '@playwright/test';
import path from 'node:path';
import fs from 'node:fs';
import os from 'node:os';

function makeTempFile(name: string, content: string): string {
  const filePath = path.join(os.tmpdir(), name);
  fs.writeFileSync(filePath, content);
  return filePath;
}

function makeTempPng(name: string): string {
  // 1x1 像素的最小 PNG（十六进制硬编码，避免引入图片处理依赖）。
  const base64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
  const filePath = path.join(os.tmpdir(), name);
  fs.writeFileSync(filePath, Buffer.from(base64, 'base64'));
  return filePath;
}

test.describe('Upload', () => {
  test('基础用法：选择文件后进入上传列表，最终状态为 success', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 基础', { exact: true });
    const filePath = makeTempFile('e2e-upload-basic.txt', 'hello upload');
    await root.locator('input[type="file"]').first().setInputFiles(filePath);

    const card = root.locator('.lotus-upload-file-card');
    await expect(card).toHaveCount(1);
    await expect(card.locator('.lotus-upload-file-name')).toHaveText('e2e-upload-basic.txt');
    await expect(card).toHaveClass(/lotus-upload-file-card-success/, { timeout: 3000 });
    await expect(page.getByLabel('Upload 事件日志', { exact: true })).toContainText('变化：1 个文件');
  });

  test('移除文件：点击移除按钮后文件从列表消失', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 基础', { exact: true });
    const filePath = makeTempFile('e2e-upload-remove.txt', 'to be removed');
    await root.locator('input[type="file"]').first().setInputFiles(filePath);
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(1);

    await root.getByLabel('移除 e2e-upload-remove.txt', { exact: true }).click();
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(0);
  });

  test('受控：onChange 拒绝更新时移除文件不会把 UI 带偏（回归防护：曾经受控模式下移除直接写本地 state，父组件拒绝更新后 UI 永久停留在操作产生的中间态，同一根因 bug 已在 Cascader/TreeSelect/Rating 组件真机验证过，详见 specs 踩坑 #100）', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 受控拒绝更新示例', { exact: true });
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(1);

    await root.getByLabel('移除 locked.png', { exact: true }).click();
    await page.waitForTimeout(300);
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(1);
    await expect(root.locator('.lotus-upload-file-name')).toHaveText('locked.png');
  });

  test('draggable：拖拽区域可见，role=button 且带 tabindex=0 语义标记', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 拖拽', { exact: true });
    const dragArea = root.locator('.lotus-upload-drag-area');
    await expect(dragArea).toHaveAttribute('role', 'button');
    await expect(dragArea).toHaveAttribute('tabindex', '0');
  });

  test('键盘无障碍：聚焦拖拽区后按 Enter 真正打开文件选择器（回归防护：此前同名测试"键盘可达"只断言过 role/tabindex 两个静态属性，从未真正按键验证过 handleTriggerKeyDown 是否被触发）', async ({ page }) => {
    await page.goto('/');
    const dragRoot = page.getByLabel('Upload 拖拽', { exact: true });
    const dragArea = dragRoot.locator('.lotus-upload-drag-area');
    await dragArea.scrollIntoViewIfNeeded();

    // 用元素级别的 locator.press（事件直接派发到该元素）而非
    // page.keyboard.press（全局键盘事件，依赖"当前恰好拥有焦点的元素"），
    // 排除 focus() 与全局按键之间可能存在的焦点丢失窗口。
    const chooserPromise = page.waitForEvent('filechooser');
    await dragArea.press('Enter');
    const chooser = await chooserPromise;
    expect(chooser).toBeTruthy();
  });

  test('键盘无障碍：聚焦拖拽区后按 Space 真正打开文件选择器', async ({ page }) => {
    await page.goto('/');
    const dragRoot = page.getByLabel('Upload 拖拽', { exact: true });
    const dragArea = dragRoot.locator('.lotus-upload-drag-area');
    await dragArea.scrollIntoViewIfNeeded();

    const chooserPromise = page.waitForEvent('filechooser');
    await dragArea.press(' ');
    const chooser = await chooserPromise;
    expect(chooser).toBeTruthy();
  });

  test('draggable：拖拽释放文件后进入上传列表', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 拖拽', { exact: true });
    const filePath = makeTempFile('e2e-upload-drag.txt', 'dragged content');

    const dragArea = root.locator('.lotus-upload-drag-area');
    const buffer = fs.readFileSync(filePath);
    const dataTransfer = await page.evaluateHandle(
      ({ fileName, base64 }) => {
        const dt = new DataTransfer();
        const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
        const file = new File([bytes], fileName, { type: 'text/plain' });
        dt.items.add(file);
        return dt;
      },
      { fileName: 'e2e-upload-drag.txt', base64: buffer.toString('base64') },
    );
    await dragArea.dispatchEvent('dragenter', { dataTransfer });
    await dragArea.dispatchEvent('drop', { dataTransfer });

    const card = root.locator('.lotus-upload-file-card');
    await expect(card).toHaveCount(1);
    await expect(card.locator('.lotus-upload-file-name')).toHaveText('e2e-upload-drag.txt');
  });

  test('listType=picture：上传图片后渲染缩略图，multiple 支持多选', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 图片墙', { exact: true });
    const input = root.locator('input[type="file"]').first();
    await expect(input).toHaveAttribute('multiple', '');
    await expect(input).toHaveAttribute('accept', 'image/*');

    const pngPath = makeTempPng('e2e-upload.png');
    await input.setInputFiles(pngPath);
    const card = root.locator('.lotus-upload-file-card');
    await expect(card).toHaveClass(/lotus-upload-file-card-picture/);
    await expect(card.locator('.lotus-upload-file-thumbnail-img')).toBeVisible({ timeout: 3000 });
  });

  test('limit + maxSize：超出大小限制的文件标记为 validateFail 并显示错误信息', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 限制', { exact: true });
    const bigFilePath = path.join(os.tmpdir(), 'e2e-upload-big.bin');
    fs.writeFileSync(bigFilePath, Buffer.alloc(6 * 1024 * 1024, 0));

    await root.locator('input[type="file"]').first().setInputFiles(bigFilePath);
    const card = root.locator('.lotus-upload-file-card');
    await expect(card).toHaveClass(/lotus-upload-file-card-validateFail/);
    await expect(card.locator('.lotus-upload-file-error-msg')).toHaveText('文件大小超出限制');
  });

  test('disabled：整体禁用时文件输入框和操作按钮不可交互', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 禁用', { exact: true });
    await expect(root.locator('input[type="file"]').first()).toBeDisabled();
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(1);
    await expect(root.locator('.lotus-upload-file-name')).toHaveText('readonly.png');
  });

  test('validateStatus=error + prompt：展示校验错误信息与提示文案', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload beforeRemove 示例', { exact: true });
    await expect(root.locator('.lotus-upload-validate-message')).toHaveText('至少上传一个文件');
    await expect(root.locator('.lotus-upload-prompt-bottom')).toHaveText('支持 jpg/png，单个文件不超过 5MB');
  });

  test('showClear + beforeRemove + onPreviewClick + onSizeError：完整的高级钩子链路', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload beforeRemove 示例', { exact: true });
    const log = page.getByLabel('Upload 高级事件日志', { exact: true });
    const filePath = makeTempFile('e2e-upload-advanced.txt', 'advanced hooks');
    await root.locator('input[type="file"]').first().setInputFiles(filePath);

    await expect(root.locator('.lotus-upload-file-list-header')).toBeVisible();
    const clearBtn = root.getByLabel('清空文件列表', { exact: true });
    await expect(clearBtn).toBeVisible();

    await root.locator('.lotus-upload-file-thumbnail').click();
    await expect(log).toContainText('预览：e2e-upload-advanced.txt');

    await root.getByLabel('移除 e2e-upload-advanced.txt', { exact: true }).click();
    await expect(log).toContainText('尝试移除：e2e-upload-advanced.txt');
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(0);

    const bigFilePath = path.join(os.tmpdir(), 'e2e-upload-advanced-big.bin');
    fs.writeFileSync(bigFilePath, Buffer.alloc(6 * 1024 * 1024, 0));
    await root.locator('input[type="file"]').first().setInputFiles(bigFilePath);
    await expect(log).toContainText('文件过大：e2e-upload-advanced-big.bin');
  });

  test('renderFileItem：完全自定义文件项渲染，替换默认卡片', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload renderFileItem 示例', { exact: true });
    await expect(root.locator('.lotus-upload-file-card')).toHaveCount(0);
    await expect(root.locator('.lotus-upload-file-card-custom')).toContainText('★ report.pdf（success）');
    await root.locator('.lotus-upload-file-card-custom button').click();
    await expect(root.locator('.lotus-upload-file-card-custom')).toHaveCount(0);
  });

  test('picture：showPicInfo 默认关闭时不展示文件名/大小 meta 信息', async ({ page }) => {
    await page.goto('/');
    const root = page.getByLabel('Upload 图片墙', { exact: true });
    const pngPath = makeTempPng('e2e-upload-picinfo.png');
    await root.locator('input[type="file"]').first().setInputFiles(pngPath);
    const card = root.locator('.lotus-upload-file-card').last();
    await expect(card.locator('.lotus-upload-file-meta')).toHaveCount(0);
  });
});
