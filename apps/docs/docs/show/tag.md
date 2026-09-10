---
title: Tag 标签
category: 展示类
---

用于标记事物的属性和维度。

## 代码演示

### 如何引入

```tsrx
import { Tag, TagGroup, SplitTagGroup } from '@lotus/ripple';
```

### 基本用法

设置 `closable` 属性和 `onClose` 回调可以让标签支持关闭。

```tsrx demo
../../src/demos/show/tag/basic.tsrx
```

### 尺寸

Tag 提供三种尺寸：`large`、`default`、`small`。

```tsrx demo
../../src/demos/show/tag/size.tsrx
```

### 配置图标

通过 `prefixIcon`/`suffixIcon` 设置标签的前后缀图标。

```tsrx demo
../../src/demos/show/tag/icon.tsrx
```

### 颜色

Tag 支持 17 种展示色。

```tsrx demo
../../src/demos/show/tag/color.tsrx
```

### 样式类型

Tag 提供三种样式类型：`light`（默认，浅色背景）、`solid`（纯色背景）、`ghost`（幽灵边框）。

```tsrx demo
../../src/demos/show/tag/type.tsrx
```

### 不可见的

通过 `visible` 属性可以控制标签的显隐。

```tsrx demo
../../src/demos/show/tag/visible.tsrx
```

## API 参考

### Tag

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 标签的标签 | string | - |
| avatarShape | 内嵌头像的形状 | `'circle' \| 'square'` | "square" |
| avatarSrc | 标签内嵌头像图片地址，与 `prefixIcon` 互斥的独立能力 | string | - |
| children | 标签内容 | any | - |
| class | 类名 | string | - |
| closable | 标签是否可以关闭 | boolean | false |
| color | 标签的颜色，可选 amber、blue、cyan、green、grey、indigo、lightBlue、lightGreen、lime、orange、pink、purple、red、teal、violet、yellow、white | string | "grey" |
| prefixIcon | 前缀图标 | any | - |
| shape | 标签外观形状：`square`（默认，方角）或 `circle`（胶囊形，完全圆角） | `'circle' \| 'square'` | "square" |
| suffixIcon | 后缀图标 | any | - |
| size | 标签的尺寸，可选 small、default、large | string | "default" |
| style | 样式 | object | - |
| tabIndex | 内部使用：TagInput 等场景需要用 -1 关闭 Tag 自身 Tab 序，改由外层管理焦点 | number | - |
| tagKey | 标识该标签的 key，`onClose` 回调透传，多标签场景区分是哪一个被关闭 | `string \| number` | - |
| type | 标签的样式类型，可选 ghost、solid、light | string | "light" |
| visible | 标签是否可见 | boolean | - |
| onClick | 单击标签时的回调函数 | `(event: MouseEvent) => void` | - |
| onClose | 关闭标签时的回调函数，携带标签内容/事件/`tagKey` | `(children, event, tagKey) => void` | - |
| onKeyDown | 键盘按下时的回调（除内置的 Backspace/Delete/Enter/Escape 处理外额外触发） | `(event: KeyboardEvent) => void` | - |
| onMouseEnter | 鼠标进入时的回调 | `() => void` | - |

`closable` 或 `onClick` 存在时，Tag 携带 `role="button"`/`tabIndex`，支持键盘操作：聚焦后 `Backspace`/`Delete` 触发关闭（`closable` 时），`Enter` 触发 `onClick`，`Escape` 失焦。

> 注意事项：lotus 版 `color` 中 `lightBlue`/`lightGreen` 采用驼峰命名，与 Semi 官方的 kebab 写法（`light-blue`/`light-green`）不同，这是 lotus 自有的类型命名约定。

### TagGroup

```tsrx
<TagGroup
    tagList={[
        { children: '标签一', color: 'blue' },
        { children: '标签二', color: 'green' },
    ]}
    maxTagCount={1}
    showPopover
/>
```

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| avatarShape | 未指定 `avatarShape` 的标签使用的默认值 | `'circle' \| 'square'` | "square" |
| class | 类名 | string | - |
| maxTagCount | 展示的标签数量上限，超出的聚合成 "+N" 标签 | number | - |
| popoverProps | 折叠气泡的 Popover 透传配置 | object | - |
| restCount | "+N" 里的 N 值，未指定时用 `tagList.length - maxTagCount` 推算 | number | - |
| showPopover | hover "+N" 标签时是否用 Popover 展示被折叠的完整标签列表 | boolean | false |
| size | 未指定 `size` 的标签使用的默认值 | `'small' \| 'default' \| 'large'` | "default" |
| style | 自定义样式 | object | - |
| tagList | 声明式标签配置数组 | `TagProps[]` | 必填 |
| onPlusNMouseEnter | 鼠标进入 "+N" 标签时的回调 | `() => void` | - |
| onTagClose | group 级统一关闭回调：每个标签自身的 `onClose`（如果有）先触发，再触发这个 | `(children, event, tagKey) => void` | - |

> `tagList` 每项自动补齐 `size`/`avatarShape`（未显式指定时用 group 级默认值）与 `tagKey`（未指定时用字符串/数字 `children` 兜底，否则用数组下标）。Ripple 没有 `React.Children.map` 等价的 children 遍历/克隆能力，因此不支持 Semi 那种 `<TagGroup><Tag>...</Tag></TagGroup>` 的 JSX children 声明式写法，改用 `tagList` 数据数组承载每个标签的配置，与 `AvatarGroup` 是同样的设计取舍。

### SplitTagGroup

把一组 `Tag` 渲染成视觉上连成一体的分段标签组：首尾两端保留圆角，中间零圆角、彼此贴合。用纯 CSS `:first-child`/`:last-child` 选择器实现，是 JSX children 声明式写法（不像 `TagGroup` 需要数据数组）：

```tsrx
<SplitTagGroup>
    <Tag color="blue">周一</Tag>
    <Tag color="blue">周二</Tag>
</SplitTagGroup>
```

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| children | `Tag` 子项 | any | - |
| class | 类名 | string | - |
| style | 自定义样式 | object | - |

## Accessibility

### ARIA

- 关闭按钮为可聚焦的可交互元素，建议通过 `aria-label` 描述标签内容以提升可访问性。
- `closable`/`onClick` 存在时 Tag 携带完整键盘操作支持（见上方说明）。
- `SplitTagGroup` 携带 `role="group"`。
- `TagGroup` 的 "+N" 聚合标签仅支持 hover 展示 Popover（对齐 Semi 官方同样的设计，不是键盘可达的操作路径，因为它只是预览而非必须操作）。

## 设计变量

- `--lotus-color-fill-0` ~ `--lotus-color-fill-2`（light 类型底色）
- `--lotus-color-border`（ghost 类型边框色）
