import { describe, it, expect } from 'vitest';
import { hexToRgb, rgbToHsb, hsbToRgb, rgbToHex, generateScale, toDarkModeVariant } from './color.js';

describe('color conversions', () => {
  it('hex -> rgb -> hex round-trips', () => {
    expect(rgbToHex(hexToRgb('#0064fa'))).toBe('#0064fa');
  });

  it('rgb -> hsb -> rgb round-trips within rounding tolerance', () => {
    const rgb = hexToRgb('#0064fa');
    const hsb = rgbToHsb(rgb);
    const back = hsbToRgb(hsb);
    expect(Math.abs(back.r - rgb.r)).toBeLessThanOrEqual(1);
    expect(Math.abs(back.g - rgb.g)).toBeLessThanOrEqual(1);
    expect(Math.abs(back.b - rgb.b)).toBeLessThanOrEqual(1);
  });
});

describe('generateScale', () => {
  it('produces exactly 10 steps', () => {
    expect(generateScale('#0064fa')).toHaveLength(10);
  });

  it('step 5 matches the brand color', () => {
    const scale = generateScale('#0064fa');
    expect(scale[5]).toBe('#0064fa');
  });

  it('lighter steps (0-4) are monotonically brighter toward index 0', () => {
    const scale = generateScale('#0064fa');
    const brightness = (hex: string) => rgbToHsb(hexToRgb(hex)).b;
    for (let i = 1; i <= 4; i++) {
      expect(brightness(scale[i - 1])).toBeGreaterThanOrEqual(brightness(scale[i]));
    }
  });

  it('darker steps (6-9) are monotonically darker toward index 9', () => {
    const scale = generateScale('#0064fa');
    const brightness = (hex: string) => rgbToHsb(hexToRgb(hex)).b;
    for (let i = 7; i <= 9; i++) {
      expect(brightness(scale[i])).toBeLessThanOrEqual(brightness(scale[i - 1]));
    }
  });
});

describe('toDarkModeVariant', () => {
  it('reduces saturation and increases brightness relative to the source', () => {
    const source = '#0064fa';
    const dark = toDarkModeVariant(source);
    const sourceHsb = rgbToHsb(hexToRgb(source));
    const darkHsb = rgbToHsb(hexToRgb(dark));
    expect(darkHsb.s).toBeLessThanOrEqual(sourceHsb.s);
    expect(darkHsb.b).toBeGreaterThanOrEqual(sourceHsb.b);
  });
});
