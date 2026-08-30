---
title: ColorPicker 拾色器
category: 输入类
---

从饱和度/色相/透明度面板中拾取颜色，内部以 HSVA/RGBA/HEX 三态表示颜色值。

## 代码演示

### 如何引入

```tsrx
import { ColorPicker } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/color-picker/basic.tsrx
```

### 弹层触发（自定义触发器）

`usePopover` 开启后拾色面板收进弹层，`children` 作为触发元素（缺省时为默认色块）。

```tsrx demo
../../src/demos/input/color-picker/popover.tsrx
```

### 无透明度模式

```tsrx demo
../../src/demos/input/color-picker/no-alpha.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| alpha | 是否显示透明度调节条 | boolean | `true` |
| aria-label | 设置默认触发色块的 aria-label | string | - |
| children | `usePopover` 模式下的自定义触发元素 | any | - |
| className | 类名 | string | - |
| defaultFormat | 底部数值输入区默认展示格式 | `'rgba' \| 'hsva'` | `'rgba'` |
| defaultValue | 非受控模式下的默认颜色 | `ColorValue` | 黑色不透明 |
| eyeDropper | 是否显示取色器按钮（仅浏览器支持 EyeDropper API 时生效） | boolean | `true` |
| height | 面板高度 | number | - |
| style | 自定义样式 | object | - |
| usePopover | 是否用弹层收纳面板，配合 `children` 自定义触发元素 | boolean | `false` |
| value | 受控颜色值 | `ColorValue` | - |
| width | 面板宽度 | number | - |
| onChange | 颜色变化时的回调 | `(value: ColorValue) => void` | - |

`ColorValue` 结构：`{ hsva: HsvaColor; rgba: RgbaColor; hex: string }`，三种表示始终保持同步。

## Accessibility

- 饱和度/明度面板、色相条、透明度条均携带 `role="slider"` 与来自 `@lotus/locale` 的本地化 `aria-label`。
- 底部 RGBA/HSVA 各数值输入框、格式切换按钮均有独立 `aria-label`。
- 饱和度/明度面板本身不支持键盘方向键操作（无 `tabIndex`/`onKeyDown`），这是当前已知限制，如实记录。

## 设计变量

- `--lotus-color-border`（面板/触发色块边框）
- `--lotus-border-radius-small`（默认色块圆角，回退 `4px`）
