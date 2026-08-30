---
title: PinCode 验证码输入框
category: 输入类
---

分格展示的验证码/短码输入框。定位为"可见分格短码"，不做遮罩显示——需要遮蔽显示的场景请使用 `Input type="password"`。

## 代码演示

### 如何引入

```tsrx
import { PinCode } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/input/pin-code/basic.tsrx
```

### 混合格式

`format="mixed"` 允许输入数字和字母。

```tsrx demo
../../src/demos/input/pin-code/mixed.tsrx
```

### 校验状态与禁用

```tsrx demo
../../src/demos/input/pin-code/validate-status.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置根容器 aria-label 属性 | string | - |
| autoFocus | 是否自动聚焦第一格 | boolean | - |
| class | 类名 | string | - |
| count | 分格数量 | number | `6` |
| defaultValue | 非受控模式下的默认值 | string | - |
| disabled | 是否禁用 | boolean | `false` |
| format | 允许输入的字符格式：数字 / 数字+字母 / 自定义正则或函数 | `'number' \| 'mixed' \| RegExp \| ((char: string) => boolean)` | `'number'` |
| size | 尺寸 | `'small' \| 'default' \| 'large'` | `'default'` |
| style | 自定义样式 | object | - |
| validateStatus | 校验状态，仅影响展示样式 | `'default' \| 'error' \| 'warning'` | `'default'` |
| value | 受控值 | string | - |
| onChange | 值变化时的回调 | `(value: string) => void` | - |
| onComplete | 最后一格填入字符时的回调（不要求全部格都非空，只判断写入索引是否为末格） | `(value: string) => void` | - |

## Accessibility

- 根容器携带 `role="group"` 与 `aria-label`。
- 每格 `<input>` 携带 `autocomplete="one-time-code"`、来自 `@lotus/locale` 的位次化 `aria-label`（如"第 1 位，共 6 位"）、`aria-invalid`（`validateStatus="error"` 时）。这套无障碍方案是 Semi 一手来源本身空白的场景，lotus 采纳社区已验证方案作为基线。
- Backspace 清空当前格并回退焦点，方向键在格间移动，输入非法字符会被拒绝且不留视觉痕迹。

## 设计变量

- `--lotus-color-border`（默认边框）
- `--lotus-color-primary`（聚焦态边框）
- `--lotus-color-danger` / `--lotus-color-warning`（校验状态边框）
- `--lotus-color-disabled-bg` / `--lotus-color-disabled-text`
- `--lotus-height-control-small` / `-default` / `-large`
