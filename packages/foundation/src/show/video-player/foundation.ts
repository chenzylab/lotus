import { Foundation, type Adapter } from '../../base/adapter.js';
import { clampVolume, clampTime, DEFAULT_VIDEO_PLAYBACK_RATE, type PlaybackRateOption } from './video-utils.js';

export * from './video-utils.js';

export interface VideoPlayerState {
  isPlaying: boolean;
  currentTime: number;
  totalTime: number;
  bufferedTime: number;
  volume: number;
  muted: boolean;
  playbackRate: number;
  isError: boolean;
  isFullscreen: boolean;
  isPictureInPicture: boolean;
  showControls: boolean;
  showNotification: boolean;
  notificationContent: string;
}

/**
 * VideoPlayer 状态机：与 AudioPlayerFoundation 同一原则——只做纯状态迁移
 * 计算，不直接操作 `<video>` 元素或调用浏览器 Fullscreen/PictureInPicture
 * API。真实的 DOM 副作用（video.play()/pause()、
 * videoWrapper.requestFullscreen()、video.requestPictureInPicture() 等）
 * 由 `.tsrx` 渲染层在调用完 Foundation 方法、拿到"应该怎么做"的计算结果后
 * 自行触发；`isFullscreen`/`isPictureInPicture` 的真实值由浏览器
 * fullscreenchange/enterpictureinpicture/leavepictureinpicture 事件回写到
 * Foundation state，Foundation 自己不会主动查询 document.fullscreenElement
 * （这是刻意偏离 chenzy.design/Semi 原版"Foundation 直接调 DOM API"架构的
 * 地方，调研已确认两者复用度低，独立设计更清晰）。
 */
export class VideoPlayerFoundation extends Foundation<VideoPlayerState> {
  private readonly seekTime: number;

  constructor(adapter: Adapter<VideoPlayerState>, options: { seekTime?: number } = {}) {
    super(adapter);
    this.seekTime = options.seekTime ?? 10;
  }

  togglePlaying(): boolean {
    const next = !this.getState().isPlaying;
    this.setState({ isPlaying: next });
    return next;
  }

  /** 播放/暂停态直接由 video 的 play/pause 原生事件回写（对齐 Semi handleVideoPlay/handleVideoPause）。 */
  syncPlayingFromMedia(isPlaying: boolean): void {
    this.setState({ isPlaying });
  }

  seekTo(value: number): number {
    const clamped = clampTime(value, this.getState().totalTime);
    this.setState({ currentTime: clamped });
    return clamped;
  }

  seekRelative(direction: number): number {
    const step = direction >= 0 ? this.seekTime : -this.seekTime;
    return this.seekTo(this.getState().currentTime + step);
  }

  /** timeupdate 事件：从 .tsrx 层读到的 video.currentTime 回写状态。 */
  handleTimeUpdate(currentTime: number): void {
    this.setState({ currentTime: Number.isNaN(currentTime) ? 0 : currentTime });
  }

  /** durationchange 事件：回写总时长。 */
  handleDurationChange(totalTime: number): void {
    this.setState({ totalTime: Number.isNaN(totalTime) ? 0 : totalTime });
  }

  /** progress 事件：从 .tsrx 层读到的 video.buffered 末端回写缓冲进度。 */
  handleProgress(bufferedTime: number): void {
    this.setState({ bufferedTime: Number.isNaN(bufferedTime) ? 0 : bufferedTime });
  }

  /** 音量变更：Math.floor 取整，返回 0-1 供写入 video.volume；音量为 0 时同步 muted=true。 */
  changeVolume(value: number): { volumeRatio: number; muted: boolean } {
    const clamped = Math.floor(clampVolume(value));
    const muted = clamped === 0;
    this.setState({ volume: clamped, muted });
    return { volumeRatio: clamped / 100, muted };
  }

  /** 静音切换：静音时记忆音量清零，取消静音时恢复此前音量。 */
  toggleMute(): { volumeRatio: number; muted: boolean } {
    const { volume, muted } = this.getState();
    if (muted) {
      this.setState({ muted: false });
      return { volumeRatio: volume / 100, muted: false };
    }
    this.setState({ muted: true });
    return { volumeRatio: 0, muted: true };
  }

  changeSpeed(rate: PlaybackRateOption): number {
    this.setState({ playbackRate: rate.value });
    return rate.value;
  }

  /** 请求切换全屏：只翻转意图，真实 requestFullscreen()/exitFullscreen() 调用留给 .tsrx 层。 */
  requestToggleFullscreen(): boolean {
    return !this.getState().isFullscreen;
  }

  /** fullscreenchange 事件：从 .tsrx 层的四前缀判断结果回写真实全屏状态。 */
  syncFullscreenFromMedia(isFullscreen: boolean): void {
    this.setState({ isFullscreen });
  }

  requestTogglePictureInPicture(): boolean {
    return !this.getState().isPictureInPicture;
  }

  syncPictureInPictureFromMedia(isPictureInPicture: boolean): void {
    this.setState({ isPictureInPicture });
  }

  showControlsNow(): void {
    this.setState({ showControls: true });
  }

  hideControls(): void {
    this.setState({ showControls: false });
  }

  showNotificationText(content: string): void {
    this.setState({ notificationContent: content, showNotification: true });
  }

  hideNotification(): void {
    this.setState({ showNotification: false });
  }

  handleEnded(): void {
    this.setState({ isPlaying: false, showControls: true });
  }

  handleError(): void {
    this.setState({ isError: true });
  }

  resetError(): void {
    this.setState({ isError: false });
  }
}

export const DEFAULT_VIDEO_PLAYER_STATE: VideoPlayerState = {
  isPlaying: false,
  currentTime: 0,
  totalTime: 0,
  bufferedTime: 0,
  volume: 100,
  muted: false,
  playbackRate: DEFAULT_VIDEO_PLAYBACK_RATE,
  isError: false,
  isFullscreen: false,
  isPictureInPicture: false,
  showControls: true,
  showNotification: false,
  notificationContent: '',
};
