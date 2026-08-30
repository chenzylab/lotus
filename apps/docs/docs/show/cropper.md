---
title: Cropper 图片裁剪
category: 展示类
---

拖拽调整裁切框位置/大小、缩放、旋转，命令式导出裁切结果 canvas。

## 代码演示

### 如何引入

```tsrx
import { Cropper } from '@lotus/ripple';
```

### 基本用法

Ripple 没有 ref 转发到自定义实例的机制，改用 `getCropperApi` 回调拿到命令式 API（对齐 `Form` 的 `getFormApi` 同一模式），通过 `getCropperCanvas()` 取出当前裁切结果。

```tsrx demo
../../src/demos/show/cropper/basic.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| aspectRatio | 受控的裁切框宽高比 | number | - |
| class | 类名 | string | - |
| defaultAspectRatio | 非受控模式下的默认宽高比 | number | `1` |
| fill | 裁切框外遮罩颜色 | string | `'rgba(0,0,0,0)'` |
| getCropperApi | 获取命令式 API（`getCropperCanvas`） | `(api: CropperApi) => void` | - |
| maxZoom | 最大缩放倍数 | number | `3` |
| minZoom | 最小缩放倍数 | number | `0.1` |
| onCrop | 裁切框/缩放/旋转任一变化后即时触发，携带一次性算好的 canvas（Semi 没有声明式裁切回调，这是 lotus 主动新增的能力） | `(canvas: HTMLCanvasElement) => void` | - |
| onZoomChange | 缩放变化时的回调 | `(zoom: number) => void` | - |
| rotate | 旋转角度（度） | number | `0` |
| shape | 裁切框形状 | `'rect' \| 'round' \| 'roundRect'` | `'rect'` |
| showResizeBox | 是否显示裁切框缩放手柄 | boolean | `true` |
| src | 图片地址 | string | 必填 |
| style | 自定义样式 | object | - |
| zoom | 受控的缩放倍数 | number | - |
| zoomStep | 每次缩放的步长 | number | `0.1` |

`CropperApi.getCropperCanvas()` 返回 `HTMLCanvasElement | null`，跨域图片会因浏览器的 canvas 污染保护而无法导出（`SecurityError`），生产环境需确保图片同源或正确配置 CORS。

## Accessibility

- 裁切框八个缩放手柄支持键盘方向键微调（步长 `KEYBOARD_STEP`），不是只能鼠标拖拽操作。
- 裁切框整体携带来自 `@lotus/locale` 的本地化 `aria-label`。

## 设计变量

- `--lotus-color-primary`（裁切框描边色）
- `--lotus-color-border`
