import { describe, it, expect } from 'vitest';
import { buildPalette, DEFAULT_BRAND } from './palette.js';

describe('buildPalette', () => {
  it('produces light and dark scales for all seven semantic hues', () => {
    const { light, dark } = buildPalette();
    const hues = Object.keys(DEFAULT_BRAND);

    expect(hues).toEqual(['primary', 'secondary', 'tertiary', 'success', 'warning', 'danger', 'info']);
    for (const hue of hues) {
      expect(light[hue as keyof typeof light]).toHaveLength(10);
      expect(dark[hue as keyof typeof dark]).toHaveLength(10);
    }
  });

  it('dark scale step 5 differs from light scale step 5 (brightness adjusted)', () => {
    const { light, dark } = buildPalette();
    expect(dark.primary[5]).not.toBe(light.primary[5]);
  });

  it('info and primary share the same brand hex input by default, producing identical light scales', () => {
    const { light } = buildPalette();
    expect(light.info).toEqual(light.primary);
  });
});
