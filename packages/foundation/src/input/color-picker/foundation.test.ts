import { describe, it, expect } from 'vitest';
import { ColorPickerFoundation, DEFAULT_COLOR_VALUE, type ColorPickerState } from './foundation.js';
import type { Adapter } from '../../base/adapter.js';

function createFoundation(alpha = true) {
  let state: ColorPickerState = { value: DEFAULT_COLOR_VALUE, format: 'hex' };
  const adapter: Adapter<ColorPickerState> = {
    getState: () => state,
    setState: (patch) => { state = { ...state, ...patch }; },
  };
  const foundation = new ColorPickerFoundation(adapter, { alpha });
  return { foundation, getState: () => state };
}

describe('ColorPickerFoundation', () => {
  it('posToSaturationValue：左上角 (0,0) 对应 s=0,v=100，右下角对应 s=100,v=0', () => {
    const { foundation } = createFoundation();
    expect(foundation.posToSaturationValue(0, 0, 200, 200)).toEqual({ s: 0, v: 100 });
    expect(foundation.posToSaturationValue(200, 200, 200, 200)).toEqual({ s: 100, v: 0 });
    expect(foundation.posToSaturationValue(100, 100, 200, 200)).toEqual({ s: 50, v: 50 });
  });

  it('handleSaturationValueChange：更新 s/v，保留原 h/a', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value.hsva;
    const value = foundation.handleSaturationValueChange(0, 0, 200, 200, false);
    expect(value.hsva.s).toBe(0);
    expect(value.hsva.v).toBe(100);
    expect(value.hsva.h).toBe(before.h);
    expect(value.hsva.a).toBe(before.a);
  });

  it('回归防护：isControlled=true 时不写 state.value，但返回值仍是计算结果', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value;
    const value = foundation.handleSaturationValueChange(0, 0, 200, 200, true);
    expect(value.hsva.s).toBe(0);
    expect(getState().value).toEqual(before);
  });

  it('saturationValueToPos：与 posToSaturationValue 互逆', () => {
    const { foundation } = createFoundation();
    const pos = foundation.saturationValueToPos(50, 50, 200, 200);
    expect(pos).toEqual({ x: 100, y: 100 });
  });

  it('posToHue：0 对应 h=0，宽度一半对应 h=180，越界钳制到 [0,360]', () => {
    const { foundation } = createFoundation();
    expect(foundation.posToHue(0, 360)).toBe(0);
    expect(foundation.posToHue(180, 360)).toBe(180);
    expect(foundation.posToHue(-10, 360)).toBe(0);
    expect(foundation.posToHue(1000, 360)).toBe(360);
  });

  it('handleHueChange：更新 h，保留原 s/v/a', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value.hsva;
    const value = foundation.handleHueChange(180, 360, false);
    expect(value.hsva.h).toBe(180);
    expect(value.hsva.s).toBe(before.s);
    expect(value.hsva.v).toBe(before.v);
  });

  it('posToAlpha：0 对应 a=0，满宽对应 a=1', () => {
    const { foundation } = createFoundation();
    expect(foundation.posToAlpha(0, 200)).toBe(0);
    expect(foundation.posToAlpha(200, 200)).toBe(1);
    expect(foundation.posToAlpha(100, 200)).toBe(0.5);
  });

  it('handleAlphaChange：alpha=false 时不生效', () => {
    const { foundation, getState } = createFoundation(false);
    const before = getState().value;
    const value = foundation.handleAlphaChange(0, 200, false);
    expect(value).toEqual(before);
  });

  it('handleAlphaChange：alpha=true 时更新 a', () => {
    const { foundation } = createFoundation(true);
    const value = foundation.handleAlphaChange(0, 200, false);
    expect(value.hsva.a).toBe(0);
    expect(value.rgba.a).toBe(0);
  });

  it('handleRgbaChannelInput：越界/非数字返回 null，不提交', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value;
    expect(foundation.handleRgbaChannelInput('r', '300', false)).toBeNull();
    expect(foundation.handleRgbaChannelInput('r', 'abc', false)).toBeNull();
    expect(getState().value).toEqual(before);
  });

  it('handleRgbaChannelInput：合法输入更新对应通道并同步 hsva/hex', () => {
    const { foundation } = createFoundation();
    const value = foundation.handleRgbaChannelInput('r', '255', false);
    expect(value?.rgba.r).toBe(255);
    expect(value?.hex.startsWith('#ff')).toBe(true);
  });

  it('handleHexInput：非法格式返回 null 不提交', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value;
    expect(foundation.handleHexInput('zzzzzz', false)).toBeNull();
    expect(getState().value).toEqual(before);
  });

  it('handleHexInput：合法输入更新三态', () => {
    const { foundation } = createFoundation();
    const value = foundation.handleHexInput('#ff0000', false);
    expect(value?.rgba).toEqual({ r: 255, g: 0, b: 0, a: 1 });
    expect(value?.hsva.h).toBe(0);
  });

  it('回归防护：isControlled=true 时 handleRgbaChannelInput/handleHexInput 都不写 state', () => {
    const { foundation, getState } = createFoundation();
    const before = getState().value;

    const rgbaResult = foundation.handleRgbaChannelInput('r', '255', true);
    expect(rgbaResult?.rgba.r).toBe(255);
    expect(getState().value).toEqual(before);

    const hexResult = foundation.handleHexInput('#ff0000', true);
    expect(hexResult?.rgba.r).toBe(255);
    expect(getState().value).toEqual(before);
  });

  it('setFormat / syncValue：切换展示格式与外部受控同步', () => {
    const { foundation, getState } = createFoundation();
    foundation.setFormat('rgba');
    expect(getState().format).toBe('rgba');
    const next = { hsva: { h: 0, s: 0, v: 0, a: 1 }, rgba: { r: 0, g: 0, b: 0, a: 1 }, hex: '#000000' };
    foundation.syncValue(next);
    expect(getState().value).toEqual(next);
  });
});
