---
title: AudioPlayer 音频播放器
category: 展示类
---

音频播放控件，支持单曲/多曲目播放列表、进度拖拽、音量调节、倍速切换。

## 代码演示

### 如何引入

```tsrx
import { AudioPlayer } from '@lotus/ripple';
```

### 基本用法

```tsrx demo
../../src/demos/show/audio-player/basic.tsrx
```

### 多曲目播放列表

`audioUrl` 传数组时展示上一曲/下一曲切换按钮，每项可带 `title`。

```tsrx demo
../../src/demos/show/audio-player/playlist.tsrx
```

## API 参考

| 属性 | 说明 | 类型 | 默认值 |
| --- | --- | --- | --- |
| audioUrl | 音频地址：单个字符串/字符串数组/`{ src, title? }` 对象或数组 | `AudioUrl` | - |
| autoPlay | 是否自动播放 | boolean | `false` |
| class | 类名 | string | - |
| showToolbar | 是否展示底部工具栏（播放/切曲/快进快退/倍速/音量） | boolean | `true` |
| skipDuration | 快进/快退按钮每次跳转的秒数 | number | `10` |
| style | 自定义样式 | object | - |
| theme | 播放器主题 | `'dark' \| 'light'` | `'dark'` |

## Accessibility

- 进度条、音量滑块均携带本地化 `aria-label`（`@lotus/locale` 的 `AudioPlayer.progress`/`volume`）。
- 播放/暂停按钮的 `aria-label` 随播放状态在"播放"/"暂停"两种本地化文案间切换。
- 上一曲/下一曲图标带阅读顺序语义，RTL 模式下水平镜像；快退/快进图标是媒体控制通用符号约定，核对 Semi 一手来源确认不做镜像。
- 加载失败时的错误提示携带 `role="alert"`。

## 设计变量

- `--lotus-color-bg-3` / `-bg-0`（dark/light 主题背景）
- `--lotus-color-text-0`
- `--lotus-color-danger`（错误提示文案）
- `--lotus-color-fill-1`（倍速菜单项 hover）
- `--lotus-border-radius-medium` / `-small`
- `--lotus-shadow-elevated`
