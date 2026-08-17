import { track, effect, untrack } from 'ripple';
import {
    ResizableFoundation,
    type ResizableState,
    type ResizableConstraints,
    type ResizeDirection,
} from '@lotus/foundation/basic/resizable';

export type { ResizeDirection };

export interface ResizableSizeChange {
    width: number;
    height: number;
}

export interface ResizableProps {
    children?: any;
    width?: number;
    height?: number;
    defaultWidth?: number;
    defaultHeight?: number;
    minWidth?: number;
    minHeight?: number;
    maxWidth?: number;
    maxHeight?: number;
    lockAspectRatio?: boolean;
    /** 未指定时 8 方向手柄全部启用；传入子集则只启用列出的方向。 */
    enable?: ResizeDirection[];
    onResizeStart?: (direction: ResizeDirection) => void;
    onChange?: (size: ResizableSizeChange, direction: ResizeDirection) => void;
    onResizeEnd?: (size: ResizableSizeChange, direction: ResizeDirection) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const ALL_DIRECTIONS: ResizeDirection[] = ['top', 'right', 'bottom', 'left', 'topRight', 'bottomRight', 'bottomLeft', 'topLeft'];

/**
 * Resizable：8 方向可调整大小容器。拖拽算法（方向-delta 计算、边界约束、宽高比锁定）
 * 完全在 `ResizableFoundation` 里自研实现，不依赖 re-resizable 等第三方库
 * （AGENTS.md 第 0 节"基础能力自研"硬性要求）。指针事件用 document 级常驻监听
 * （effect 无清理函数机制，与 Select 的点击外部关闭处理是同一模式），回调内部
 * 实时读取 isResizing 状态判断是否需要处理，避免每次 resize 周期反复装卸监听器。
 */
export function Resizable(&{
    children,
    width: widthProp,
    height: heightProp,
    defaultWidth = 320,
    defaultHeight = 200,
    minWidth = 0,
    minHeight = 0,
    maxWidth = Infinity,
    maxHeight = Infinity,
    lockAspectRatio = false,
    enable,
    onResizeStart,
    onChange,
    onResizeEnd,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ResizableProps) @{
    const isControlled = widthProp !== undefined && heightProp !== undefined;
    let &[state] = track<ResizableState>({
        width: widthProp ?? defaultWidth,
        height: heightProp ?? defaultHeight,
        isResizing: false,
        direction: null,
    });

    effect(() => {
        if (!isControlled) return;
        const w = widthProp;
        const h = heightProp;
        if (w === undefined || h === undefined) return;
        const current = untrack(() => state);
        if (current.width === w && current.height === h) return;
        state = { ...current, width: w, height: h };
    });

    const foundation = new ResizableFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<ResizableState>) => { state = { ...state, ...patch }; },
    });

    const enabledDirections = enable ?? ALL_DIRECTIONS;

    const constraints: ResizableConstraints = { minWidth, minHeight, maxWidth, maxHeight, lockAspectRatio };

    function startResize(direction: ResizeDirection, pointerX: number, pointerY: number) {
        foundation.onResizeStart(direction, pointerX, pointerY);
        onResizeStart?.(direction);
    }

    effect(() => {
        const handlePointerMove = (event: MouseEvent) => {
            const current = untrack(() => state);
            if (!current.isResizing || !current.direction) return;
            const size = foundation.onResize(event.clientX, event.clientY, constraints);
            if (size) {
                onChange?.(size, current.direction);
            }
        };
        const handlePointerUp = () => {
            const current = untrack(() => state);
            if (!current.isResizing || !current.direction) return;
            const direction = current.direction;
            const finalSize = { width: current.width, height: current.height };
            foundation.onResizeEnd();
            onResizeEnd?.(finalSize, direction);
        };
        document.addEventListener('mousemove', handlePointerMove);
        document.addEventListener('mouseup', handlePointerUp);
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-resizable',
            state.isResizing ? 'lotus-resizable-resizing' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    let &[sizeStyle] = track<Record<string, any>>(() => ({
        ...style,
        width: `${state.width}px`,
        height: `${state.height}px`,
    }));

    <>
        <div class={classes} style={sizeStyle} aria-label={ariaLabel}>
            <div class="lotus-resizable-content">{children}</div>

            @for (const direction of enabledDirections; key direction) {
                <div
                    class={`lotus-resizable-handler lotus-resizable-handler-${direction}`}
                    onMouseDown={(event: MouseEvent) => {
                        event.preventDefault();
                        startResize(direction, event.clientX, event.clientY);
                    }}
                />
            }
        </div>

        <style>
            .lotus-resizable {
                position: relative;
                box-sizing: border-box;
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small);
                overflow: hidden;
            }

            .lotus-resizable-resizing {
                user-select: none;
            }

            .lotus-resizable-content {
                width: 100%;
                height: 100%;
                overflow: auto;
            }

            .lotus-resizable-handler {
                position: absolute;
                z-index: var(--lotus-z-resizable-handler);
            }

            .lotus-resizable-handler-top {
                top: -3px;
                left: 0;
                width: 100%;
                height: 6px;
                cursor: ns-resize;
            }

            .lotus-resizable-handler-bottom {
                bottom: -3px;
                left: 0;
                width: 100%;
                height: 6px;
                cursor: ns-resize;
            }

            .lotus-resizable-handler-left {
                top: 0;
                left: -3px;
                width: 6px;
                height: 100%;
                cursor: ew-resize;
            }

            .lotus-resizable-handler-right {
                top: 0;
                right: -3px;
                width: 6px;
                height: 100%;
                cursor: ew-resize;
            }

            .lotus-resizable-handler-topLeft {
                top: -3px;
                left: -3px;
                width: 10px;
                height: 10px;
                cursor: nwse-resize;
            }

            .lotus-resizable-handler-topRight {
                top: -3px;
                right: -3px;
                width: 10px;
                height: 10px;
                cursor: nesw-resize;
            }

            .lotus-resizable-handler-bottomLeft {
                bottom: -3px;
                left: -3px;
                width: 10px;
                height: 10px;
                cursor: nesw-resize;
            }

            .lotus-resizable-handler-bottomRight {
                bottom: -3px;
                right: -3px;
                width: 10px;
                height: 10px;
                cursor: nwse-resize;
            }
        </style>
    </>
}
