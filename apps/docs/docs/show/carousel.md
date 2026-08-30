---
title: Carousel 走马灯
category: 展示类
---

在有限空间内循环展示一组内容，支持自动播放、滑动/淡入淡出动画、多种指示器样式。

## 代码演示

### 如何引入

```tsrx
import { Carousel } from '@lotus/ripple';
```

### 基本用法

`items` 是渲染内容数组（Ripple 无法像 React 那样遍历 JSX children，改用数组数据源，是相对 Semi 原始 API 的必要设计调整）。

```tsrx demo
../../src/demos/show/carousel/basic.tsrx
```

### 自动播放

`autoPlay` 传对象可配置播放间隔与"hover 时暂停"。

```tsrx demo
../../src/demos/show/carousel/autoplay.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeIndex | 受控的当前索引 | number | - |
| animation | 切换动画 | `'slide' \| 'fade'` | `'slide'` |
| aria-label | 设置 aria-label 属性 | string | - |
| arrowType | 箭头显示时机 | `'always' \| 'hover'` | `'always'` |
| autoPlay | 是否自动播放，或传 `{ interval?, hoverToPause? }` 配置 | `boolean \| { interval?: number; hoverToPause?: boolean }` | `true` |
| class | 类名 | string | - |
| defaultActiveIndex | 非受控模式下的默认索引 | number | `0` |
| indicatorPosition | 指示器位置 | `'left' \| 'center' \| 'right'` | `'center'` |
| indicatorType | 指示器样式 | `'dot' \| 'line' \| 'columnar'` | `'dot'` |
| items | 每一项的渲染内容 | any[] | 必填 |
| showArrow | 是否显示左右箭头 | boolean | `true` |
| showIndicator | 是否显示指示器 | boolean | `true` |
| speed | 切换动画时长（毫秒） | number | `300` |
| style | 自定义样式 | object | - |
| theme | 主题 | `'primary' \| 'light' \| 'dark'` | `'light'` |
| trigger | 指示器切换触发方式 | `'click' \| 'hover'` | `'click'` |
| onChange | 索引变化时的回调 | `(index: number, prevIndex: number) => void` | - |

## Accessibility

- 上一张/下一张按钮携带来自 `@lotus/locale` 的本地化 `aria-label`（`Carousel.prev`/`next`）。
- 左右箭头带阅读顺序语义，RTL 模式下箭头容器物理位置（`inset-inline-start/end`）与图标朝向（`scaleX(-1)`）均自动镜像。
- 动画时长可通过 `speed` 控制，配合 `autoPlay.interval` 可将闪烁/切换频率控制在安全范围内（建议整体切换节奏 < 3 次/秒）。

## 设计变量

- `--lotus-border-radius-medium` / `-circle`
- `--lotus-spacing-tight`
