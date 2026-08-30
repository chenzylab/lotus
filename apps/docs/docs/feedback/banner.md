---
title: Banner 通栏提示
category: 反馈类
---

页面顶部通栏展示重要提示信息，支持关闭。

## 代码演示

### 如何引入

```tsrx
import { Banner } from '@lotus/ripple';
```

### 基本用法

四种类型：`info`/`success`/`warning`/`danger`，各自带对应的默认图标与背景色。

```tsrx demo
../../src/demos/feedback/banner/basic.tsrx
```

### 卡片模式

`fullMode={false}` 时不再是页面通栏样式，可用 `bordered` 加边框，适合嵌入页面局部区域。

```tsrx demo
../../src/demos/feedback/banner/bordered.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bordered | 卡片模式（`fullMode={false}`）下是否显示边框 | boolean | `false` |
| children | 额外内容，渲染在主体下方 | any | - |
| class | 类名 | string | - |
| closeIcon | 自定义关闭按钮图标；传 `null` 时不展示关闭按钮 | any | - |
| description | 描述文案 | any | - |
| fullMode | 是否为通栏铺满模式 | boolean | `true` |
| icon | 自定义图标；传 `null` 时不展示图标 | any | - |
| style | 自定义样式 | object | - |
| title | 标题 | any | - |
| type | 类型 | `info` \| `success` \| `warning` \| `danger` | `info` |
| onClose | 点击关闭按钮时的回调 | `(event: MouseEvent) => void` | - |

## Accessibility

- 根元素携带 `role="alert"`。
- 关闭按钮的可访问名称来自 `@lotus/locale` 的 `Banner.close`，跟随 `ConfigProvider` 切换语言实时更新。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-info-light-default` / `--lotus-color-info`
- `--lotus-color-success-light-default` / `--lotus-color-success`
- `--lotus-color-warning-light-default` / `--lotus-color-warning`
- `--lotus-color-danger-light-default` / `--lotus-color-danger`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-border-radius-small`
