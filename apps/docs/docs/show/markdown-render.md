---
title: MarkdownRender Markdown 渲染
category: 展示类
---

将 Markdown 原文渲染为格式化内容。解析管线基于 `remark`（Markdown → mdast）+ `rehype`（mdast → hast），渲染时把标题/段落/链接/图片/表格统一替换为对应的 lotus 组件（`Typography`/`Image`/`Table`），而非原生 HTML 标签 + CSS 样式化——保持与库内其它内容一致的视觉与交互（对齐 Semi Design `markdownRender/components/` 的设计）；代码块高亮复用 `CodeHighlight` 的 Prism 方案。

## 代码演示

### 如何引入

```tsrx
import { MarkdownRender } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/markdown-render/basic.tsrx
```

### GFM 扩展语法（表格 / 任务列表）

`remarkGfm`（默认开启）支持 GitHub Flavored Markdown 扩展：表格、任务列表、删除线、自动链接等。

```tsrx demo
../../src/demos/show/markdown-render/gfm-table.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | 无 |
| raw | Markdown 原文 | string | `''` |
| rehypePlugins | 额外的 rehype 插件（hast 阶段） | `UnifiedPluginEntry[]` | 无 |
| remarkGfm | 是否启用 GFM 扩展语法 | boolean | `true` |
| remarkPlugins | 额外的 remark 插件（mdast 阶段） | `UnifiedPluginEntry[]` | 无 |
| style | 自定义样式 | object | 无 |

## 元素映射

| Markdown 语法 | 渲染组件 | 说明 |
| --- | --- | --- |
| `# ~ ######` | `TypographyTitle` | `heading` 对应标题层级，底层标签仍是 `<h1>`-`<h6>` |
| 段落 | `TypographyParagraph` | |
| `[text](url)` | `TypographyText`（`link` 配置） | 底层渲染为 `<a>`，`href`/`target` 透传 |
| `![alt](src)` | `Image` | 宽度自适应容器，下方展示 `alt` 文案 |
| GFM 表格 | `Table` | 提取表头/表体后交给 Table 组件渲染，非原生 `<table>` + CSS |
| 围栏代码块 | `CodeHighlight` | 语言取自 ```` ```lang ```` 围栏标记，`lineNumber` 默认开启 |
| 行内代码 | `span.lotus-markdown-render-simple-code` | 未复用 CodeHighlight（对齐 Semi：行内代码不做语法高亮） |

## Accessibility

- 标题/段落/链接底层仍渲染标准语义化标签（`<h1>`-`<h6>`/`<a>`），保留 Markdown 原有的文档结构语义，屏幕阅读器可正常按标题层级导航。
- 内容变化时异步重新编译，用 stale 标记丢弃过期请求的结果，避免快速连续更新时出现内容闪烁或倒序覆盖。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-1`
- `--lotus-color-border`
