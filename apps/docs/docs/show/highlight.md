---
title: Highlight 关键词高亮
category: 展示类
---

在一段文本中高亮显示指定的关键词，常用于搜索结果展示。

## 代码演示

### 如何引入

```tsrx
import { Highlight } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/highlight/basic.tsrx
```

### 自定义样式

`searchWords` 传对象数组时，每个关键词可以有独立的 `className`/`style`。

```tsrx demo
../../src/demos/show/highlight/custom-style.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| autoEscape | 是否自动转义 `searchWords` 中的正则特殊字符 | boolean | `true` |
| caseSensitive | 匹配是否区分大小写 | boolean | `false` |
| class | 类名 | string | - |
| component | 高亮片段的渲染标签 | `'mark' \| 'span' \| 'strong' \| 'em'` | `'mark'` |
| highlightClassName | 所有高亮片段的统一类名 | string | - |
| highlightStyle | 所有高亮片段的统一样式 | object | - |
| searchWords | 要高亮的关键词，字符串或 `{ text, className?, style? }` 对象 | `HighlightSearchWordInput[]` | `[]` |
| sourceString | 源文本 | string | `''` |
| style | 外层容器自定义样式 | object | - |

## Accessibility

- 默认用原生 `<mark>` 标签渲染高亮片段，浏览器/屏幕阅读器天然识别其"标记高亮"语义，不需要额外 ARIA 属性。

## 设计变量

- `--lotus-color-highlight-bg`（高亮背景色）
- `--lotus-color-highlight`（高亮文字色）
