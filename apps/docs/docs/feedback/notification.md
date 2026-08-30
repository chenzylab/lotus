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
| Notification.destroyAll | 关闭全部通知并卸载挂载容器 | `() => void` |

### NotificationOptions

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| content | 通知正文内容 | any | - |
| duration | 自动关闭时长（秒），传 `0` 时不自动关闭 | number | `3` |
| icon | 自定义图标 | any | - |
| id | 自定义 id，用于后续手动 `close` | string | 自动生成 |
| position | 弹出位置 | `top` \| `bottom` \| `topLeft` \| `topRight` \| `bottomLeft` \| `bottomRight` | `topRight` |
| showClose | 是否展示关闭按钮 | boolean | `true` |
| title | 标题 | any | - |

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
