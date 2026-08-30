---
title: Progress 进度条
category: 反馈类
---

展示操作的当前进度。

## 代码演示

### 如何引入

```tsrx
import { Progress } from '@lotus/ripple';
```

### 基本用法

`type="line"`（默认）为线形进度条，需要外部容器给出明确宽度约束（组件本身不假设占满容器，对齐 Semi 的既定设计——参照 Semi 官方 demo 一律用 `<div style={{ width: 200 }}>` 包裹）。

```tsrx demo
../../src/demos/feedback/progress/basic.tsrx
```

### 环形进度条

`type="circle"`，可通过 `width` 控制环形直径。

```tsrx demo
../../src/demos/feedback/progress/circle.tsrx
```

### 多段渐变色与受控更新

`stroke` 传入 `{ percent, color }[]` 数组并开启 `strokeGradient` 后，描边色按当前百分比在多个颜色断点间插值。数值变化的视觉过渡由纯 CSS `transition` 驱动（`width`/`stroke-dashoffset`），不使用 JS `requestAnimationFrame` 手动计算；`motion={false}` 时可禁用该过渡。

```tsrx demo
../../src/demos/feedback/progress/controlled.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| direction | 线形进度条方向 | `horizontal` \| `vertical` | `horizontal` |
| format | 自定义文案渲染函数，返回值用于展示文案；若返回字符串/数字也会同步到 `aria-valuetext` | `(percent: number) => any` | 无 |
| motion | 是否启用数值变化的 CSS 过渡动画 | boolean | `true` |
| orbitStroke | 未完成部分（轨道）的颜色 | string | - |
| percent | 当前百分比（0-100） | number | `0` |
| showInfo | 是否显示进度文案 | boolean | `false` |
| size | 尺寸 | `small` \| `default` \| `large` | `default` |
| strokeGradient | 是否对 `stroke` 数组按百分比做渐变插值 | boolean | `false` |
| strokeLinecap | 描边端点样式 | `round` \| `square` \| `butt` | `round` |
| stroke | 描边颜色，可传单一颜色字符串或多段渐变断点数组 | `string \| { percent: number; color: string }[]` | - |
| strokeWidth | 描边宽度 | number | `4` |
| style | 自定义样式 | object | - |
| type | 进度条类型 | `line` \| `circle` | `line` |
| width | 环形进度条直径（`type="circle"` 时生效） | number | `72`（`size="small"` 时为 `24`） |

## Accessibility

- 根元素携带 `role="progressbar"`、`aria-valuemin={0}`、`aria-valuemax={100}`、`aria-valuenow`（始终反映真实目标百分比，不会跟随视觉过渡报告中间态数字）。
- `aria-valuetext` 只在 `format` 返回字符串/数字这类可安全转文本的内容时设置，复杂 JSX 场景保持不设置（不设置空字符串占位，避免部分屏幕阅读器把空字符串误判为"显式覆盖为空白"）。

## 设计变量

- `--lotus-color-fill-0` / `-fill-1`（轨道底色）
- `--lotus-color-success`（默认描边色）
- `--lotus-color-text-0` / `-text-1`（文案颜色）
- `--lotus-border-radius-full`
- `--lotus-font-label-size`
