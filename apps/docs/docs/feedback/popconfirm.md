---
title: Popconfirm 气泡确认框
category: 反馈类
---

点击元素后弹出的确认气泡，用于代替浏览器原生的 `confirm` 弹窗，常用在删除、重置等有风险的操作前二次确认。

## 代码演示

### 如何引入

```tsrx
import { Popconfirm } from '@lotus/ripple';
```

### 基本用法

`children` 是触发元素，点击后弹出确认框，`onConfirm`/`onCancel` 分别对应确认/取消按钮的回调。

```tsrx demo
../../src/demos/feedback/popconfirm/basic.tsrx
```

### 异步确认

`onConfirm`/`onCancel` 返回 `Promise` 时，对应按钮会展示 loading 态直到 Promise resolve，确认框在此期间保持打开。

```tsrx demo
../../src/demos/feedback/popconfirm/async.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| cancelButtonProps | 透传给取消按钮的额外 Button props | ButtonProps | - |
| cancelText | 取消按钮文案 | string | 跟随 locale（默认"取消"） |
| cancelType | 取消按钮的 type | ButtonType | `tertiary` |
| children | 触发元素 | any | - |
| defaultVisible | 非受控模式下的初始可见性 | boolean | `false` |
| description | 描述文案 | any | - |
| disabled | 是否禁用触发 | boolean | `false` |
| icon | 自定义图标；传 `null` 时不展示图标 | any | - |
| okButtonProps | 透传给确认按钮的额外 Button props | ButtonProps | - |
| okText | 确认按钮文案 | string | 跟随 locale（默认"确定"） |
| okType | 确认按钮的 type | ButtonType | `primary` |
| showCloseIcon | 是否展示右上角关闭图标 | boolean | `true` |
| title | 标题 | any | - |
| visible | 受控可见性 | boolean | - |
| onCancel | 点击取消按钮时的回调，可返回 Promise | `(event: MouseEvent) => Promise<any> \| void` | - |
| onConfirm | 点击确认按钮时的回调，可返回 Promise | `(event: MouseEvent) => Promise<any> \| void` | - |
| onVisibleChange | 可见性变化时的回调 | `(visible: boolean) => void` | - |

其余 `Popover` 定位相关的 props（如 `position`）同样支持透传，详见 Popover 文档。

## Accessibility

- 内部基于 Popover 浮层实现，关闭后焦点归还到触发元素（确认/取消/点击外部/Esc 全部关闭路径均归还，是浮层类组件中覆盖最全的一个）。
- 支持 Esc 键关闭确认框。

## 设计变量

- `--lotus-color-warning`（默认图标颜色）
- `--lotus-color-text-0` / `-text-1`
- `--lotus-font-body-size` / `-font-label-size`
