---
title: Switch 开关
category: 输入类
---

用于两种相反的状态之间的切换。

## 代码演示

### 如何引入

```tsrx
import { Switch } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/switch/basic.tsrx
```

### 尺寸

Switch 提供三种尺寸：`large`、`default`、`small`。

```tsrx demo
../../src/demos/input/switch/size.tsrx
```

### 不可用

```tsrx demo
../../src/demos/input/switch/disabled.tsrx
```

### 带文本

通过 `checkedText`/`uncheckedText` 设置开关内文案，`size="small"` 时不生效。

```tsrx demo
../../src/demos/input/switch/text.tsrx
```

### 受控组件

传入 `checked` 与 `onChange` 可以完全接管开关状态。

```tsrx demo
../../src/demos/input/switch/controlled.tsrx
```

### 加载中

```tsrx demo
../../src/demos/input/switch/loading.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | aria-label 属性 | string | - |
| aria-labelledby | aria-labelledby 属性 | string | - |
| checked | 指示当前是否选中，配合 onChange 使用 | boolean | - |
| checkedText | 打开时展示的内容，size 为 small 时无效 | any | - |
| class | 类名 | string | - |
| defaultChecked | 初始是否选中 | boolean | false |
| disabled | 是否禁用 | boolean | false |
| loading | 设置加载状态 | boolean | false |
| size | 尺寸，可选 large、default、small | string | "default" |
| style | 内联样式 | object | - |
| uncheckedText | 关闭时展示的内容，size 为 small 时无效 | any | - |
| onChange | 变化时回调函数 | `(checked: boolean) => void` | - |
| onMouseEnter | 鼠标移入时回调 | `(event: MouseEvent) => void` | - |
| onMouseLeave | 鼠标移出时回调 | `(event: MouseEvent) => void` | - |

## Accessibility

### ARIA

- Switch 渲染时会带上 `role="switch"` 与 `aria-checked`，可传入 `aria-label` 或 `aria-labelledby`（指向外部标签元素 id）描述开关作用。

## 设计变量

- `--lotus-color-primary`（开启态背景色）
- `--lotus-color-fill-2`（关闭态背景色）
