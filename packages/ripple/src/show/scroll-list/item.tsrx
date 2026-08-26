import { track, effect, untrack } from 'ripple';
import {
    findNearestIndex,
    getScrollTopForIndex,
    calcCycledListLayout,
    normalizeIndex,
    type ScrollListItemData,
} from '@lotus/foundation/show/scroll-list';

export type { ScrollListItemData };
export type ScrollItemMode = 'normal' | 'wheel';

export interface ScrollItemProps<T = any> {
    list?: ScrollListItemData<T>[];
    mode?: ScrollItemMode;
    cycled?: boolean;
    selectedIndex?: number;
    onSelect?: (data: ScrollListItemData<T> & { index: number }) => void;
    type?: string | number;
    itemHeight?: number;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const DEFAULT_ITEM_HEIGHT = 36;
const SELECT_DEBOUNCE_MS = 34;

export function ScrollItem(&{
    list = [],
    mode = 'wheel',
    cycled = false,
    selectedIndex = 0,
    onSelect,
    itemHeight = DEFAULT_ITEM_HEIGHT,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ScrollItemProps) @{
    let &[containerHeight] = track<number>(0);
    let &[cycledLayout] = track(() => cycled ? calcCycledListLayout(list.length, itemHeight, containerHeight) : { prependCount: 0, appendCount: 0 });

    let &[renderedItems] = track<ScrollListItemData[]>(() => {
        if (!cycled || list.length === 0) return list;
        const { prependCount, appendCount } = cycledLayout;
        const copies: ScrollListItemData[] = [];
        for (let c = -prependCount; c <= appendCount; c++) {
            copies.push(...list);
        }
        return copies;
    });

    let &[baseOffset] = track<number>(() => {
        if (!cycled || list.length === 0) return 0;
        return cycledLayout.prependCount * list.length;
    });

    let containerNode: HTMLElement | null = null;
    let selectTimer: ReturnType<typeof setTimeout> | null = null;
    let &[lastSelectedIndex] = track<number>(untrack(() => selectedIndex));

    /**
     * ResizeObserver 必须绑定在"尺寸不受自身渲染内容影响"的稳定外层容器上
     * （高度由父级 flex 布局决定），不能绑定在滚动列表 <ul> 本身——cycled 模式
     * 下 <ul> 的内容（item 数量）由 containerHeight 算出的 cycledLayout 决定，
     * 若 ResizeObserver 也观察 <ul>，会形成
     * containerHeight → cycledLayout → renderedItems（DOM 变化）→ ResizeObserver
     * 触发 → containerHeight → ... 的响应式死循环，页面卡死。
     */
    function handleWrapperRef(node: HTMLElement | null) {
        if (!node || typeof ResizeObserver === 'undefined') return;
        const observer = new ResizeObserver((entries) => {
            const entry = entries[0];
            if (!entry) return;
            const height = Math.round(entry.contentRect.height);
            if (height !== untrack(() => containerHeight)) containerHeight = height;
        });
        observer.observe(node);
        return () => observer.disconnect();
    }

    function handleListRef(node: HTMLElement | null) {
        if (!node) return;
        containerNode = node;
        return () => { containerNode = null; };
    }

    function commitSelection(renderedIndex: number) {
        const dataIndex = normalizeIndex(renderedIndex - untrack(() => baseOffset), list.length);
        if (dataIndex < 0) return;
        const item = list[dataIndex];
        if (!item || item.disabled) return;
        if (dataIndex !== untrack(() => lastSelectedIndex)) {
            untrack(() => { lastSelectedIndex = dataIndex; });
            onSelect?.({ ...item, index: dataIndex });
        }
    }

    function scrollToRenderedIndex(renderedIndex: number, smooth: boolean = true) {
        const node = containerNode;
        if (!node) return;
        const height = untrack(() => containerHeight);
        // <ul> 首尾各有 (height-itemHeight)/2 的 padding（见 CSS），让首/尾项也能真正
        // 滚到视觉中心；scrollTop 坐标系相应整体偏移了这个 padding 量。
        const padding = Math.max((height - itemHeight) / 2, 0);
        const targetTop = getScrollTopForIndex(renderedIndex, itemHeight, height) + padding;
        if (smooth && typeof node.scrollTo === 'function') {
            node.scrollTo({ top: targetTop, behavior: 'smooth' });
        } else {
            node.scrollTop = targetTop;
        }
    }

    function handleScroll() {
        const node = containerNode;
        const height = untrack(() => containerHeight);
        if (!node || height === 0) return;
        if (selectTimer) clearTimeout(selectTimer);
        selectTimer = setTimeout(() => {
            const padding = Math.max((height - itemHeight) / 2, 0);
            const nearest = findNearestIndex(untrack(() => renderedItems), itemHeight, node.scrollTop - padding, height);
            if (nearest < 0) return;
            commitSelection(nearest);
        }, SELECT_DEBOUNCE_MS);
    }

    function handleItemClick(renderedIndex: number) {
        const item = renderedItems[renderedIndex];
        if (!item || item.disabled) return;
        scrollToRenderedIndex(renderedIndex);
        commitSelection(renderedIndex);
    }

    let &[hasPositioned] = track<boolean>(false);
    effect(() => {
        if (containerHeight === 0 || !containerNode) return;
        const targetRenderedIndex = baseOffset + selectedIndex;
        if (!untrack(() => hasPositioned)) {
            untrack(() => { hasPositioned = true; lastSelectedIndex = selectedIndex; });
            scrollToRenderedIndex(targetRenderedIndex, false);
        } else if (selectedIndex !== untrack(() => lastSelectedIndex)) {
            untrack(() => { lastSelectedIndex = selectedIndex; });
            scrollToRenderedIndex(targetRenderedIndex, false);
        }
    });

    let &[classes] = track<string>(() =>
        ['lotus-scroll-item', `lotus-scroll-item-${mode}`, className ?? ''].filter(Boolean).join(' '),
    );

    // 首尾各留白 (containerHeight-itemHeight)/2，让首/尾项也能真正滚到视觉中心
    // （对齐 Semi 的 ::before 留白手法，这里用 padding 直接实现）。
    let &[listPadding] = track<number>(() => Math.max((containerHeight - itemHeight) / 2, 0));

    <>
        <div class={classes} style={style} ref={handleWrapperRef}>
            @if (mode === 'wheel') {
                <div class="lotus-scroll-item-selector" style={{ height: `${itemHeight}px` }} />
            }
            <ul
                class="lotus-scroll-item-list"
                role="listbox"
                aria-multiselectable="false"
                aria-label={ariaLabel}
                style={{ height: `${Math.max(containerHeight - listPadding * 2, 0)}px`, paddingTop: `${listPadding}px`, paddingBottom: `${listPadding}px` }}
                onScroll={handleScroll}
                ref={handleListRef}
            >
                @for (const item of renderedItems; index i) {
                    <li
                        class={[
                            'lotus-scroll-item-option',
                            normalizeIndex(i - baseOffset, list.length) === lastSelectedIndex ? 'lotus-scroll-item-option-selected' : '',
                            item?.disabled ? 'lotus-scroll-item-option-disabled' : '',
                        ].filter(Boolean).join(' ')}
                        role="option"
                        aria-disabled={item?.disabled}
                        style={{ height: `${itemHeight}px` }}
                        onClick={() => handleItemClick(i)}
                    >
                        {item?.text ?? String(item?.value ?? '')}
                    </li>
                }
            </ul>
        </div>

        <style>
            .lotus-scroll-item {
                position: relative;
                flex: 1;
                min-width: 0;
                min-height: 0;
                height: 100%;
                overflow: hidden;
            }

            .lotus-scroll-item-selector {
                position: absolute;
                inset-inline: 0;
                top: 50%;
                transform: translateY(-50%);
                border-top: 1px solid var(--lotus-color-border);
                border-bottom: 1px solid var(--lotus-color-border);
                pointer-events: none;
                z-index: 1;
            }

            .lotus-scroll-item-list {
                height: 100%;
                margin: 0;
                padding: 0;
                list-style: none;
                overflow-y: auto;
            }

            /**
             * 故意不用 CSS scroll-snap：浏览器原生吸附行为会和 JS 驱动的
             * findNearestIndex + scrollTop/scrollTo 程序化定位互相竞争
             * （两套独立的"吸附到哪一项"计算逻辑，坐标系细节不完全一致，
             * 会导致 JS 刚设置的目标位置被浏览器 snap 行为悄悄纠偏），
             * 吸附完全交给 JS 侧的 scroll 事件防抖判定实现（对齐调研到
             * 的 Semi 原始实现思路：没有使用 CSS scroll-snap）。
             */

            .lotus-scroll-item-option {
                display: flex;
                align-items: center;
                justify-content: center;
                box-sizing: border-box;
                cursor: pointer;
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-scroll-item-option-selected {
                color: var(--lotus-color-primary);
                font-weight: 600;
            }

            .lotus-scroll-item-option-disabled {
                color: var(--lotus-color-text-3);
                cursor: not-allowed;
            }
        </style>
    </>
}
