---
title: IconButton 图标按钮
category: 基础
---

Button 的图标语义化封装。默认无 `children` 时是恒定正方形的纯图标按钮，强制要求 `aria-label`；传入 `children` 后对齐 Semi——不再是恒定正方形，走与 Button 相同的横向撑开布局，`iconPosition` 控制图标在文本左/右。不新建独立 Foundation，点击拦截逻辑与 Button 完全相同，直接复用 `ButtonFoundation`。

## 代码演示

### 如何引入

```tsrx
import { IconButton } from '@lotus/ripple';
```

### 基本用法

四种主题：`borderless`（默认）、`light`、`solid`、`outline`。

```tsrx demo
../../src/demos/basic/icon-button/basic.tsrx
```

### 尺寸与状态

三种尺寸：`small`、`default`、`large`；支持 `loading`（转圈图标覆盖原图标，且不再响应点击）与 `disabled`。

```tsrx demo
../../src/demos/basic/icon-button/state.tsrx
```

### 图标 + 文本

传入 `children` 后不再是恒定正方形，走与 Button 相同的横向撑开布局；`iconPosition` 控制图标在文本左（默认）/右，`noHorizontalPadding`、`contentClassName` 与 Button 语义一致。

```tsrx demo
../../src/demos/basic/icon-button/text.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 可访问名称（无 `children` 时必填——纯图标按钮省略会导致屏幕阅读器用户完全无法辨识；有 `children` 时按钮已有可见文本，可省略） | string | 无 |
| children | 图标旁的文本内容；传了以后按钮不再是恒定正方形 | any | 无 |
| class | 类名 | string | 无 |
| contentClassName | 文本内容包裹层的类名 | string | 无 |
| disabled | 是否禁用 | boolean | `false` |
| htmlType | 原生 `<button>` 的 `type` 属性 | `'button'` \| `'submit'` \| `'reset'` | `'button'` |
| icon | 图标内容 | any | 必填 |
| iconPosition | 有 `children` 时，图标相对文本的位置 | `'left'` \| `'right'` | `'left'` |
| loading | 是否处于加载态（覆盖为转圈图标，禁止点击） | boolean | `false` |
| noHorizontalPadding | 有 `children` 时，清零指定方向的水平内边距 | `boolean \| 'left' \| 'right' \| ('left' \| 'right')[]` | 无 |
| size | 尺寸 | `'small'` \| `'default'` \| `'large'` | `'default'` |
| style | 自定义样式 | object | 无 |
| theme | 视觉主题 | `'borderless'` \| `'light'` \| `'solid'` \| `'outline'` | `'borderless'` |
| type | 语义色 | `'primary'` \| `'secondary'` \| `'tertiary'` \| `'warning'` \| `'danger'` | `'primary'` |
| onClick | 点击回调（`disabled`/`loading` 时不触发） | `(event: MouseEvent) => void` | 无 |

## Accessibility

- 渲染为原生 `<button>`，天然支持 Tab 聚焦与 Enter/Space 触发。
- 无 `children` 时强制要求 `aria-label`（类型层标注为必填 prop，而非可选后靠约定遵守）；有 `children` 时按钮已有可见文本，`aria-label` 不再是必需项。
- `loading` 态携带 `aria-busy={true}`，`disabled` 态使用原生 `disabled` 属性（同时移出 Tab 顺序，与 Button 组件语义一致）。

## 设计变量

- `--lotus-height-control-default` / `-large` / `-small`（三档尺寸）
- `--lotus-border-radius-small`
- `--lotus-border-width-control`
- `--lotus-color-primary` / `-secondary` / `-tertiary` / `-warning` / `-danger`（及各自 `-hover`/`-active` 变体，`solid`/`light`/`borderless`/`outline` 四种主题各自映射）
- `--lotus-color-fill-0` / `-1` / `-2`（light/borderless/outline 主题的底色阶梯）
- `--lotus-color-disabled-bg` / `-text` / `-border`
