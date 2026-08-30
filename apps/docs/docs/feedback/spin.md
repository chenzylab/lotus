---
title: Spin 加载中
category: 反馈类
---

用于页面和区块的加载中状态。

## 代码演示

### 如何引入

```tsrx
import { Spin } from '@lotus/ripple';
```

### 基本用法

不传 `children` 时，`Spin` 是独立的转圈指示器。

```tsrx demo
../../src/demos/feedback/spin/basic.tsrx
```

### 包裹内容

传入 `children` 后，`Spin` 会在内容区域上叠加一层加载中蒙层；`spinning` 切换时被包裹内容淡出但不卸载。

```tsrx demo
../../src/demos/feedback/spin/wrap-children.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| childStyle | 被包裹内容区域的自定义样式 | object | - |
| children | 被包裹的内容；不传时 `Spin` 是独立指示器 | any | - |
| delay | 延迟显示加载态的毫秒数，避免快速完成的操作也闪烁一下 loading | number | `0` |
| indicator | 自定义加载指示器 | any | - |
| size | 指示器尺寸 | `small` \| `middle` \| `large` | `middle` |
| spinning | 是否处于加载中 | boolean | `true` |
| style | 自定义样式 | object | - |
| tip | 加载文案 | any | - |
| wrapperClassName | 根元素类名 | string | - |

## Accessibility

- 根元素携带 `aria-busy`，跟随 `spinning`（考虑 `delay` 后的真实展示状态）同步。
- 可通过 `aria-label` 描述加载指示器的用途。

## 设计变量

- `--lotus-color-primary`（指示器颜色）
- `--lotus-color-bg-1`（包裹模式下蒙层背景色）
- `--lotus-color-text-1`（`tip` 文案颜色）
