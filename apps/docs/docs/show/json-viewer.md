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

### 固定容器尺寸

设置 `width`/`height` 后，内容超出时容器内滚动，不撑开外部布局。

```tsrx demo
../../src/demos/show/json-viewer/size.tsrx
```

### 原地编辑

`editable` 开启后点击叶子节点的值即可进入编辑态，`Enter` 或失焦提交，`Esc` 取消。提交时按节点原始类型解析输入（`string` 类型原样保留，其余按 JSON 字面量解析，解析失败回退为字符串），通过 `onChange` 拿到更新后的完整数据。

```tsrx demo
../../src/demos/show/json-viewer/editable.tsrx
```

### 搜索

`showSearch` 开启后显示搜索框，匹配节点 key 或叶子展示值（大小写不敏感），命中的祖先节点自动展开，当前命中项高亮并滚动到可见区域，可通过"上一个"/"下一个"按钮循环跳转。

```tsrx demo
../../src/demos/show/json-viewer/search.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 无障碍标签 | string | 无 |
| class | 类名 | string | 无 |
| defaultExpandDepth | 默认展开层级，`0` 全部折叠，`Infinity` 全部展开 | number | `1` |
| editable | 是否允许点击叶子值原地编辑 | boolean | `false` |
| height | 容器高度，超出内容滚动 | number \| string | 无 |
| onChange | 编辑提交后触发，参数为更新后的完整数据 | (value: unknown) => void | 无 |
| showCopy | 是否显示复制按钮（复制格式化后的完整 JSON 文本） | boolean | `true` |
| showSearch | 是否显示搜索框 | boolean | `false` |
| style | 自定义样式 | object | 无 |
| value | 待展示的数据 | unknown | 无 |
| width | 容器宽度，超出内容滚动 | number \| string | 无 |

## Accessibility

- 展开/折叠为原生 `<button>`，工具栏"全部展开"/"全部折叠"按钮文案来自 `@lotus/locale`（`JsonViewer.expandAll`/`collapseAll`），随语言切换更新。
- 可编辑模式下，叶子值区域带 `role="button"`/`tabIndex={0}`，支持键盘 `Enter`/`Space` 进入编辑，编辑框有 `aria-label`（来自 `JsonViewer.editValue`）。
- 搜索框、上一个/下一个按钮文案均来自 `@lotus/locale`，随语言切换更新。

## 设计变量

- `--lotus-color-text-0` / `-text-2`
- `--lotus-color-fill-1`
- `--lotus-color-border`
