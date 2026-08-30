---
title: Anchor 锚点
category: 导航类
---

用于跳转到页面指定位置，并高亮当前滚动到的锚点链接。

## 代码演示

### 如何引入

```tsrx
import { Anchor } from '@lotus/ripple';
```

### 基本用法

`links` 为扁平数组，`getContainer` 指定滚动监听的容器（不传则监听 `window`）。点击链接会平滑滚动到目标元素，滚动过程中根据各目标元素与容器顶部的距离自动计算并高亮当前锚点。

```tsrx demo
../../src/demos/navigation/anchor/basic.tsrx
```

### 嵌套锚点

`links` 数组项可通过 `children` 嵌套子锚点，渲染时按层级缩进。

```tsrx demo
../../src/demos/navigation/anchor/nested.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeLink | 受控的当前高亮锚点 href | string | - |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultActiveLink | 非受控模式下的默认高亮锚点 href | string | - |
| getContainer | 滚动监听的容器，不传则监听 `window` | `() => HTMLElement \| Window` | - |
| links | 锚点链接数组，每项为 `{ href, title, children? }` | `AnchorLinkInput[]` | 必填 |
| offsetTop | 计算高亮命中与滚动定位时的顶部偏移量 | number | `0` |
| style | 自定义样式 | object | - |
| onChange | 高亮锚点变化时的回调 | `(currentLink: string \| null, previousLink: string \| null) => void` | - |
| onClick | 点击锚点链接时的回调（先于滚动触发） | `(event: MouseEvent, link: string) => void` | - |

## Accessibility

- 根容器可通过 `aria-label` 描述其用途；组件本身用原生 `<a>` 标签渲染各锚点链接，天然可被 Tab 聚焦、Enter 触发。

## 设计变量

- `--lotus-color-border`（左侧分隔线）
- `--lotus-color-text-1`（默认文字色）
- `--lotus-color-primary`（hover/高亮态文字色）
- `--lotus-font-body-size` / `-label-size`
- `--lotus-font-weight-semibold`（高亮态字重）
