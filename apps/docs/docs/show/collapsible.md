---
title: Collapsible 展开收起容器
category: 展示类
---

无头（headless）展开/收起动画容器，不带 header/触发器，完全受控，可包裹任意内容。用 CSS `max-height` transition 实现动画。

## 代码演示

### 如何引入

```tsrx
import { Collapsible } from '@lotus/ripple';
```

### 基本用法

`isOpen` 完全受控，触发器需要使用方自行实现（如一个普通 `Button` + 外部状态）。

```tsrx demo
../../src/demos/show/collapsible/basic.tsrx
```

### 预览高度与 keepDOM

`collapseHeight` 让收起态仍保留一定高度（露出内容预览）；`keepDOM` 让子内容在收起态也保持挂载（不销毁 DOM 节点）。

```tsrx demo
../../src/demos/show/collapsible/collapse-height.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| children | 内容 | any | - |
| class | 类名 | string | - |
| collapseHeight | 收起态保留的高度（像素） | number | `0` |
| duration | 动画时长（毫秒） | number | `250` |
| id | 元素 id | string | - |
| isOpen | 是否展开 | boolean | `false` |
| keepDOM | 收起态是否仍挂载子内容（默认收起且非 `keepDOM` 时不渲染子内容） | boolean | `false` |
| motion | 是否启用过渡动画 | boolean | `true` |
| style | 自定义样式 | object | - |

## Accessibility

- 容器在收起状态携带 `aria-hidden={true}`，展开后自动移除，避免屏幕阅读器读取到视觉不可见的内容。

## 设计变量

- `--lotus-color-border`（示例边框，非组件自身样式变量——Collapsible 本身是无样式的裸容器）
