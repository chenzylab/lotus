export type StepStatus = 'wait' | 'process' | 'finish' | 'error' | 'warning';
export type StepsDirection = 'horizontal' | 'vertical';
export type StepsSize = 'default' | 'small';

export interface StepItemInput {
  title?: any;
  description?: any;
  icon?: any;
  /** 显式指定时覆盖自动计算的 status。 */
  status?: StepStatus;
  disabled?: boolean;
}

export interface ResolvedStep extends StepItemInput {
  stepNumber: number;
  status: StepStatus;
  active: boolean;
  done: boolean;
  /** 当前项是"当前步的前一步"且整体 status=error 时为 true，用于给连接线标红。 */
  isPreErrorStep: boolean;
}

/**
 * 计算每个 step 项的最终展示状态。Ripple 没有 React.cloneElement 那种
 * "父组件批量向 children 注入 props" 的能力（同 ButtonGroup/AvatarGroup
 * 先例的设计取舍），Steps 采用 items 数组 + 该函数统一计算的模式，而非
 * children 组合。纯函数、无框架依赖，可完全脱离渲染单测。
 */
export function resolveSteps(items: StepItemInput[], current: number, status: StepStatus, initial: number): ResolvedStep[] {
  return items.map((item, index) => {
    const stepNumber = initial + index;
    const active = stepNumber === current;
    const done = stepNumber < current;
    const isPreErrorStep = status === 'error' && stepNumber === current - 1;

    let resolvedStatus: StepStatus;
    if (item.status) {
      resolvedStatus = item.status;
    } else if (active) {
      resolvedStatus = status;
    } else if (done) {
      resolvedStatus = 'finish';
    } else {
      resolvedStatus = 'wait';
    }

    return { ...item, stepNumber, status: resolvedStatus, active, done, isPreErrorStep };
  });
}
