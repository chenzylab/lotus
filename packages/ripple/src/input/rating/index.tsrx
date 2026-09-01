import { track, untrack, effect } from 'ripple';
import { RatingFoundation, starFillState, type RatingState, type RatingFoundationOptions } from '@lotus/foundation/input/rating';
import { IconStar } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { Tooltip } from '../../show/tooltip/index.tsrx';

export type RatingSize = 'small' | 'default' | number;

export interface RatingApi {
    /** 命令式聚焦（对齐 Semi 的 ref.current.focus()，如挂载时自动聚焦之外
     * 由外部触发聚焦的场景）；`preventScroll` 透传给原生 focus() 的同名选项。 */
    focus: (options?: { preventScroll?: boolean }) => void;
    /** 命令式移出焦点，同上。 */
    blur: () => void;
}

export interface RatingProps {
    value?: number;
    defaultValue?: number;
    count?: number;
    allowHalf?: boolean;
    allowClear?: boolean;
    disabled?: boolean;
    character?: any;
    size?: RatingSize;
    /** 挂载后是否自动聚焦（对齐 Semi autoFocus），disabled 时不生效。 */
    autoFocus?: boolean;
    /** 每颗星 hover 时展示的自定义提示文案（对齐 Semi tooltips），数组下标
     * 对应星的 index（0-based），不传或对应下标为空字符串时不展示提示。 */
    tooltips?: string[];
    getRatingApi?: (api: RatingApi) => void;
    onChange?: (value: number) => void;
    onHoverChange?: (value: number | undefined) => void;
    onFocus?: (event: FocusEvent) => void;
    onBlur?: (event: FocusEvent) => void;
    'aria-label'?: string;
    'aria-labelledby'?: string;
    'aria-describedby'?: string;
    'aria-errormessage'?: string;
    'aria-invalid'?: boolean;
    'aria-required'?: boolean;
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
    autoFocus = false,
    tooltips,
    getRatingApi,
    onChange,
    onHoverChange,
    onFocus,
    onBlur,
    'aria-label': ariaLabel,
    'aria-labelledby': ariaLabelledBy,
    'aria-describedby': ariaDescribedBy,
    'aria-errormessage': ariaErrorMessage,
    'aria-invalid': ariaInvalid,
    'aria-required': ariaRequired,
    style,
    class: className,
}: RatingProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = value !== undefined;

    let &[state] = track<RatingState>({
        value: isControlled ? value! : defaultValue,
        hoverValue: undefined,
        clearedValue: null,
    });

    const foundationOpts: RatingFoundationOptions = { count, allowHalf, allowClear, isRtl: untrack(() => locale).dir === 'rtl' };

    // 方向是运行时可能切换的全局状态（ConfigProvider.direction 或 locale
    // 切换），固化挂载时的方向会导致切换语言方向后键盘操作方向感知与
    // 视觉镜像不再对应（同 Slider isRtl 已验证的既定同步模式）。
    effect(() => {
        foundationOpts.isRtl = locale.dir === 'rtl';
    });

    const foundation = new RatingFoundation(
        {
            getState: () => untrack(() => state),
            setState: (patch: Partial<RatingState>) => { state = { ...untrack(() => state), ...patch }; },
        },
        foundationOpts,
    );

    let rootNode: HTMLElement | null = null;

    getRatingApi?.({
        focus: (options) => { if (!disabled) rootNode?.focus(options); },
        blur: () => rootNode?.blur(),
    });

    effect(() => {
        if (!autoFocus || disabled) return;
        untrack(() => rootNode?.focus());
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
        const result = foundation.handleClick(index, fraction, isControlled);
        if (result.changed) onChange?.(result.value);
    }

    function handleKeyDown(event: KeyboardEvent) {
        if (disabled) return;
        if (!['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(event.key)) return;
        event.preventDefault();
        const result = foundation.handleKeyDown(event.key, isControlled);
        if (result?.changed) onChange?.(result.value);
    }

    // 受控模式下已提交值（hover 预览之外的"底值"）必须直接来自 value prop，
    // 不能读 state.value——真机验证过“先写本地 state、指望某个 effect 把它
    // 纠正回受控值”这条路径在父组件 onChange 拒绝更新时完全失效（那个纠正
    // effect 只在 value prop 本身变化时才会被重新调度）。committedValue 与
    // Select 的 `isControlled ? value : state.value` 是同一个正确模式。
    let &[committedValue] = track<number>(() => (isControlled ? value! : state.value));
    let &[displayValue] = track<number>(() => (state.hoverValue === undefined ? committedValue : state.hoverValue));

    // hoverIndex：当前 hover 预览值对应落在哪一颗星上（0-based），仅用于
    // tooltips 的显隐判断——对齐 Semi `hoverValue - 1 === ind` 的语义，
    // half 值（如 2.5）向上取整到第 3 颗星（index 2）展示提示。
    let &[hoverIndex] = track<number | undefined>(() =>
        state.hoverValue === undefined ? undefined : Math.ceil(state.hoverValue) - 1,
    );

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
            aria-labelledby={ariaLabelledBy}
            aria-describedby={ariaDescribedBy}
            aria-errormessage={ariaErrorMessage}
            aria-invalid={ariaInvalid}
            aria-required={ariaRequired}
            tabIndex={disabled ? -1 : 0}
            ref={(node: HTMLElement) => { rootNode = node; }}
            onKeyDown={handleKeyDown}
            onMouseLeave={handleMouseLeave}
            onFocus={(e: FocusEvent) => onFocus?.(e)}
            onBlur={(e: FocusEvent) => onBlur?.(e)}
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
                    @if (tooltips?.[star.index]) {
                        <>
                        <Tooltip
                            trigger="custom"
                            visible={hoverIndex === star.index}
                            content={tooltips[star.index]}
                            position="top"
                        >
                            <span class="lotus-rating-star-bg">{character ?? <IconStar />}</span>
                            <span
                                class="lotus-rating-star-fill-layer"
                                style={{ width: star.fill === 'full' ? '100%' : star.fill === 'half' ? '50%' : '0%' }}
                            >
                                {character ?? <IconStar />}
                            </span>
                        </Tooltip>
                        </>
                    } @else {
                        <>
                        <span class="lotus-rating-star-bg">{character ?? <IconStar />}</span>
                        <span
                            class="lotus-rating-star-fill-layer"
                            style={{ width: star.fill === 'full' ? '100%' : star.fill === 'half' ? '50%' : '0%' }}
                        >
                            {character ?? <IconStar />}
                        </span>
                        </>
                    }
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
