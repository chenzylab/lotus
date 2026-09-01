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

### tooltips 每颗星自定义提示文案

`tooltips` 数组下标对应星的 index（0-based），hover 到某颗星时展示对应提示。

```tsrx demo
../../src/demos/input/rating/tooltips.tsrx
```

### 命令式 API

通过 `getRatingApi` 拿到 `api` 引用，可在外部调用 `focus()`/`blur()` 命令式聚焦/失焦（对齐 Semi `ref.current.focus()`/`blur()`）。

```tsrx demo
../../src/demos/input/rating/rating-api.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| aria-labelledby | 关联外部 label 元素 | string | - |
| aria-describedby | 关联描述性文字元素 | string | - |
| aria-errormessage | 关联错误信息元素 | string | - |
| aria-invalid | 是否处于校验错误态 | boolean | - |
| aria-required | 是否为必填项 | boolean | - |
| allowClear | 是否允许点击已选中值清零 | boolean | `true` |
| allowHalf | 是否允许半星选取 | boolean | `false` |
| autoFocus | 挂载后是否自动聚焦，disabled 时不生效 | boolean | `false` |
| character | 自定义星星图标 | any | - |
| class | 类名 | string | - |
| count | 星星总数 | number | `5` |
| defaultValue | 非受控模式下的默认值 | number | `0` |
| disabled | 是否禁用 | boolean | `false` |
| getRatingApi | 挂载时回调，传入 api 引用 | `(api: RatingApi) => void` | - |
| size | 尺寸 | `'small' \| 'default' \| number` | `'default'` |
| style | 自定义样式 | object | - |
| tooltips | 每颗星 hover 时展示的自定义提示文案，数组下标对应星的 index | string[] | - |
| value | 受控值 | number | - |
| onBlur | 失焦时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 值变化时的回调 | `(value: number) => void` | - |
| onFocus | 聚焦时的回调 | `(event: FocusEvent) => void` | - |
| onHoverChange | hover 预览值变化时的回调 | `(value: number \| undefined) => void` | - |

### RatingApi

| 方法 | 说明 |
| --- | --- |
| focus(options?) | 命令式聚焦，`options.preventScroll` 透传给原生 `focus()` 的同名选项 |
| blur() | 命令式移出焦点 |

## Accessibility

- 根元素为 `<ul role="radiogroup">`，携带 `aria-label`（或 `aria-labelledby`），`tabIndex={0}`（禁用时为 `-1`），支持方向键（← → ↑ ↓）调整评分——RTL 方向下（`ConfigProvider` 或 locale 设置为 rtl）方向键的增减方向随之镜像，符合"往右操作应减小值"的 RTL 直觉。
- 每颗星为 `<li role="radio">`，携带 `aria-checked`（是否为完整星）、`aria-posinset`/`aria-setsize` 表示在评分组中的位置。
- `aria-describedby`/`aria-errormessage`/`aria-invalid`/`aria-required` 用于关联表单场景下的描述文字/错误信息/校验态。

## 设计变量

- `--lotus-color-fill-2`（未选中星星颜色）
- `--lotus-color-warning`（选中星星颜色，回退 `#fadb14`）
- `--lotus-color-primary-light`（focus 态外框，回退 `rgba(0, 100, 250, 0.2)`）
- `--lotus-border-radius-small`
