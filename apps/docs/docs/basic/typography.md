---
title: Typography 排版
category: 基础
---

用于文本内容的展示，包含标题、文本、段落、数值格式化四个子组件。

## 代码演示

### 如何引入

```tsrx
import { TypographyTitle, TypographyText, TypographyParagraph, TypographyNumeral } from '@lotus/ripple';
```

> 注意事项：Semi 官方用 `Typography.Title`/`Typography.Text`/`Typography.Paragraph` 静态属性写法，lotus 版本改为独立命名导出 `TypographyTitle`/`TypographyText`/`TypographyParagraph`（与 `Skeleton.Xxx` → `SkeletonXxx` 的处理方式一致，Ripple 没有等价的静态属性组合能力）。

### 标题组件

通过 `heading` 属性设置标题级别，可选 1~6，映射到对应的语义化 `<h1>`~`<h6>` 标签。

```tsrx demo
../../src/demos/basic/typography/title.tsrx
```

### 文本组件

`Text` 支持 `type`（primary/secondary/tertiary/quaternary/warning/danger/success）、`disabled`、`mark`、`code`、`delete`、`underline`、`strong`、`link` 等视觉修饰。

```tsrx demo
../../src/demos/basic/typography/text.tsrx
```

### 段落组件

```tsrx demo
../../src/demos/basic/typography/paragraph.tsrx
```

### 文本大小

`Text`/`Paragraph` 支持 `size`：`normal`（默认）、`small`。

```tsrx demo
../../src/demos/basic/typography/size.tsrx
```

### 可复制文本

设置 `copyable` 可以让文本旁边展示一个复制按钮；传对象可以通过 `content` 自定义实际复制的内容（与展示文本不同）。

> 注意事项：`copyable`/`ellipsis` 依赖读取文本的字符串内容，而 Ripple 编译器对 `<Text>纯文本</Text>` 这种 JSX 标签子节点写法会无条件包装成渲染句柄、无法在组件内部读取原始字符串；只有 `children={'...'}` 显式 prop 写法才会原样透传字符串。因此启用 `copyable`/`ellipsis` 时，必须用 `children={'...'}` 显式传入文本，不能用标签子节点写法。

```tsrx demo
../../src/demos/basic/typography/copyable.tsrx
```

### 省略文本

`ellipsis` 支持末尾/中间截断（`pos: 'end' | 'middle'`）、多行截断（`rows`）、展开收起（`expandable`/`collapsible`）、悬浮显示完整内容（`showTooltip`）。截断算法在挂载后于隐藏容器中做精确 DOM 测量（对齐 Semi `packages/semi-ui/typography/util.tsx` 的二分查找策略），而非简单的字符数估算。

```tsrx demo
../../src/demos/basic/typography/ellipsis.tsrx
```

### 自定义渲染元素

`component` 覆盖默认渲染标签：`Text` 默认 `span`，`Title` 默认由 `heading` 决定（`h1`~`h6`），`Paragraph` 默认 `p`。

```tsrx demo
../../src/demos/basic/typography/component.tsrx
```

### 数值格式化

`Numeral` 是 `Text` 的特化版本，格式化字符串中的数字片段后渲染。`rule` 支持 `text`（默认，仅按 `precision` 截断不额外处理）、`numbers`（提取数字用逗号 join）、`bytes-decimal`/`bytes-binary`（字节单位换算）、`percentages`（百分比）、`exponential`（科学计数法）；`truncate` 控制截断方式（`round`/`ceil`/`floor`）；`parser` 传入时忽略以上规则，直接用自定义函数处理。

> 注意事项：`children` 必须是纯字符串（`ellipsis`/`copyable` 的字符串限制同样适用于 `Numeral`，且更严格——`rule`/`precision` 依赖对内容做正则提取数字，非字符串场景直接透传原始 children 给 `Text`，不做格式化）。

```tsrx demo
../../src/demos/basic/typography/numeral.tsrx
```

## API 参考

### Text

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 文本内容，`ellipsis`/`copyable` 生效时必须用 `children={'...'}` 显式传入字符串 | any | - |
| code | 是否用 `code` 样式包裹 | boolean | false |
| component | 自定义渲染元素，`link` 场景下固定渲染 `<a>`，忽略此项 | string | "span" |
| copyable | 是否可拷贝 | boolean \| CopyableConfig | false |
| delete | 添加删除线样式 | boolean | false |
| disabled | 禁用文本 | boolean | false |
| ellipsis | 设置自动溢出省略 | boolean \| EllipsisConfig | false |
| icon | 前缀图标 | any | - |
| link | 是否为链接，传对象时属性透传给 `<a>` 标签 | boolean \| `{ href?, target?, [key: string]: any }` | false |
| mark | 添加标记样式 | boolean | false |
| size | 文本大小，可选 normal、small、inherit | string | "normal" |
| strong | 是否加粗 | boolean | false |
| type | 文本类型，可选 primary、secondary、tertiary、quaternary、warning、danger、success | string | "primary" |
| underline | 添加下划线样式 | boolean | false |
| weight | 设置字重，可选 light、regular、medium、semibold、bold、default | string | "default" |
| onClick | 单击事件 | `(event: MouseEvent) => void` | - |

### Title

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 标题内容 | any | - |
| component | 自定义渲染元素，覆盖 `heading` 决定的默认标签 | string | 由 heading 决定 |
| copyable | 是否可拷贝 | boolean \| CopyableConfig | false |
| delete | 添加删除线样式 | boolean | false |
| disabled | 禁用文本 | boolean | false |
| ellipsis | 设置自动溢出省略 | boolean \| EllipsisConfig | false |
| heading | 标题级别，可选 1~6 | number | 1 |
| link | 是否为链接 | boolean \| object | false |
| mark | 添加标记样式 | boolean | false |
| type | 文本类型 | string | "primary" |
| underline | 添加下划线样式 | boolean | false |
| weight | 设置字重 | string | "default" |

### Paragraph

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 段落内容 | any | - |
| component | 自定义渲染元素 | string | "p" |
| copyable | 是否可拷贝 | boolean \| CopyableConfig | false |
| delete | 添加删除线样式 | boolean | false |
| disabled | 禁用文本 | boolean | false |
| ellipsis | 设置自动溢出省略 | boolean \| EllipsisConfig | false |
| link | 是否为链接 | boolean \| object | false |
| mark | 添加标记样式 | boolean | false |
| size | 文本大小，可选 normal、small | string | "normal" |
| spacing | 行距大小，可选 normal、extended | string | "normal" |
| strong | 是否加粗 | boolean | false |
| type | 文本类型 | string | "primary" |
| underline | 添加下划线样式 | boolean | false |
| onClick | 单击事件 | `(event: MouseEvent) => void` | - |

### Numeral

除以下数值格式化专属属性外，其余属性（`type`/`disabled`/`mark`/`code`/`delete`/`underline`/`strong`/`link`/`icon`/`copyable`/`ellipsis`/`size`/`weight`/`component`/`style`/`class`/`aria-label`）与 `Text` 完全一致（`Numeral` 是 `Text` 的特化版本）。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 待格式化文本，必须是纯字符串 | string | - |
| rule | 解析规则，可选 text、numbers、bytes-decimal、bytes-binary、percentages、exponential | string | "text" |
| precision | 小数点后保留位数 | number | 0 |
| truncate | 截断取整方式，可选 ceil、floor、round | string | "round" |
| parser | 自定义数值解析函数，传入后忽略 rule/precision/truncate | `(value: string) => string` | - |

### EllipsisConfig

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| collapseText | 折叠的展示文本 | string | "收起" |
| collapsible | 是否支持折叠 | boolean | false |
| expandText | 展开的展示文本 | string | "展开" |
| expandable | 是否支持展开 | boolean | false |
| onExpand | 展开/收起的回调 | `(expanded: boolean, event: MouseEvent) => void` | - |
| pos | 省略截断的位置，支持 end、middle | string | "end" |
| rows | 省略溢出行数 | number | 1 |
| showTooltip | 截断后是否用 Tooltip 展示完整原文 | boolean | false |
| suffix | 始终展示的后缀 | string | - |

> 注意事项：lotus 的 `showTooltip` 是简化版布尔开关，不支持 Semi 的 `{ type: 'tooltip' \| 'popover', opts, renderTooltip }` 定制对象。

### CopyableConfig

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| content | 复制出的文本，未设置时默认复制 `children` | string | - |
| copyTip | 复制图标的提示内容 | any | - |
| icon | 自定义复制图标 | any | - |
| onCopy | 复制回调 | `(event, content: string, succeeded: boolean) => void` | - |
| render | 自定义渲染复制节点 | `(copied: boolean, doCopy: (event) => void) => any` | - |
| successTip | 复制成功的展示内容 | any | - |

## Accessibility

### ARIA

- `Title` 渲染为语义化的 `<h1>`~`<h6>` 标签，天然具备标题层级的可访问性语义。
- `link` 为对象时可传 `aria-label` 等标准 `<a>` 属性（通过 `{...linkConfig}` 透传）。

## 设计变量

- `--lotus-font-h1-size` ~ `--lotus-font-h6-size`（标题字号刻度）
- `--lotus-font-body-size` / `--lotus-font-label-size`（正文/小号文本字号）
- `--lotus-font-weight-light` / `regular` / `medium` / `semibold` / `bold`（字重五档）
- `--lotus-color-text-0` ~ `--lotus-color-text-3`（不同 type 的文本色）
- `--lotus-color-link` / `--lotus-color-link-hover` / `--lotus-color-link-active`（链接色）
- `--lotus-color-highlight-bg` / `--lotus-color-highlight`（mark 标记色）
