---
title: ScrollList 滚动选择列表
category: 展示类
---

滚轮式/点击式列表选择器，常用于时间选择、年月选择这类"多列组合选值"场景（如 DatePicker/TimePicker 内部就复用了这套能力）。`ScrollList` 是外层容器（header/body/footer 布局壳），`ScrollItem` 是具体的可滚动选择列。

## 代码演示

### 如何引入

```tsrx
import { ScrollList, ScrollItem } from '@lotus/ripple';
```

### normal 模式：普通点击列表

```tsrx demo
../../src/demos/show/scroll-list/normal.tsrx
```

### wheel 模式 + cycled 循环滚动：时/分两列组合

`mode="wheel"`（默认）带中心线吸附效果；`cycled` 开启后列表首尾循环衔接（如小时 23 之后接回 0）。

```tsrx demo
../../src/demos/show/scroll-list/wheel-cycled.tsrx
```

## API 参考

### ScrollList

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bodyHeight | 主体区域高度 | string \| number | 无 |
| children | `ScrollItem` 列（可并排多列） | any | 无 |
| class | 类名 | string | 无 |
| footer | 底部内容 | any | 无 |
| header | 顶部内容 | any | 无 |
| style | 自定义样式 | object | 无 |

### ScrollItem

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | 无 |
| class | 类名 | string | 无 |
| cycled | 是否首尾循环衔接 | boolean | `false` |
| itemHeight | 单项高度（像素） | number | `36` |
| list | 数据源，每项 `{ value, text?, disabled? }` | `ScrollListItemData[]` | `[]` |
| mode | 交互模式：`wheel` 带中心线吸附，`normal` 普通点击列表 | `'normal' \| 'wheel'` | `'wheel'` |
| onSelect | 选中项变化时的回调 | `(data) => void` | 无 |
| selectedIndex | 受控的选中索引 | number | `0` |
| style | 自定义样式 | object | 无 |

## Accessibility

- 列表渲染为 `<ul role="listbox">` + `<li role="option">`，携带 `aria-disabled`（禁用项）与调用方传入的 `aria-label`。
- 吸附判定完全由 JS 侧 `scroll` 事件防抖计算（不使用 CSS `scroll-snap`，避免两套独立吸附逻辑互相竞争坐标）。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-1` / `-text-3`
- `--lotus-color-primary`
- `--lotus-font-body-size`
