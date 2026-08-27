import { track, untrack, effect } from 'ripple';
import {
    TagInputFoundation,
    type TagInputState,
    type Separator,
} from '@lotus/foundation/input/tag-input';
import { foldTags } from '@lotus/foundation/input/tree-select';
import {
    computeTargetIndexWrap,
    computeItemTransformsWrap,
    type WrapRect,
} from '@lotus/foundation/base/sortable-drag';
import { Tag } from '../../show/tag/index.tsrx';
import { Popover } from '../../show/popover/index.tsrx';
import { IconClear, IconHandle } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type TagInputSize = 'small' | 'default' | 'large';
export type TagInputValidateStatus = 'default' | 'error' | 'warning';

export interface TagInputProps {
    value?: string[];
    defaultValue?: string[];
    inputValue?: string;
    onChange?: (value: string[]) => void;
    onInputChange?: (value: string) => void;
    onAdd?: (addedValue: string[]) => void;
    onRemove?: (removedValue: string, index: number) => void;
    onExceed?: (value: string[]) => void;
    disabled?: boolean;
    size?: TagInputSize;
    validateStatus?: TagInputValidateStatus;
    placeholder?: string;
    separator?: Separator;
    allowDuplicates?: boolean;
    max?: number;
    maxTagCount?: number;
    showRestTagsPopover?: boolean;
    addOnBlur?: boolean;
    showClear?: boolean;
    draggable?: boolean;
    prefix?: any;
    suffix?: any;
    autoFocus?: boolean;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

interface DragState {
    activeIndex: number | null;
    startX: number;
    startY: number;
    currentX: number;
    currentY: number;
}

/**
 * TagInput：标签输入框。核心是纯自由文本输入，无候选下拉（不是 AutoComplete，
 * Semi 源码里没有 onSearch/建议列表这类能力，调研已核实）。Enter/失焦
 * （addOnBlur）触发按分隔符拆分新增标签，Backspace 在输入框为空时删除最后
 * 一个标签，均移植自 Semi semi-foundation/tagInput/foundation.ts 的算法
 * 思路（对齐参考实现 chenzy.design 的等价设计）。
 *
 * 标签渲染直接复用 Tag 组件（color="white" type="light"，已有真实 button
 * 关闭按钮，键盘可达性天然具备），不重新实现。maxTagCount 折叠复用
 * TreeSelect 已验证的 foldTags 纯函数，但展开状态用独立的 restExpanded
 * 布尔量（点击触发），不照搬 Semi 把展开语义隐式耦合在容器 active 全局态
 * 上的设计（调研已核实这是 Semi 自身的技术债，chenzy.design 已验证独立
 * 开关更清晰）。"+N" 折叠气泡补充 role="button"+tabIndex+onKeyDown Enter/
 * Space 键盘可达性（Semi 和 chenzy.design 两方在这一点均是空白，对齐
 * Upload 组件已验证过的键盘增强模式主动补强）。
 *
 * draggable 拖拽排序用 flex-wrap 二维几何算法（computeTargetIndexWrap/
 * computeItemTransformsWrap，移植自参考实现 chenzy.design 已验证的纯函数
 * 算法——1D 单轴的中线扫描法在跨行移动时会失效，wrap 布局必须用最近中心点
 * 判定），document 级 mousemove/mouseup 监听（复用 lotus Slider/Transfer
 * 已验证的拖拽模式，onMouseDown 不用 onPointerDown，对齐踩坑 #81）。
 */
export function TagInput(&{
    value,
    defaultValue = [],
    inputValue: inputValueProp,
    onChange,
    onInputChange,
    onAdd,
    onRemove,
    onExceed,
    disabled = false,
    size = 'default',
    validateStatus = 'default',
    placeholder,
    separator = ',',
    allowDuplicates = true,
    max,
    maxTagCount,
    showRestTagsPopover = true,
    addOnBlur = false,
    showClear = false,
    draggable = false,
    prefix,
    suffix,
    autoFocus = false,
    'aria-label': ariaLabel,
    style,
    class: className,
}: TagInputProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = value !== undefined;
    const isInputControlled = inputValueProp !== undefined;

    let &[state] = track<TagInputState>({
        tagsArray: isControlled ? value! : defaultValue,
        inputValue: isInputControlled ? inputValueProp! : '',
    });

    const foundation = new TagInputFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<TagInputState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        { separator, allowDuplicates, max },
    );

    effect(() => {
        if (value === undefined) return;
        untrack(() => foundation.syncTagsArray(value!));
    });

    effect(() => {
        if (inputValueProp === undefined) return;
        const v = inputValueProp;
        untrack(() => { state = { ...state, inputValue: v }; });
    });

    let inputNode: HTMLInputElement | null = null;
    let &[restExpanded] = track<boolean>(false);

    function emitInputChange(v: string) {
        onInputChange?.(v);
    }

    function handleInput(event: Event) {
        const v = (event.target as HTMLInputElement).value;
        foundation.setInputValue(v);
        emitInputChange(v);
    }

    function commitInput() {
        const result = foundation.addTagsFromInput(isControlled);
        emitInputChange('');
        if (!result) return;
        if (result.exceeded.length > 0) onExceed?.(result.exceeded);
        if (result.added.length > 0) {
            onAdd?.(result.added);
            onChange?.(result.tagsArray);
        }
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (event.key === 'Enter') {
            event.preventDefault();
            if (untrack(() => state).inputValue !== '') commitInput();
            return;
        }
        if (event.key === 'Backspace') {
            const result = foundation.removeLastTag(isControlled);
            if (!result) return;
            onRemove?.(result.removed, result.index);
            onChange?.(result.tagsArray);
        }
    }

    function handleBlur() {
        if (addOnBlur && untrack(() => state).inputValue !== '') commitInput();
    }

    function handleRemoveTag(index: number) {
        if (disabled) return;
        const result = foundation.removeTagAt(index, isControlled);
        if (!result) return;
        onRemove?.(result.removed, index);
        onChange?.(result.tagsArray);
    }

    function handleClear() {
        if (disabled) return;
        const next = foundation.clearAll(isControlled);
        onChange?.(next);
    }

    function focusInput() {
        if (disabled) return;
        inputNode?.focus();
    }

    // ===================== maxTagCount 折叠 =====================

    let &[foldResult] = track(() => foldTags(state.tagsArray, maxTagCount));
    let &[showFolded] = track<boolean>(() => foldResult.restCount > 0 && !restExpanded);
    let &[visibleTags] = track<string[]>(() => (showFolded ? foldResult.visible : state.tagsArray));

    function toggleRestExpanded() {
        untrack(() => { restExpanded = !restExpanded; });
    }

    function handleRestKeyDown(event: KeyboardEvent) {
        if (event.key !== 'Enter' && event.key !== ' ') return;
        event.preventDefault();
        toggleRestExpanded();
    }

    // ===================== 拖拽排序（wrap 二维几何） =====================

    let &[dragState] = track<DragState>({ activeIndex: null, startX: 0, startY: 0, currentX: 0, currentY: 0 });
    let tagNodes: Array<HTMLElement | null> = [];
    // 拖拽开始时的静态矩形快照——拖拽过程中被拖拽项会应用 CSS transform 位移，
    // getBoundingClientRect() 会反映变换后的视觉位置而非原始布局位置，若在
    // mousemove/mouseup 时重新测量会读到"跟随鼠标漂移后的位置"而非真实布局，
    // 导致目标索引判定完全失真（复现过：拖到底后 targetIndex 恒等于
    // activeIndex，因为量到的是拖拽项自己漂移到终点附近的矩形，不是它原本
    // 该在的位置）。必须只在 mousedown 那一刻测量一次并全程复用。
    let dragStartRects: WrapRect[] = [];

    function measureRects(): WrapRect[] {
        const rects: WrapRect[] = [];
        for (const node of tagNodes) {
            if (!node) {
                rects.push({ left: 0, top: 0, width: 0, height: 0 });
                continue;
            }
            const rect = node.getBoundingClientRect();
            rects.push({ left: rect.left, top: rect.top, width: rect.width, height: rect.height });
        }
        return rects;
    }

    function handleDragStart(index: number, event: MouseEvent) {
        if (!draggable || disabled) return;
        dragStartRects = measureRects();
        untrack(() => {
            dragState = { activeIndex: index, startX: event.clientX, startY: event.clientY, currentX: event.clientX, currentY: event.clientY };
        });
    }

    effect(() => {
        const handleMove = (event: MouseEvent) => {
            const current = untrack(() => dragState);
            if (current.activeIndex === null) return;
            untrack(() => { dragState = { ...current, currentX: event.clientX, currentY: event.clientY }; });
        };
        const handleUp = () => {
            const current = untrack(() => dragState);
            if (current.activeIndex === null) return;
            const rects = dragStartRects;
            const activeRect = rects[current.activeIndex];
            const pointerX = activeRect ? activeRect.left + activeRect.width / 2 + (current.currentX - current.startX) : current.currentX;
            const pointerY = activeRect ? activeRect.top + activeRect.height / 2 + (current.currentY - current.startY) : current.currentY;
            const targetIndex = computeTargetIndexWrap(pointerX, pointerY, rects);
            untrack(() => { dragState = { activeIndex: null, startX: 0, startY: 0, currentX: 0, currentY: 0 }; });
            if (targetIndex !== current.activeIndex) {
                const next = foundation.moveTag(current.activeIndex, targetIndex, isControlled);
                onChange?.(next);
            }
        };
        document.addEventListener('mousemove', handleMove);
        document.addEventListener('mouseup', handleUp);
        return () => {
            document.removeEventListener('mousemove', handleMove);
            document.removeEventListener('mouseup', handleUp);
        };
    });

    let &[dragTransforms] = track<Array<{ x: number; y: number }>>(() => {
        if (dragState.activeIndex === null) return [];
        const rects = dragStartRects;
        const activeRect = rects[dragState.activeIndex];
        const pointerX = activeRect ? activeRect.left + activeRect.width / 2 + (dragState.currentX - dragState.startX) : dragState.currentX;
        const pointerY = activeRect ? activeRect.top + activeRect.height / 2 + (dragState.currentY - dragState.startY) : dragState.currentY;
        const targetIndex = computeTargetIndexWrap(pointerX, pointerY, rects);
        return computeItemTransformsWrap(
            dragState.activeIndex,
            targetIndex,
            dragState.currentX - dragState.startX,
            dragState.currentY - dragState.startY,
            rects,
        );
    });

    // ===================== 派生展示值 =====================

    let &[classes] = track<string>(() =>
        [
            'lotus-tag-input',
            `lotus-tag-input-${size}`,
            validateStatus !== 'default' ? `lotus-tag-input-${validateStatus}` : '',
            disabled ? 'lotus-tag-input-disabled' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    <>
        <div
            class={classes}
            style={style}
            role="group"
            aria-label={ariaLabel}
            aria-disabled={disabled}
            onClick={focusInput}
        >
            @if (prefix) {
                <span class="lotus-tag-input-prefix">{prefix}</span>
            }
            <div class="lotus-tag-input-tags">
                @for (const item of visibleTags; index ti; key item) {
                    <span
                        class="lotus-tag-input-tag-wrapper"
                        style={dragState.activeIndex === ti ? { transform: `translate(${dragTransforms[ti]?.x ?? 0}px, ${dragTransforms[ti]?.y ?? 0}px)`, position: 'relative', zIndex: 1 } : (dragTransforms[ti] ? { transform: `translate(${dragTransforms[ti]?.x ?? 0}px, ${dragTransforms[ti]?.y ?? 0}px)` } : undefined)}
                        ref={(node: HTMLElement) => { tagNodes[ti] = node; }}
                    >
                        @if (draggable) {
                            <span
                                class="lotus-tag-input-drag-handle"
                                role="button"
                                aria-label={locale.TagInput.dragHandle(item)}
                                onMouseDown={(e: MouseEvent) => handleDragStart(ti, e)}
                            >
                                <IconHandle />
                            </span>
                        }
                        <Tag
                            color="white"
                            type="light"
                            size={size === 'large' ? 'default' : size}
                            closable={!disabled}
                            onClose={() => handleRemoveTag(ti)}
                            aria-label={!disabled ? locale.TagInput.closableTag(item) : locale.TagInput.plainTag(item)}
                        >
                            {item}
                        </Tag>
                    </span>
                }
                @if (showFolded) {
                    @if (showRestTagsPopover) {
                        <Popover
                            trigger="hover"
                            content={
                                <div class="lotus-tag-input-rest-popover">
                                    @for (const item of foldResult.rest; index ri; key item) {
                                        <Tag color="white" type="light" size="small" aria-label={item}>{item}</Tag>
                                    }
                                </div>
                            }
                        >
                            <span
                                class="lotus-tag-input-rest"
                                role="button"
                                tabIndex={0}
                                aria-label={locale.TagInput.moreTagsExpand(foldResult.restCount)}
                                onClick={toggleRestExpanded}
                                onKeyDown={handleRestKeyDown}
                            >
                                +{foldResult.restCount}
                            </span>
                        </Popover>
                    } @else {
                        <span
                            class="lotus-tag-input-rest"
                            role="button"
                            tabIndex={0}
                            aria-label={locale.TagInput.moreTagsExpand(foldResult.restCount)}
                            onClick={toggleRestExpanded}
                            onKeyDown={handleRestKeyDown}
                        >
                            +{foldResult.restCount}
                        </span>
                    }
                }
                <input
                    type="text"
                    class="lotus-tag-input-input"
                    value={state.inputValue}
                    placeholder={state.tagsArray.length === 0 ? placeholder : undefined}
                    disabled={disabled}
                    autofocus={autoFocus}
                    aria-label={locale.TagInput.inputLabel}
                    onInput={handleInput}
                    onKeyDown={handleKeyDown}
                    onBlur={handleBlur}
                    ref={(node: HTMLInputElement) => { inputNode = node; }}
                />
            </div>
            @if (showClear && state.tagsArray.length > 0 && !disabled) {
                <span
                    class="lotus-tag-input-clear"
                    role="button"
                    tabIndex={0}
                    aria-label={locale.TagInput.clearAll}
                    onClick={handleClear}
                    onKeyDown={(e: KeyboardEvent) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleClear(); } }}
                >
                    <IconClear />
                </span>
            }
            @if (suffix) {
                <span class="lotus-tag-input-suffix">{suffix}</span>
            }
        </div>

        <style>
            .lotus-tag-input {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 4px;
                min-height: var(--lotus-height-control-default, 32px);
                padding: 3px 8px;
                border: 1px solid var(--lotus-color-border);
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-bg-1);
                cursor: text;
                box-sizing: border-box;
            }

            .lotus-tag-input:focus-within {
                border-color: var(--lotus-color-primary);
            }

            .lotus-tag-input-small {
                min-height: 24px;
                padding: 1px 6px;
            }

            .lotus-tag-input-large {
                min-height: 40px;
                padding: 5px 10px;
            }

            .lotus-tag-input-error {
                border-color: var(--lotus-color-danger, #d94711);
            }

            .lotus-tag-input-warning {
                border-color: var(--lotus-color-warning, #fadb14);
            }

            .lotus-tag-input-disabled {
                cursor: not-allowed;
                opacity: 0.6;
                background: var(--lotus-color-fill-0);
            }

            .lotus-tag-input-prefix,
            .lotus-tag-input-suffix {
                display: inline-flex;
                align-items: center;
                color: var(--lotus-color-text-2);
                flex-shrink: 0;
            }

            .lotus-tag-input-tags {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 4px;
                flex: 1;
                min-width: 60px;
            }

            .lotus-tag-input-tag-wrapper {
                display: inline-flex;
                align-items: center;
                transition: transform 0.15s ease;
            }

            .lotus-tag-input-drag-handle {
                display: inline-flex;
                align-items: center;
                cursor: grab;
                color: var(--lotus-color-text-2);
                margin-inline-end: 2px;
            }

            .lotus-tag-input-rest {
                display: inline-flex;
                align-items: center;
                height: 24px;
                padding: 0 8px;
                border-radius: var(--lotus-border-radius-small, 4px);
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-1);
                font-size: var(--lotus-font-label-size);
                cursor: pointer;
            }

            .lotus-tag-input-rest:focus-visible {
                outline: 2px solid var(--lotus-color-primary);
                outline-offset: 1px;
            }

            .lotus-tag-input-rest-popover {
                display: flex;
                flex-wrap: wrap;
                gap: 4px;
                max-width: 240px;
                padding: 4px;
            }

            .lotus-tag-input-input {
                flex: 1;
                min-width: 40px;
                border: none;
                outline: none;
                background: transparent;
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
                height: 22px;
            }

            .lotus-tag-input-clear,
            .lotus-tag-input-suffix {
                flex-shrink: 0;
            }

            .lotus-tag-input-clear {
                display: inline-flex;
                align-items: center;
                cursor: pointer;
                color: var(--lotus-color-text-2);
            }

            .lotus-tag-input-clear:hover {
                color: var(--lotus-color-text-0);
            }
        </style>
    </>
}
