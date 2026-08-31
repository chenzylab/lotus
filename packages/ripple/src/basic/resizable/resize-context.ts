import { Context } from 'ripple';
import type { ResizeStartCallback, ResizeChangeCallback } from '@lotus/foundation/basic/resizable';

export interface ResizeContextValue {
    direction: 'horizontal' | 'vertical';
    registerItem: (
        node: HTMLElement,
        min: string | undefined,
        max: string | undefined,
        defaultSize: string | number | undefined,
        onResizeStart: ResizeStartCallback | undefined,
        onChange: ResizeChangeCallback | undefined,
        onResizeEnd: ResizeChangeCallback | undefined,
    ) => number;
    registerHandler: (node: HTMLElement) => number;
    notifyResizeStart: (handlerIndex: number, event: MouseEvent) => void;
}

/**
 * ResizeGroup 向 ResizeItem/ResizeHandler 广播的协作接口（父传子）。Ripple 的
 * Context 只支持父传子查找，没有 React 那种"子组件向上注册自己"的机制——这里
 * 改用父组件下发一份含注册回调的 plain object，子组件挂载时主动调用回调把
 * 自己的 DOM 节点和配置报给父组件，模拟出等价于 React ref 注册的效果。
 */
export const ResizeContext = new Context<ResizeContextValue>();
