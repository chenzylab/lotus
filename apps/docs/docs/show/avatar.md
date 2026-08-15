---
title: Avatar 头像
category: 展示类
---

用图标、图片或字符的形式展示用户或事物信息的图形化表示。

## 代码演示

### 如何引入

```tsrx
import { Avatar, AvatarGroup } from '@lotus/ripple';
```

### 尺寸

Avatar 提供七种尺寸：`extra-extra-small`、`extra-small`、`small`、`default`、`medium`、`large`、`extra-large`。

```tsrx demo
../../src/demos/show/avatar/size.tsrx
```

### 颜色

```tsrx demo
../../src/demos/show/avatar/color.tsrx
```

### 自适应字符大小

通过 `gap` 控制字符距离左右两侧的像素大小，数值越小字符越大。

```tsrx demo
../../src/demos/show/avatar/gap.tsrx
```

### 图片

通过 `src` 设置图片头像；此时应显式传 `isText={false}`（Ripple 无法像 Semi 那样自动判断内容是否为纯文字并自适应缩放）。

```tsrx demo
../../src/demos/show/avatar/image.tsrx
```

### 形状

```tsrx demo
../../src/demos/show/avatar/shape.tsrx
```

### 事件

```tsrx demo
../../src/demos/show/avatar/event.tsrx
```

### 顶部和底部 Slot

```tsrx demo
../../src/demos/show/avatar/slot.tsrx
```

### 额外边框

```tsrx demo
../../src/demos/show/avatar/border.tsrx
```

### 额外动效

```tsrx demo
../../src/demos/show/avatar/motion.tsrx
```

### 头像组

Semi 版本 `AvatarGroup` 用 children 承载子 `Avatar`；lotus 没有 children 反射/克隆能力，改用 `items` 数组声明每个头像的配置。

```tsrx demo
../../src/demos/show/avatar/group.tsrx
```

## API 参考

### Avatar

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| alt | 图像的替代文本描述 | string | - |
| border | 额外边框 | `boolean \| { color?: string; motion?: boolean }` | - |
| bottomSlot | 底部 Slot 配置 | object | - |
| children | 头像内容（文字/图标） | any | - |
| class | 类名 | string | - |
| color | 指定头像的颜色 | string | "grey" |
| contentMotion | 头像内容区域动效 | boolean | false |
| gap | 字符头像距离左右两侧的像素大小 | number | 3 |
| hoverMask | hover 时头像内容覆盖层 | any | - |
| isText | 内容是否为纯文字（决定是否启用自适应字符缩放），Ripple 特有，需显式声明 | boolean | true |
| shape | 指定头像的形状，支持 circle、square | string | "circle" |
| size | 支持 7 档关键字和合法 width 值 | string | "medium" |
| src | 图片类头像的资源地址 | string | - |
| srcSet | 设置图片类头像响应式资源地址 | string | - |
| style | 样式 | object | - |
| topSlot | 顶部 Slot 配置 | object | - |
| onClick | 单击头像的回调 | `(event: MouseEvent) => void` | - |
| onError | 图片加载失败的事件，返回 false 会关闭组件默认的 fallback 行为 | `() => boolean \| void` | - |
| onMouseEnter | MouseEnter 事件的回调 | `(event: MouseEvent) => void` | - |
| onMouseLeave | MouseLeave 事件的回调 | `(event: MouseEvent) => void` | - |

> 注意事项：lotus 未实现 `imgAttr`（原生 img 属性透传）。

### AvatarGroup

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| items | 头像列表（每项等价于一份 Avatar 的 props），lotus 特有，替代 Semi 的 children 写法 | array | - |
| maxCount | 最大数量限制，超出后显示 +N | number | - |
| overlapFrom | 设置头像覆盖方向，支持 start、end | string | "start" |
| renderMore | 自定义渲染 more 标签 | `(restCount, restItems) => any` | - |
| shape | 指定头像的形状，支持 circle、square | string | "circle" |
| size | 设置头像的大小 | string | "medium" |

## Accessibility

### ARIA

- Avatar 可传入 `alt` 生成可访问性描述；`AvatarGroup` 容器渲染为 `role="list"`。

## 设计变量

- `--lotus-color-bg-1`（AvatarGroup 头像间描边色）
- `--lotus-color-fill-2`（+N 更多头像底色）
