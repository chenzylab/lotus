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
| defaultActiveKey | 非受控模式下默认展开的面板 key | `string \| string[]` | - |
| expandIconPosition | 展开图标位置 | `'left' \| 'right'` | `'right'` |
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

## 设计变量

- `--lotus-color-border`
- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-0`（hover 背景）
