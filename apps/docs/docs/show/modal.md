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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| afterClose | 关闭动画结束后的回调 | `() => void` | 无 |
| aria-label | 设置 aria-label 属性 | string | 无 |
| bodyStyle | 内容区域自定义样式 | object | 无 |
| cancelLoading | 取消按钮 loading 态 | boolean | `false` |
| cancelText | 取消按钮文案 | string | 本地化默认值 |
| centered | 是否垂直居中 | boolean | `false` |
| class | 类名 | string | 无 |
| closable | 是否显示右上角关闭按钮 | boolean | `true` |
| closeOnEsc | 是否支持 Esc 关闭 | boolean | `true` |
| confirmLoading | 确定按钮 loading 态 | boolean | `false` |
| footer | 自定义底部内容，覆盖默认按钮组 | any | 无 |
| fullScreen | 是否全屏展示 | boolean | `false` |
| hasCancel | 是否显示取消按钮 | boolean | `true` |
| header | 自定义头部内容，覆盖默认标题栏 | any | 无 |
| height | 高度 | string \| number | 无 |
| mask | 是否显示遮罩 | boolean | `true` |
| maskClosable | 点击遮罩是否关闭 | boolean | `true` |
| okText | 确定按钮文案 | string | 本地化默认值 |
| okType | 确定按钮类型 | `ButtonType` | `'primary'` |
| size | 尺寸 | `ModalSize` | `'medium'` |
| style | 自定义样式 | object | 无 |
| title | 标题 | any | 无 |
| visible | 是否显示 | boolean | `false` |
| width | 宽度 | string \| number | 无 |
| zIndex | 层级 | number | 无 |
| onCancel | 点击取消/关闭按钮/遮罩/Esc 时的回调 | `(event) => void \| Promise<any>` | 无 |
| onOk | 点击确定按钮时的回调（可返回 Promise 驱动 `confirmLoading`） | `(event) => void \| Promise<any>` | 无 |

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
