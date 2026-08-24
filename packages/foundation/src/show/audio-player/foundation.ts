import { Foundation, type Adapter } from '../../base/adapter.js';
import {
  normalizeAudioUrl,
  clampVolume,
  clampTime,
  nextTrackIndex,
  DEFAULT_RATE,
  type AudioUrl,
  type AudioTrack,
  type PlaybackRate,
} from './audio-track.js';

export * from './audio-track.js';

export interface AudioPlayerState {
  isPlaying: boolean;
  currentTime: number;
  totalTime: number;
  volume: number;
  playbackRate: PlaybackRate;
  currentTrackIndex: number;
  isError: boolean;
}

/**
 * AudioPlayer 状态机：只做纯状态迁移计算，不直接操作 `<audio>` 元素——
 * 与 chenzy.design 的 push-based（listeners/emit）headless 设计不同，
 * lotus 走 Foundation 只管 getState/setState 的 pull 模式（对齐 Adapter<S>
 * 基类契约），真正的 DOM 读写（play()/pause()/设置 currentTime 等）由
 * `.tsrx` 渲染层在调用完 Foundation 方法、拿到"应该怎么做"的计算结果后
 * 自行触发，与 ChatFoundation/TransferFoundation 同一惯用法。
 *
 * 与 CarouselFoundation 重合度低（调研已确认）：Carousel 自己驱动
 * setInterval 定时器，AudioPlayer 的"时钟"是浏览器原生 `<audio>` 元素
 * 派发的 timeupdate/ended/error 事件，不需要 Foundation 持有任何定时器，
 * 因此不复用/不继承 CarouselFoundation，仅在 nextTrackIndex 的取模循环
 * 这一个两行惯用法上与 Carousel 的 getValidIndex 思路一致。
 */
export class AudioPlayerFoundation extends Foundation<AudioPlayerState> {
  private tracks: AudioTrack[];
  private readonly autoPlay: boolean;
  private readonly skipDuration: number;

  constructor(
    adapter: Adapter<AudioPlayerState>,
    options: { audioUrl?: AudioUrl; autoPlay?: boolean; skipDuration?: number } = {},
  ) {
    super(adapter);
    this.tracks = normalizeAudioUrl(options.audioUrl);
    this.autoPlay = options.autoPlay ?? false;
    this.skipDuration = options.skipDuration ?? 10;
  }

  getTracks(): AudioTrack[] {
    return this.tracks.slice();
  }

  getCurrentTrack(): AudioTrack | undefined {
    return this.tracks[this.getState().currentTrackIndex];
  }

  isMultiTrack(): boolean {
    return this.tracks.length > 1;
  }

  /** 播放 ⇄ 暂停：返回新的 isPlaying，供 .tsrx 层据此调用 audio.play()/pause()。 */
  togglePlaying(): boolean {
    const next = !this.getState().isPlaying;
    this.setState({ isPlaying: next });
    return next;
  }

  /**
   * 切曲（无环绕，取模循环）：只计算并写回新索引与重置后的进度状态，
   * 不触碰 audio.src——切换 src/load() 由 .tsrx 层的 effect 监听
   * currentTrackIndex 变化后自行完成，playbackRate 也需要 .tsrx 层显式
   * 写回 audio.playbackRate=1（跨 load() 不会自动重置）。
   */
  changeTrack(direction: 'next' | 'prev'): number {
    if (this.tracks.length <= 1) return this.getState().currentTrackIndex;
    const next = nextTrackIndex(this.getState().currentTrackIndex, this.tracks.length, direction);
    this.setState({
      currentTrackIndex: next,
      currentTime: 0,
      totalTime: 0,
      isError: false,
      isPlaying: true,
      playbackRate: { ...DEFAULT_RATE },
    });
    return next;
  }

  /** 跳转到绝对秒（钳制），返回钳制后的值供 .tsrx 层写入 audio.currentTime。 */
  seekTo(value: number): number {
    const clamped = clampTime(value, this.getState().totalTime);
    this.setState({ currentTime: clamped });
    return clamped;
  }

  /** 相对快进（direction>=0）/快退（direction<0）skipDuration 秒。 */
  seekRelative(direction: number): number {
    const step = direction >= 0 ? this.skipDuration : -this.skipDuration;
    return this.seekTo(this.getState().currentTime + step);
  }

  changeSpeed(value: PlaybackRate): void {
    this.setState({ playbackRate: { ...value } });
  }

  /** 重播：出错态需要 .tsrx 层调用 audio.load()；非出错态只需回到 0（不影响播放态）。 */
  refresh(): { shouldReload: boolean } {
    const { isError } = this.getState();
    if (isError) {
      this.setState({ isError: false });
      return { shouldReload: true };
    }
    this.setState({ currentTime: 0 });
    return { shouldReload: false };
  }

  /** 音量变更：Math.floor 取整（拖拽产生的连续浮点值需去小数），返回 0-1 供写入 audio.volume。 */
  changeVolume(value: number): number {
    const clamped = Math.floor(clampVolume(value));
    this.setState({ volume: clamped });
    return clamped / 100;
  }

  /** timeupdate 事件：从 .tsrx 层读到的 audio.currentTime 回写状态。 */
  handleTimeUpdate(currentTime: number): void {
    this.setState({ currentTime: Number.isNaN(currentTime) ? 0 : currentTime });
  }

  /** loadedmetadata / 初始化：从 .tsrx 层读到的 duration/volume/rate 回写状态。 */
  initFromMedia(duration: number, volume: number, rate: number): void {
    this.setState({
      totalTime: Number.isNaN(duration) ? 0 : duration,
      volume: Number.isNaN(volume) ? 100 : volume * 100,
      playbackRate: { label: DEFAULT_RATE.label, value: rate || 1 },
      isPlaying: this.autoPlay,
    });
  }

  resetProgress(): void {
    this.setState({ currentTime: 0, totalTime: 0, isError: false });
  }

  /** ended 事件：多曲切下一曲（循环连播，末曲绕回首曲）；单曲则停。返回是否切换了曲目。 */
  handleEnded(): boolean {
    if (this.isMultiTrack()) {
      this.changeTrack('next');
      return true;
    }
    this.setState({ isPlaying: false });
    return false;
  }

  handleError(): void {
    this.setState({ isError: true });
  }

  setAudioUrl(audioUrl: AudioUrl | undefined): void {
    this.tracks = normalizeAudioUrl(audioUrl);
    const { currentTrackIndex } = this.getState();
    const clampedIndex = this.tracks.length > 0 ? Math.min(currentTrackIndex, this.tracks.length - 1) : 0;
    this.setState({
      currentTrackIndex: clampedIndex,
      currentTime: 0,
      totalTime: 0,
      isError: false,
    });
  }
}
