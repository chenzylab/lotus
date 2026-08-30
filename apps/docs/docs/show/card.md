---
title: Card 卡片
category: 展示类
---

将信息聚合展示在一个独立区块内，支持标题、封面、操作区、加载态。

## 代码演示

### 如何引入

```tsrx
import { Card, CardMeta, CardGroup } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/card/basic.tsrx
```

### CardMeta 与加载态

`CardMeta` 提供头像+标题+描述的通用布局；`loading` 开启后内容区切换为骨架屏。

```tsrx demo
../../src/demos/show/card/meta-and-loading.tsrx
```

### CardGroup 卡片组

```tsrx demo
../../src/demos/show/card/group.tsrx
```

## API 参考

### Card

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| actions | 底部操作区元素数组 | any[] | - |
| aria-label | 设置 aria-label 属性 | string | - |
| bodyStyle | 内容区自定义样式 | object | - |
| bordered | 是否显示边框 | boolean | `true` |
| children | 内容 | any | - |
| class | 类名 | string | - |
| cover | 封面内容（渲染在标题区下方、内容区上方） | any | - |
| footer | 底部内容 | any | - |
| footerLine | 底部是否显示分隔线 | boolean | `false` |
| footerStyle | 底部自定义样式 | object | - |
| header | 完全自定义标题区内容（优先于 `title`/`headerExtraContent`） | any | - |
| headerExtraContent | 标题区右侧额外内容 | any | - |
| headerLine | 标题区是否显示分隔线 | boolean | `true` |
| headerStyle | 标题区自定义样式 | object | - |
| loading | 是否展示加载骨架屏 | boolean | `false` |
| shadows | 阴影展示时机 | `'hover' \| 'always'` | - |
| style | 自定义样式 | object | - |

### CardMeta

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| avatar | 头像/图标区域 | any | - |
| description | 描述文案 | any | - |
| title | 标题 | any | - |

### CardGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| spacing | 卡片间距（单值或 `[水平, 垂直]`） | `number \| number[]` | `16` |
| type | 布局类型，`'grid'` 时卡片间共享边框、无间隙 | `'grid'` | - |

## Accessibility

- `loading` 为 `true` 时根容器携带 `aria-busy={true}`，提示屏幕阅读器内容正在加载。
- 标题为字符串时使用 `TypographyTitle` 渲染并支持自动省略+ Tooltip，保留原生语义标题层级。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-border`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-shadow-elevated`
- `--lotus-border-radius-medium`
- `--lotus-spacing-tight` / `-base` / `-base-loose`
