---
title: HotKeys 快捷键
category: 基础
---

快捷键组合监听 + 可选键位提示 UI。匹配算法（修饰键精确比较 + `code` 优先/`key` 回退）在 Foundation 层以纯函数实现，不维护"当前按下按键集合"，每次 `keydown` 独立判断。

## 代码演示

### 如何引入

```tsrx
import { HotKeys } from '@lotus/ripple';
```

### 基本用法

`hotKeys` 是恰好 1 个普通键 + 0~多个修饰键组成的数组（不是 `'ctrl+s'` 这种字符串），默认监听 `document.body`。未渲染键位提示时可传 `render={null}`。

```tsrx demo
../../src/demos/basic/hotkeys/basic.tsrx
```

### 可点击提示徽标

传入 `onClick` 后，键位提示徽标本身变为可点击元素（`role="button"`，支持 Tab 聚焦与 Enter/Space 触发），此时必须提供 `aria-label` 描述其用途。

```tsrx demo
../../src/demos/basic/hotkeys/clickable.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 传了 `onClick` 时提示徽标的可访问名称 | string | 无 |
| class | 类名 | string | 无 |
| content | 键位提示文案；不传则回退用 `hotKeys` 本身渲染 | string[] | 无 |
| getListenerTarget | 监听目标 | `() => HTMLElement` | `document.body` |
| hotKeys | 快捷键组合 | `HotKey[]` | 必填 |
| preventDefault | 匹配成功时是否阻止默认行为 | boolean | `false` |
| render | 自定义渲染内容；传 `null` 或返回 `null` 时不渲染任何节点 | `(() => any) \| any` | 无 |
| style | 自定义样式 | object | 无 |
| onClick | 点击提示徽标时的回调（同时使徽标具备 `role="button"`） | `() => void` | 无 |
| onHotKey | 快捷键匹配成功时的回调 | `(event: KeyboardEvent) => void` | 无 |

> `mergeMetaCtrl` 是对齐 Semi API 形状保留的死 prop，声明了但不改变匹配逻辑。

## Accessibility

- 传入 `onClick` 时，提示徽标携带 `role="button"`、`tabIndex={0}`、`aria-label`，支持键盘 Enter/Space 触发（对齐鼠标点击的等价操作）。
- 未传 `onClick` 时提示徽标是纯展示元素，不参与 Tab 顺序。
- 快捷键监听本身（`onHotKey`）是全局键盘事件监听，与页面上其他可聚焦元素的键盘操作相互独立，不冲突。

## 设计变量

- `--lotus-color-text-1`（提示文案颜色）
- `--lotus-color-text-3`（`+` 分隔符颜色）
- `--lotus-color-fill-1`（键位徽标背景）
- `--lotus-color-border`（键位徽标边框）
- `--lotus-border-radius-small`
