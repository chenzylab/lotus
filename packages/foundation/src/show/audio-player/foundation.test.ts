import { describe, expect, it } from 'vitest';
import { AudioPlayerFoundation, type AudioPlayerState } from './foundation.js';

function createFoundation(
  initial: AudioPlayerState,
  options?: { audioUrl?: any; autoPlay?: boolean; skipDuration?: number },
) {
  let state = initial;
  const foundation = new AudioPlayerFoundation(
    {
      getState: () => state,
      setState: (patch) => {
        state = { ...state, ...patch };
      },
    },
    options,
  );
  return { foundation, getState: () => state };
}

const INITIAL: AudioPlayerState = {
  isPlaying: false,
  currentTime: 0,
  totalTime: 100,
  volume: 100,
  playbackRate: { label: '1.0x', value: 1 },
  currentTrackIndex: 0,
  isError: false,
};

describe('AudioPlayerFoundation', () => {
  it('getTracks/isMultiTrack 反映归一化后的曲目', () => {
    const { foundation } = createFoundation(INITIAL, { audioUrl: ['a.mp3', 'b.mp3'] });
    expect(foundation.getTracks()).toEqual([{ src: 'a.mp3' }, { src: 'b.mp3' }]);
    expect(foundation.isMultiTrack()).toBe(true);
  });

  it('单曲时 isMultiTrack 为 false', () => {
    const { foundation } = createFoundation(INITIAL, { audioUrl: 'a.mp3' });
    expect(foundation.isMultiTrack()).toBe(false);
  });

  it('togglePlaying 切换播放态', () => {
    const { foundation, getState } = createFoundation(INITIAL);
    expect(foundation.togglePlaying()).toBe(true);
    expect(getState().isPlaying).toBe(true);
    expect(foundation.togglePlaying()).toBe(false);
  });

  it('changeTrack 单曲时不生效，索引不变', () => {
    const { foundation } = createFoundation(INITIAL, { audioUrl: 'a.mp3' });
    expect(foundation.changeTrack('next')).toBe(0);
  });

  it('changeTrack 多曲时取模循环并重置进度状态', () => {
    const { foundation, getState } = createFoundation(INITIAL, { audioUrl: ['a.mp3', 'b.mp3'] });
    const next = foundation.changeTrack('next');
    expect(next).toBe(1);
    expect(getState()).toMatchObject({
      currentTrackIndex: 1,
      currentTime: 0,
      totalTime: 0,
      isError: false,
      isPlaying: true,
    });
  });

  it('seekTo 钳制到 [0, totalTime]', () => {
    const { foundation, getState } = createFoundation(INITIAL);
    expect(foundation.seekTo(150)).toBe(100);
    expect(getState().currentTime).toBe(100);
    expect(foundation.seekTo(-10)).toBe(0);
  });

  it('seekRelative 按 skipDuration 快进快退', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, currentTime: 50 }, { skipDuration: 10 });
    foundation.seekRelative(1);
    expect(getState().currentTime).toBe(60);
    foundation.seekRelative(-1);
    expect(getState().currentTime).toBe(50);
  });

  it('changeSpeed 更新倍速状态', () => {
    const { foundation, getState } = createFoundation(INITIAL);
    foundation.changeSpeed({ label: '2.0x', value: 2 });
    expect(getState().playbackRate).toEqual({ label: '2.0x', value: 2 });
  });

  it('refresh 出错态返回 shouldReload=true 并清除 isError', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, isError: true });
    const result = foundation.refresh();
    expect(result.shouldReload).toBe(true);
    expect(getState().isError).toBe(false);
  });

  it('refresh 非出错态只重置 currentTime，不影响播放态', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, currentTime: 50, isPlaying: true });
    const result = foundation.refresh();
    expect(result.shouldReload).toBe(false);
    expect(getState().currentTime).toBe(0);
    expect(getState().isPlaying).toBe(true);
  });

  it('changeVolume 取整并返回 0-1 区间供写入 audio.volume', () => {
    const { foundation, getState } = createFoundation(INITIAL);
    const written = foundation.changeVolume(45.9);
    expect(written).toBe(0.45);
    expect(getState().volume).toBe(45);
  });

  it('handleTimeUpdate 回写 currentTime，NaN 视为 0', () => {
    const { foundation, getState } = createFoundation(INITIAL);
    foundation.handleTimeUpdate(42);
    expect(getState().currentTime).toBe(42);
    foundation.handleTimeUpdate(NaN);
    expect(getState().currentTime).toBe(0);
  });

  it('initFromMedia 回写 totalTime/volume/rate/isPlaying(=autoPlay)', () => {
    const { foundation, getState } = createFoundation(INITIAL, { autoPlay: true });
    foundation.initFromMedia(200, 0.8, 1.5);
    expect(getState()).toMatchObject({
      totalTime: 200,
      volume: 80,
      playbackRate: { label: '1.0x', value: 1.5 },
      isPlaying: true,
    });
  });

  it('resetProgress 归零进度并清除错误态', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, currentTime: 50, totalTime: 100, isError: true });
    foundation.resetProgress();
    expect(getState()).toMatchObject({ currentTime: 0, totalTime: 0, isError: false });
  });

  it('handleEnded 多曲切下一曲并返回 true', () => {
    const { foundation, getState } = createFoundation(INITIAL, { audioUrl: ['a.mp3', 'b.mp3'] });
    const switched = foundation.handleEnded();
    expect(switched).toBe(true);
    expect(getState().currentTrackIndex).toBe(1);
  });

  it('handleEnded 单曲停止播放并返回 false', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, isPlaying: true }, { audioUrl: 'a.mp3' });
    const switched = foundation.handleEnded();
    expect(switched).toBe(false);
    expect(getState().isPlaying).toBe(false);
  });

  it('handleError 置 isError，不影响播放态', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, isPlaying: true });
    foundation.handleError();
    expect(getState().isError).toBe(true);
    expect(getState().isPlaying).toBe(true);
  });

  it('setAudioUrl 替换曲目并归零进度，越界索引钳制到最后一首', () => {
    const { foundation, getState } = createFoundation({ ...INITIAL, currentTrackIndex: 2 }, { audioUrl: ['a.mp3', 'b.mp3', 'c.mp3'] });
    foundation.setAudioUrl(['x.mp3']);
    expect(foundation.getTracks()).toEqual([{ src: 'x.mp3' }]);
    expect(getState()).toMatchObject({ currentTrackIndex: 0, currentTime: 0, totalTime: 0, isError: false });
  });
});
