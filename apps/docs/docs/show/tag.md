---
title: Tag 标签
category: 展示类
---

用于标记事物的属性和维度。

## 代码演示

### 如何引入

```tsrx
import { Tag } from '@lotus/ripple';
```

### 基本用法

设置 `closable` 属性和 `onClose` 回调可以让标签支持关闭。

```tsrx demo
../../src/demos/show/tag/basic.tsrx
```

### 尺寸

Tag 提供三种尺寸：`large`、`default`、`small`。

```tsrx demo
../../src/demos/show/tag/size.tsrx
```

### 配置图标

通过 `prefixIcon`/`suffixIcon` 设置标签的前后缀图标。

```tsrx demo
../../src/demos/show/tag/icon.tsrx
```

### 颜色

Tag 支持 17 种展示色。

```tsrx demo
../../src/demos/show/tag/color.tsrx
```

### 样式类型

Tag 提供三种样式类型：`light`（默认，浅色背景）、`solid`（纯色背景）、`ghost`（幽灵边框）。

```tsrx demo
../../src/demos/show/tag/type.tsrx
```

### 不可见的

通过 `visible` 属性可以控制标签的显隐。

```tsrx demo
../../src/demos/show/tag/visible.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 标签的标签 | string | - |
| children | 标签内容 | any | - |
| class | 类名 | string | - |
| closable | 标签是否可以关闭 | boolean | false |
| color | 标签的颜色，可选 amber、blue、cyan、green、grey、indigo、lightBlue、lightGreen、lime、orange、pink、purple、red、teal、violet、yellow、white | string | "grey" |
| prefixIcon | 前缀图标 | any | - |
| suffixIcon | 后缀图标 | any | - |
| size | 标签的尺寸，可选 small、default、large | string | "default" |
| style | 样式 | object | - |
| type | 标签的样式类型，可选 ghost、solid、light | string | "light" |
| visible | 标签是否可见 | boolean | - |
| onClick | 单击标签时的回调函数 | `(event: MouseEvent) => void` | - |
| onClose | 关闭标签时的回调函数 | `(event: MouseEvent) => void` | - |

> 注意事项：lotus 版 `color` 中 `lightBlue`/`lightGreen` 采用驼峰命名，与 Semi 官方的 kebab 写法（`light-blue`/`light-green`）不同，这是 lotus 自有的类型命名约定。lotus 尚未实现 `shape`（形状）、`avatarSrc`（头像标签）、`colorful`/`gradient`（多彩标签）、`TagGroup`、`SplitTagGroup`。

## Accessibility

### ARIA

- 关闭按钮为可聚焦的可交互元素，建议通过 `aria-label` 描述标签内容以提升可访问性。

## 设计变量

- `--lotus-color-fill-0` ~ `--lotus-color-fill-2`（light 类型底色）
- `--lotus-color-border`（ghost 类型边框色）
