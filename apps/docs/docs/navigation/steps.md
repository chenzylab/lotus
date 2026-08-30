---
title: Steps 步骤条
category: 导航类
---

引导用户按照流程完成任务的导航条，展示当前所在步骤及任务进度。

## 代码演示

### 如何引入

```tsrx
import { Steps } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/navigation/steps/basic.tsrx
```

### fill 类型

`type="fill"` 用填充色条代替默认的圆点+连线样式。

```tsrx demo
../../src/demos/navigation/steps/fill.tsrx
```

### 垂直方向与错误态

`direction="vertical"` 切换为垂直排列；`status="error"` 将当前步骤标记为错误态。

```tsrx demo
../../src/demos/navigation/steps/vertical-error.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| aria-label | 设置 aria-label 属性 | string | - |
| class | 类名 | string | - |
| current | 受控的当前步骤序号（从 0 开始） | number | - |
| defaultCurrent | 非受控模式下的默认步骤序号 | number | `0` |
| direction | 排列方向 | `horizontal` \| `vertical` | `horizontal` |
| hasLine | 是否显示步骤间的连接线 | boolean | `true` |
| initial | 起始步骤序号（影响步骤编号显示，不影响 `current`） | number | `0` |
| items | 步骤项数组 | `StepItemInput[]` | 必填 |
| size | 尺寸 | `default` \| `small` | `default` |
| status | 当前步骤的状态 | `wait` \| `process` \| `finish` \| `error` \| `warning` | `process` |
| style | 自定义样式 | object | - |
| type | 视觉类型 | `basic` \| `fill` | `basic` |
| onChange | 步骤变化时的回调 | `(current: number) => void` | - |

`StepItemInput` 结构：`{ title?, description?, icon?, status?, disabled? }`——单个步骤项的 `status` 会覆盖组件级 `status` 对该步骤的自动计算。

## Accessibility

- 各步骤项当前依赖视觉图标（圆点/勾选/叹号/序号）区分状态，无原生语义角色；建议配合有意义的 `title`/`description` 文案，不要仅靠颜色传达状态。

## 设计变量

- `--lotus-color-bg-1`（步骤圆点背景）
- `--lotus-color-border`（未激活态描边/连接线颜色）
- `--lotus-color-primary`（当前/已完成步骤颜色）
- `--lotus-color-danger`（错误态颜色）
- `--lotus-color-warning`（警告态颜色）
- `--lotus-color-text-0` / `-text-1`
- `--lotus-font-body-size` / `-label-size`
- `--lotus-font-weight-regular` / `-semibold`
- `--lotus-spacing-base` / `-tight`
- `--lotus-border-radius-full`
