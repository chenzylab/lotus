---
title: Anchor 锚点
category: 导航类
---

用于跳转到页面指定位置，并高亮当前滚动到的锚点链接。

## 代码演示

### 如何引入

```tsrx
import { Anchor } from '@lotus/ripple';
```

### 基本用法

`links` 为扁平数组，`getContainer` 指定滚动监听的容器（不传则监听 `window`）。点击链接会平滑滚动到目标元素，滚动过程中根据各目标元素与容器顶部的距离自动计算并高亮当前锚点。

```tsrx demo
../../src/demos/navigation/anchor/basic.tsrx
```

### 嵌套锚点

`links` 数组项可通过 `children` 嵌套子锚点，渲染时按层级缩进。

```tsrx demo
../../src/demos/navigation/anchor/nested.tsrx
```

### AnchorLink 声明式写法

除 `links` 数组外，也可以用嵌套的 `<AnchorLink>` 子组件声明每个锚点（对齐 Semi `<Anchor><Anchor.Link>` 的 JSX 嵌套视觉），层级由 `<AnchorLink>` 的嵌套关系自动推导。`disabled` 禁用单个链接。两种写法二选一，`links` 存在时优先生效。

```tsrx demo
../../src/demos/navigation/anchor/declarative.tsrx
```

### autoCollapse + showTooltip

`autoCollapse` 让非激活链接的子链接自动折叠隐藏，点击父链接后展开；`showTooltip` 在标题过长被省略时 hover 展示完整标题。

```tsrx demo
../../src/demos/navigation/anchor/advanced.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| activeLink | 受控的当前高亮锚点 href | string | - |
| aria-label | 设置 aria-label 属性 | string | - |
| autoCollapse | 非激活链接的子链接自动折叠隐藏 | boolean | `false` |
| children | `<AnchorLink>` 声明式子组件写法（与 `links` 二选一） | any | - |
| class | 类名 | string | - |
| defaultActiveLink | 非受控模式下的默认高亮锚点 href | string | - |
| getContainer | 滚动监听的容器，不传则监听 `window` | `() => HTMLElement \| Window` | - |
| links | 锚点链接数组写法，每项为 `{ href, title, disabled?, children? }`（与 `children` 声明式写法二选一） | `AnchorLinkInput[]` | - |
| maxHeight / maxWidth | 容器最大高/宽，超出后滚动 | `string \| number` | - |
| offsetTop | 计算高亮命中的顶部偏移量 | number | `0` |
| position | 锚点栏位置，影响滑块方向与文字对齐 | `'left' \| 'right'` | `'left'` |
| railTheme | 滑块/高亮态颜色主题 | `'primary' \| 'muted'` | `'primary'` |
| scrollMotion | 点击后滚动是否带平滑动画 | boolean | `false` |
| showTooltip | 标题过长被省略时 hover 展示完整标题 | `boolean \| { position?: string }` | `false` |
| size | 尺寸 | `'default' \| 'small'` | `'default'` |
| style | 自定义样式 | object | - |
| targetOffset | 点击后滚动目标位置的独立偏移量，默认与 `offsetTop` 相同 | number | - |
| onChange | 高亮锚点变化时的回调 | `(currentLink: string \| null, previousLink: string \| null) => void` | - |
| onClick | 点击锚点链接时的回调（先于滚动触发） | `(event: MouseEvent, link: string) => void` | - |

`AnchorLink`（`<AnchorLink href title disabled>`）props：`href`（必填）、`title`、`disabled`、`children`（嵌套 `AnchorLink` 表达子锚点层级）。

> 实现说明：Ripple 无 `React.cloneElement` 等反射/克隆能力，`AnchorLink` 通过 Context 双层机制实现声明式写法——mount 时把自己注册进 `Anchor` 的状态表（同 `Form.Field` 的 `registerField` 模式），层级由子孙 `AnchorLink` 读取父级 Context 自动 +1 还原。**已知限制**：多个顶层 `AnchorLink` 兄弟之间的相对顺序取决于各自注册的时序，不保证与 JSX 书写顺序完全一致（同一父节点下的父子关系顺序不受影响，始终正确）；追求顺序确定性的场景建议使用 `links` 数组写法。

## Accessibility

- 根容器可通过 `aria-label` 描述其用途；组件本身用原生 `<a>` 标签渲染各锚点链接，天然可被 Tab 聚焦、Enter 触发。
- `disabled` 链接携带 `aria-disabled="true"` 且不响应点击。

## 设计变量

- `--lotus-color-border`（左侧分隔线）
- `--lotus-color-text-1`（默认文字色）
- `--lotus-color-primary`（hover/高亮态文字色）
- `--lotus-font-body-size` / `-label-size`
- `--lotus-font-weight-semibold`（高亮态字重）
