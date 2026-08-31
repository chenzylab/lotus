---
title: Skeleton 骨架屏
category: 反馈类
---

在需要等待加载内容的位置提供的占位组件。

## 概述

- `Avatar`：占位头像，默认为圆形，默认尺寸：Avatar medium：`width: 48px`，`height: 48px`。支持 Avatar 的 size、shape 属性。
- `Image`：占位图像，默认尺寸：`width: 100%`，`height: 100%`。
- `Title`：占位标题，默认尺寸：`width: 100%`，`height: 24px`。
- `Paragraph`：占位内容部分，默认尺寸：`width: 100%`，`height: 16px`，`margin-bottom: 10px`。
- `Button`：占位按钮，默认尺寸：`width: 115px`，`height: 32px`。

> 注意：默认样式均可通过 `class` 或 `style` 进行自定义。

lotus 只提供 Semi 的 `Skeleton.Avatar`/`Skeleton.Image`/`Skeleton.Title`/`Skeleton.Button`/`Skeleton.Paragraph`
对应的独立命名导出——`SkeletonAvatar`/`SkeletonImage`/`SkeletonTitle`/`SkeletonButton`/`SkeletonParagraph`。
Ripple 没有 children 反射能力，无法在运行时给 `Skeleton` 函数挂载 `Avatar`/`Image` 等静态属性，
这是在 Ripple 约束下的诚实设计取舍，与 lotus 里 `AvatarGroup`（而非 `Avatar.Group`）的先例一致。

## 代码演示

### 如何引入

```tsrx
import { Skeleton, SkeletonAvatar, SkeletonImage, SkeletonTitle, SkeletonButton, SkeletonParagraph } from '@lotus/ripple';
```

### 基本使用

```tsrx demo
../../src/demos/feedback/skeleton/basic.tsrx
```

### 组合使用

图片和标题。

```tsrx demo
../../src/demos/feedback/skeleton/combine-image-title.tsrx
```

统计数字。Semi 官方此处用 `Descriptions` 组件展示，lotus 尚未实现 Descriptions，用等价的原生
HTML 结构模拟同样的视觉效果，Skeleton 本身的用法不受影响。

```tsrx demo
../../src/demos/feedback/skeleton/combine-descriptions.tsrx
```

头像和标题。

```tsrx demo
../../src/demos/feedback/skeleton/combine-avatar-title.tsrx
```

居中段落和按钮。

```tsrx demo
../../src/demos/feedback/skeleton/combine-centered.tsrx
```

头像、标题和段落。

```tsrx demo
../../src/demos/feedback/skeleton/combine-avatar-title-paragraph.tsrx
```

表格。Semi 官方此处用 `Table` 组件展示，lotus 尚未实现 Table，用原生 `<table>` 模拟同样的
行列结构与骨架占位效果，Skeleton 本身的用法不受影响。

```tsrx demo
../../src/demos/feedback/skeleton/combine-table.tsrx
```

### 加载动画

通过设置 `active` 属性可以展示动画效果。

```tsrx demo
../../src/demos/feedback/skeleton/active.tsrx
```

## API 参考

### Skeleton

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| active | 是否展示动画效果 | boolean | false |
| class | 类名 | string | - |
| loading | 为 true 时，显示占位元素。反之则显示子组件 | boolean | true |
| placeholder | 加载等待时的占位元素 | any | - |
| style | 样式 | object | - |

### SkeletonAvatar

> `SkeletonImage`、`SkeletonTitle`、`SkeletonButton` 大部分 API 与 `SkeletonAvatar` 相同。其中 shape 仅 `SkeletonAvatar` 支持。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | - |
| size | 设置头像的大小，支持 `extra-extra-small`、`extra-small`、`small`、`medium`、`large`、`extra-large` | string | `medium` |
| style | 样式 | object | - |
| shape | 指定头像的形状，支持 `circle`、`square` | string | `circle` |

### SkeletonParagraph

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | - |
| rows | 设置段落占位图的行数 | number | 4 |
| style | 样式 | object | - |

### SkeletonImage / SkeletonTitle / SkeletonButton

三者仅接受通用的 `class`/`style`，对齐 Semi `Skeleton.Image`/`Skeleton.Title`/`Skeleton.Button` 的实际用法（Semi 文档表格未单独列出，源码/示例确认无其他专属 prop）。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | - |
| style | 样式 | object | - |

## 文案规范

- 不变的固定内容直接展示固定内容，可变的内容使用骨架屏展示。

## 设计变量

- `--lotus-color-fill-1`（骨架元素底色）
- `--lotus-color-fill-2`（`active` 动效的高光色）
