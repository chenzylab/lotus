import { track, effect, untrack } from 'ripple';
import { IconChevronLeft, IconChevronRight } from '@lotus/icons';
import { CarouselFoundation, type CarouselState } from '@lotus/foundation/show/carousel';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type CarouselAnimation = 'slide' | 'fade';
export type CarouselTheme = 'primary' | 'light' | 'dark';
export type CarouselArrowType = 'always' | 'hover';
export type CarouselIndicatorType = 'dot' | 'line' | 'columnar';
export type CarouselIndicatorPosition = 'left' | 'center' | 'right';
export type CarouselTrigger = 'click' | 'hover';

export interface CarouselAutoPlayConfig {
    interval?: number;
    hoverToPause?: boolean;
}

export interface CarouselProps {
    /**
     * 每一项的渲染内容。Ripple 没有 React.Children.map，无法像 Semi 那样
     * 直接遍历 JSX children 拿到每一项，因此改用数组形式的数据源——这是
     * 相对 Semi 原始 API（纯 JSX children）的一处必要设计调整，非遗漏。
     */
    items: any[];
    activeIndex?: number;
    defaultActiveIndex?: number;
    animation?: CarouselAnimation;
    autoPlay?: boolean | CarouselAutoPlayConfig;
    theme?: CarouselTheme;
    showArrow?: boolean;
    arrowType?: CarouselArrowType;
    showIndicator?: boolean;
    indicatorType?: CarouselIndicatorType;
    indicatorPosition?: CarouselIndicatorPosition;
    trigger?: CarouselTrigger;
    speed?: number;
    onChange?: (index: number, prevIndex: number) => void;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const DEFAULT_INTERVAL = 2000;

export function Carousel(&{
    items,
    activeIndex: activeIndexProp,
    defaultActiveIndex = 0,
    animation = 'slide',
    autoPlay = true,
    theme = 'light',
    showArrow = true,
    arrowType = 'always',
    showIndicator = true,
    indicatorType = 'dot',
    indicatorPosition = 'center',
    trigger = 'click',
    speed = 300,
    onChange,
    style,
    class: className,
    'aria-label': ariaLabel,
}: CarouselProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    const isControlled = activeIndexProp !== undefined;

    let &[state] = track<CarouselState>({
        activeIndex: isControlled ? activeIndexProp! : defaultActiveIndex,
        isReverse: false,
    });

    const foundation = new CarouselFoundation({
        getState: () => untrack(() => state),
        setState: (patch) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (!isControlled) return;
        const current = untrack(() => state);
        if (activeIndexProp === current.activeIndex) return;
        state = { ...current, activeIndex: activeIndexProp!, isReverse: activeIndexProp! < current.activeIndex };
    });

    function resolveIntervalMs(): number {
        if (autoPlay === true) return DEFAULT_INTERVAL + speed;
        if (autoPlay && typeof autoPlay === 'object') return (autoPlay.interval ?? DEFAULT_INTERVAL) + speed;
        return DEFAULT_INTERVAL + speed;
    }

    function shouldAutoPlay(): boolean {
        return items.length > 1 && (autoPlay === true || (!!autoPlay && typeof autoPlay === 'object'));
    }

    effect(() => {
        if (!shouldAutoPlay()) return;
        untrack(() => foundation.play(items.length, resolveIntervalMs()));
    });

    function handleChange(nextIndex: number) {
        const prevIndex = untrack(() => state).activeIndex;
        onChange?.(nextIndex, prevIndex);
    }

    function goTo(index: number) {
        const next = foundation.goTo(index, items.length);
        handleChange(next);
    }

    function handlePrev() {
        const next = foundation.prev(items.length);
        handleChange(next);
    }

    function handleNext() {
        const next = foundation.next(items.length);
        handleChange(next);
    }

    function handleMouseEnter() {
        const hoverToPause = autoPlay === true || (!!autoPlay && typeof autoPlay === 'object' && autoPlay.hoverToPause !== false);
        if (hoverToPause) foundation.stop();
    }

    function handleMouseLeave() {
        if (!isControlled && shouldAutoPlay()) foundation.play(items.length, resolveIntervalMs());
    }

    function handleIndicatorTrigger(index: number) {
        if (trigger === 'click') goTo(index);
    }

    function handleIndicatorHover(index: number) {
        if (trigger === 'hover') goTo(index);
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-carousel',
            `lotus-carousel-theme-${theme}`,
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[indicatorClasses] = track<string>(() =>
        [
            'lotus-carousel-indicators',
            `lotus-carousel-indicators-${indicatorPosition}`,
            `lotus-carousel-indicators-${indicatorType}`,
        ].filter(Boolean).join(' '),
    );

    <>
        <div class={classes} style={style} aria-label={ariaLabel} onMouseEnter={handleMouseEnter} onMouseLeave={handleMouseLeave}>
            <div class="lotus-carousel-viewport">
                @for (const item of items; index i) {
                    <div
                        class={[
                            'lotus-carousel-item',
                            `lotus-carousel-item-${animation}`,
                            i === state.activeIndex ? 'lotus-carousel-item-active' : '',
                            i === state.activeIndex && state.isReverse ? 'lotus-carousel-item-reverse' : '',
                        ].filter(Boolean).join(' ')}
                        style={{ transitionDuration: `${speed}ms`, animationDuration: `${speed}ms` }}
                    >
                        {item}
                    </div>
                }
            </div>

            @if (showArrow && items.length > 1) {
                <button
                    type="button"
                    class={['lotus-carousel-arrow', 'lotus-carousel-arrow-left', arrowType === 'hover' ? 'lotus-carousel-arrow-hover' : ''].filter(Boolean).join(' ')}
                    aria-label={locale.Carousel.prev}
                    onClick={handlePrev}
                >
                    <IconChevronLeft />
                </button>
            }
            @if (showArrow && items.length > 1) {
                <button
                    type="button"
                    class={['lotus-carousel-arrow', 'lotus-carousel-arrow-right', arrowType === 'hover' ? 'lotus-carousel-arrow-hover' : ''].filter(Boolean).join(' ')}
                    aria-label={locale.Carousel.next}
                    onClick={handleNext}
                >
                    <IconChevronRight />
                </button>
            }

            @if (showIndicator && items.length > 1) {
                <div class={indicatorClasses}>
                    @for (const item of items; index i) {
                        <span
                            class={['lotus-carousel-indicator-item', i === state.activeIndex ? 'lotus-carousel-indicator-item-active' : ''].filter(Boolean).join(' ')}
                            onClick={() => handleIndicatorTrigger(i)}
                            onMouseEnter={() => handleIndicatorHover(i)}
                        />
                    }
                </div>
            }
        </div>

        <style>
            .lotus-carousel {
                position: relative;
                width: 100%;
                height: 100%;
                overflow: hidden;
                border-radius: var(--lotus-border-radius-medium);
            }

            .lotus-carousel-viewport {
                position: relative;
                width: 100%;
                height: 100%;
            }

            .lotus-carousel-item {
                position: absolute;
                inset: 0;
                visibility: hidden;
            }

            .lotus-carousel-item-active {
                visibility: visible;
            }

            .lotus-carousel-item-fade {
                opacity: 0;
                transition-property: opacity;
            }

            .lotus-carousel-item-fade.lotus-carousel-item-active {
                opacity: 1;
            }

            .lotus-carousel-item-slide.lotus-carousel-item-active {
                animation-name: lotus-carousel-slide-in;
                animation-timing-function: ease;
            }

            .lotus-carousel-item-slide.lotus-carousel-item-active.lotus-carousel-item-reverse {
                animation-name: lotus-carousel-slide-in-reverse;
            }

            @keyframes lotus-carousel-slide-in {
                from { transform: translateX(100%); }
                to { transform: translateX(0); }
            }

            @keyframes lotus-carousel-slide-in-reverse {
                from { transform: translateX(-100%); }
                to { transform: translateX(0); }
            }

            .lotus-carousel-arrow {
                position: absolute;
                top: 50%;
                transform: translateY(-50%);
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: var(--lotus-border-radius-circle);
                background: rgba(0, 0, 0, 0.3);
                color: #fff;
                border: none;
                cursor: pointer;
                z-index: 1;
                opacity: 1;
                transition: opacity 0.2s ease;
            }

            .lotus-carousel-arrow-hover {
                opacity: 0;
            }

            .lotus-carousel:hover .lotus-carousel-arrow-hover {
                opacity: 1;
            }

            .lotus-carousel-arrow-left {
                left: var(--lotus-spacing-tight);
            }

            .lotus-carousel-arrow-right {
                right: var(--lotus-spacing-tight);
            }

            .lotus-carousel-indicators {
                position: absolute;
                bottom: var(--lotus-spacing-tight);
                display: flex;
                gap: var(--lotus-spacing-super-tight);
                z-index: 1;
                width: 100%;
                padding: 0 var(--lotus-spacing-tight);
                box-sizing: border-box;
            }

            .lotus-carousel-indicators-left {
                justify-content: flex-start;
            }

            .lotus-carousel-indicators-center {
                justify-content: center;
            }

            .lotus-carousel-indicators-right {
                justify-content: flex-end;
            }

            .lotus-carousel-indicator-item {
                cursor: pointer;
                background: rgba(255, 255, 255, 0.5);
                transition: background 0.2s ease;
            }

            .lotus-carousel-indicators-dot .lotus-carousel-indicator-item {
                width: 8px;
                height: 8px;
                border-radius: var(--lotus-border-radius-circle);
            }

            .lotus-carousel-indicators-line .lotus-carousel-indicator-item {
                width: 16px;
                height: 3px;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-carousel-indicators-columnar .lotus-carousel-indicator-item {
                width: 4px;
                height: 16px;
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-carousel-indicator-item-active {
                background: #fff;
            }

            .lotus-carousel-theme-primary .lotus-carousel-indicator-item-active {
                background: var(--lotus-color-primary);
            }
        </style>
    </>
}
