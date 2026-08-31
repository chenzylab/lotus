---
title: Toast 提示
category: 反馈类
---

顶部居中的轻量级反馈提示，通过命令式 API 调用触发，由用户操作触发，用于展示操作结果状态。

## 代码演示

### 如何引入

```tsrx
import { Toast } from '@lotus/ripple';
```

### 基本用法

`Toast` 不是声明式组件，而是命令式单例 API：调用 `Toast.info()`/`Toast.success()`/`Toast.warning()`/`Toast.error()` 即可弹出提示，首次调用时才会懒挂载一个全局容器（`ensureMounted`），无需手动在组件树中放置 `<Toast>` 标签。参数可以是纯字符串，也可以是 `ToastOptions` 对象。

```tsrx demo
../../src/demos/feedback/toast/basic.tsrx
```

### 堆叠展示

`stack: true` 时同屏多条 Toast 会折叠堆叠，鼠标悬停展开，避免同时弹出多条时互相遮挡或过度打扰。

```tsrx demo
../../src/demos/feedback/toast/stack.tsrx
```

### 填充样式与最大宽度

`theme` 支持 `normal`（默认）与 `light`；`textMaxWidth` 控制内容最大宽度。

```tsrx demo
../../src/demos/feedback/toast/theme.tsrx
```

## API 参考

### Toast 静态方法

| 方法 | 说明 | 类型 |
| --- | --- | --- |
| Toast.info | 展示 info 类型提示 | `(opts: ToastOptions \| string) => string` |
| Toast.success | 展示 success 类型提示 | `(opts: ToastOptions \| string) => string` |
| Toast.warning | 展示 warning 类型提示 | `(opts: ToastOptions \| string) => string` |
| Toast.error | 展示 error 类型提示 | `(opts: ToastOptions \| string) => string` |
| Toast.close | 关闭指定 id 的提示 | `(id: string) => void` |
| Toast.config | 设置全局默认配置（`top`/`bottom`/`left`/`right`/`zIndex`/`theme`/`duration`），未被单次调用显式覆盖的字段才会生效；对已挂载的容器实时生效，无需 `destroyAll` 重新挂载 | `(config: ToastGlobalConfig) => void` |
| Toast.destroyAll | 关闭全部提示并卸载挂载容器 | `() => void` |

所有 `open` 类方法返回该条提示的 `id`，可用于后续 `Toast.close(id)`。

### ToastOptions

Semi 文档："Toast Options 支持以下 API 及 Config 中的 API"——即 `top`/`bottom`/`left`/`right`/`zIndex` 这类 Config 字段也可以在单次调用里传入，等价于临时更新一次全局配置（所有 Toast 共享同一个 wrapper 容器，不存在"每条各自独立位置"的概念）。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bottom | 覆盖弹出位置 bottom（等价于临时调用一次 `Toast.config`） | number \| string | 无 |
| content | 提示内容（必填） | any | 必填 |
| duration | 自动关闭时长（秒），传 `0` 时不自动关闭 | number | `3` |
| getPopupContainer | 指定挂载的父级 DOM；不同调用方指定不同容器时各自独立渲染 | `() => HTMLElement` | `document.body` |
| icon | 自定义图标 | any | - |
| id | 自定义 id，用于后续手动 `close` | string | 自动生成 |
| left | 覆盖弹出位置 left | number \| string | 无 |
| right | 覆盖弹出位置 right | number \| string | 无 |
| showClose | 是否展示关闭按钮 | boolean | `false` |
| stack | 是否加入堆叠折叠展示 | boolean | `false` |
| textMaxWidth | 内容的最大宽度 | number \| string | `450` |
| theme | 填充样式 | `'normal'` \| `'light'` | `'normal'` |
| top | 覆盖弹出位置 top | number \| string | 无 |
| zIndex | 弹层 z-index | number | 无 |
| onClose | 提示关闭时的回调（主动点击关闭、`duration` 到时自动关闭都会触发） | `() => void` | - |

### ToastGlobalConfig

`Toast.config()` 接受的配置对象，字段均可选。

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| bottom | 弹出位置 bottom 默认值 | number \| string | 无 |
| duration | 自动关闭时长（秒）默认值 | number | 无 |
| left | 弹出位置 left 默认值 | number \| string | 无 |
| right | 弹出位置 right 默认值 | number \| string | 无 |
| theme | 填充样式默认值 | `'normal'` \| `'light'` | 无 |
| top | 弹出位置 top 默认值 | number \| string | 无 |
| zIndex | 弹层 z-index 默认值 | number | 无 |

## Accessibility

- 每条提示携带 `role="alert"`，屏幕阅读器会在提示出现时主动播报。
- 关闭按钮的可访问名称来自 `@lotus/locale` 的 `Toast.close`，跟随 `ConfigProvider` 切换语言实时更新。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-shadow-elevated`
- `--lotus-color-success` / `-warning` / `-danger` / `-primary`（各类型图标颜色）
- `--lotus-color-text-0` / `-text-1`
- `--lotus-z-toast`
- `--lotus-border-radius-medium`
