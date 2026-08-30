---
title: Image 图片
category: 展示类
---

带加载态、加载失败兜底、点击放大预览的图片容器；`ImagePreviewGroup` 支持多图分组预览与切换。

## 代码演示

### 如何引入

```tsrx
import { Image, ImagePreviewGroup } from '@lotus/ripple';
```

### 基本用法

默认 `preview={true}`，点击图片弹出放大预览层，支持缩放/旋转/下载/关闭。

```tsrx demo
../../src/demos/show/image/basic.tsrx
```

### 预览组

`ImagePreviewGroup` 包裹多张 `Image` 后，预览层支持上一张/下一张切换。

```tsrx demo
../../src/demos/show/image/preview-group.tsrx
```

## API 参考

### Image

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| alt | 图片替代文本 | string | - |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| fallback | 加载失败时的兜底展示（图片地址或自定义内容） | `string \| any` | - |
| height | 高度 | `string \| number` | - |
| imgClass | 内部 `<img>` 类名 | string | - |
| imgStyle | 内部 `<img>` 自定义样式 | object | - |
| placeholder | 加载中的占位内容（不传则默认展示骨架屏） | any | - |
| preview | 是否支持点击预览 | boolean | `true` |
| previewSrc | 预览层展示的图片地址（不传则用 `src`，用于缩略图与高清图分离场景） | string | - |
| src | 图片地址 | string | - |
| style | 外层容器自定义样式 | object | - |
| width | 宽度 | `string \| number` | - |
| onClick | 点击图片时的回调 | `(event: MouseEvent) => void` | - |
| onError | 加载失败时的回调 | `(event: Event) => void` | - |
| onLoad | 加载成功时的回调 | `(event: Event) => void` | - |

### ImagePreviewGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 内部的 `Image` 组件 | any | - |
| closeOnEsc | 是否支持 Esc 关闭 | boolean | - |
| currentIndex | 受控的当前预览索引 | number | - |
| defaultCurrentIndex | 非受控模式下的默认索引 | number | - |
| infinite | 上一张/下一张是否循环切换 | boolean | - |
| maskClosable | 点击遮罩是否关闭 | boolean | - |
| src | 图片地址数组（不传则从 `children` 里的 `Image` 自动收集） | string[] | - |
| zIndex | 预览层层级 | number | - |
| onIndexChange | 预览索引变化时的回调 | `(index: number) => void` | - |
| onVisibleChange | 预览层显示/隐藏变化时的回调 | `(visible: boolean, index: number) => void` | - |

## Accessibility

- 预览层容器携带 `role="dialog"`。
- 上一张/下一张/放大/缩小/旋转/下载/关闭按钮均携带来自 `@lotus/locale` 的本地化 `aria-label`。
- `closeOnEsc` 开启时支持键盘 Esc 关闭预览层。

## 设计变量

- `--lotus-color-overlay-bg`（预览遮罩背景）
- `--lotus-color-bg-1`
- `--lotus-border-radius-medium`
