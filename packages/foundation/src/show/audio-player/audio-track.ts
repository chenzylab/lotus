/**
 * AudioPlayer 数据结构与纯函数：audioUrl 归一化、数值钳制、时间格式化。
 * 对齐 Semi Design semi-foundation/audioPlayer（Plus 分类组件，纯封装原生
 * `<audio>` + 自建工具栏，无第三方媒体库依赖）。
 */

export interface AudioInfo {
  src: string;
  title?: string;
  cover?: string;
}

export type AudioUrl = string | string[] | AudioInfo | AudioInfo[];

export interface AudioTrack {
  src: string;
  title?: string;
  cover?: string;
}

export interface PlaybackRate {
  label: string;
  value: number;
}

export const DEFAULT_RATE: PlaybackRate = { label: '1.0x', value: 1 };

export const RATE_OPTIONS: PlaybackRate[] = [
  { label: '0.5x', value: 0.5 },
  { label: '0.75x', value: 0.75 },
  { label: '1.0x', value: 1 },
  { label: '1.5x', value: 1.5 },
  { label: '2.0x', value: 2 },
];

function isAudioInfo(v: unknown): v is AudioInfo {
  return typeof v === 'object' && v !== null && 'src' in v && typeof (v as AudioInfo).src === 'string';
}

function toTrack(info: AudioInfo): AudioTrack {
  const track: AudioTrack = { src: info.src };
  if (info.title !== undefined) track.title = info.title;
  if (info.cover !== undefined) track.cover = info.cover;
  return track;
}

/**
 * 把 audioUrl 四形态（string | string[] | AudioInfo | AudioInfo[]）归一为曲目数组。
 * 空/无效输入一律得到空数组；数组形态里丢弃空串/无 src 的无效项。
 */
export function normalizeAudioUrl(audioUrl: AudioUrl | undefined | null): AudioTrack[] {
  if (audioUrl == null) return [];
  if (typeof audioUrl === 'string') {
    return audioUrl ? [{ src: audioUrl }] : [];
  }
  if (Array.isArray(audioUrl)) {
    const out: AudioTrack[] = [];
    for (const item of audioUrl) {
      if (typeof item === 'string') {
        if (item) out.push({ src: item });
      } else if (isAudioInfo(item)) {
        out.push(toTrack(item));
      }
    }
    return out;
  }
  if (isAudioInfo(audioUrl)) {
    return [toTrack(audioUrl)];
  }
  return [];
}

/** 把 0–100 的音量钳到合法区间；NaN 视为 0。 */
export function clampVolume(value: number): number {
  if (Number.isNaN(value)) return 0;
  if (value < 0) return 0;
  if (value > 100) return 100;
  return value;
}

/** 把秒数钳到 [0, total]；NaN/负数视为 0，total<=0 时上界视为 0。 */
export function clampTime(value: number, total: number): number {
  if (Number.isNaN(value) || value < 0) return 0;
  const upper = total > 0 ? total : 0;
  if (upper > 0 && value > upper) return upper;
  return value;
}

/** 取模循环索引（对齐 Semi handleTrackChange：next=(i+1)%len，prev=(i-1+len)%len）。 */
export function nextTrackIndex(current: number, length: number, direction: 'next' | 'prev'): number {
  if (length <= 0) return 0;
  return direction === 'next' ? (current + 1) % length : (current - 1 + length) % length;
}

/** 秒数格式化为 mm:ss（对齐 Semi formatTime，无小时列）。 */
export function formatTime(seconds: number): string {
  if (Number.isNaN(seconds) || seconds < 0) seconds = 0;
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}
