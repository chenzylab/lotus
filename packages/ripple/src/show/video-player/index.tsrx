import { track, effect, untrack } from 'ripple';
import {
    VideoPlayerFoundation,
    DEFAULT_VIDEO_PLAYER_STATE,
    formatVideoTime,
    DEFAULT_PLAYBACK_RATE_LIST,
    type VideoPlayerState,
    type PlaybackRateOption,
} from '@lotus/foundation/show/video-player';
import {
    IconPlay,
    IconPause,
    IconVolume2,
    IconMute,
    IconFullScreenStroked,
    IconShrinkScreenStroked,
    IconMaximize2,
} from '@lotus/icons';
import { AudioSlider } from '../audio-player/audio-slider.tsrx';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { PlaybackRateOption };

export interface VideoPlayerProps {
    src?: string;
    poster?: string;
    width?: string | number;
    height?: string | number;
    autoPlay?: boolean;
    loop?: boolean;
    muted?: boolean;
    volume?: number;
    seekTime?: number;
    theme?: 'dark' | 'light';
    playbackRateList?: PlaybackRateOption[];
    showPictureInPicture?: boolean;
    class?: string;
    style?: Record<string, any>;
    onPlay?: () => void;
    onPause?: () => void;
    onRateChange?: (rate: number) => void;
    onVolumeChange?: (volume: number) => void;
}

/** 检测真实全屏元素是否是本播放器容器（跨浏览器四前缀 + iOS Safari 兼容判断）。 */
function isWrapperFullscreen(wrapper: HTMLElement | null): boolean {
    if (!wrapper) return false;
    const doc = document as Document & {
        webkitFullscreenElement?: Element | null;
        mozFullScreenElement?: Element | null;
        msFullscreenElement?: Element | null;
    };
    const el = wrapper as HTMLElement & { webkitDisplayingFullscreen?: boolean };
    return !!(
        doc.fullscreenElement === wrapper ||
        doc.webkitFullscreenElement === wrapper ||
        doc.mozFullScreenElement === wrapper ||
        doc.msFullscreenElement === wrapper ||
        el.webkitDisplayingFullscreen
    );
}

export function VideoPlayer(&{
    src,
    poster,
    width,
    height,
    autoPlay = false,
    loop = false,
    muted: mutedProp = false,
    volume: volumeProp = 100,
    seekTime = 10,
    theme = 'dark',
    playbackRateList = DEFAULT_PLAYBACK_RATE_LIST,
    showPictureInPicture = true,
    class: className,
    style,
    onPlay,
    onPause,
    onRateChange,
    onVolumeChange,
}: VideoPlayerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<VideoPlayerState>(() => ({
        ...DEFAULT_VIDEO_PLAYER_STATE,
        isPlaying: autoPlay,
        volume: volumeProp,
        muted: mutedProp,
    }));

    const foundation = new VideoPlayerFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<VideoPlayerState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { seekTime },
    );

    let videoEl: HTMLVideoElement | null = null;
    let wrapperEl: HTMLElement | null = null;
    let &[showRateMenu] = track<boolean>(false);
    let controlsHideTimer: ReturnType<typeof setTimeout> | undefined;
    let scrollPosition: { x: number; y: number } | null = null;

    function handlePlayPause() {
        const el = untrack(() => videoEl);
        if (!el) return;
        if (el.paused) void el.play();
        else el.pause();
    }

    function handleVideoPlay() {
        foundation.syncPlayingFromMedia(true);
        onPlay?.();
    }

    function handleVideoPause() {
        foundation.syncPlayingFromMedia(false);
        onPause?.();
    }

    function handleTimeUpdate() {
        const el = untrack(() => videoEl);
        if (el) foundation.handleTimeUpdate(el.currentTime);
    }

    function handleDurationChange() {
        const el = untrack(() => videoEl);
        if (el) foundation.handleDurationChange(el.duration);
    }

    function handleProgress() {
        const el = untrack(() => videoEl);
        if (el && el.buffered.length > 0) {
            foundation.handleProgress(el.buffered.end(el.buffered.length - 1));
        }
    }

    function handleEnded() {
        foundation.handleEnded();
    }

    function handleError() {
        foundation.handleError();
    }

    function handleSeek(value: number) {
        const el = untrack(() => videoEl);
        const clamped = foundation.seekTo(value);
        if (el) el.currentTime = clamped;
    }

    function handleVolumeChange(value: number) {
        const el = untrack(() => videoEl);
        const { volumeRatio } = foundation.changeVolume(value);
        if (el) el.volume = volumeRatio;
        onVolumeChange?.(value);
    }

    function handleToggleMute() {
        const el = untrack(() => videoEl);
        const { volumeRatio } = foundation.toggleMute();
        if (el) el.volume = volumeRatio;
    }

    function handleSpeedChange(rate: PlaybackRateOption) {
        const el = untrack(() => videoEl);
        foundation.changeSpeed(rate);
        if (el) el.playbackRate = rate.value;
        onRateChange?.(rate.value);
        showRateMenu = false;
    }

    function handleToggleFullscreen() {
        const wrapper = untrack(() => wrapperEl);
        if (!wrapper) return;
        if (isWrapperFullscreen(wrapper)) {
            void document.exitFullscreen();
        } else {
            scrollPosition = { x: window.scrollX, y: window.scrollY };
            void wrapper.requestFullscreen();
        }
    }

    function handleTogglePictureInPicture() {
        const el = untrack(() => videoEl);
        if (!el) return;
        if (document.pictureInPictureElement === el) {
            void document.exitPictureInPicture();
        } else {
            void el.requestPictureInPicture?.();
        }
    }

    function handleLeavePictureInPicture() {
        const el = untrack(() => videoEl);
        if (el) foundation.syncPictureInPictureFromMedia(false);
    }

    function scheduleHideControls() {
        if (controlsHideTimer) clearTimeout(controlsHideTimer);
        controlsHideTimer = setTimeout(() => {
            if (untrack(() => state).isPlaying) foundation.hideControls();
        }, 3000);
    }

    function handleMouseMove() {
        foundation.showControlsNow();
        scheduleHideControls();
    }

    function handleMouseLeaveWrapper() {
        if (untrack(() => state).isPlaying) foundation.hideControls();
    }

    effect(() => {
        function handleFullscreenChange() {
            const wrapper = untrack(() => wrapperEl);
            const isFs = isWrapperFullscreen(wrapper);
            foundation.syncFullscreenFromMedia(isFs);
            if (!isFs && scrollPosition) {
                const pos = scrollPosition;
                setTimeout(() => window.scrollTo(pos.x, pos.y), 0);
                scrollPosition = null;
            }
        }
        document.addEventListener('fullscreenchange', handleFullscreenChange);
        return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
    });

    <>
        <div
            class={['lotus-video-player', `lotus-video-player-${theme}`, className ?? ''].filter(Boolean).join(' ')}
            style={{
                ...style,
                ...(width !== undefined ? { width: `${width}` } : {}),
                ...(height !== undefined ? { height: `${height}` } : {}),
            }}
            ref={(node: HTMLElement | null) => { wrapperEl = node; }}
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeaveWrapper}
        >
            <video
                ref={(node: HTMLVideoElement | null) => { videoEl = node; }}
                class="lotus-video-player-media"
                src={src}
                poster={poster}
                loop={loop}
                autoPlay={autoPlay}
                onPlay={handleVideoPlay}
                onPause={handleVideoPause}
                onTimeUpdate={handleTimeUpdate}
                onDurationChange={handleDurationChange}
                onProgress={handleProgress}
                onEnded={handleEnded}
                onError={handleError}
                onLeavePictureInPicture={handleLeavePictureInPicture}
                onClick={handlePlayPause}
            />

            @if (state.isError) {
                <div class="lotus-video-player-error" role="alert">{locale.VideoPlayer.loadError}</div>
            }

            @if (state.showNotification) {
                <div class="lotus-video-player-notification">{state.notificationContent}</div>
            }

            @if (!state.isPlaying) {
                <button type="button" class="lotus-video-player-center-play" aria-label={locale.VideoPlayer.play} onClick={handlePlayPause}>
                    <IconPlay />
                </button>
            }

            <div class={['lotus-video-player-controls', state.showControls ? 'lotus-video-player-controls-visible' : ''].filter(Boolean).join(' ')}>
                <div class="lotus-video-player-progress">
                    <AudioSlider value={state.currentTime} max={state.totalTime} aria-label={locale.VideoPlayer.progress} onChange={handleSeek} />
                </div>
                <div class="lotus-video-player-toolbar">
                    <button type="button" class="lotus-video-player-btn" aria-label={state.isPlaying ? locale.VideoPlayer.pause : locale.VideoPlayer.play} onClick={handlePlayPause}>
                        @if (state.isPlaying) {
                            <IconPause />
                        } @else {
                            <IconPlay />
                        }
                    </button>

                    <button type="button" class="lotus-video-player-btn" aria-label={state.muted ? locale.VideoPlayer.unmute : locale.VideoPlayer.mute} onClick={handleToggleMute}>
                        @if (state.muted) {
                            <IconMute />
                        } @else {
                            <IconVolume2 />
                        }
                    </button>
                    <div class="lotus-video-player-volume">
                        <AudioSlider value={state.muted ? 0 : state.volume} max={100} aria-label={locale.VideoPlayer.volume} onChange={handleVolumeChange} />
                    </div>

                    <span class="lotus-video-player-time">
                        {formatVideoTime(state.currentTime)} / {formatVideoTime(state.totalTime)}
                    </span>

                    <div class="lotus-video-player-spacer" />

                    <div class="lotus-video-player-rate-wrap">
                        <button type="button" class="lotus-video-player-btn lotus-video-player-rate-btn" aria-label={locale.VideoPlayer.rate} onClick={() => { showRateMenu = !showRateMenu; }}>
                            {state.playbackRate}x
                        </button>
                        @if (showRateMenu) {
                            <ul class="lotus-video-player-rate-menu" role="menu">
                                @for (const rate of playbackRateList; key rate.value) {
                                    <li role="menuitem">
                                        <button type="button" class="lotus-video-player-rate-item" onClick={() => handleSpeedChange(rate)}>
                                            {rate.label}
                                        </button>
                                    </li>
                                }
                            </ul>
                        }
                    </div>

                    @if (showPictureInPicture) {
                        <button type="button" class="lotus-video-player-btn" aria-label={locale.VideoPlayer.pictureInPicture} onClick={handleTogglePictureInPicture}>
                            <IconMaximize2 />
                        </button>
                    }

                    <button type="button" class="lotus-video-player-btn" aria-label={state.isFullscreen ? locale.VideoPlayer.exitFullscreen : locale.VideoPlayer.fullscreen} onClick={handleToggleFullscreen}>
                        @if (state.isFullscreen) {
                            <IconShrinkScreenStroked />
                        } @else {
                            <IconFullScreenStroked />
                        }
                    </button>
                </div>
            </div>
        </div>

        <style>
            .lotus-video-player {
                position: relative;
                background: #000;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-video-player :global(.lotus-video-player-media) {
                display: block;
                width: 100%;
                height: 100%;
                background: #000;
            }

            .lotus-video-player-error {
                position: absolute;
                inset: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                color: var(--lotus-color-danger);
                background: rgba(0, 0, 0, 0.6);
            }

            .lotus-video-player-notification {
                position: absolute;
                top: 12px;
                left: 50%;
                transform: translateX(-50%);
                background: rgba(0, 0, 0, 0.6);
                color: #fff;
                padding: 4px 12px;
                border-radius: var(--lotus-border-radius-small);
                font-size: 12px;
            }

            .lotus-video-player-center-play {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                width: 56px;
                height: 56px;
                border-radius: 50%;
                border: none;
                background: rgba(0, 0, 0, 0.5);
                color: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                font-size: 24px;
            }

            .lotus-video-player-controls {
                position: absolute;
                left: 0;
                right: 0;
                bottom: 0;
                padding: 8px 12px;
                background: linear-gradient(to top, rgba(0, 0, 0, 0.7), transparent);
                opacity: 0;
                transition: opacity 0.2s;
                pointer-events: none;
            }

            .lotus-video-player-controls-visible {
                opacity: 1;
                pointer-events: auto;
            }

            .lotus-video-player-progress {
                margin-bottom: 6px;
            }

            .lotus-video-player-toolbar {
                display: flex;
                align-items: center;
                gap: 6px;
                color: #fff;
            }

            .lotus-video-player-btn {
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

            .lotus-video-player-btn:hover {
                background: rgba(255, 255, 255, 0.15);
            }

            .lotus-video-player-volume {
                width: 60px;
            }

            .lotus-video-player-time {
                font-size: 12px;
                font-variant-numeric: tabular-nums;
                white-space: nowrap;
            }

            .lotus-video-player-spacer {
                flex: 1;
            }

            .lotus-video-player-rate-wrap {
                position: relative;
            }

            .lotus-video-player-rate-btn {
                width: auto;
                padding: 0 6px;
                font-size: 12px;
            }

            .lotus-video-player-rate-menu {
                position: absolute;
                bottom: 100%;
                right: 0;
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

            .lotus-video-player-rate-item {
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

            .lotus-video-player-rate-item:hover {
                background: var(--lotus-color-fill-1);
            }
        </style>
    </>
}
