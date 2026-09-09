---
title: Modal 对话框
category: 展示类
---

模态对话框，用于承载需要用户处理但不希望跳转页面的信息。默认带焦点陷阱与 Esc 关闭、遮罩点击关闭能力。

## 代码演示

### 如何引入

```tsrx
import { Modal } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/modal/basic.tsrx
```

### 自定义 footer

传入 `footer` 完全替换默认的"确定/取消"按钮组。

```tsrx demo
../../src/demos/show/modal/custom-footer.tsrx
```

### icon / closeIcon / footerFill

`icon` 在标题旁展示自定义图标；`closeIcon` 替换右上角默认关闭图标；`footerFill` 让底部确定/取消按钮撑满宽度各占一半。

```tsrx demo
../../src/demos/show/modal/icon-footer-fill.tsrx
```

### motion / keepDOM / lazyRender

`motion=false` 关闭展开/收起过渡动画，立即显隐；`keepDOM` 关闭后内容不从 DOM 卸载（只是 CSS 隐藏），配合 `lazyRender`（默认 `true`）控制首次挂载时是否提前渲染。

```tsrx demo
../../src/demos/show/modal/motion-keep-dom.tsrx
```

### getPopupContainer / maskFixed

`getPopupContainer` 指定浮层挂载的目标容器，不传则挂载到 `document.body`；挂载到非 `document.body` 容器时默认相对该容器定位，`maskFixed` 可强制保持 `position: fixed`。

```tsrx demo
../../src/demos/show/modal/popup-container.tsrx
```

### cancelButtonProps / okButtonProps

透传给取消/确认按钮的额外 `Button` props。

```tsrx demo
../../src/demos/show/modal/button-props.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| afterClose | 关闭动画结束后的回调 | `() => void` | 无 |
| aria-label | 设置 aria-label 属性 | string | 无 |
| bodyStyle | 内容区域自定义样式 | object | 无 |
| cancelButtonProps | 透传给取消按钮的额外 props | `Partial<ButtonProps>` | 无 |
| cancelLoading | 取消按钮 loading 态 | boolean | `false` |
| cancelText | 取消按钮文案 | string | 本地化默认值 |
| centered | 是否垂直居中 | boolean | `false` |
| class | 类名 | string | 无 |
| closable | 是否显示右上角关闭按钮 | boolean | `true` |
| closeIcon | 自定义关闭按钮图标，默认 `IconClose` | any | 无 |
| closeOnEsc | 是否支持 Esc 关闭 | boolean | `true` |
| confirmLoading | 确定按钮 loading 态 | boolean | `false` |
| footer | 自定义底部内容，覆盖默认按钮组 | any | 无 |
| footerFill | 底部确定/取消按钮是否撑满宽度 | boolean | `false` |
| fullScreen | 是否全屏展示 | boolean | `false` |
| getPopupContainer | 浮层挂载的目标容器 | `() => HTMLElement` | `() => document.body` |
| hasCancel | 是否显示取消按钮 | boolean | `true` |
| header | 自定义头部内容，覆盖默认标题栏 | any | 无 |
| height | 高度 | string \| number | 无 |
| icon | 标题旁自定义图标 | any | 无 |
| keepDOM | 关闭时是否保留内部 DOM 不销毁 | boolean | `false` |
| lazyRender | 配合 keepDOM 使用，为 `true` 时挂载时不提前渲染，等首次展开后才渲染 | boolean | `true` |
| mask | 是否显示遮罩 | boolean | `true` |
| maskClosable | 点击遮罩是否关闭 | boolean | `true` |
| maskFixed | 挂载到非 `document.body` 容器时，遮罩/内容是否仍固定定位 | boolean | `false` |
| maskStyle | 遮罩自定义样式 | object | 无 |
| modalContentClass | 对话框内容容器的自定义类名（与顶层 `class` 分开） | string | 无 |
| motion | 展开/收起是否带过渡动画 | boolean | `true` |
| okButtonProps | 透传给确认按钮的额外 props | `Partial<ButtonProps>` | 无 |
| okText | 确定按钮文案 | string | 本地化默认值 |
| okType | 确定按钮类型 | `ButtonType` | `'primary'` |
| preventScroll | 聚焦时是否阻止浏览器自动滚动到视口 | boolean | 无 |
| size | 尺寸 | `ModalSize` | `'medium'` |
| style | 自定义样式 | object | 无 |
| title | 标题 | any | 无 |
| visible | 是否显示 | boolean | `false` |
| width | 宽度 | string \| number | 无 |
| zIndex | 层级 | number | 无 |
| onCancel | 点击取消/关闭按钮/遮罩/Esc 时的回调 | `(event) => void \| Promise<any>` | 无 |
| onOk | 点击确定按钮时的回调（可返回 Promise 驱动 `confirmLoading`） | `(event) => void \| Promise<any>` | 无 |

> 注意事项：Semi 的 `content`（对话框内容）是自身的 dead prop——`propTypes` 里未声明，`ModalReactProps` 类型声明了但源码 `renderDialog`/`ModalContent` 从未消费，实际内容渲染始终走 `children`，不是文档遗漏。`modalRender`（自定义包裹渲染整个 Modal 内容的函数）未实现：当前 tsrx 编译器版本里，把组件本体内的 JSX 抽到一个普通函数（`function foo() { return <div>...</div> }`）中再调用会丢失该组件 `<style>` 块的自动 scope class（编译器架构性设计——scope 收集穿过嵌套组件作用域，但明确不穿过用户函数边界，仅供编译器自身合成闭包的内部标记除外），导致 CSS 完全失效，无法在保留样式作用域的前提下支持这种"包裹渲染结果"的写法。

## Accessibility

- 打开时启用焦点陷阱（Tab 循环限制在 Modal 内部），关闭后焦点归还到触发元素。
- `closeOnEsc` 默认开启，Esc 键关闭。
- 打开时锁定 `body` 滚动（引用计数实现，与 SideSheet 共用同一套滚动锁定逻辑，多个浮层嵌套时互不干扰）。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-overlay-bg`
- `--lotus-border-radius-medium`
- `--lotus-shadow-elevated`
- `--lotus-z-modal`
