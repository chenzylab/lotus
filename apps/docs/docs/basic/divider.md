---
title: Divider 分割线
category: 基础
---

分割线是一个呈线状的轻量化组件，用于有逻辑的组织元素内容和页面结构或区域。

## 代码演示

### 如何引入

```tsrx
import { Divider } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/basic/divider/basic.tsrx
```

### 包含内容

```tsrx demo
../../src/demos/basic/divider/with-text.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| align | 带内容时，内容对齐方式 | `left` \| `center` \| `right` | `center` |
| children | 内容 | any | 无 |
| class | 类名 | string | 无 |
| dashed | 是否为虚线 | boolean | `false` |
| layout | 分割线方向 | `horizontal` \| `vertical` | `horizontal` |
| margin | 分割线上下 margin（垂直方向时为左右 margin） | number \| string | 无 |
| style | 自定义样式 | object | 无 |

## Accessibility

- Divider 使用 `<div>` 渲染，无原生语义，纯装饰性分割线不需要 ARIA role。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-1`
- `--lotus-spacing-base`
- `--lotus-spacing-tight`
