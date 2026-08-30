---
title: Lottie 动画
category: 展示类
---

播放 Lottie（After Effects 导出的 JSON 动画）格式的矢量动画，基于 `lottie-web` 运行时驱动 SVG/Canvas 渲染。

## 代码演示

### 如何引入

```tsrx
import { Lottie } from '@lotus/ripple';
```

### 基本用法

`getAnimationInstance` 拿到底层动画实例后可调用 `play`/`pause`/`stop`/`setSpeed` 等方法命令式控制播放。

```tsrx demo
../../src/demos/show/lottie/basic.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | 无 |
| getAnimationInstance | 拿到 `lottie-web` 动画实例的回调，用于命令式控制播放 | `(instance: AnimationItem \| null) => void` | 无 |
| getLottie | 拿到 `lottie-web` 库本身的回调 | `(lottiePKG) => void` | 无 |
| height | 容器高度 | string | 无 |
| params | 加载参数（`path`/`animationData` 等，透传给 `lottie-web` 的 `loadAnimation`） | `LottieLoadParams` | 必填 |
| style | 自定义样式 | object | 无 |
| width | 容器宽度 | string | 无 |

## Accessibility

- 动画容器本身是纯装饰性渲染层，不携带交互语义；若动画传达重要信息，建议调用方在外部补充文字说明。
- 组件卸载时正确调用 `animation.destroy()` 释放底层渲染资源，避免残留渲染循环。

## 设计变量

本组件视觉完全由传入的 Lottie JSON 动画数据决定，不消费 lotus Design Token。
