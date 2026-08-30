---
title: CodeHighlight 代码高亮
category: 展示类
---

代码块语法高亮展示。基于 Prism.js 手动高亮模式（`Prism.manual = true`，不自动扫描 DOM），就地写纯文本节点后交给 Prism 处理，不经 `innerHTML`/`{@html}`，规避 XSS 风险。

## 代码演示

### 如何引入

```tsrx
import { CodeHighlight } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/code-highlight/basic.tsrx
```

### 不显示行号

```tsrx demo
../../src/demos/show/code-highlight/no-line-number.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | 无 |
| code | 代码内容 | string | `''` |
| defaultTheme | 是否使用内置默认主题样式 | boolean | `true` |
| language | 语言（决定语法高亮规则），已注册 markup/clike/javascript/css/typescript/jsx/tsx/bash/json | string | `'markup'` |
| lineNumber | 是否显示行号 | boolean | `true` |
| style | 自定义样式 | object | 无 |

## Accessibility

- 渲染为原生 `<pre><code>` 结构，屏幕阅读器可正常读取代码文本内容；高亮只影响视觉颜色，不影响文本可读性。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-1`
