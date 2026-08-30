---
title: BackTop 回到顶部
category: 导航类
---

返回页面顶部的操作按钮，当滚动超过设定阈值后出现。

## 代码演示

### 如何引入

```tsrx
import { BackTop } from '@lotus/ripple';
```

### 基本用法

`target` 指定滚动监听的容器，不传则监听 `window`（此时按钮效果发生在整个页面级别）。下方 demo 用一个有限高度的容器演示滚动阈值触发的效果——实际项目里若监听 `window`，滚动整个页面到超过 `visibilityHeight` 阈值时右下角会出现回顶按钮。

```tsrx demo
../../src/demos/navigation/back-top/basic.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性，不传则回退用 `@lotus/locale` 的 `BackTop.label`（"回到顶部"） | string | - |
| children | 自定义按钮内容，不传则显示默认的向上箭头图标 | any | - |
| class | 类名 | string | - |
| duration | 回顶动画时长（毫秒） | number | `450` |
| style | 自定义样式 | object | - |
| target | 滚动监听的容器，不传则监听 `window` | `() => HTMLElement \| Window` | - |
| visibilityHeight | 滚动超过多少像素后显示按钮 | number | `400` |
| onClick | 点击按钮时的回调（回顶动画开始前触发） | `(event: MouseEvent) => void` | - |

## Accessibility

- 按钮携带 `aria-label`（默认取本地化文案"回到顶部"），可被 Tab 聚焦、Enter/Space 触发（原生 `<button>` 语义）。
- 按钮只在滚动超过 `visibilityHeight` 阈值后才渲染到 DOM（未达到阈值时不占用 Tab 顺序）。

## 设计变量

- `--lotus-color-bg-1`（按钮背景色）
- `--lotus-color-fill-1`（hover 态背景色）
- `--lotus-color-text-1`（图标颜色）
- `--lotus-shadow-elevated`（按钮阴影）
- `--lotus-border-radius-full`
- `--lotus-z-back-top`
