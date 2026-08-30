---
title: JsonViewer JSON 查看器
category: 展示类
---

以树形结构展示 JSON 数据，支持节点展开/折叠与一键复制格式化文本。

## 代码演示

### 如何引入

```tsrx
import { JsonViewer } from '@lotus/ripple';
```

### 基本用法

`value` 接受已解析的对象/数组/原始值，也接受 JSON 字符串。默认只展开根节点（`defaultExpandDepth={1}`）。

```tsrx demo
../../src/demos/show/json-viewer/basic.tsrx
```

### 控制默认展开深度

`defaultExpandDepth={Infinity}` 全部展开，`0` 全部折叠。

```tsrx demo
../../src/demos/show/json-viewer/expand-depth.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| class | 类名 | string | 无 |
| defaultExpandDepth | 默认展开层级，`0` 全部折叠，`Infinity` 全部展开 | number | `1` |
| showCopy | 是否显示复制按钮（复制格式化后的完整 JSON 文本） | boolean | `true` |
| style | 自定义样式 | object | 无 |
| value | 待展示的数据 | unknown | 无 |

## Accessibility

- 展开/折叠为原生 `<button>`，工具栏"全部展开"/"全部折叠"按钮文案来自 `@lotus/locale`（`JsonViewer.expandAll`/`collapseAll`），随语言切换更新。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-1`
- `--lotus-color-border`
