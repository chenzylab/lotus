import { effect } from 'ripple';
import type { ResizeStartCallback, ResizeChangeCallback } from '@lotus/foundation/basic/resizable';
import { ResizeContext } from './resize-context.js';

export interface ResizeItemProps {
    children?: any;
    /** 三选一语义：'400px' 固定像素、'20%' 固定百分比、纯数字（如 `1`/`0.5`）按比例分配剩余空间（对齐 Semi）。 */
    defaultSize?: string | number;
    /** 百分比或像素字符串，未指定视为 0%。 */
    min?: string;
    /** 百分比或像素字符串，未指定视为 100%。 */
    max?: string;
    onResizeStart?: ResizeStartCallback;
    onChange?: ResizeChangeCallback;
    onResizeEnd?: ResizeChangeCallback;
    style?: Record<string, any>;
    class?: string;
}

/**
 * ResizeGroup 内的一个分栏面板。必须在 ResizeGroup 内使用——挂载时通过
 * ResizeContext 向父组件注册自己的 DOM 节点与配置（Ripple 没有 React 那种
 * ref 回调式的子传父机制，改用 Context 下发注册函数、子组件主动调用的方式
 * 模拟等价效果，详见 resize-context.ts 的说明）。
 */
export function ResizeItem(&{
    children,
    defaultSize,
    min,
    max,
    onResizeStart,
    onChange,
    onResizeEnd,
    style,
    class: className,
}: ResizeItemProps) @{
    let itemNode: HTMLElement | null = null;
    // Context.get() 必须在组件 setup 阶段同步调用——它依赖 Ripple 运行时的
    // "当前活跃组件"指针，effect 回调触发时该指针已经不指向本组件，会拿到
    // undefined（浏览器实测发现：注册完全不生效，对齐 Grid Row/Col 的既有用法）。
    const context = ResizeContext.get();

    effect(() => {
        if (!context || !itemNode) return;
        context.registerItem(itemNode, min, max, defaultSize, onResizeStart, onChange, onResizeEnd);
    });

    <div
        class={['lotus-resizable-group-item', className ?? ''].filter(Boolean).join(' ')}
        style={style}
        ref={(node: HTMLElement) => { itemNode = node; }}
    >
        {children}
    </div>
}
