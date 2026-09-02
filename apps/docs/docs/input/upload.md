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

### 高级钩子与自定义渲染

`beforeRemove`/`beforeClear` 支持异步确认拦截移除/清空；`showClear` 展示清空按钮；`onPreviewClick`/`onSizeError` 提供更细粒度的事件；`renderFileItem` 完全自定义文件项渲染。

```tsrx demo
../../src/demos/input/upload/advanced-hooks.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| accept | 限制可选择的文件类型（原生 `accept` 属性） | string | - |
| action | 上传目标地址 | string | 必填 |
| addOnPasting | 是否支持从剪贴板粘贴文件（全局监听 `document.body` 的 paste 事件） | boolean | `false` |
| aria-label | 设置 aria-label 属性 | string | - |
| beforeClear | 清空前的确认钩子，返回 `false`/`Promise<false>` 阻止清空 | `(fileList) => boolean \| Promise<boolean>` | - |
| beforeRemove | 移除前的确认钩子，返回 `false`/`Promise<false>` 阻止移除 | `(file, fileList) => boolean \| Promise<boolean>` | - |
| beforeUpload | 上传前的校验/转换钩子，返回 `false` 阻止上传 | `(file, fileItem) => boolean \| BeforeUploadResult \| Promise<...>` | - |
| capture | 移动端拍照/录制来源 | `boolean \| 'user' \| 'environment'` | - |
| class | 类名 | string | - |
| customRequest | 自定义上传实现，接管默认的网络请求逻辑 | `(args: CustomRequestArgs) => void` | - |
| data | 附加到请求的额外字段 | `Record<string, unknown> \| ((file) => Record<string, unknown>)` | - |
| defaultFileList | 非受控模式下的默认文件列表 | `FileItem[]` | - |
| directory | 是否支持选择整个目录上传 | boolean | `false` |
| disabled | 是否禁用 | boolean | `false` |
| draggable | 是否支持拖拽上传 | boolean | `false` |
| dragIcon | 拖拽区域自定义图标 | any | - |
| dragMainText / dragSubText | 拖拽区域主/副文案 | string | 本地化默认值 |
| fileList | 受控的文件列表 | `FileItem[]` | - |
| fileName | 请求中文件字段名（`name` 的别名，用于规避与 `Form.Upload` 的 `name` prop 冲突） | string | - |
| headers | 请求头 | `UploadHeaders \| ((file) => UploadHeaders)` | - |
| hotSpotLocation | 操作按钮（重试/替换/删除）的排列位置 | `'start' \| 'end'` | `'end'` |
| itemStyle | 文件卡片自定义内联样式 | object | - |
| limit | 最多允许的文件数量 | number | - |
| listType | 文件列表展示形态 | `'list' \| 'picture' \| 'none'` | `'list'` |
| maxSize / minSize | 单文件大小上/下限（字节） | number | - |
| multiple | 是否允许一次选择多个文件 | boolean | `false` |
| name | 请求中文件字段名 | string | - |
| picHeight / picWidth | 图片墙模式下卡片高/宽 | `string \| number` | - |
| previewFile | 自定义缩略图渲染 | `(props: RenderFileItemProps) => any` | - |
| prompt | 提示文案 | any | - |
| promptPosition | 提示文案位置 | `'left' \| 'right' \| 'bottom'` | `'right'` |
| renderFileItem | 完全自定义单个文件项渲染，替换默认卡片 | `(props: RenderFileItemProps) => any` | - |
| showClear | 是否展示清空按钮 | boolean | `false` |
| showPicInfo | 图片墙模式下是否展示文件名/大小信息 | boolean | `false` |
| showReplace | 是否展示替换按钮 | boolean | - |
| showRetry | 上传失败时是否展示重试按钮 | boolean | - |
| showTooltip | 是否在文件名上展示完整文件名 tooltip | boolean | `true` |
| showUploadList | 是否展示文件列表 | boolean | `true` |
| timeout | 请求超时时间（毫秒），真正接入 `xhr.timeout` | number | - |
| transformFile | 自定义 File → FileItem 转换 | `(file: File) => FileItem` | - |
| uploadTrigger | 上传触发方式 | `'auto' \| 'custom'` | `'auto'` |
| validateMessage | 校验错误信息，配合 `validateStatus="error"` 展示 | any | - |
| validateStatus | 校验状态，仅影响展示样式 | `'default' \| 'error' \| 'warning' \| 'success'` | `'default'` |
| withCredentials | 请求是否携带 cookie | boolean | `false` |
| afterUpload | 上传成功后的覆盖钩子，可修改 status/name/url 或 autoRemove | `(args) => AfterUploadResult \| void` | - |
| onAcceptInvalid | 文件类型不匹配 `accept` 时的回调 | `(files: File[]) => void` | - |
| onChange | 文件列表变化时的回调 | `(fileList: FileItem[]) => void` | - |
| onClear | 清空文件列表后的回调 | `() => void` | - |
| onDrop | 拖拽释放文件时的回调 | `(event, files, fileList) => void` | - |
| onError | 上传失败时的回调 | `(error: unknown, file: FileItem) => void` | - |
| onExceed | 超过 `limit` 时的回调 | `(files: File[]) => void` | - |
| onFileChange | 文件被选中（选择器/拖拽/粘贴均触发）时的回调 | `(files: File[]) => void` | - |
| onOpenFileDialog | 打开文件选择器时的回调 | `() => void` | - |
| onPastingError | 粘贴上传出错时的回调 | `(error: Error) => void` | - |
| onPreviewClick | 点击文件缩略图时的回调 | `(file: FileItem) => void` | - |
| onProgress | 上传进度变化时的回调 | `(percent: number, file: FileItem) => void` | - |
| onRemove | 移除文件时的回调 | `(file: FileItem, fileList: FileItem[]) => void` | - |
| onRetry | 点击重试时的回调 | `(file: FileItem) => void` | - |
| onSizeError | 文件大小校验失败时的回调 | `(file: FileItem, fileList: FileItem[]) => void` | - |
| onSuccess | 上传成功时的回调 | `(response: unknown, file: FileItem) => void` | - |

`FileItem` 结构：`{ uid, name, size?, status?, percent?, url? }`；`status` 取值 `'wait' | 'uploading' | 'success' | 'uploadFail' | 'validateFail'`。

> 明确不做：`crop`/`beforeCrop`/`onCropError`/`cropModalProps` 等裁剪相关能力——lotus 已有独立的 `Cropper` 组件，不在 Upload 内重复实现。不做并发队列/pause/abort——Semi 本身没有这些能力。

## Accessibility

- 拖拽区域与触发按钮均携带 `role="button"`、`tabIndex`，支持 Enter/Space 键盘触发（对齐已验证的键盘无障碍增强方案）。
- 文件列表容器携带 `role="list"` 与本地化 `aria-label`（`@lotus/locale` 的 `Upload.fileListLabel`）；每个文件项携带 `role="listitem"`。
- 进度、重试、替换、移除、清空按钮均携带本地化 `aria-label`（对应文件名动态生成）。
- `renderFileItem` 完全自定义渲染时，无障碍语义（`role="listitem"`）由外层容器保留，自定义内容本身的语义需调用方自行保证。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-primary`（拖拽悬停态/进度条）
- `--lotus-color-fill-0`
- `--lotus-color-danger`（错误态）
- `--lotus-color-success`（成功态）
- `--lotus-color-text-0` / `-text-2`
- `--lotus-border-radius-small` / `-medium`
