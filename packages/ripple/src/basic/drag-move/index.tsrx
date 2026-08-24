import { track, effect, untrack } from 'ripple';
import {
    DragMoveFoundation,
    calcMoveRangeAbsolute,
    calcMoveRangeRelative,
    type DragMoveState,
    type DragPositionStrategy,
    type DragRect,
} from '@lotus/foundation/basic/drag-move';

export type { DragPositionStrategy };

export interface DragMoveProps {
    children?: any;
    /** 拖拽把手：不传时整个元素都可拖拽（对齐 Semi handler 缺省=元素本身）。 */
    handler?: () => HTMLElement | null;
    /** 约束容器：'parent' 取父元素，或自定义函数；不传则不设边界。 */
    constrainer?: (() => HTMLElement | null) | 'parent';
    positionStrategy?: DragPositionStrategy;
    /** 拖拽发起前的谓词，返回 false 时本次不进入拖拽态。 */
    allowMove?: (event: MouseEvent | TouchEvent, element: HTMLElement) => boolean;
    /** 自定义位置写入；不传则组件直接写 style.top/left。 */
    customMove?: (element: HTMLElement, top: number, left: number) => void;
    /** input/textarea 上点击时是否仍允许触发拖拽，默认 false（对齐 Semi）。 */
    allowInputDrag?: boolean;
    onMouseDown?: (event: MouseEvent) => void;
    onMouseMove?: (event: MouseEvent) => void;
    onMouseUp?: (event: MouseEvent) => void;
    onTouchStart?: (event: TouchEvent) => void;
    onTouchMove?: (event: TouchEvent) => void;
    onTouchEnd?: (event: TouchEvent) => void;
    onTouchCancel?: (event: TouchEvent) => void;
    style?: Record<string, any>;
    class?: string;
}

function toDragRect(el: HTMLElement): DragRect {
    const rect = el.getBoundingClientRect();
    return { left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom, width: rect.width, height: rect.height };
}

/** offsetParent 链路从元素累积到约束容器的偏移（对齐 Semi _calcMoveRange absolute 分支的 while 循环）。 */
function accumulateOffsetToConstrainer(element: HTMLElement, constrainer: HTMLElement): { x: number; y: number } {
    let node = element.offsetParent as HTMLElement | null;
    let x = 0;
    let y = 0;
    while (node !== constrainer && node !== null) {
        x -= node.offsetLeft;
        y -= node.offsetTop;
        node = node.offsetParent as HTMLElement | null;
    }
    return { x, y };
}

/**
 * DragMove：自由二维拖拽容器。对齐 Semi Design dragMove（Plus 分类，是 Modal
 * draggable 的底层实现）——absolute/relative 两种定位策略、可选约束容器、
 * 可选拖拽把手。算法（边界钳制、起点快照）在 DragMoveFoundation 里自研
 * 实现（三段式生命周期，对齐 ResizableFoundation 同构模式），不依赖第三方
 * 拖拽库。约束范围在 mousedown 时算一次并缓存，不在 mousemove 里重算——
 * TagInput 组件踩坑 #88 的教训：元素一旦叠加了 style.top/left 位移，
 * mousemove 中再次测量会读到已经偏移后的视觉位置而非原始布局位置。
 */
export function DragMove(&{
    children,
    handler,
    constrainer,
    positionStrategy = 'absolute',
    allowMove,
    customMove,
    allowInputDrag = false,
    onMouseDown,
    onMouseMove,
    onMouseUp,
    onTouchStart,
    onTouchMove,
    onTouchEnd,
    onTouchCancel,
    style,
    class: className,
}: DragMoveProps) @{
    let &[state] = track<DragMoveState>({ top: 0, left: 0, isDragging: false });
    // elementEl 必须是响应式变量：把手绑定 effect() 依赖它就绪后才能拿到真实
    // DOM 元素，ref 回调赋值发生在组件挂载之后，普通闭包变量不会让这个 effect
    // 重新触发（与 Lottie/Cropper 组件同一先例）。
    let &[elementEl] = track<HTMLElement | null>(null);

    const foundation = new DragMoveFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<DragMoveState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    function resolveConstrainer(): HTMLElement | null {
        const el = untrack(() => elementEl);
        if (!constrainer || !el) return null;
        if (constrainer === 'parent') return el.parentElement;
        return constrainer();
    }

    function resolveHandlerElement(currentElementEl: HTMLElement | null): HTMLElement | null {
        return handler ? handler() : currentElementEl;
    }

    function isAllowedTarget(event: MouseEvent | TouchEvent): boolean {
        if (allowInputDrag) return true;
        const tag = (event.target as HTMLElement)?.tagName?.toLowerCase();
        return tag !== 'input' && tag !== 'textarea';
    }

    function calcRange(el: HTMLElement) {
        const constrainerEl = resolveConstrainer();
        if (!constrainerEl) return null;
        if (positionStrategy === 'relative') {
            const style2 = window.getComputedStyle(el);
            const currentLeft = parseFloat(style2.left) || 0;
            const currentTop = parseFloat(style2.top) || 0;
            return calcMoveRangeRelative(toDragRect(el), toDragRect(constrainerEl), currentLeft, currentTop);
        }
        const { x, y } = accumulateOffsetToConstrainer(el, constrainerEl);
        return calcMoveRangeAbsolute({
            offsetParentAccumX: x,
            offsetParentAccumY: y,
            constrainerWidth: constrainerEl.offsetWidth,
            constrainerHeight: constrainerEl.offsetHeight,
            elementWidth: el.offsetWidth,
            elementHeight: el.offsetHeight,
        });
    }

    function startDrag(clientX: number, clientY: number, event: MouseEvent | TouchEvent) {
        const el = untrack(() => elementEl);
        if (!el) return;
        const range = calcRange(el);
        if (!isAllowedTarget(event)) return;
        if (allowMove && !allowMove(event, el)) return;
        foundation.onDragStart(positionStrategy, clientX, clientY, el.offsetLeft, el.offsetTop, range);
        event.preventDefault();
    }

    function applyPosition(top: number, left: number) {
        const el = untrack(() => elementEl);
        if (!el) return;
        if (customMove) {
            customMove(el, top, left);
            return;
        }
        el.style.top = `${top}px`;
        el.style.left = `${left}px`;
    }

    function handleMouseDown(event: MouseEvent) {
        onMouseDown?.(event);
        startDrag(event.clientX, event.clientY, event);
    }

    function handleTouchStart(event: TouchEvent) {
        onTouchStart?.(event);
        const touch = event.targetTouches[0];
        if (touch) startDrag(touch.clientX, touch.clientY, event);
    }

    effect(() => {
        function handleMouseMove(event: MouseEvent) {
            onMouseMove?.(event);
            if (!untrack(() => state).isDragging) return;
            const next = foundation.onDragMove(event.clientX, event.clientY);
            if (next) applyPosition(next.top, next.left);
        }
        function handleMouseUp(event: MouseEvent) {
            onMouseUp?.(event);
            if (!untrack(() => state).isDragging) return;
            foundation.onDragEnd();
        }
        function handleTouchMove(event: TouchEvent) {
            onTouchMove?.(event);
            if (!untrack(() => state).isDragging) return;
            const touch = event.targetTouches[0];
            if (!touch) return;
            const next = foundation.onDragMove(touch.clientX, touch.clientY);
            if (next) applyPosition(next.top, next.left);
        }
        function handleTouchEnd(event: TouchEvent) {
            onTouchEnd?.(event);
            if (!untrack(() => state).isDragging) return;
            foundation.onDragEnd();
        }
        function handleTouchCancel(event: TouchEvent) {
            onTouchCancel?.(event);
            if (!untrack(() => state).isDragging) return;
            foundation.onDragEnd();
        }
        document.addEventListener('mousemove', handleMouseMove);
        document.addEventListener('mouseup', handleMouseUp);
        document.addEventListener('touchmove', handleTouchMove);
        document.addEventListener('touchend', handleTouchEnd);
        document.addEventListener('touchcancel', handleTouchCancel);
        return () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            document.removeEventListener('touchmove', handleTouchMove);
            document.removeEventListener('touchend', handleTouchEnd);
            document.removeEventListener('touchcancel', handleTouchCancel);
        };
    });

    // 把手按下监听绑定到实际把手元素（可能是子元素而非容器本身），容器就绪
    // 后再绑定——elementEl 必须是响应式变量，ref 回调赋值发生在挂载后。
    effect(() => {
        const target = resolveHandlerElement(elementEl);
        if (!target) return;
        target.style.cursor = 'move';
        target.addEventListener('mousedown', handleMouseDown);
        target.addEventListener('touchstart', handleTouchStart);
        return () => {
            target.removeEventListener('mousedown', handleMouseDown);
            target.removeEventListener('touchstart', handleTouchStart);
        };
    });

    <div
        class={['lotus-drag-move', state.isDragging ? 'lotus-drag-move-dragging' : '', className ?? ''].filter(Boolean).join(' ')}
        style={{ position: positionStrategy, top: `${state.top}px`, left: `${state.left}px`, ...style }}
        ref={(node: HTMLElement | null) => { elementEl = node; }}
    >
        {children}
    </div>
}
