---
title: Upload 上传
category: 输入类
---

文件上传，支持点击/拖拽触发、图片墙展示、数量与大小限制、进度反馈。

## 代码演示

### 如何引入

```tsrx
import { Upload } from '@lotus/ripple';
```

### 基本用法

`customRequest` 自定义上传实现（本页演示环境用它模拟上传进度，不发起真实网络请求；生产环境可省略，Upload 会用内置逻辑向 `action` 发起真实请求）。

```tsrx demo
../../src/demos/input/upload/basic.tsrx
```

### 图片墙 + 多选

`listType="picture"` 展示图片缩略图墙；`multiple` 允许一次选择多个文件。

```tsrx demo
../../src/demos/input/upload/picture.tsrx
```

### 数量与大小限制

`limit` 限制文件总数，超出触发 `onExceed`；`maxSize`/`minSize` 限制单文件大小（字节）。

```tsrx demo
../../src/demos/input/upload/limit.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| accept | 限制可选择的文件类型（原生 `accept` 属性） | string | - |
| action | 上传目标地址 | string | 必填 |
| aria-label | 设置 aria-label 属性 | string | - |
| beforeUpload | 上传前的校验/转换钩子，返回 `false` 阻止上传 | `(file, fileItem) => boolean \| BeforeUploadResult \| Promise<...>` | - |
| class | 类名 | string | - |
| customRequest | 自定义上传实现，接管默认的网络请求逻辑 | `(args: CustomRequestArgs) => void` | - |
| data | 附加到请求的额外字段 | `Record<string, unknown> \| ((file) => Record<string, unknown>)` | - |
| defaultFileList | 非受控模式下的默认文件列表 | `FileItem[]` | - |
| disabled | 是否禁用 | boolean | `false` |
| draggable | 是否支持拖拽上传 | boolean | `false` |
| dragMainText / dragSubText | 拖拽区域主/副文案 | string | 本地化默认值 |
| fileList | 受控的文件列表 | `FileItem[]` | - |
| headers | 请求头 | `UploadHeaders \| ((file) => UploadHeaders)` | - |
| limit | 最多允许的文件数量 | number | - |
| listType | 文件列表展示形态 | `'list' \| 'picture' \| 'none'` | `'list'` |
| maxSize / minSize | 单文件大小上/下限（字节） | number | - |
| multiple | 是否允许一次选择多个文件 | boolean | `false` |
| name | 请求中文件字段名 | string | - |
| showReplace | 是否展示替换按钮 | boolean | - |
| showRetry | 上传失败时是否展示重试按钮 | boolean | - |
| uploadTrigger | 上传触发方式 | `'auto' \| 'custom'` | `'auto'` |
| withCredentials | 请求是否携带 cookie | boolean | `false` |
| onAcceptInvalid | 文件类型不匹配 `accept` 时的回调 | `(files: File[]) => void` | - |
| onChange | 文件列表变化时的回调 | `(fileList: FileItem[]) => void` | - |
| onError | 上传失败时的回调 | `(error: unknown, file: FileItem) => void` | - |
| onExceed | 超过 `limit` 时的回调 | `(files: File[]) => void` | - |
| onProgress | 上传进度变化时的回调 | `(percent: number, file: FileItem) => void` | - |
| onRemove | 移除文件时的回调 | `(file: FileItem, fileList: FileItem[]) => void` | - |
| onRetry | 点击重试时的回调 | `(file: FileItem) => void` | - |
| onSuccess | 上传成功时的回调 | `(response: unknown, file: FileItem) => void` | - |

`FileItem` 结构：`{ uid, name, size?, status?, percent?, url? }`；`status` 取值 `'uploading' | 'success' | 'error'`。

## Accessibility

- 拖拽区域与触发按钮均携带 `role="button"`、`tabIndex`，支持 Enter/Space 键盘触发（对齐已验证的键盘无障碍增强方案）。
- 文件列表容器携带 `role="list"` 与本地化 `aria-label`（`@lotus/locale` 的 `Upload.fileListLabel`）；每个文件项携带 `role="listitem"`。
- 进度、重试、替换、移除按钮均携带本地化 `aria-label`（对应文件名动态生成）。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-primary`（拖拽悬停态/进度条）
- `--lotus-color-fill-0`
- `--lotus-color-danger`（错误态）
- `--lotus-color-success`（成功态）
- `--lotus-color-text-0` / `-text-2`
- `--lotus-border-radius-small` / `-medium`
