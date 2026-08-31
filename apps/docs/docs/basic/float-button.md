---
title: FloatButton 悬浮按钮
category: 基础
---

固定定位的悬浮操作按钮，默认吸附在视口右下角。不新建复杂 Foundation 状态机，点击拦截逻辑与 Button 同量级（仅 `disabled` 判断）。

## 代码演示

### 如何引入

```tsrx
import { FloatButton } from '@lotus/ripple';
```

### 基本用法

`FloatButton` 是纯图标按钮（无文本插槽），默认 `position: fixed` 固定在视口右下角；下方示例为便于并排展示，用 `style` 覆盖为 `position: relative`，实际使用时通常不需要覆盖。支持 `colorful`（AI 场景专属渐变色）、`shape`（`round`/`square`）、`size`（`small`/`default`/`large`）与 `disabled`。

```tsrx demo
../../src/demos/basic/float-button/basic.tsrx
```

### 角标

`badge` 透传给 `Badge` 包裹按钮本体，支持 `Badge` 的全部配置（`count`、`dot`、`position` 等）。

```tsrx demo
../../src/demos/basic/float-button/badge.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 可访问名称（必填——纯图标按钮省略会导致屏幕阅读器用户无法辨识） | string | 必填 |
| badge | 角标参数，透传给 `Badge` 包裹按钮本体 | `Omit<BadgeProps, 'children'>` | 无 |
| class | 类名 | string | 无 |
| colorful | 是否使用 AI 场景专属渐变色 | boolean | `false` |
| disabled | 是否禁用 | boolean | `false` |
| href | 点击后跳转的链接地址 | string | 无 |
| icon | 图标内容 | any | 无 |
| shape | 形状 | `'round'` \| `'square'` | `'round'` |
| size | 尺寸 | `'small'` \| `'default'` \| `'large'` | `'default'` |
| style | 自定义样式 | object | 无 |
| target | 配合 `href` 使用，`'_blank'` 时用 `window.open` 新窗口打开 | string | 无 |
| onClick | 点击回调（`disabled` 时不触发） | `(event: MouseEvent) => void` | 无 |

## Accessibility

- 渲染为原生 `<button>`，天然支持 Tab 聚焦与 Enter/Space 触发。
- 强制要求 `aria-label`（类型层标注为必填 prop）。
- `disabled` 态使用原生 `disabled` 属性，同时移出 Tab 顺序。

## 设计变量

- `--lotus-height-control-large` / `-default`（`large`/`default` 尺寸）
- `--lotus-border-radius-full` / `-medium`（`round`/`square` 形状）
- `--lotus-z-back-top`（层级）
- `--lotus-color-bg-1`、`--lotus-color-text-0`、`--lotus-shadow-elevated`（默认态背景/文字/阴影）
- `--lotus-color-fill-1` / `-2`（hover/active 态背景）
- `--lotus-color-ai-general` / `-general-hover` / `-general-active`（`colorful` 渐变色三态）
- `--lotus-color-disabled-bg` / `-text`
