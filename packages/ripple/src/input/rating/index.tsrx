import { track, untrack, effect } from 'ripple';
import { RatingFoundation, starFillState, type RatingState, type RatingFoundationOptions } from '@lotus/foundation/input/rating';
import { IconStar } from '@lotus/icons';

export type RatingSize = 'small' | 'default' | number;

export interface RatingProps {
    value?: number;
    defaultValue?: number;
    count?: number;
    allowHalf?: boolean;
    allowClear?: boolean;
    disabled?: boolean;
    character?: any;
    size?: RatingSize;
    onChange?: (value: number) => void;
    onHoverChange?: (value: number | undefined) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

function fractionWithin(clientX: number, rect: DOMRect): number {
    if (rect.width === 0) return 0;
    return (clientX - rect.left) / rect.width;
}

/**
 * Rating：星级评分，单值可半星。像素↔分值换算、hover 预览、点击清零、键盘环绕
 * 移植自 Semi semi-foundation/rating/foundation.ts 的算法（对齐参考实现
 * chenzy.design 的 Rating.svelte）。星星填充用"背景星 + 裁剪叠层星"两层
 * overflow:hidden 实现半星视觉效果，比 Semi 原始的 first/second 双 role=radio
 * 结构简化——整组只用一个可聚焦容器 + 方向键操作，不做逐星 roving tabindex。
 */
export function Rating(&{
    value,
    defaultValue = 0,
    count = 5,
    allowHalf = false,
    allowClear = true,
    disabled = false,
    character,
    size = 'default',
    onChange,
    onHoverChange,
    'aria-label': ariaLabel,
    style,
    class: className,
}: RatingProps) @{
    const isControlled = value !== undefined;

    let &[state] = track<RatingState>({
        value: isControlled ? value! : defaultValue,
        hoverValue: undefined,
        clearedValue: null,
    });

    const foundationOpts: RatingFoundationOptions = { count, allowHalf, allowClear };

    const foundation = new RatingFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<RatingState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        foundationOpts,
    );

    effect(() => {
        if (value === undefined) return;
        untrack(() => { state = { ...state, value: value! }; });
    });

    let starNodes: Array<HTMLElement | null> = [];

    function handleStarMouseMove(index: number, event: MouseEvent) {
        if (disabled) return;
        const node = starNodes[index];
        if (!node) return;
        const rect = node.getBoundingClientRect();
        const fraction = fractionWithin(event.clientX, rect);
        const changed = foundation.handleHover(index, fraction);
        if (changed) onHoverChange?.(untrack(() => state).hoverValue);
    }

    function handleMouseLeave() {
        if (disabled) return;
        foundation.handleLeave();
        onHoverChange?.(undefined);
    }

    function handleStarClick(index: number, event: MouseEvent) {
        if (disabled) return;
        const node = starNodes[index];
        if (!node) return;
        const rect = node.getBoundingClientRect();
        const fraction = fractionWithin(event.clientX, rect);
        const result = foundation.handleClick(index, fraction);
        if (result.changed) onChange?.(result.value);
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (!['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(event.key)) return;
        event.preventDefault();
        const result = foundation.handleKeyDown(event.key);
        if (result?.changed) onChange?.(result.value);
    }

    let &[displayValue] = track<number>(() => (state.hoverValue === undefined ? state.value : state.hoverValue));

    let &[stars] = track<Array<{ index: number; fill: 'empty' | 'half' | 'full' }>>(() =>
        Array.from({ length: count }, (_v, index) => ({ index, fill: starFillState(displayValue, index, allowHalf) })),
    );

    let &[fontSize] = track<string>(() => (typeof size === 'number' ? `${size}px` : ''));

    let &[classes] = track<string>(() =>
        [
            'lotus-rating',
            disabled ? 'lotus-rating-disabled' : '',
            typeof size === 'string' ? `lotus-rating-${size}` : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    <>
        <ul
            class={classes}
            style={style}
            role="radiogroup"
            aria-label={ariaLabel}
            tabIndex={disabled ? -1 : 0}
            onKeyDown={handleKeyDown}
            onMouseLeave={handleMouseLeave}
        >
            @for (const star of stars; index si; key star.index) {
                <li
                    class={['lotus-rating-star', `lotus-rating-star-${star.fill}`].join(' ')}
                    style={fontSize ? { fontSize } : undefined}
                    role="radio"
                    aria-checked={star.fill === 'full'}
                    aria-posinset={star.index + 1}
                    aria-setsize={count}
                    ref={(node: HTMLElement) => { starNodes[star.index] = node; }}
                    onMouseMove={(e: MouseEvent) => handleStarMouseMove(star.index, e)}
                    onClick={(e: MouseEvent) => handleStarClick(star.index, e)}
                >
                    <span class="lotus-rating-star-bg">{character ?? <IconStar />}</span>
                    <span
                        class="lotus-rating-star-fill-layer"
                        style={{ width: star.fill === 'full' ? '100%' : star.fill === 'half' ? '50%' : '0%' }}
                    >
                        {character ?? <IconStar />}
                    </span>
                </li>
            }
        </ul>

        <style>
            .lotus-rating {
                display: inline-flex;
                list-style: none;
                margin: 0;
                padding: 0;
                gap: 4px;
                outline: none;
            }

            .lotus-rating:focus-visible {
                box-shadow: 0 0 0 2px var(--lotus-color-primary-light, rgba(0, 100, 250, 0.2));
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-rating-star {
                position: relative;
                display: inline-flex;
                cursor: pointer;
                font-size: 24px;
                line-height: 1;
                color: var(--lotus-color-fill-2);
            }

            .lotus-rating-small .lotus-rating-star {
                font-size: 16px;
            }

            .lotus-rating-star-bg {
                display: inline-flex;
            }

            .lotus-rating-star-fill-layer {
                position: absolute;
                top: 0;
                inset-inline-start: 0;
                overflow: hidden;
                white-space: nowrap;
                color: var(--lotus-color-warning, #fadb14);
            }

            .lotus-rating-star:hover {
                transform: scale(1.1);
            }

            .lotus-rating-disabled .lotus-rating-star {
                cursor: default;
            }

            .lotus-rating-disabled .lotus-rating-star:hover {
                transform: none;
            }
        </style>
    </>
}
