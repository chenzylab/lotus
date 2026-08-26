import { track, effect, untrack } from 'ripple';
import {
    AudioPlayerFoundation,
    formatTime,
    RATE_OPTIONS,
    type AudioPlayerState,
    type AudioUrl,
    type PlaybackRate,
} from '@lotus/foundation/show/audio-player';
import { IconPlay, IconPause, IconChevronLeft, IconChevronRight, IconRefresh, IconVolume2, IconVolumeSilentStroked } from '@lotus/icons';
import { Popover } from '../popover/index.tsrx';
import { AudioSlider } from './audio-slider.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { AudioUrl, PlaybackRate };

export interface AudioPlayerProps {
    audioUrl?: AudioUrl;
    autoPlay?: boolean;
    showToolbar?: boolean;
    skipDuration?: number;
    theme?: 'dark' | 'light';
    class?: string;
    style?: Record<string, any>;
}

export function AudioPlayer(&{
    audioUrl,
    autoPlay = false,
    showToolbar = true,
    skipDuration = 10,
    theme = 'dark',
    class: className,
    style,
}: AudioPlayerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<AudioPlayerState>(() => ({
        isPlaying: autoPlay,
        currentTime: 0,
        totalTime: 0,
        volume: 100,
        playbackRate: { label: '1.0x', value: 1 },
        currentTrackIndex: 0,
        isError: false,
    }));

    const foundation = new AudioPlayerFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<AudioPlayerState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { audioUrl, autoPlay, skipDuration },
    );

    let audioEl: HTMLAudioElement | null = null;
    let &[showRateMenu] = track<boolean>(false);

    // audioUrl 变化时（外部 prop 变化）重新归一化曲目列表——用响应式 track()
    // 变量承载，好让下面 currentTrack/isMultiTrack 的 track() 计算体在它变化
    // 时也能重新求值。
    let &[tracksList] = track(() => foundation.getTracks());
    effect(() => {
        foundation.setAudioUrl(audioUrl);
        tracksList = foundation.getTracks();
    });

    // 关键：track() 计算体内必须直接读 state.currentTrackIndex（响应式变量
    // 本身），不能包一层 foundation.getCurrentTrack()——该方法内部经
    // this.getState()（Adapter 里用 untrack() 包裹）取值，会阻断这里的
    // track() 依赖收集，导致切曲后 currentTrack 永远不重新求值（响应式阻断
    // 踩坑 #74/#78/#85 系列的再次复现，AudioPlayer 组件排查发现）。
    let &[currentTrack] = track(() => tracksList[state.currentTrackIndex]);
    let &[isMultiTrack] = track<boolean>(() => tracksList.length > 1);

    // 曲目切换后同步真实 <audio> 元素的 src；playbackRate 跨 load() 不会自动
    // 保留，需要显式写回 1x（对齐 Foundation.changeTrack 已经把状态重置为
    // DEFAULT_RATE，这里只是让真实 DOM 属性跟上状态）。
    effect(() => {
        const activeTrack = currentTrack;
        const el = untrack(() => audioEl);
        if (!el || !activeTrack) return;
        if (el.src === activeTrack.src) return;
        el.src = activeTrack.src;
        el.load();
        el.playbackRate = 1;
        if (untrack(() => state).isPlaying) void el.play();
    });

    function handlePlayPause() {
        const el = untrack(() => audioEl);
        if (!el) return;
        const willPlay = foundation.togglePlaying();
        if (willPlay) void el.play();
        else el.pause();
    }

    function handleTrackChange(direction: 'next' | 'prev') {
        foundation.changeTrack(direction);
    }

    function handleSeek(value: number) {
        const el = untrack(() => audioEl);
        const clamped = foundation.seekTo(value);
        if (el) el.currentTime = clamped;
    }

    function handleSkip(direction: number) {
        const el = untrack(() => audioEl);
        const clamped = foundation.seekRelative(direction);
        if (el) el.currentTime = clamped;
    }

    function handleSpeedChange(rate: PlaybackRate) {
        const el = untrack(() => audioEl);
        foundation.changeSpeed(rate);
        if (el) el.playbackRate = rate.value;
        showRateMenu = false;
    }

    function handleRefresh() {
        const el = untrack(() => audioEl);
        const { shouldReload } = foundation.refresh();
        if (!el) return;
        if (shouldReload) el.load();
        else el.currentTime = 0;
    }

    function handleVolumeChange(value: number) {
        const el = untrack(() => audioEl);
        const written = foundation.changeVolume(value);
        if (el) el.volume = written;
    }

    function handleTimeUpdate() {
        const el = untrack(() => audioEl);
        if (el) foundation.handleTimeUpdate(el.currentTime);
    }

    function handleLoadedMetadata() {
        const el = untrack(() => audioEl);
        if (!el) return;
        foundation.initFromMedia(el.duration, el.volume, el.playbackRate);
    }

    function handleEnded() {
        foundation.handleEnded();
    }

    function handleError() {
        foundation.handleError();
    }

    <>
        <div class={['lotus-audio-player', `lotus-audio-player-${theme}`, className ?? ''].filter(Boolean).join(' ')} style={style}>
            <audio
                ref={(node: HTMLAudioElement | null) => { audioEl = node; }}
                onTimeUpdate={handleTimeUpdate}
                onLoadedMetadata={handleLoadedMetadata}
                onEnded={handleEnded}
                onError={handleError}
                style={{ display: 'none' }}
            />

            @if (currentTrack?.title) {
                <div class="lotus-audio-player-title">{currentTrack.title}</div>
            }

            @if (state.isError) {
                <div class="lotus-audio-player-error" role="alert">{locale.AudioPlayer.loadError}</div>
            }

            <div class="lotus-audio-player-progress">
                <span class="lotus-audio-player-time">{formatTime(state.currentTime)}</span>
                <AudioSlider value={state.currentTime} max={state.totalTime} aria-label={locale.AudioPlayer.progress} onChange={handleSeek} />
                <span class="lotus-audio-player-time">{formatTime(state.totalTime)}</span>
            </div>

            @if (showToolbar) {
                <div class="lotus-audio-player-toolbar">
                    @if (isMultiTrack) {
                        <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.prev} onClick={() => handleTrackChange('prev')}>
                            <IconChevronLeft />
                        </button>
                    }

                    <button type="button" class="lotus-audio-player-btn lotus-audio-player-btn-play" aria-label={state.isPlaying ? locale.AudioPlayer.pause : locale.AudioPlayer.play} onClick={handlePlayPause}>
                        @if (state.isPlaying) {
                            <IconPause />
                        } @else {
                            <IconPlay />
                        }
                    </button>

                    @if (isMultiTrack) {
                        <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.next} onClick={() => handleTrackChange('next')}>
                            <IconChevronRight />
                        </button>
                    }

                    <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.rewind} onClick={() => handleSkip(-1)}>«</button>
                    <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.forward} onClick={() => handleSkip(1)}>»</button>
                    <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.replay} onClick={handleRefresh}>
                        <IconRefresh />
                    </button>

                    <div class="lotus-audio-player-rate-wrap">
                        <button type="button" class="lotus-audio-player-btn lotus-audio-player-rate-btn" aria-label={locale.AudioPlayer.rate} onClick={() => { showRateMenu = !showRateMenu; }}>
                            {state.playbackRate.label}
                        </button>
                        @if (showRateMenu) {
                            <ul class="lotus-audio-player-rate-menu" role="menu">
                                @for (const rate of RATE_OPTIONS; key rate.value) {
                                    <li role="menuitem">
                                        <button type="button" class="lotus-audio-player-rate-item" onClick={() => handleSpeedChange(rate)}>
                                            {rate.label}
                                        </button>
                                    </li>
                                }
                            </ul>
                        }
                    </div>

                    <Popover
                        trigger="click"
                        content={
                            <div class="lotus-audio-player-volume-popover">
                                <AudioSlider value={state.volume} max={100} vertical={true} aria-label={locale.AudioPlayer.volume} onChange={handleVolumeChange} />
                            </div>
                        }
                    >
                        <button type="button" class="lotus-audio-player-btn" aria-label={locale.AudioPlayer.volume}>
                            @if (state.volume === 0) {
                                <IconVolumeSilentStroked />
                            } @else {
                                <IconVolume2 />
                            }
                        </button>
                    </Popover>
                </div>
            }
        </div>

        <style>
            .lotus-audio-player {
                display: flex;
                flex-direction: column;
                gap: 8px;
                padding: 12px 16px;
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-audio-player-dark {
                background: var(--lotus-color-bg-3, #1c1c1c);
                color: var(--lotus-color-white);
            }

            .lotus-audio-player-light {
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-0);
                border: 1px solid var(--lotus-color-border);
            }

            .lotus-audio-player-title {
                font-size: 13px;
                font-weight: 600;
            }

            .lotus-audio-player-error {
                color: var(--lotus-color-danger);
                font-size: 12px;
            }

            .lotus-audio-player-progress {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .lotus-audio-player-progress :global(.lotus-audio-slider) {
                flex: 1;
            }

            .lotus-audio-player-time {
                font-size: 12px;
                font-variant-numeric: tabular-nums;
                min-width: 32px;
            }

            .lotus-audio-player-toolbar {
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .lotus-audio-player-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 28px;
                height: 28px;
                border: none;
                background: transparent;
                color: inherit;
                cursor: pointer;
                border-radius: var(--lotus-border-radius-small);
                font-size: 13px;
            }

            .lotus-audio-player-btn:hover {
                background: rgba(255, 255, 255, 0.1);
            }

            .lotus-audio-player-btn-play {
                width: 32px;
                height: 32px;
            }

            .lotus-audio-player-rate-wrap {
                position: relative;
            }

            .lotus-audio-player-rate-btn {
                width: auto;
                padding: 0 6px;
                font-size: 12px;
            }

            .lotus-audio-player-rate-menu {
                position: absolute;
                bottom: 100%;
                left: 0;
                margin: 0 0 4px;
                padding: 4px;
                list-style: none;
                background: var(--lotus-color-bg-0);
                color: var(--lotus-color-text-0);
                border-radius: var(--lotus-border-radius-small);
                box-shadow: var(--lotus-shadow-elevated, 0 2px 8px rgba(0, 0, 0, 0.15));
                min-width: 60px;
                z-index: 10;
            }

            .lotus-audio-player-rate-item {
                width: 100%;
                border: none;
                background: transparent;
                color: inherit;
                text-align: start;
                padding: 4px 8px;
                cursor: pointer;
                border-radius: var(--lotus-border-radius-small);
                font-size: 12px;
            }

            .lotus-audio-player-rate-item:hover {
                background: var(--lotus-color-fill-1);
            }

            .lotus-audio-player-volume-popover {
                height: 100px;
                display: flex;
                justify-content: center;
                padding: 8px 0;
            }
        </style>
    </>
}
