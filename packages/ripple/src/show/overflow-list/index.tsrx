import { track, effect, untrack } from 'ripple';
import {
    layoutOverflowList,
    estimateMaxRenderCount,
    type OverflowListCollapseFrom,
} from '@lotus/foundation/show/overflow-list';

export type { OverflowListCollapseFrom };

export interface OverflowListProps<T = any> {
    items?: T[];
    itemKey?: (item: T, index: number) => string | number;
    visibleItemRenderer?: (item: T, index: number) => any;
    overflowRenderer?: (overflowItems: T[]) => any;
    onOverflow?: (overflowItems: T[]) => void;
    collapseFrom?: OverflowListCollapseFrom;
    minVisibleItems?: number;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

function defaultItemKey(item: any, index: number): string | number {
    return item?.key ?? index;
}

export function OverflowList(&{
    items = [],
    itemKey = defaultItemKey,
    visibleItemRenderer,
    overflowRenderer,
    onOverflow,
    collapseFrom = 'end',
    minVisibleItems = 0,
    style,
    class: className,
    'aria-label': ariaLabel,
}: OverflowListProps) @{
    let &[containerWidth] = track<number>(0);
    let &[overflowWidth] = track<number>(0);
    let &[itemSizes] = track<Map<string | number, number>>(new Map());

    let &[renderKeys] = track<(string | number)[]>(() => {
        const maxCount = estimateMaxRenderCount(containerWidth, items.length);
        return items.slice(0, maxCount).map((item, i) => itemKey(item, i));
    });

    let &[allMeasured] = track<boolean>(() => {
        if (renderKeys.length === 0) return items.length === 0;
        return renderKeys.every((key) => itemSizes.has(key));
    });

    let &[layout] = track(() => {
        if (!allMeasured) return { visible: [] as any[], overflow: [] as any[] };
        const sizes = items.map((item, i) => itemSizes.get(itemKey(item, i)) ?? 0);
        const availableWidth = Math.max(containerWidth - overflowWidth, 0);
        return layoutOverflowList(items, sizes, availableWidth, collapseFrom, minVisibleItems);
    });

    let &[prevOverflowLength] = track<number>(-1);
    effect(() => {
        if (!allMeasured) return;
        const overflowItems = layout.overflow;
        if (overflowItems.length !== untrack(() => prevOverflowLength)) {
            untrack(() => { prevOverflowLength = overflowItems.length; });
            onOverflow?.(overflowItems);
        }
    });

    function handleContainerRef(node: HTMLElement | null) {
        if (!node || typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver((entries) => {
            const entry = entries[0];
            if (!entry) return;
            const width = entry.contentRect.width;
            if (width !== untrack(() => containerWidth)) containerWidth = width;
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    function handleOverflowRef(node: HTMLElement | null) {
        if (!node || typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver((entries) => {
            const entry = entries[0];
            if (!entry) return;
            const width = entry.contentRect.width;
            if (width !== untrack(() => overflowWidth)) overflowWidth = width;
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    function handleItemRef(key: string | number, node: HTMLElement | null) {
        if (!node || typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver((entries) => {
            const entry = entries[0];
            if (!entry) return;
            const width = entry.contentRect.width;
            const current = untrack(() => itemSizes);
            if (current.get(key) === width) return;
            const nextSizes = new Map(current);
            nextSizes.set(key, width);
            itemSizes = nextSizes;
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    let &[visibleClasses] = track<string>(() =>
        ['lotus-overflow-list', className ?? ''].filter(Boolean).join(' '),
    );


    <>
        <div class={visibleClasses} style={{ ...style, ...(allMeasured ? {} : { visibility: 'hidden' }) }} role="list" aria-label={ariaLabel} ref={handleContainerRef}>
            @if (!allMeasured) {
                @for (const item of items.slice(0, renderKeys.length); index i) {
                    <div class="lotus-overflow-list-measure" ref={(node: HTMLElement | null) => { return handleItemRef(renderKeys[i] as string | number, node); }}>
                        {visibleItemRenderer ? visibleItemRenderer(item, i) : null}
                    </div>
                }
            }
            @if (allMeasured) {
                <>
                    @for (const item of layout.visible; index i) {
                        <div class="lotus-overflow-list-item" role="listitem">
                            {visibleItemRenderer ? visibleItemRenderer(item, i) : null}
                        </div>
                    }
                    @if (layout.overflow.length > 0) {
                        <div class="lotus-overflow-list-overflow" ref={handleOverflowRef}>
                            {overflowRenderer ? overflowRenderer(layout.overflow) : null}
                        </div>
                    }
                </>
            }
        </div>

        <style>
            .lotus-overflow-list {
                display: flex;
                align-items: center;
                width: 100%;
                min-width: 0;
                overflow: hidden;
            }

            .lotus-overflow-list-measure {
                flex-shrink: 0;
                white-space: nowrap;
            }

            .lotus-overflow-list-item {
                flex-shrink: 0;
                white-space: nowrap;
            }

            .lotus-overflow-list-overflow {
                flex-shrink: 0;
                white-space: nowrap;
            }
        </style>
    </>
}
