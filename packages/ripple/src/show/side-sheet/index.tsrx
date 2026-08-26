import { track, effect, untrack, Portal } from 'ripple';
import { SideSheetFoundation, initialSideSheetState, type SideSheetState } from '@lotus/foundation/show/side-sheet';
import { getFocusableElements, resolveTabWrapTarget } from '@lotus/foundation/base/focus-trap';
import { IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type SideSheetPlacement = 'top' | 'right' | 'bottom' | 'left';
export type SideSheetSize = 'small' | 'medium' | 'large';

export interface SideSheetProps {
    visible?: boolean;
    title?: any;
    children?: any;
    footer?: any;
    onCancel?: (event: MouseEvent | KeyboardEvent) => void;
    afterVisibleChange?: (visible: boolean) => void;
    closable?: boolean;
    closeOnEsc?: boolean;
    maskClosable?: boolean;
    mask?: boolean;
    width?: string | number;
    height?: string | number;
    size?: SideSheetSize;
    placement?: SideSheetPlacement;
    zIndex?: number;
    keepDOM?: boolean;
    disableScroll?: boolean;
    bodyStyle?: Record<string, any>;
    headerStyle?: Record<string, any>;
    maskStyle?: Record<string, any>;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const SIZE_WIDTH: Record<SideSheetSize, string> = {
    small: '448px',
    medium: '684px',
    large: '920px',
};

const SIZE_HEIGHT: Record<SideSheetSize, string> = {
    small: '448px',
    medium: '684px',
    large: '920px',
};

function isVerticalPlacement(placement: SideSheetPlacement): boolean {
    return placement === 'left' || placement === 'right';
}

let scrollLockCount = 0;
let originalBodyOverflow = '';

function lockBodyScroll() {
    if (scrollLockCount === 0) {
        originalBodyOverflow = document.body.style.overflow;
        const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
        document.body.style.overflow = 'hidden';
        if (scrollbarWidth > 0) document.body.style.paddingRight = `${scrollbarWidth}px`;
    }
    scrollLockCount += 1;
}

function unlockBodyScroll() {
    scrollLockCount = Math.max(0, scrollLockCount - 1);
    if (scrollLockCount === 0) {
        document.body.style.overflow = originalBodyOverflow;
        document.body.style.paddingRight = '';
    }
}

export function SideSheet(&{
    visible = false,
    title,
    children,
    footer,
    onCancel,
    afterVisibleChange,
    closable = true,
    closeOnEsc = false,
    maskClosable = true,
    mask = true,
    width,
    height,
    size = 'small',
    placement = 'right',
    zIndex = 1000,
    keepDOM = false,
    disableScroll = true,
    bodyStyle,
    headerStyle,
    maskStyle,
    style,
    class: className,
    'aria-label': ariaLabel,
}: SideSheetProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<SideSheetState>(initialSideSheetState(untrack(() => visible)));

    const foundation = new SideSheetFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<SideSheetState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let &[contentNode] = track<HTMLDivElement | null>(null);
    let prevFocusElement: HTMLElement | null = null;

    effect(() => {
        if (visible) {
            untrack(() => foundation.handleShow());
        }
    });

    effect(() => {
        if (!untrack(() => disableScroll)) return;
        if (visible) {
            lockBodyScroll();
            return () => unlockBodyScroll();
        }
    });

    // 焦点管理对齐 Modal 的处理水平（Semi 自身在 SideSheet 上未实现，本次主动补齐）：
    // 打开时记录触发前焦点并把焦点移入面板，Tab 键在面板内循环，关闭动画结束后归还焦点。
    effect(() => {
        const container = contentNode;
        if (!visible || !container) return;
        prevFocusElement = untrack(() => document.activeElement instanceof HTMLElement ? document.activeElement : null);
        if (prevFocusElement && container.contains(prevFocusElement)) return;
        const focusable = getFocusableElements(container);
        (focusable[0] ?? container).focus({ preventScroll: true });
    });

    function handleContentKeyDown(event: KeyboardEvent) {
        if (event.key !== 'Tab') return;
        const container = contentNode;
        if (!container) return;
        const focusable = getFocusableElements(container);
        const target = resolveTabWrapTarget(focusable, document.activeElement, event.shiftKey);
        if (target) {
            event.preventDefault();
            target.focus({ preventScroll: true });
        }
    }

    function handleContentTransitionEnd() {
        if (!visible) {
            foundation.handleAnimationEnd(false);
            prevFocusElement?.focus({ preventScroll: true });
            afterVisibleChange?.(false);
        }
    }

    function handleCancel(event: MouseEvent | KeyboardEvent) {
        onCancel?.(event);
    }

    function handleMaskClick(event: MouseEvent) {
        if (!maskClosable) return;
        const target = event.target as HTMLElement;
        if (target.classList.contains('lotus-side-sheet-content') || target.closest('.lotus-side-sheet-content')) return;
        handleCancel(event);
    }

    effect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!closeOnEsc) return;
            if (!untrack(() => visible)) return;
            if (event.key === 'Escape') handleCancel(event);
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    let &[shouldRender] = track<boolean>(() => visible || keepDOM || !state.displayNone);

    let &[maskClasses] = track<string>(() =>
        [
            'lotus-side-sheet-mask',
            visible ? 'lotus-side-sheet-mask-visible' : '',
            keepDOM && !visible ? 'lotus-side-sheet-hidden' : '',
        ].filter(Boolean).join(' '),
    );

    let &[contentClasses] = track<string>(() =>
        [
            'lotus-side-sheet-content',
            `lotus-side-sheet-content-${placement}`,
            visible ? 'lotus-side-sheet-content-visible' : '',
            keepDOM && !visible ? 'lotus-side-sheet-hidden' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[contentStyle] = track<Record<string, any>>(() => {
        const vertical = isVerticalPlacement(placement);
        return {
            ...style,
            width: vertical ? (width ?? SIZE_WIDTH[size]) : undefined,
            height: !vertical ? (height ?? SIZE_HEIGHT[size]) : undefined,
        };
    });

    <>
        @if (shouldRender) {
            <Portal target={typeof document !== 'undefined' ? document.body : null}>
                @if (mask) {
                    <div class={maskClasses} style={{ zIndex, ...maskStyle }} aria-hidden="true" onClick={handleMaskClick} />
                }
                <div
                    class={contentClasses}
                    style={{ zIndex: zIndex + 1, ...contentStyle }}
                    role="dialog"
                    aria-modal="true"
                    tabIndex={-1}
                    aria-label={ariaLabel}
                    onClick={(e: MouseEvent) => e.stopPropagation()}
                    onTransitionEnd={handleContentTransitionEnd}
                    onKeyDown={handleContentKeyDown}
                    ref={(node: HTMLDivElement | null) => { contentNode = node; }}
                >
                    @if (title !== undefined) {
                        <div class="lotus-side-sheet-header" style={headerStyle} role="heading" aria-level={1}>
                            <div class="lotus-side-sheet-title">{title}</div>
                        </div>
                    }
                    @if (closable) {
                        <button type="button" class="lotus-side-sheet-close" aria-label={locale.SideSheet.close} onClick={handleCancel}>
                            <IconClose />
                        </button>
                    }

                    <div class="lotus-side-sheet-body" style={bodyStyle}>
                        {children}
                    </div>

                    @if (footer !== undefined) {
                        <div class="lotus-side-sheet-footer">{footer}</div>
                    }
                </div>
            </Portal>
        }

        <style>
            .lotus-side-sheet-mask {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.6);
                opacity: 0;
                transition: opacity 0.18s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            }

            .lotus-side-sheet-mask-visible {
                opacity: 1;
            }

            .lotus-side-sheet-content {
                position: fixed;
                display: flex;
                flex-direction: column;
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
                transition: transform 0.18s cubic-bezier(0.25, 0.46, 0.45, 0.94);
                max-width: 100vw;
                max-height: 100vh;
            }

            .lotus-side-sheet-hidden {
                display: none;
            }

            .lotus-side-sheet-content-right {
                top: 0;
                right: 0;
                bottom: 0;
                transform: translateX(100%);
            }

            .lotus-side-sheet-content-right.lotus-side-sheet-content-visible {
                transform: translateX(0);
            }

            .lotus-side-sheet-content-left {
                top: 0;
                left: 0;
                bottom: 0;
                transform: translateX(-100%);
            }

            .lotus-side-sheet-content-left.lotus-side-sheet-content-visible {
                transform: translateX(0);
            }

            .lotus-side-sheet-content-top {
                top: 0;
                left: 0;
                right: 0;
                width: 100%;
                transform: translateY(-100%);
            }

            .lotus-side-sheet-content-top.lotus-side-sheet-content-visible {
                transform: translateY(0);
            }

            .lotus-side-sheet-content-bottom {
                bottom: 0;
                left: 0;
                right: 0;
                width: 100%;
                transform: translateY(100%);
            }

            .lotus-side-sheet-content-bottom.lotus-side-sheet-content-visible {
                transform: translateY(0);
            }

            .lotus-side-sheet-header {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                padding-right: calc(var(--lotus-spacing-base-loose) + 32px);
            }

            .lotus-side-sheet-title {
                font-size: var(--lotus-font-h5-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-side-sheet-close {
                position: absolute;
                top: var(--lotus-spacing-base);
                right: var(--lotus-spacing-base);
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border-radius: var(--lotus-border-radius-small);
                background: transparent;
                border: none;
                cursor: pointer;
                color: var(--lotus-color-text-2);
            }

            .lotus-side-sheet-close:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-side-sheet-body {
                flex: 1;
                overflow-y: auto;
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-side-sheet-footer {
                display: flex;
                justify-content: flex-end;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
            }
        </style>
    </>
}
