import { effect, track } from 'ripple';
import { ResizeContext } from './resize-context.js';

export interface ResizeHandlerProps {
    children?: any;
    class?: string;
    style?: Record<string, any>;
}

/**
 * ResizeGroup 内相邻两个 ResizeItem 之间的可拖拽分隔条。挂载时向 ResizeGroup
 * 注册自己的 DOM 节点；按下时通过 ResizeContext 通知 Group 开始拖拽（Group
 * 按当前 handler 在注册顺序中的下标决定它左右/上下两侧是哪两个 item）。
 */
export function ResizeHandler(&{ children, class: className, style }: ResizeHandlerProps) @{
    let handlerNode: HTMLElement | null = null;
    let handlerIndex = -1;

    effect(() => {
        const context = ResizeContext.get();
        if (!context || !handlerNode) return;
        handlerIndex = context.registerHandler(handlerNode);
    });

    const context = ResizeContext.get();
    let &[direction] = track(() => context?.direction ?? 'horizontal');

    // 直接闭包捕获 setup 阶段拿到的 context 引用，不在事件回调里重新调用
    // ResizeContext.get()——Context.get() 依赖 Ripple 运行时的"当前活跃组件"
    // 指针，只在组件 setup 阶段有效，mousedown 事件触发时这个指针已经不再
    // 指向本组件，重新调用会拿不到值（浏览器实测发现：拖拽完全不生效）。
    function handleMouseDown(event: MouseEvent) {
        context?.notifyResizeStart(handlerIndex, event);
    }

    <>
        <div
            class={[
                'lotus-resizable-group-handler',
                `lotus-resizable-group-handler-${direction}`,
                className ?? '',
            ].filter(Boolean).join(' ')}
            style={style}
            ref={(node: HTMLElement) => { handlerNode = node; }}
            onMouseDown={handleMouseDown}
        >
            {children}
        </div>

        <style>
            .lotus-resizable-group-handler {
                flex-shrink: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                background: var(--lotus-color-border);
                box-sizing: border-box;
            }

            .lotus-resizable-group-handler-horizontal {
                width: 6px;
                cursor: ew-resize;
            }

            .lotus-resizable-group-handler-vertical {
                height: 6px;
                cursor: ns-resize;
            }
        </style>
    </>
}
