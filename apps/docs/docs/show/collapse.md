---
title: Collapse 折叠面板
category: 展示类
---

将内容区域折叠/展开，支持手风琴模式（同时只展开一个面板）。

## 代码演示

### 如何引入

```tsrx
import { Collapse, CollapsePanel } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/collapse/basic.tsrx
```

### 手风琴模式

```tsrx demo
../../src/demos/show/collapse/accordion.tsrx
```

## API 参考

### Collapse

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| accordion | 手风琴模式：同时只能展开一个面板 | boolean | `false` |
| activeKey | 受控的展开面板 key（数组或单个字符串） | `string \| string[]` | - |
| aria-label | 设置 aria-label 属性 | string | - |
| children | `CollapsePanel` 子项 | any | - |
| clickHeaderToExpand | 点击整个标题区域是否触发展开/收起 | boolean | `true` |
| collapseIcon | 自定义收起状态图标（替换默认的向上 Chevron） | any | - |
| defaultActiveKey | 非受控模式下默认展开的面板 key | `string \| string[]` | - |
| expandIcon | 自定义展开状态图标（替换默认的向下 Chevron） | any | - |
| expandIconPosition | 展开图标位置 | `'left' \| 'right'` | `'right'` |
| keepDOM | 收起态是否保留 Panel 内容的 DOM（不销毁重建），透传给内部 Collapsible | boolean | `false` |
| lazyRender | 内容首次展开前不渲染，展开一次后即使收起也保留 DOM（需要 `keepDOM` 才有意义） | boolean | `false` |
| motion | 展开/收起是否有动画过渡，`false` 时立即切换 | boolean | `true` |
| style | 自定义样式 | object | - |
| onChange | 展开面板变化时的回调 | `(activeKey: string[], event: MouseEvent) => void` | - |

### CollapsePanel

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 面板内容 | any | - |
| class | 类名 | string | - |
| disabled | 是否禁用（不可展开/收起） | boolean | `false` |
| extra | 标题区右侧额外内容 | any | - |
| header | 标题内容 | any | - |
| itemKey | 面板唯一标识，对应 `Collapse` 的 `activeKey` | string | 必填 |
| showArrow | 是否显示展开箭头图标 | boolean | `true` |
| style | 自定义样式 | object | - |

## Accessibility

- 标题区携带 `role="button"`、`aria-expanded`（反映展开状态）、`aria-disabled`。
- 内容区在收起状态携带 `aria-hidden={true}`，避免屏幕阅读器读取到不可见内容。
- 展开箭头图标携带 `aria-hidden="true"`（纯装饰，语义已由标题区的 `aria-expanded` 表达）。

## 实现说明

Panel 内容区的展开/收起动画由内部的 [Collapsible](./collapsible) 组件承载：用 `ResizeObserver` 实测内容真实高度驱动 CSS `height` 过渡，不是 `max-height` 近似值——后者按声明的常量差值算过渡进度而非内容真实高度，短内容展开时视觉上大半时间在过渡"看不见的空白"，内容超过声明的上限还会被直接截断。

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-0`（hover 背景）
