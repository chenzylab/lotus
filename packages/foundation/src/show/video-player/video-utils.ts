/**
 * VideoPlayer 纯函数：数值钳制、时间格式化、倍速选项。
 * 对齐 Semi Design semi-foundation/videoPlayer（Plus 分类组件，纯封装原生
 * `<video>` + 自建工具栏，无第三方媒体库依赖，不支持 HLS/DASH 自适应码流）。
 *
 * 与 AudioPlayer（packages/foundation/src/show/audio-player/audio-track.ts）
 * 的复用度调研已核实：只有数值钳制（clampVolume/clampTime）与媒体类型无关，
 * 可直接复用；formatTime 因为 Video 场景常见超过一小时的时长需要 H:MM:SS
 * 分支而不能共用 AudioPlayer 的纯 mm:ss 版本；倍速档位 Semi VideoPlayer 是
 * 5 档降序（2.0→0.75，含 1.25x），与 AudioPlayer 的 5 档升序（0.5→2.0，不含
 * 1.25x）顺序和档位都不同，不能共用同一份 RATE_OPTIONS 列表；VideoPlayer
 * 的 src 是单一地址，没有 AudioPlayer 那种多曲目播放列表概念，不需要
 * normalizeAudioUrl/nextTrackIndex 这类曲目归一化与循环索引函数。
 */
export { clampVolume, clampTime } from '../audio-player/audio-track.js';

export interface PlaybackRateOption {
  label: string;
  value: number;
}

/** Semi VideoPlayer 默认倍速菜单：2.0x → 0.75x 降序，含 1.25x。 */
export const DEFAULT_PLAYBACK_RATE_LIST: PlaybackRateOption[] = [
  { label: '2.0x', value: 2 },
  { label: '1.5x', value: 1.5 },
  { label: '1.25x', value: 1.25 },
  { label: '1.0x', value: 1 },
  { label: '0.75x', value: 0.75 },
];

export const DEFAULT_VIDEO_PLAYBACK_RATE = 1;
export const DEFAULT_VOLUME = 100;
export const DEFAULT_SEEK_TIME = 10;

/**
 * 秒数格式化：≥3600 秒时输出 H:MM:SS，否则 M:SS（对齐 Semi VideoPlayer 的
 * 时长展示，与 AudioPlayer 固定 mm:ss 的 formatTime 不同——视频时长常见
 * 超过一小时，需要小时分支）。
 */
export function formatVideoTime(seconds: number): string {
  if (Number.isNaN(seconds) || seconds < 0) seconds = 0;
  const hours = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);
  if (hours > 0) {
    return `${hours}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}
