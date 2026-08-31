---
title: Notification 通知
category: 反馈类
---

屏幕角落的通知提醒，通过命令式 API 调用触发，用于展示不需要用户立即处理但需要留意的信息。

## 代码演示

### 如何引入

```tsrx
import { Notification } from '@lotus/ripple';
```

### 基本用法

与 `Toast` 同为命令式单例 API：调用 `Notification.info()`/`Notification.success()`/`Notification.warning()`/`Notification.error()` 触发，支持 6 个弹出位置（`position`），不同位置各自独立分组渲染，互不影响。

```tsrx demo
../../src/demos/feedback/notification/basic.tsrx
```

### 填充样式

`theme` 支持 `normal`（默认，纯色卡片）与 `light`（各语义色浅底 + 同色边框）。

```tsrx demo
../../src/demos/feedback/notification/theme.tsrx
```

### 点击回调

`onClick` 在点击通知卡片本身时触发；`onCloseClick` 仅在点击关闭按钮时触发；`onClose` 在通知被移除时触发（无论是点击关闭按钮还是 `duration` 到时自动关闭）。

```tsrx demo
../../src/demos/feedback/notification/callback.tsrx
```

## API 参考

### Notification 静态方法

| 方法 | 说明 | 类型 |
| --- | --- | --- |
| Notification.open | 展示默认类型通知 | `(opts: NotificationOptions) => string` |
| Notification.info | 展示 info 类型通知 | `(opts: NotificationOptions) => string` |
| Notification.success | 展示 success 类型通知 | `(opts: NotificationOptions) => string` |
| Notification.warning | 展示 warning 类型通知 | `(opts: NotificationOptions) => string` |
| Notification.error | 展示 error 类型通知 | `(opts: NotificationOptions) => string` |
| Notification.close | 关闭指定 id 的通知 | `(id: string) => void` |
| Notification.config | 设置全局默认配置（`position`/`duration`/`top`/`bottom`/`left`/`right`/`zIndex`），未被单次调用显式覆盖的字段才会生效 | `(config: NotificationGlobalConfig) => void` |
| Notification.destroyAll | 关闭全部通知并卸载挂载容器 | `() => void` |

### NotificationOptions

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| content | 通知正文内容 | any | - |
| duration | 自动关闭时长（秒），传 `0` 时不自动关闭 | number | `3` |
| getPopupContainer | 指定挂载的父级 DOM；不同调用方指定不同容器时各自独立渲染 | `() => HTMLElement` | `document.body` |
| icon | 自定义图标 | any | - |
| id | 自定义 id，用于后续手动 `close` | string | 自动生成 |
| position | 弹出位置 | `top` \| `bottom` \| `topLeft` \| `topRight` \| `bottomLeft` \| `bottomRight` | `topRight` |
| showClose | 是否展示关闭按钮 | boolean | `true` |
| theme | 填充样式 | `'normal'` \| `'light'` | `'normal'` |
| title | 标题 | any | - |
| zIndex | 弹层 z-index | number | 无 |
| onClick | 点击通知卡片本身时的回调（点击关闭按钮不触发） | `(event: MouseEvent) => void` | - |
| onClose | 通知关闭时的回调（主动点击关闭、`duration` 到时自动关闭都会触发） | `() => void` | - |
| onCloseClick | 主动点击关闭按钮时的回调（先于 `onClose` 触发） | `(id: string) => void` | - |

### NotificationGlobalConfig

`Notification.config()` 接受的配置对象，字段均可选，只影响调用 `config()` 之后、未显式指定对应字段的通知。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bottom | 覆盖 `bottom`/`bottomLeft`/`bottomRight` 位置的 `bottom` 偏移 | number \| string | 无 |
| duration | 自动关闭时长（秒）默认值 | number | 无 |
| left | 覆盖 `topLeft`/`bottomLeft` 位置的 `left` 偏移 | number \| string | 无 |
| position | 弹出位置默认值 | `NotificationPosition` | 无 |
| right | 覆盖 `topRight`/`bottomRight` 位置的 `right` 偏移 | number \| string | 无 |
| top | 覆盖 `top`/`topLeft`/`topRight` 位置的 `top` 偏移 | number \| string | 无 |
| zIndex | 弹层 z-index 默认值 | number | 无 |

## Accessibility

- 每条通知携带 `role="alert"`。
- 核对 Semi 一手来源确认 Notification 完全不做任何焦点操作（非模态通知本就不该抢焦点，符合 `role="alert"` 的既定语义），关闭按钮的可访问名称来自 `@lotus/locale` 的 `Notification.close`。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-shadow-elevated`
- `--lotus-color-success` / `-warning` / `-danger` / `-primary`（各类型图标颜色）
- `--lotus-color-text-0` / `-text-1`
- `--lotus-z-notification`
- `--lotus-border-radius-medium`
