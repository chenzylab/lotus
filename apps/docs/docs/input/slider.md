---
title: Slider 滑块
category: 输入类
---

通过拖拽滑块在一个固定区间内进行选择，支持单值与范围双滑块。

## 代码演示

### 如何引入

```tsrx
import { Slider } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/slider/basic.tsrx
```

### 范围选择

`range` 开启双滑块，`value`/`defaultValue` 为 `[number, number]`。

```tsrx demo
../../src/demos/input/slider/range.tsrx
```

### 刻度标记

`marks` 传入 `{ 数值: 文案 }` 在轨道上显示刻度标签。

```tsrx demo
../../src/demos/input/slider/marks.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultValue | 非受控模式下的默认值 | `number \| [number, number]` | `min`（`range` 时为 `[min, min]`） |
| disabled | 是否禁用 | boolean | `false` |
| included | 轨道是否用颜色填充已选区间 | boolean | `true` |
| marks | 刻度标记 | `Record<number, string>` | - |
| max | 最大值 | number | `100` |
| min | 最小值 | number | `0` |
| range | 是否为范围选择（双滑块） | boolean | `false` |
| step | 步长 | number | `1` |
| style | 自定义样式 | object | - |
| tipFormatter | 拖拽提示文案格式化，传 `null` 关闭提示 | `((value: number) => any) \| null` | - |
| value | 受控值 | `number \| [number, number]` | - |
| vertical | 是否垂直方向 | boolean | `false` |
| verticalReverse | 垂直方向时是否反转（从下到上递增变为从上到下） | boolean | `false` |
| onAfterChange | 拖拽结束（松开鼠标）时的回调 | `(value: number \| [number, number]) => void` | - |
| onChange | 值变化时的回调（拖拽过程中持续触发） | `(value: number \| [number, number]) => void` | - |

## Accessibility

- 每个滑块手柄携带 `role="slider"`、`aria-valuemin`/`aria-valuemax`/`aria-valuenow`、`aria-disabled`，`range` 模式下两个手柄各自独立设置。
- 单值模式下手柄携带 `aria-label`；`range` 模式下建议通过外部文案说明两个手柄分别代表的含义。

## 设计变量

- `--lotus-color-primary`（已选区间/手柄颜色）
- `--lotus-color-fill-1`（未选区间轨道颜色）
- `--lotus-color-bg-1`（手柄背景）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
