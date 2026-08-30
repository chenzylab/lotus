---
title: UserGuide 用户引导
category: 展示类
---

分步引导组件，支持高亮目标元素的 popup 模式，以及居中弹窗轮播式介绍的 modal 模式。

## 代码演示

### 如何引入

```tsrx
import { UserGuide } from '@lotus/ripple';
```

### popup 模式：依次高亮目标元素

支持"上一步/下一步/跳过"，键盘 Esc 跳过、方向键 ←/→ 切换上一步/下一步。

```tsrx demo
../../src/demos/show/user-guide/popup.tsrx
```

### modal 模式：居中弹窗轮播式介绍

无目标元素高亮，纯内容轮播介绍。

```tsrx demo
../../src/demos/show/user-guide/modal.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | 无 |
| class | 类名 | string | 无 |
| current | 受控的当前步骤索引 | number | `0` |
| finishText | 最后一步的按钮文案 | string | 无 |
| mask | 是否显示遮罩 | boolean | `true` |
| mode | 展示模式 | `'popup' \| 'modal'` | `'popup'` |
| nextButtonProps | 透传给"下一步"按钮的 Props | `ButtonProps` | 无 |
| position | 浮层相对高亮框的定位（popup 模式） | `FloatingPosition` | 无 |
| prevButtonProps | 透传给"上一步"按钮的 Props | `ButtonProps` | 无 |
| showPrevButton | 是否显示"上一步"按钮 | boolean | `true` |
| showSkipButton | 是否显示"跳过"按钮 | boolean | `true` |
| spotlightPadding | 高亮框相对目标元素的额外内边距（popup 模式） | number | 无 |
| steps | 步骤数据数组 | `UserGuideStep[]` | `[]` |
| style | 自定义样式 | object | 无 |
| theme | 主题 | `'default' \| 'primary'` | `'default'` |
| visible | 是否显示 | boolean | `false` |
| zIndex | 层级 | number | 无 |
| onChange | 当前步骤变化时的回调 | `(current: number) => void` | 无 |
| onFinish | 完成引导时的回调 | `() => void` | 无 |
| onNext | 点击"下一步"时的回调 | `(current: number) => void` | 无 |
| onPrev | 点击"上一步"时的回调 | `(current: number) => void` | 无 |
| onSkip | 跳过引导时的回调 | `() => void` | 无 |

`UserGuideStep` 结构：`{ target?: () => Element | null, title?, description?, position?, spotlightPadding?, theme? }`。

## Accessibility

- 键盘支持：Esc 触发跳过，方向键 ←/→ 触发上一步/下一步（Semi 一手来源未提供此能力，是 lotus 主动新增）。
- 窗口尺寸变化时高亮框和浮层自动重新定位（Semi 一手来源同样未提供，lotus 主动新增 resize 监听）。
- popup 模式用 SVG `<mask>` 实现镂空遮罩，镂空区域内部完全穿透，可正常与目标元素交互；镂空外的透明矩形精确拦截点击，不会误触到页面其他区域。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0` / `-text-1`
- `--lotus-color-overlay-bg`
- `--lotus-border-radius-medium`
- `--lotus-shadow-elevated`
