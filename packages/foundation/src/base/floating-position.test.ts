import { describe, it, expect } from 'vitest';
import { calcFloatingStyle, type FloatingRect } from './floating-position.js';

const CENTER_TRIGGER: FloatingRect = { top: 400, left: 400, right: 500, bottom: 440, width: 100, height: 40 };
const VIEWPORT = { viewportWidth: 1000, viewportHeight: 800 };
const SIZE = { width: 120, height: 40 };

describe('calcFloatingStyle: 基础锚点计算（无溢出场景）', () => {
  it('top：锚点在触发元素上方水平居中，transform 向左上平移自身尺寸', () => {
    const style = calcFloatingStyle({ position: 'top', triggerRect: CENTER_TRIGGER, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('top');
    expect(style.left).toBe(450);
    expect(style.top).toBe(392);
    expect(style.transform).toBe('translate(-50%, -100%)');
  });

  it('bottomLeft：锚点在触发元素左下角，无水平平移', () => {
    const style = calcFloatingStyle({ position: 'bottomLeft', triggerRect: CENTER_TRIGGER, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('bottomLeft');
    expect(style.left).toBe(400);
    expect(style.top).toBe(448);
  });

  it('right：锚点在触发元素右侧垂直居中', () => {
    const style = calcFloatingStyle({ position: 'right', triggerRect: CENTER_TRIGGER, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('right');
    expect(style.left).toBe(508);
    expect(style.top).toBe(420);
  });

  it('spacing 自定义间距生效', () => {
    const style = calcFloatingStyle({ position: 'top', triggerRect: CENTER_TRIGGER, floatingSize: SIZE, spacing: 20, ...VIEWPORT });
    expect(style.top).toBe(380);
  });
});

describe('calcFloatingStyle: autoAdjustOverflow 溢出翻转', () => {
  it('触发元素贴近视口顶部时，position=top 因空间不足翻转为 bottom', () => {
    const nearTopTrigger: FloatingRect = { top: 10, left: 400, right: 500, bottom: 50, width: 100, height: 40 };
    const style = calcFloatingStyle({ position: 'top', triggerRect: nearTopTrigger, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('bottom');
  });

  it('触发元素贴近视口底部时，position=bottom 因空间不足翻转为 top', () => {
    const nearBottomTrigger: FloatingRect = { top: 770, left: 400, right: 500, bottom: 795, width: 100, height: 25 };
    const style = calcFloatingStyle({ position: 'bottom', triggerRect: nearBottomTrigger, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('top');
  });

  it('两侧空间都不足时保留首选方向（不做过度降级）', () => {
    const tinyViewport = { viewportWidth: 1000, viewportHeight: 60 };
    const trigger: FloatingRect = { top: 10, left: 400, right: 500, bottom: 50, width: 100, height: 40 };
    const style = calcFloatingStyle({ position: 'top', triggerRect: trigger, floatingSize: SIZE, ...tinyViewport });
    expect(style.position).toBe('top');
  });

  it('autoAdjustOverflow=false 时即使溢出也不翻转', () => {
    const nearTopTrigger: FloatingRect = { top: 10, left: 400, right: 500, bottom: 50, width: 100, height: 40 };
    const style = calcFloatingStyle({ position: 'top', triggerRect: nearTopTrigger, floatingSize: SIZE, autoAdjustOverflow: false, ...VIEWPORT });
    expect(style.position).toBe('top');
  });

  it('水平方向溢出（position=left 贴近视口左边）翻转为 right', () => {
    const nearLeftTrigger: FloatingRect = { top: 400, left: 10, right: 60, bottom: 440, width: 50, height: 40 };
    const style = calcFloatingStyle({ position: 'left', triggerRect: nearLeftTrigger, floatingSize: SIZE, ...VIEWPORT });
    expect(style.position).toBe('right');
  });
});
