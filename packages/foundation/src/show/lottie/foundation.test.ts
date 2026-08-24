import { describe, expect, it } from 'vitest';
import { resolveLoadParams } from './foundation.js';

describe('resolveLoadParams', () => {
  it('默认 renderer=svg、loop=true、autoplay=true', () => {
    const container = {} as Element;
    const result = resolveLoadParams(container, { path: '/a.json' });
    expect(result).toEqual({
      container,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      path: '/a.json',
    });
  });

  it('用户 params 逐项覆盖默认值', () => {
    const container = {} as Element;
    const result = resolveLoadParams(container, { renderer: 'canvas', loop: false, autoplay: false });
    expect(result).toMatchObject({ renderer: 'canvas', loop: false, autoplay: false });
  });

  it('container 由调用方显式传入，不受 params 影响', () => {
    const container = {} as Element;
    const result = resolveLoadParams(container, { path: '/a.json' });
    expect(result.container).toBe(container);
  });

  it('animationData 形态的 params 同样正确透传', () => {
    const container = {} as Element;
    const data = { v: '5.0.0' };
    const result = resolveLoadParams(container, { animationData: data });
    expect(result.animationData).toBe(data);
  });
});
