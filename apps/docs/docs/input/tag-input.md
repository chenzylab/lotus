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

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| addOnBlur | 失焦时是否把输入框剩余内容提交为新标签 | boolean | `false` |
| allowDuplicates | 是否允许重复标签 | boolean | `true` |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| defaultValue | 非受控模式下的默认标签数组 | string[] | `[]` |
| disabled | 是否禁用 | boolean | `false` |
| draggable | 是否支持拖拽排序 | boolean | `false` |
| inputValue | 受控的输入框文本 | string | - |
| max | 最多允许的标签数量 | number | - |
| maxTagCount | 超出后折叠展示的标签数量阈值 | number | - |
| placeholder | 占位提示文字（仅无标签时显示） | string | - |
| prefix | 前缀内容 | any | - |
| separator | 触发拆分新增的分隔符 | string | `,` |
| showClear | 有标签时是否展示清除全部按钮 | boolean | `false` |
| showRestTagsPopover | 折叠时 hover "+N" 是否弹出展示被折叠的标签 | boolean | `true` |
| size | 尺寸 | `small` \| `default` \| `large` | `default` |
| style | 自定义样式 | object | - |
| suffix | 后缀内容 | any | - |
| value | 受控的标签数组 | string[] | - |
| onAdd | 新增标签时的回调 | `(addedValue: string[]) => void` | - |
| onChange | 标签数组变化时的回调 | `(value: string[]) => void` | - |
| onExceed | 超过 `max` 限制时的回调 | `(value: string[]) => void` | - |
| onInputChange | 输入框文本变化时的回调 | `(value: string) => void` | - |
| onRemove | 移除标签时的回调 | `(removedValue: string, index: number) => void` | - |

> 注意事项：lotus 尚未实现 Semi 的 `renderTagItem` 自定义标签渲染，标签渲染固定复用内置 `Tag` 组件（`color="white" type="light"`）。

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
