---
title: Chart 图表
category: 展示类
---

柱状图/折线图/面积图/饼图/漏斗图/雷达图。Semi 官方没有可移植的 Chart 组件源码（其"Semi DV"是闭源 SaaS 生成的 VChart 主题包，业务代码直接用 VChart 原生 spec API），lotus 走"包一层 `@visactor/vchart` + 移植其主题层实现方式"的路线：图表渲染完全交给 VChart，lotus 只做 spec 组装与 Token → VChart 主题的映射。

## 代码演示

### 如何引入

```tsrx
import { Chart } from '@lotus/ripple';
```

### 基本用法

`data` 是 VChart 原生数据格式（`Array<{ id, values }>`），`spec` 透传其余 VChart spec 字段（`xField`/`yField`/`categoryField`/`seriesField` 等），不做 lotus 自己的字段改名封装。容器需要给出明确的宽高（`width`/`height` 或外层容器尺寸）。

```tsrx demo
../../src/demos/show/chart/basic.tsrx
```

### loading 与空数据态

`loading` 时整个图表区域覆盖 Spin 蒙层，不销毁已有的 VChart 实例（数据刷新期间旧图表仍在原地）；`data` 所有系列 `values` 均为空数组时展示 Empty 占位，不创建 VChart 实例。

```tsrx demo
../../src/demos/show/chart/loading-empty.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 图表的可访问名称 | string | 无 |
| class | 类名 | string | 无 |
| data | VChart 原生数据格式 | `Array<{ id: string; values: Record<string, unknown>[] }>` | 必填 |
| empty | 数据为空时的自定义占位内容；不传时用 Empty 组件 + locale 默认文案兜底 | any | 无 |
| exportFileName | 导出图片的文件名（不含扩展名） | string | `'chart'` |
| getChartInstance | 获取底层 VChart 实例的回调 | `(instance: VChart \| null) => void` | 无 |
| height | 高度 | string | 无 |
| loading | 加载中状态，覆盖 Spin 蒙层但不销毁已有实例 | boolean | `false` |
| onClick | 点击图表内数据点时的回调 | `(params: ChartEventParams) => void` | 无 |
| onExport | 导出图片完成后的回调 | `() => void` | 无 |
| onHover | 悬浮图表内数据点时的回调 | `(params: ChartEventParams) => void` | 无 |
| showExportButton | 是否展示右上角导出图片按钮 | boolean | `false` |
| spec | 其余 VChart spec 字段，逐项透传 | `Record<string, unknown>` | 无 |
| style | 自定义样式 | object | 无 |
| type | 图表类型 | `'bar' \| 'line' \| 'area' \| 'pie' \| 'funnel' \| 'radar'` | 必填 |
| width | 宽度 | string | 无 |

`ChartEventParams` 只透传业务方能直接消费的两个字段：`{ datum: Record<string, unknown> | undefined; event: Event | undefined }`（不泄漏 VChart 内部的 `mark`/`model`/`chart` 等渲染层对象）。

## Accessibility

- 图表容器与空数据占位均携带 `role="img"` 与 `aria-label`（未传时空态回退到 `locale.Chart.emptyTitle`）。
- 导出按钮的可访问名称来自 `@lotus/locale` 的 `Chart.exportImage`，随语言切换更新。
- 图表内部数据可视化依赖颜色区分系列，VChart 本身不提供图案/纹理等色觉无障碍替代方案，如实记录为当前限制（继承自底层库能力）。

## 设计变量

- Chart 主题色板来自 `@lotus/tokens` 的数据可视化调色板（`--lotus-color-data-0` ~ `-19`，亮暗模式各独立 20 色），通过 `theme.ts` 映射到 VChart 主题，不直接消费单个 CSS 变量。
