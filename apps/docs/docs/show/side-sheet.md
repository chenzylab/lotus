---
title: SideSheet 侧边抽屉
category: 展示类
---

从屏幕边缘滑出的浮层面板，用于承载表单、详情等不需要完全打断当前上下文的内容。

## 代码演示

### 如何引入

```tsrx
import { SideSheet } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/side-sheet/basic.tsrx
```

### placement="left"：从左侧滑入

```tsrx demo
../../src/demos/show/side-sheet/placement-left.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| afterVisibleChange | 显隐状态变化（含关闭动画结束）后的回调 | `(visible: boolean) => void` | 无 |
| aria-label | 设置 aria-label 属性 | string | 无 |
| bodyStyle | 内容区域自定义样式 | object | 无 |
| class | 类名 | string | 无 |
| closable | 是否显示关闭按钮 | boolean | `true` |
| closeOnEsc | 是否支持 Esc 关闭 | boolean | `true` |
| disableScroll | 是否禁用 `body` 滚动锁定 | boolean | `true` |
| footer | 底部内容 | any | 无 |
| headerStyle | 头部自定义样式 | object | 无 |
| height | 高度（`placement` 为 `top`/`bottom` 时生效） | string \| number | 无 |
| keepDOM | 关闭后是否保留 DOM（不销毁） | boolean | `false` |
| mask | 是否显示遮罩 | boolean | `true` |
| maskClosable | 点击遮罩是否关闭 | boolean | `true` |
| maskStyle | 遮罩自定义样式 | object | 无 |
| placement | 滑出方向 | `SideSheetPlacement` | `'right'` |
| size | 尺寸（`small`/`medium`/`large` 对应预设宽度） | `SideSheetSize` | `'medium'` |
| style | 自定义样式 | object | 无 |
| title | 标题 | any | 无 |
| visible | 是否显示 | boolean | `false` |
| width | 宽度（`placement` 为 `left`/`right` 时生效） | string \| number | 无 |
| zIndex | 层级 | number | 无 |
| onCancel | 点击关闭按钮/遮罩/Esc 时的回调 | `(event) => void` | 无 |

## Accessibility

- 打开时启用焦点陷阱，关闭后焦点归还到触发元素。
- `closeOnEsc` 默认开启，Esc 键关闭。
- 打开时锁定 `body` 滚动（引用计数实现，与 Modal 共用同一套滚动锁定逻辑）；`disableScroll={false}` 可关闭这个行为。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-overlay-bg`
- `--lotus-shadow-elevated`
- `--lotus-z-modal`
