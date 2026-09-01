---
title: TagInput 标签输入框
category: 输入类
---

自由文本输入，按分隔符拆分成多个标签。纯输入型组件，无候选下拉（不是 AutoComplete）。

## 代码演示

### 如何引入

```tsrx
import { TagInput } from '@lotus/ripple';
```

### 基本用法

按 Enter 或分隔符（默认逗号）新增标签，输入框为空时按 Backspace 删除最后一个标签。

```tsrx demo
../../src/demos/input/tag-input/basic.tsrx
```

### maxTagCount 折叠

超出 `maxTagCount` 的标签折叠为 "+N"，`showRestTagsPopover`（默认开启）时 hover 展示被折叠的标签，点击 "+N" 可展开/收起。

```tsrx demo
../../src/demos/input/tag-input/fold.tsrx
```

### 拖拽排序

`draggable` 开启后每个标签左侧出现拖拽手柄，支持二维拖拽换位（flex-wrap 换行布局下也能正确判定目标位置）。

```tsrx demo
../../src/demos/input/tag-input/draggable.tsrx
```

### maxLength 单标签字符限制

`maxLength` 限制按分隔符拆分后每一段的最大字符数，超限时该次输入变更被拒绝并触发 `onInputExceed`（不限制标签总数，那是 `max` 的职责）。

```tsrx demo
../../src/demos/input/tag-input/max-length.tsrx
```

### 自定义标签渲染

`renderTagItem` 可以完全替换默认的 `Tag` 渲染，接收 `(value, index, onClose)`；`showContentTooltip`（默认 `true`）控制内容超长时是否省略并展示完整内容的 `title` 提示；`clearIcon` 覆盖默认的清除按钮图标。

```tsrx demo
../../src/demos/input/tag-input/render-tag-item.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| addOnBlur | 失焦时是否把输入框剩余内容提交为新标签 | boolean | `false` |
| allowDuplicates | 是否允许重复标签 | boolean | `true` |
| aria-label | 设置 aria-label 属性 | string | - |
| autoFocus | 挂载后是否自动聚焦输入框 | boolean | `false` |
| class | 类名 | string | - |
| clearIcon | 自定义清除按钮图标，覆盖默认的 `IconClear` | any | - |
| defaultValue | 非受控模式下的默认标签数组 | string[] | `[]` |
| disabled | 是否禁用 | boolean | `false` |
| draggable | 是否支持拖拽排序 | boolean | `false` |
| expandRestTagsOnClick | 点击折叠气泡本身是否展开剩余标签 | boolean | `true` |
| inputValue | 受控的输入框文本 | string | - |
| max | 最多允许的标签数量 | number | - |
| maxLength | 单个标签片段（按 separator 拆分后每一段）的最大字符数，超限拒绝该次输入并触发 `onInputExceed` | number | - |
| maxTagCount | 超出后折叠展示的标签数量阈值 | number | - |
| placeholder | 占位提示文字（仅无标签时显示） | string | - |
| preventScroll | `autoFocus` 聚焦时是否阻止浏览器自动滚动到视口 | boolean | - |
| prefix | 前缀内容 | any | - |
| renderTagItem | 自定义单个标签的渲染，接收 `(value, index, onClose)`，替换默认的 `Tag` 渲染 | `(value: string, index: number, onClose: () => void) => any` | - |
| restTagsPopoverProps | 折叠气泡 Popover 的透传配置（`children`/`content` 由组件自己控制） | object | - |
| separator | 触发拆分新增的分隔符 | string | `,` |
| showClear | 有标签时是否展示清除全部按钮 | boolean | `false` |
| showContentTooltip | 标签内容超出时是否省略并展示完整内容的 `title` 提示 | boolean | `true` |
| showRestTagsPopover | 折叠时 hover "+N" 是否弹出展示被折叠的标签 | boolean | `true` |
| size | 尺寸 | `small` \| `default` \| `large` | `default` |
| split | 自定义拆分函数，覆盖默认按 `separator` 拆分的逻辑 | `(originString: string, separator: Separator) => string[]` | - |
| style | 自定义样式 | object | - |
| suffix | 后缀内容 | any | - |
| value | 受控的标签数组 | string[] | - |
| onAdd | 新增标签时的回调 | `(addedValue: string[]) => void` | - |
| onBlur | 输入框失焦时的回调 | `(event: FocusEvent) => void` | - |
| onChange | 标签数组变化时的回调 | `(value: string[]) => void` | - |
| onExceed | 超过 `max` 限制时的回调 | `(value: string[]) => void` | - |
| onFocus | 输入框聚焦时的回调 | `(event: FocusEvent) => void` | - |
| onInputChange | 输入框文本变化时的回调 | `(value: string) => void` | - |
| onInputExceed | 单次输入超过 `maxLength` 时的回调 | `(value: string) => void` | - |
| onKeyDown | 原生 keydown 事件透传（在 Foundation 处理完 Enter/Backspace 之后仍会触发） | `(event: KeyboardEvent) => void` | - |
| onRemove | 移除标签时的回调 | `(removedValue: string, index: number) => void` | - |

## Accessibility

- 根容器携带 `role="group"` 与 `aria-disabled`。
- 每个标签复用 `Tag` 组件的关闭按钮（键盘可达）。
- 拖拽手柄携带本地化 `aria-label`。
- 折叠的 "+N" 携带 `role="button"`、`tabIndex={0}`，支持 Enter/Space 展开/收起。
- 清除按钮携带 `role="button"`、`tabIndex={0}`，支持 Enter/Space 触发。

## 设计变量

- `--lotus-height-control-default`
- `--lotus-color-border` / `-primary`（聚焦态边框）/ `-danger` / `-warning`（校验状态边框）
- `--lotus-color-bg-1`
- `--lotus-color-fill-0`（折叠 "+N" 背景）
- `--lotus-color-text-0` / `-text-1` / `-text-2`
- `--lotus-border-radius-small`
- `--lotus-font-family` / `-font-body-size` / `-font-label-size`
