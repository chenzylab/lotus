import { describe, it, expect } from 'vitest';
import { resolveSteps, type StepItemInput } from './foundation.js';

const ITEMS: StepItemInput[] = [
  { title: 'Step 1' },
  { title: 'Step 2' },
  { title: 'Step 3' },
  { title: 'Step 4' },
];

describe('resolveSteps', () => {
  it('current 之前的步骤状态为 finish，done=true', () => {
    const resolved = resolveSteps(ITEMS, 2, 'process', 0);

    expect(resolved[0]!.status).toBe('finish');
    expect(resolved[0]!.done).toBe(true);
    expect(resolved[1]!.status).toBe('finish');
    expect(resolved[1]!.done).toBe(true);
  });

  it('current 对应的步骤状态取外部传入的 status，active=true', () => {
    const resolved = resolveSteps(ITEMS, 2, 'process', 0);

    expect(resolved[2]!.status).toBe('process');
    expect(resolved[2]!.active).toBe(true);
    expect(resolved[2]!.done).toBe(false);
  });

  it('current 之后的步骤状态为 wait', () => {
    const resolved = resolveSteps(ITEMS, 2, 'process', 0);

    expect(resolved[3]!.status).toBe('wait');
    expect(resolved[3]!.done).toBe(false);
    expect(resolved[3]!.active).toBe(false);
  });

  it('status=error 时当前步状态为 error，前一步标记 isPreErrorStep', () => {
    const resolved = resolveSteps(ITEMS, 2, 'error', 0);

    expect(resolved[2]!.status).toBe('error');
    expect(resolved[1]!.isPreErrorStep).toBe(true);
    expect(resolved[0]!.isPreErrorStep).toBe(false);
    expect(resolved[2]!.isPreErrorStep).toBe(false);
  });

  it('item 显式声明 status 时覆盖自动计算', () => {
    const items: StepItemInput[] = [{ title: 'A', status: 'warning' }, { title: 'B' }];
    const resolved = resolveSteps(items, 0, 'process', 0);

    expect(resolved[0]!.status).toBe('warning');
  });

  it('initial 偏移影响 stepNumber 计算，但不改变数组下标', () => {
    const resolved = resolveSteps(ITEMS, 12, 'process', 10);

    expect(resolved[0]!.stepNumber).toBe(10);
    expect(resolved[1]!.stepNumber).toBe(11);
    expect(resolved[2]!.stepNumber).toBe(12);
    expect(resolved[2]!.active).toBe(true);
  });

  it('current=0 时第一步是 active，其余全部 wait', () => {
    const resolved = resolveSteps(ITEMS, 0, 'process', 0);

    expect(resolved[0]!.active).toBe(true);
    expect(resolved[0]!.status).toBe('process');
    resolved.slice(1).forEach((step) => {
      expect(step.status).toBe('wait');
    });
  });

  it('current 超过所有步骤数时全部步骤状态为 finish', () => {
    const resolved = resolveSteps(ITEMS, 99, 'process', 0);

    resolved.forEach((step) => {
      expect(step.status).toBe('finish');
      expect(step.done).toBe(true);
    });
  });

  it('空数组返回空结果', () => {
    expect(resolveSteps([], 0, 'process', 0)).toEqual([]);
  });
});
