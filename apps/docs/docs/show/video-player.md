---
title: VideoPlayer 视频播放器
category: 展示类
---

带完整控制条的视频播放器：播放/暂停、进度拖拽、音量、倍速、画中画、全屏。

## 代码演示

### 如何引入

```tsrx
import { VideoPlayer } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/video-player/basic.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| autoPlay | 是否自动播放 | boolean | `false` |
| class | 类名 | string | 无 |
| height | 播放器高度 | string \| number | 无 |
| loop | 是否循环播放 | boolean | `false` |
| muted | 是否静音 | boolean | `false` |
| playbackRateList | 可选倍速列表 | `PlaybackRateOption[]` | `[2.0, 1.5, 1.25, 1.0, 0.75]` |
| poster | 封面图 URL | string | 无 |
| seekTime | 跳转到指定时间（秒），一次性触发跳转 | number | 无 |
| showPictureInPicture | 是否显示画中画按钮 | boolean | `true` |
| src | 视频源地址 | string | 无 |
| style | 自定义样式 | object | 无 |
| theme | 控制条主题 | `'dark' \| 'light'` | `'dark'` |
| volume | 音量（0-1） | number | 无 |
| width | 播放器宽度 | string \| number | 无 |
| onPause | 暂停时的回调 | `() => void` | 无 |
| onPlay | 播放时的回调 | `() => void` | 无 |
| onRateChange | 播放速率变化时的回调 | `(rate: number) => void` | 无 |
| onVolumeChange | 音量变化时的回调 | `(volume: number) => void` | 无 |

## Accessibility

- 播放/暂停/静音/取消静音/播放速度/全屏等按钮均携带来自 `@lotus/locale` 的本地化 `aria-label`（`VideoPlayer.play`/`pause`/`mute`/`unmute`/`rate`/`fullscreen` 等），随语言切换更新。
- 组件卸载时正确清理 `controlsHideTimer`（控制条自动隐藏的防抖定时器）与 `fullscreenchange` 事件监听，避免悬挂定时器/监听器泄漏。

## 设计变量

- `--lotus-color-bg-1`
- `--lotus-color-text-0`
- `--lotus-border-radius-medium`
