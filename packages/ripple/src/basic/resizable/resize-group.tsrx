import { effect } from 'ripple';
import {
    initializeItemPercents,
    resizeAdjacentItems,
    type GroupItemSpec,
    type ResizeStartCallback,
    type ResizeChangeCallback,
} from '@lotus/foundation/basic/resizable';
import { ResizeContext, type ResizeContextValue } from './resize-context.js';
import { ResizeItem } from './resize-item.tsrx';
import { ResizeHandler } from './resize-handler.tsrx';

export interface ResizeGroupItemConfig extends GroupItemSpec {
    /** 简化 API（`items` prop）专用：面板渲染内容。JSX 写法（`<ResizeItem>` 子组件）不使用此字段。 */
    content?: any;
    style?: Record<string, any>;
    class?: string;
    onResizeStart?: ResizeStartCallback;
    onChange?: ResizeChangeCallback;
    onResizeEnd?: ResizeChangeCallback;
}

export interface ResizeGroupProps {
    children?: any;
    direction?: 'horizontal' | 'vertical';
    /**
     * 简化 API：直接传入面板配置数组，内部渲染 ResizeItem/ResizeHandler，无需
     * 手写 JSX 协作组件（Ripple 架构下的合理简化——JSX 写法依赖 Context 回调
     * 模拟子传父，配置数组则是纯声明式的一次性传入，两种写法二选一）。
     * 传入时会忽略 `children`。
     */
    items?: ResizeGroupItemConfig[];
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

interface RegisteredItem {
    node: HTMLElement;
    min?: string;
    max?: string;
    defaultSize?: string | number;
    onResizeStart?: ResizeStartCallback;
    onChange?: ResizeChangeCallback;
    onResizeEnd?: ResizeChangeCallback;
}

/**
 * 可拖拽分隔条的多栏面板容器。算法（百分比初始化、拖拽时相邻两项联动、
 * min/max 约束）在 `group-foundation.ts` 里自研实现，此处只做 DOM 注册与
 * 指针事件桥接。拖拽过程直接命令式写 item 的 style.width/height（对齐 Semi
 * 的实现思路），不经过响应式 track——每次指针移动都要写 DOM，包一层 track
 * 只会多一次无意义的 diff。
 */
export function ResizeGroup(&{ children, direction = 'horizontal', items, style, class: className, 'aria-label': ariaLabel }: ResizeGroupProps) @{
    let groupNode: HTMLElement | null = null;
    const registeredItems: RegisteredItem[] = [];
    const handlerNodes: HTMLElement[] = [];
    let itemPercents: number[] = [];
    let dragOrigin: {
        handlerIndex: number;
        startX: number;
        startY: number;
        lastSizePx: number;
        nextSizePx: number;
    } | null = null;

    function groupSize(): number {
        if (!groupNode) return 0;
        return direction === 'horizontal' ? groupNode.offsetWidth : groupNode.offsetHeight;
    }

    // handler 是 flex-shrink:0 的固定宽度分隔条，不参与百分比分配——item 的
    // 可用空间是容器总尺寸减去全部 handler 占用的空间，而不是容器总尺寸本身
    // （真机 e2e 实测发现：600px 容器、1 个 6px handler，固定 200px 项此前
    // 按 200/600=33.33% 换算，实际只分到 594px 可用空间的 33.33%=198px，
    // 差 2px）。直接算出目标像素值赋值而非拼百分比字符串——用 calc() 表达式
    // 试过（calc(percent% - handlerOffset*percent/100 px)）但那个公式本身
    // 数学上不等价于"总可用空间的 percent%"，仍有偏差；百分比在这里唯一
    // 服务的目的就是换算出最终像素值，既然如此不如直接算好像素值更直观。
    function handlersTotalSize(): number {
        return handlerNodes.reduce((sum, node) => sum + (direction === 'horizontal' ? node.offsetWidth : node.offsetHeight), 0);
    }

    function applyPercent(index: number, percent: number) {
        const item = registeredItems[index];
        if (!item) return;
        const availableSize = groupSize() - handlersTotalSize();
        const value = `${(availableSize * percent) / 100}px`;
        if (direction === 'horizontal') {
            item.node.style.width = value;
        } else {
            item.node.style.height = value;
        }
    }

    function initializeSpace() {
        if (registeredItems.length === 0) return;
        const specs: GroupItemSpec[] = registeredItems.map((item) => ({ defaultSize: item.defaultSize, min: item.min, max: item.max }));
        // 百分比的 100% 基准必须与 applyPercent 换算像素时用的基准一致——都是
        // "可用空间"（容器总尺寸减去 handler 占用），否则两处各自的基准不同，
        // 百分比在中间转手一次会引入新的偏差。
        itemPercents = initializeItemPercents(specs, groupSize() - handlersTotalSize());
        itemPercents.forEach((percent, index) => applyPercent(index, percent));
    }

    function notifyResizeStart(handlerIndex: number, event: MouseEvent) {
        const lastItem = registeredItems[handlerIndex];
        const nextItem = registeredItems[handlerIndex + 1];
        if (!lastItem || !nextItem) return;
        const lastSizePx = direction === 'horizontal' ? lastItem.node.offsetWidth : lastItem.node.offsetHeight;
        const nextSizePx = direction === 'horizontal' ? nextItem.node.offsetWidth : nextItem.node.offsetHeight;
        dragOrigin = { handlerIndex, startX: event.clientX, startY: event.clientY, lastSizePx, nextSizePx };
        lastItem.onResizeStart?.(direction === 'horizontal' ? 'right' : 'bottom', event);
        nextItem.onResizeStart?.(direction === 'horizontal' ? 'left' : 'top', event);
    }

    function handlePointerMove(event: MouseEvent) {
        if (!dragOrigin) return;
        const { handlerIndex, startX, startY, lastSizePx, nextSizePx } = dragOrigin;
        const lastItem = registeredItems[handlerIndex];
        const nextItem = registeredItems[handlerIndex + 1];
        if (!lastItem || !nextItem) return;

        const delta = direction === 'horizontal' ? event.clientX - startX : event.clientY - startY;
        const parentSize = groupSize();
        const result = resizeAdjacentItems(
            lastSizePx, nextSizePx, delta,
            { min: lastItem.min, max: lastItem.max },
            { min: nextItem.min, max: nextItem.max },
            parentSize,
        );

        itemPercents[handlerIndex] = result.lastPercent;
        itemPercents[handlerIndex + 1] = result.nextPercent;
        applyPercent(handlerIndex, result.lastPercent);
        applyPercent(handlerIndex + 1, result.nextPercent);

        const lastDirection = direction === 'horizontal' ? 'right' : 'bottom';
        const nextDirection = direction === 'horizontal' ? 'left' : 'top';
        lastItem.onChange?.({ width: lastItem.node.offsetWidth, height: lastItem.node.offsetHeight }, lastDirection);
        nextItem.onChange?.({ width: nextItem.node.offsetWidth, height: nextItem.node.offsetHeight }, nextDirection);
    }

    function handlePointerUp() {
        if (!dragOrigin) return;
        const { handlerIndex } = dragOrigin;
        const lastItem = registeredItems[handlerIndex];
        const nextItem = registeredItems[handlerIndex + 1];
        dragOrigin = null;
        if (!lastItem || !nextItem) return;
        const lastDirection = direction === 'horizontal' ? 'right' : 'bottom';
        const nextDirection = direction === 'horizontal' ? 'left' : 'top';
        lastItem.onResizeEnd?.({ width: lastItem.node.offsetWidth, height: lastItem.node.offsetHeight }, lastDirection);
        nextItem.onResizeEnd?.({ width: nextItem.node.offsetWidth, height: nextItem.node.offsetHeight }, nextDirection);
    }

    effect(() => {
        document.addEventListener('mousemove', handlePointerMove);
        document.addEventListener('mouseup', handlePointerUp);
        return () => {
            document.removeEventListener('mousemove', handlePointerMove);
            document.removeEventListener('mouseup', handlePointerUp);
        };
    });

    const contextValue: ResizeContextValue = {
        direction,
        registerItem: (node, min, max, defaultSize, onResizeStart, onChange, onResizeEnd) => {
            const index = registeredItems.length;
            registeredItems.push({ node, min, max, defaultSize, onResizeStart, onChange, onResizeEnd });
            // 挂载顺序等价于 React ref 注册顺序：Ripple 的 children 按声明顺序同步挂载，
            // 首帧渲染完毕后一次性初始化空间分配（对齐 Semi componentDidMount 时机）。
            // 用 requestAnimationFrame 而非 queueMicrotask——microtask 在浏览器完成
            // 布局（layout）之前就会触发，此时 groupSize() 读到的 offsetWidth 可能
            // 还没反映 flex 子项各自撑开后的最终容器宽度，固定 px 项按不准确的
            // parentSize 换算成百分比会有几像素的舍入误差（真机 e2e 实测发现：
            // 固定 200px 项在 600px 容器下渲染成 198px）。rAF 保证在下一次绘制前、
            // 布局已经完成后才读取尺寸。
            requestAnimationFrame(() => {
                if (registeredItems.length === (items?.length ?? countJsxItems())) initializeSpace();
            });
            return index;
        },
        registerHandler: (node) => {
            const index = handlerNodes.length;
            handlerNodes.push(node);
            return index;
        },
        notifyResizeStart,
    };

    function countJsxItems(): number {
        // items 简化 API 未使用时，无法提前知道 JSX 子级里 ResizeItem 的数量，
        // 退化为“每次注册后用 microtask 重新触发一次”，多次调用 initializeSpace
        // 是幂等的（用最新的 registeredItems 全量重算），不会产生视觉抖动。
        return registeredItems.length;
    }

    ResizeContext.set(contextValue);

    // 打平成单一列表，用一层 @if/@else 区分 item/handler 两种节点，渲染结构
    // 更清晰、也便于按 key 做 keyed diff。
    //
    // 注：之前这里的注释声称"@for 循环体内嵌套 @if 会在 SSR 触发编译器的
    // JSXFragment 序列化错误，打平是为了规避该限制"——这个判断是错的，此写法
    // 本身不受影响，实测打平前后 SSR build 都会报同样的错。真实根因是
    // `@tsrx/core` 解析器的 bug：`@if` 分支体（`#parseTemplateControlFlowBlock`）
    // 解析期间会把 `#path` 清空，导致嵌套在其分支体里的 `@for`/`@switch`/`@try`
    // 等指令在解析自己的 `{ }` 循环体时，`parseBlock` 的“是否处于原生模板节点
    // 内”判定失败，从而退化为普通 JS 语句解析，把嵌套指令包成裸
    // `ExpressionStatement`，esrap 的 `ts` 语言包无法序列化其中的 JSXFragment
    // 包装节点而报错。已在 `@tsrx/core` 补丁修复（见 pnpm patch），此文件本身
    // 无需再规避。
    type RenderNode =
        | { kind: 'item'; key: string; item: ResizeGroupItemConfig }
        | { kind: 'handler'; key: string };
    const itemsRenderList: RenderNode[] = (items ?? []).flatMap((item, index) => {
        const nodes: RenderNode[] = [{ kind: 'item', key: `item-${index}`, item }];
        if (index < (items?.length ?? 0) - 1) nodes.push({ kind: 'handler', key: `handler-${index}` });
        return nodes;
    });

    <>
        <div
            class={['lotus-resizable-group', `lotus-resizable-group-${direction}`, className ?? ''].filter(Boolean).join(' ')}
            style={{ ...style, flexDirection: direction === 'vertical' ? 'column' : 'row' }}
            ref={(node: HTMLElement) => { groupNode = node; }}
            aria-label={ariaLabel}
        >
            @if (items) {
                @for (const node of itemsRenderList; index i; key node.key) {
                    @if (node.kind === 'item') {
                        <ResizeItem
                            defaultSize={node.item.defaultSize}
                            min={node.item.min}
                            max={node.item.max}
                            style={node.item.style}
                            class={node.item.class}
                            onResizeStart={node.item.onResizeStart}
                            onChange={node.item.onChange}
                            onResizeEnd={node.item.onResizeEnd}
                        >
                            {node.item.content}
                        </ResizeItem>
                    } @else {
                        <ResizeHandler />
                    }
                }
            } @else {
                <div class="lotus-resizable-group-children">{children}</div>
            }
        </div>

        <style>
            .lotus-resizable-group {
                display: flex;
                box-sizing: border-box;
                width: 100%;
                height: 100%;
            }

            .lotus-resizable-group-children {
                display: contents;
            }
        </style>
    </>
}
