---
title: ConfigProvider 全局配置
category: 其他
---

全局配置容器，用 Context 向子树注入语言、主题、文字方向。不渲染任何自身 DOM，只是配置的传递层。

## 代码演示

### 如何引入

```tsrx
import { ConfigProvider } from '@lotus/ripple';
```

### 语言切换

`locale` 切换后子树内组件的文案（含 Form 校验错误信息）实时更新，不需要重新挂载——文案走响应式 Context 读取，不是挂载时读取一次的静态值。

```tsrx demo
../../src/demos/other/config-provider/locale.tsrx
```

### 主题模式切换

`mode` 写入 `document.documentElement` 的 `data-theme` 属性，全局生效（不局限于 `ConfigProvider` 包裹的子树）。未传时不写入该属性，交给页面自己决定（如 `prefers-color-scheme` 或手动设置）。

```tsrx demo
../../src/demos/other/config-provider/mode.tsrx
```

### 文字方向切换

`direction` 写入 `document.documentElement` 的 `dir` 属性，全局生效。未传时跟随 `locale.dir`（每个语言包自带默认方向）。

```tsrx demo
../../src/demos/other/config-provider/direction.tsrx
```

### 全局默认浮层容器

`getPopupContainer` 下发给子树内所有浮层类组件（Popover/Tooltip/Dropdown 及基于它们实现的 Select/DatePicker/TimePicker 等）作为兜底——组件自身未显式传 `getPopupContainer` 时才会读取这个全局默认值。

```tsrx demo
../../src/demos/other/config-provider/popup-container.tsrx
```

### 全局默认时区

`timeZone` 下发给 DatePicker/TimePicker 作为兜底默认时区。组件内部始终按“本机墙钟时间”保存状态，只有 `value` 传入与 `onChange` 传出这两个边界会把时区时刻与本机时刻互转（不是让面板整体切换时区显示）。

```tsrx demo
../../src/demos/other/config-provider/time-zone.tsrx
```

### 响应式断点监听

`responsiveObserve` 开启后，`onBreakpoint` 可订阅断点变化（懒注册：无订阅者时不会注册任何 `matchMedia` 监听）；`responsiveMap` 可自定义断点媒体查询。

```tsrx demo
../../src/demos/other/config-provider/responsive.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 子树内容 | any | - |
| direction | 文字方向，未传时跟随 `locale.dir` | `'ltr' \| 'rtl'` | - |
| getPopupContainer | 全局默认的浮层挂载容器，浮层类组件自身未显式传该 prop 时兜底使用 | `() => HTMLElement \| null` | - |
| locale | 子树内组件消费的语言包 | `LocaleShape` | `zhCN` |
| mode | 亮/暗主题模式 | `'light' \| 'dark'` | - |
| responsiveMap | 自定义响应式断点媒体查询 | `Record<'xs'\|'sm'\|'md'\|'lg'\|'xl'\|'xxl', string>` | 内置默认断点 |
| responsiveObserve | 是否启用断点监听；关闭时不注册任何 `matchMedia` | boolean | `false` |
| timeZone | 全局默认时区，DatePicker/TimePicker 自身未显式传 `timeZone` 时兜底使用 | `string \| number` | - |

> 架构说明：核对 Semi 一手来源确认其 `ConfigProvider` 的 Context 只有 `locale`/`direction`/`timeZone`/`getPopupContainer`/`responsiveMap`/`responsiveObserve` 等字段，本身不承载主题能力（暗色模式是脱离 `ConfigProvider` 的全局 DOM 属性操作）。`mode` 是 lotus 自己 Phase 5 spec 承诺、Semi 没有对应实现的能力，选择让 `ConfigProvider` 承接是因为"全局配置容器"这个定位与它已有的 `locale` 职责一致，不是照搬 Semi API。
>
> `mode`/`direction` 都是写在 `document.documentElement` 上的全局副作用（对齐彼此的实现方式），不是局部子树样式隔离——多个嵌套的 `ConfigProvider` 后写入的会覆盖先写入的，卸载时会移除对应属性。
>
> `getPopupContainer` 本身不做任何 DOM 操作，只是把函数原样透传给 Context；实际的兜底逻辑在 Popover/Tooltip 内部——`resolvePortalTarget()` 优先用组件自身的 `getPopupContainer` prop，其次读 `ConfigProvider` 下发的全局值，最后兜底 `document.body`。Dropdown 及所有基于 Popover 实现浮层的输入类组件（Select/AutoComplete/Cascader/TreeSelect/DatePicker/TimePicker 等）都透传同名 prop 给 Popover，因此自动继承这条兜底链路，不需要逐个组件重复接线。
>
> `timeZone` 的转换语义对齐 Semi：假设用户机器系统时区为 UTC+8，`timeZone="GMT+09:00"`，用户在面板选择了「22:00」——组件内部按本机时区把这次选择存成 `22:00`（UTC+8 的墙钟时间），但对外 `onChange` 通知的是「UTC+9 的 22:00」换算成的 UTC 时刻（即 UTC+8 的 21:00）；反过来外部传入 `value` 时按同样规则从 UTC 时刻换算回本机墙钟时间显示。取值支持 IANA 时区名（如 `Asia/Shanghai`）、`GMT±HH:00` 写法、或数值小时偏移（支持 `5.5` 这类半小时制）。
>
> `responsiveObserve`/`onBreakpoint`/`responsiveMap` 对齐 Semi：`responsiveObserve` 默认 `false`（不注册任何监听），首个 `onBreakpoint` 订阅者出现时才真正注册 `matchMedia`，最后一个订阅者退订后立即注销，避免无人使用时的常驻开销。

## Accessibility

- `ConfigProvider` 本身不渲染任何 DOM 节点，无独立的无障碍语义。
- `direction` 切换后，子树内组件读取 `locale.dir` 做 RTL 布局镜像与方向性图标翻转（如 Pagination/DatePicker 的翻页箭头）。

## 设计变量

- 无（`ConfigProvider` 本身不消费任何 `--lotus-*` 变量，`mode`/`direction` 只是触发下游组件重新应用各自的 token）。
