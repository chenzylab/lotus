import { track, effect, untrack } from 'ripple';
import {
    ResizableFoundation,
    type ResizableState,
    type ResizableConstraints,
    type ResizeDirection,
} from '@lotus/foundation/basic/resizable';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ResizeDirection };

export interface ResizableSizeChange {
    width: number;
    height: number;
}

export type ResizeHandleMap = Partial<Record<ResizeDirection, any>>;
export type ResizeHandleStyleMap = Partial<Record<ResizeDirection, Record<string, any>>>;
export type ResizeHandleClassMap = Partial<Record<ResizeDirection, string>>;

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
    /** 拖动像素与实际尺寸变化的比例，默认 1（对齐 Semi `ratio`）。 */
    ratio?: number;
    /** 容器被 CSS transform scale 缩放时的坐标还原系数，默认 1（对齐 Semi `scale`）。 */
    scale?: number;
    /** 限制调整范围的边界元素：'parent'|'window'|自定义 DOM 元素（对齐 Semi `boundElement`）。 */
    boundElement?: 'parent' | 'window' | HTMLElement;
    /** 每个方向自定义手柄渲染内容（对齐 Semi `handleNode`）。 */
    handleNode?: ResizeHandleMap;
    /** 每个方向手柄的自定义样式（对齐 Semi `handleStyle`）。 */
    handleStyle?: ResizeHandleStyleMap;
    /** 每个方向手柄的自定义类名（对齐 Semi `handleClass`）。 */
    handleClass?: ResizeHandleClassMap;
    /** 增量对齐步长，默认 [1,1] 表示不生效（对齐 Semi `grid`）。 */
    grid?: [number, number];
    /** 吸附到指定绝对像素点（对齐 Semi `snap`）。 */
    snap?: { x?: number[]; y?: number[] };
    /** 吸附生效的最小间隙阈值，默认 0（对齐 Semi `snapGap`）。 */
    snapGap?: number;
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
 * （与 Select 的点击外部关闭处理是同一模式，effect 只在挂载时执行一次，卸载
 * 时用返回的清理函数移除监听），回调内部实时读取 isResizing 状态判断是否需要
 * 处理，避免每次 resize 周期反复装卸监听器。
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
    ratio = 1,
    scale = 1,
    boundElement,
    handleNode,
    handleStyle,
    handleClass,
    grid,
    snap,
    snapGap,
    onResizeStart,
    onChange,
    onResizeEnd,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ResizableProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = widthProp !== undefined && heightProp !== undefined;
    let &[state] = track<ResizableState>({
        width: widthProp ?? defaultWidth,
        height: heightProp ?? defaultHeight,
        isResizing: false,
        direction: null,
    });

    let resizableNode: HTMLElement | null = null;

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

    function startResize(direction: ResizeDirection, pointerX: number, pointerY: number) {
        foundation.onResizeStart(direction, pointerX, pointerY);
        onResizeStart?.(direction);
    }

    // boundElement 收窄 max 约束：'parent' 用父节点、'window' 用视口、自定义元素用其自身
    // 的边界矩形，只在方向包含对应轴向时才需要收窄（对齐 Semi calBoundaryMax 思路，
    // 简化为直接用 getBoundingClientRect 计算可用剩余空间，不复刻 flex 场景的复杂分支）。
    function resolveBoundMax(): { maxWidth: number; maxHeight: number } {
        if (!boundElement || !resizableNode) return { maxWidth, maxHeight };
        const rect = resizableNode.getBoundingClientRect();
        let boundRect: { right: number; bottom: number } | null = null;
        if (boundElement === 'parent' && resizableNode.parentElement) {
            boundRect = resizableNode.parentElement.getBoundingClientRect();
        } else if (boundElement === 'window') {
            boundRect = { right: window.innerWidth, bottom: window.innerHeight };
        } else if (boundElement instanceof HTMLElement) {
            boundRect = boundElement.getBoundingClientRect();
        }
        if (!boundRect) return { maxWidth, maxHeight };
        const availableWidth = boundRect.right - rect.left;
        const availableHeight = boundRect.bottom - rect.top;
        return {
            maxWidth: Math.min(maxWidth, availableWidth),
            maxHeight: Math.min(maxHeight, availableHeight),
        };
    }

    effect(() => {
        const handlePointerMove = (event: MouseEvent) => {
            const current = untrack(() => state);
            if (!current.isResizing || !current.direction) return;
            // 每次移动都实时读取约束 prop（而非挂载时固化的闭包变量）——这个
            // document 级监听在 effect 首次执行时创建一次、之后不会重新调度，
            // minWidth/maxWidth 等约束运行时变化后必须靠这里的实时读取才能
            // 生效，不能依赖外层一次性 const 快照（对齐 Slider RTL opts 固化
            // 踩坑 #98 的教训）。
            const bound = resolveBoundMax();
            const constraints: ResizableConstraints = {
                minWidth, minHeight, maxWidth: bound.maxWidth, maxHeight: bound.maxHeight,
                lockAspectRatio, ratio, scale, grid, snap, snapGap,
            };
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
        return () => {
            document.removeEventListener('mousemove', handlePointerMove);
            document.removeEventListener('mouseup', handlePointerUp);
        };
    });

    const KEYBOARD_STEP = 10;
    const HORIZONTAL_LEFT: ResizeDirection[] = ['left', 'topLeft', 'bottomLeft'];
    const HORIZONTAL_RIGHT: ResizeDirection[] = ['right', 'topRight', 'bottomRight'];
    const VERTICAL_TOP: ResizeDirection[] = ['top', 'topLeft', 'topRight'];
    const VERTICAL_BOTTOM: ResizeDirection[] = ['bottom', 'bottomLeft', 'bottomRight'];

    // 键盘无障碍：聚焦某个方向手柄后按方向键，以固定步长调整尺寸——没有连续
    // 指针坐标可用，符号需要按手柄方向换算（如 left 手柄按 ArrowLeft 意味着
    // 手柄往外移，容器变宽，对应 deltaWidth 为正）。
    function handleHandleKeyDown(direction: ResizeDirection, event: KeyboardEvent) {
        let deltaWidth = 0;
        let deltaHeight = 0;
        switch (event.key) {
            case 'ArrowLeft':
                if (HORIZONTAL_LEFT.includes(direction)) deltaWidth = KEYBOARD_STEP;
                else if (HORIZONTAL_RIGHT.includes(direction)) deltaWidth = -KEYBOARD_STEP;
                else return;
                break;
            case 'ArrowRight':
                if (HORIZONTAL_RIGHT.includes(direction)) deltaWidth = KEYBOARD_STEP;
                else if (HORIZONTAL_LEFT.includes(direction)) deltaWidth = -KEYBOARD_STEP;
                else return;
                break;
            case 'ArrowUp':
                if (VERTICAL_TOP.includes(direction)) deltaHeight = KEYBOARD_STEP;
                else if (VERTICAL_BOTTOM.includes(direction)) deltaHeight = -KEYBOARD_STEP;
                else return;
                break;
            case 'ArrowDown':
                if (VERTICAL_BOTTOM.includes(direction)) deltaHeight = KEYBOARD_STEP;
                else if (VERTICAL_TOP.includes(direction)) deltaHeight = -KEYBOARD_STEP;
                else return;
                break;
            default:
                return;
        }
        event.preventDefault();
        const constraints: ResizableConstraints = { minWidth, minHeight, maxWidth, maxHeight, lockAspectRatio };
        const size = foundation.resizeByStep(deltaWidth, deltaHeight, constraints);
        onChange?.(size, direction);
        onResizeEnd?.(size, direction);
    }

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
        <div
            class={classes}
            style={sizeStyle}
            aria-label={ariaLabel}
            ref={(node: HTMLElement) => { resizableNode = node; }}
        >
            <div class="lotus-resizable-content">{children}</div>

            @for (const direction of enabledDirections; key direction) {
                <div
                    class={[
                        'lotus-resizable-handler',
                        `lotus-resizable-handler-${direction}`,
                        handleClass?.[direction] ?? '',
                    ].filter(Boolean).join(' ')}
                    style={handleStyle?.[direction]}
                    role="button"
                    tabIndex={0}
                    aria-label={locale.Resizable.handleLabel(direction)}
                    onMouseDown={(event: MouseEvent) => {
                        event.preventDefault();
                        startResize(direction, event.clientX, event.clientY);
                    }}
                    onKeyDown={(event: KeyboardEvent) => handleHandleKeyDown(direction, event)}
                >
                    {handleNode?.[direction]}
                </div>
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
