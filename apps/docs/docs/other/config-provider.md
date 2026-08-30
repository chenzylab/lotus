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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| children | 子树内容 | any | - |
| direction | 文字方向，未传时跟随 `locale.dir` | `'ltr' \| 'rtl'` | - |
| locale | 子树内组件消费的语言包 | `LocaleShape` | `zhCN` |
| mode | 亮/暗主题模式 | `'light' \| 'dark'` | - |

> 架构说明：核对 Semi 一手来源确认其 `ConfigProvider` 的 Context 只有 `locale`/`direction`/`timeZone` 等字段，本身不承载主题能力（暗色模式是脱离 `ConfigProvider` 的全局 DOM 属性操作）。`mode` 是 lotus 自己 Phase 5 spec 承诺、Semi 没有对应实现的能力，选择让 `ConfigProvider` 承接是因为"全局配置容器"这个定位与它已有的 `locale` 职责一致，不是照搬 Semi API。
>
> `mode`/`direction` 都是写在 `document.documentElement` 上的全局副作用（对齐彼此的实现方式），不是局部子树样式隔离——多个嵌套的 `ConfigProvider` 后写入的会覆盖先写入的，卸载时会移除对应属性。

## Accessibility

- `ConfigProvider` 本身不渲染任何 DOM 节点，无独立的无障碍语义。
- `direction` 切换后，子树内组件读取 `locale.dir` 做 RTL 布局镜像与方向性图标翻转（如 Pagination/DatePicker 的翻页箭头）。

## 设计变量

- 无（`ConfigProvider` 本身不消费任何 `--lotus-*` 变量，`mode`/`direction` 只是触发下游组件重新应用各自的 token）。
