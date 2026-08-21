import { describe, it, expect } from 'vitest';
import { rgbaToHsva, hsvaToRgba, rgbaToHex, hexToRgba, hsvaToHsla, hslaToHsva, fromHsva, fromRgba, fromHex } from './convert.js';

describe('color-picker convert', () => {
  it('rgbaToHsva：Semi 品牌青绿色 rgb(57,197,187) 换算', () => {
    const hsva = rgbaToHsva({ r: 57, g: 197, b: 187, a: 1 });
    expect(hsva.h).toBe(176);
    expect(hsva.s).toBe(71);
    expect(hsva.v).toBe(77);
    expect(hsva.a).toBe(1);
  });

  it('hsvaToRgba：往返换算应恢复原值（允许 ±1 舍入误差）', () => {
    const rgba = hsvaToRgba({ h: 176, s: 71, v: 77, a: 1 });
    expect(Math.abs(rgba.r - 57)).toBeLessThanOrEqual(1);
    expect(Math.abs(rgba.g - 197)).toBeLessThanOrEqual(1);
    expect(Math.abs(rgba.b - 187)).toBeLessThanOrEqual(1);
  });

  it('六原色边界：红、绿、蓝、黄、青、品红', () => {
    expect(hsvaToRgba({ h: 0, s: 100, v: 100, a: 1 })).toEqual({ r: 255, g: 0, b: 0, a: 1 });
    expect(hsvaToRgba({ h: 120, s: 100, v: 100, a: 1 })).toEqual({ r: 0, g: 255, b: 0, a: 1 });
    expect(hsvaToRgba({ h: 240, s: 100, v: 100, a: 1 })).toEqual({ r: 0, g: 0, b: 255, a: 1 });
    expect(rgbaToHsva({ r: 255, g: 255, b: 0, a: 1 }).h).toBe(60);
    expect(rgbaToHsva({ r: 0, g: 255, b: 255, a: 1 }).h).toBe(180);
    expect(rgbaToHsva({ r: 255, g: 0, b: 255, a: 1 }).h).toBe(300);
  });

  it('黑白灰：s=0 或 v=0 时 h 恒为 0', () => {
    expect(rgbaToHsva({ r: 0, g: 0, b: 0, a: 1 })).toEqual({ h: 0, s: 0, v: 0, a: 1 });
    expect(rgbaToHsva({ r: 255, g: 255, b: 255, a: 1 })).toEqual({ h: 0, s: 0, v: 100, a: 1 });
    expect(rgbaToHsva({ r: 128, g: 128, b: 128, a: 1 }).s).toBe(0);
  });

  it('rgbaToHex：a=1 输出 6 位，a<1 输出 8 位', () => {
    expect(rgbaToHex({ r: 57, g: 197, b: 187, a: 1 })).toBe('#39c5bb');
    expect(rgbaToHex({ r: 255, g: 0, b: 0, a: 0.5 })).toBe('#ff000080');
  });

  it('hexToRgba：支持 3/4/6/8 位缩写与完整格式', () => {
    expect(hexToRgba('#39c5bb')).toEqual({ r: 57, g: 197, b: 187, a: 1 });
    expect(hexToRgba('39c5bb')).toEqual({ r: 57, g: 197, b: 187, a: 1 });
    expect(hexToRgba('#fff')).toEqual({ r: 255, g: 255, b: 255, a: 1 });
    expect(hexToRgba('#f00a')?.a).toBeCloseTo(2 / 3, 1);
  });

  it('hexToRgba：非法输入返回 null', () => {
    expect(hexToRgba('not-a-color')).toBeNull();
    expect(hexToRgba('#ff')).toBeNull();
    expect(hexToRgba('#gggggg')).toBeNull();
  });

  it('hsvaToHsla / hslaToHsva：往返换算恢复原值', () => {
    const hsva = { h: 176, s: 71, v: 77, a: 1 };
    const hsla = hsvaToHsla(hsva);
    const back = hslaToHsva(hsla);
    expect(back.h).toBe(hsva.h);
    expect(Math.abs(back.s - hsva.s)).toBeLessThanOrEqual(1);
    expect(Math.abs(back.v - hsva.v)).toBeLessThanOrEqual(1);
  });

  it('fromHsva/fromRgba/fromHex：三态互相一致', () => {
    const fromH = fromHsva({ h: 176, s: 71, v: 77, a: 1 });
    const fromR = fromRgba(fromH.rgba);
    const fromX = fromHex(fromH.hex);
    expect(fromR.hex).toBe(fromH.hex);
    expect(fromX?.rgba).toEqual(fromH.rgba);
  });

  it('fromHex：非法输入返回 null', () => {
    expect(fromHex('invalid')).toBeNull();
  });
});
