---
title: Rating 评分
category: 输入类
---

星级评分组件，单值可半星。

## 代码演示

### 如何引入

```tsrx
import { Rating } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/rating/basic.tsrx
```

### 半星与自定义总数

`allowHalf` 开启半星选取，`count` 自定义星星总数。

```tsrx demo
../../src/demos/input/rating/half.tsrx
```

### 尺寸与禁用

```tsrx demo
../../src/demos/input/rating/size-disabled.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| allowClear | 是否允许点击已选中值清零 | boolean | `true` |
| allowHalf | 是否允许半星选取 | boolean | `false` |
| character | 自定义星星图标 | any | - |
| class | 类名 | string | - |
| count | 星星总数 | number | `5` |
| defaultValue | 非受控模式下的默认值 | number | `0` |
| disabled | 是否禁用 | boolean | `false` |
| size | 尺寸 | `'small' \| 'default' \| number` | `'default'` |
| style | 自定义样式 | object | - |
| value | 受控值 | number | - |
| onChange | 值变化时的回调 | `(value: number) => void` | - |
| onHoverChange | hover 预览值变化时的回调 | `(value: number \| undefined) => void` | - |

## Accessibility

- 根元素为 `<ul role="radiogroup">`，携带 `aria-label`，`tabIndex={0}`（禁用时为 `-1`），支持方向键（← → ↑ ↓）调整评分。
- 每颗星为 `<li role="radio">`，携带 `aria-checked`（是否为完整星）、`aria-posinset`/`aria-setsize` 表示在评分组中的位置。

## 设计变量

- `--lotus-color-fill-2`（未选中星星颜色）
- `--lotus-color-warning`（选中星星颜色，回退 `#fadb14`）
- `--lotus-color-primary-light`（focus 态外框，回退 `rgba(0, 100, 250, 0.2)`）
- `--lotus-border-radius-small`
