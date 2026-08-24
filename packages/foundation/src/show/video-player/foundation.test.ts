import { describe, expect, it } from 'vitest';
import { VideoPlayerFoundation, DEFAULT_VIDEO_PLAYER_STATE, type VideoPlayerState } from './foundation.js';

function createFoundation(patch: Partial<VideoPlayerState> = {}, options?: { seekTime?: number }) {
  let state: VideoPlayerState = { ...DEFAULT_VIDEO_PLAYER_STATE, ...patch };
  const foundation = new VideoPlayerFoundation(
    {
      getState: () => state,
      setState: (p) => {
        state = { ...state, ...p };
      },
    },
    options,
  );
  return { foundation, getState: () => state };
}

describe('VideoPlayerFoundation', () => {
  it('togglePlaying 切换播放态', () => {
    const { foundation, getState } = createFoundation();
    expect(foundation.togglePlaying()).toBe(true);
    expect(getState().isPlaying).toBe(true);
  });

  it('syncPlayingFromMedia 直接回写播放态（原生事件驱动）', () => {
    const { foundation, getState } = createFoundation();
    foundation.syncPlayingFromMedia(true);
    expect(getState().isPlaying).toBe(true);
  });

  it('seekTo 钳制到 [0,totalTime]', () => {
    const { foundation, getState } = createFoundation({ totalTime: 100 });
    expect(foundation.seekTo(150)).toBe(100);
    expect(getState().currentTime).toBe(100);
  });

  it('seekRelative 按 seekTime 快进快退', () => {
    const { foundation, getState } = createFoundation({ totalTime: 100, currentTime: 50 }, { seekTime: 10 });
    foundation.seekRelative(1);
    expect(getState().currentTime).toBe(60);
    foundation.seekRelative(-1);
    expect(getState().currentTime).toBe(50);
  });

  it('handleTimeUpdate/handleDurationChange/handleProgress 回写对应字段', () => {
    const { foundation, getState } = createFoundation();
    foundation.handleTimeUpdate(42);
    foundation.handleDurationChange(200);
    foundation.handleProgress(88);
    expect(getState()).toMatchObject({ currentTime: 42, totalTime: 200, bufferedTime: 88 });
  });

  it('changeVolume 取整、返回 0-1 区间、音量为 0 时同步 muted', () => {
    const { foundation, getState } = createFoundation();
    const result = foundation.changeVolume(45.9);
    expect(result).toEqual({ volumeRatio: 0.45, muted: false });
    expect(getState().volume).toBe(45);

    const zeroResult = foundation.changeVolume(0);
    expect(zeroResult.muted).toBe(true);
  });

  it('toggleMute 静音记忆并恢复此前音量', () => {
    const { foundation, getState } = createFoundation({ volume: 80, muted: false });
    const muted = foundation.toggleMute();
    expect(muted).toEqual({ volumeRatio: 0, muted: true });
    expect(getState().volume).toBe(80);

    const unmuted = foundation.toggleMute();
    expect(unmuted).toEqual({ volumeRatio: 0.8, muted: false });
  });

  it('changeSpeed 更新倍速状态', () => {
    const { foundation, getState } = createFoundation();
    foundation.changeSpeed({ label: '2.0x', value: 2 });
    expect(getState().playbackRate).toBe(2);
  });

  it('requestToggleFullscreen 只返回意图，不直接改状态', () => {
    const { foundation, getState } = createFoundation({ isFullscreen: false });
    expect(foundation.requestToggleFullscreen()).toBe(true);
    expect(getState().isFullscreen).toBe(false);
  });

  it('syncFullscreenFromMedia 回写真实全屏状态', () => {
    const { foundation, getState } = createFoundation();
    foundation.syncFullscreenFromMedia(true);
    expect(getState().isFullscreen).toBe(true);
  });

  it('requestTogglePictureInPicture/syncPictureInPictureFromMedia', () => {
    const { foundation, getState } = createFoundation({ isPictureInPicture: false });
    expect(foundation.requestTogglePictureInPicture()).toBe(true);
    foundation.syncPictureInPictureFromMedia(true);
    expect(getState().isPictureInPicture).toBe(true);
  });

  it('showControlsNow/hideControls', () => {
    const { foundation, getState } = createFoundation({ showControls: false });
    foundation.showControlsNow();
    expect(getState().showControls).toBe(true);
    foundation.hideControls();
    expect(getState().showControls).toBe(false);
  });

  it('showNotificationText/hideNotification', () => {
    const { foundation, getState } = createFoundation();
    foundation.showNotificationText('缓冲中');
    expect(getState()).toMatchObject({ notificationContent: '缓冲中', showNotification: true });
    foundation.hideNotification();
    expect(getState().showNotification).toBe(false);
  });

  it('handleEnded 停止播放并显示控件', () => {
    const { foundation, getState } = createFoundation({ isPlaying: true, showControls: false });
    foundation.handleEnded();
    expect(getState()).toMatchObject({ isPlaying: false, showControls: true });
  });

  it('handleError/resetError', () => {
    const { foundation, getState } = createFoundation();
    foundation.handleError();
    expect(getState().isError).toBe(true);
    foundation.resetError();
    expect(getState().isError).toBe(false);
  });
});
