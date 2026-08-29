import { track, effect, untrack, Portal } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { ModalFoundation, initialModalState, type ModalState } from '@lotus/foundation/show/modal';
import { getFocusableElements, resolveTabWrapTarget } from '@lotus/foundation/base/focus-trap';
import { lockBodyScroll, unlockBodyScroll } from '@lotus/foundation/base/scroll-lock';
import { Button, type ButtonType } from '../../basic/button/index.tsrx';
import { IconClose } from '@lotus/icons';

export type ModalSize = 'small' | 'medium' | 'large' | 'full-width';

export interface ModalProps {
    visible?: boolean;
    title?: any;
    header?: any;
    footer?: any;
    children?: any;
    onOk?: (event: MouseEvent) => void | Promise<any>;
    onCancel?: (event: MouseEvent) => void | Promise<any>;
    afterClose?: () => void;
    closable?: boolean;
    closeOnEsc?: boolean;
    maskClosable?: boolean;
    mask?: boolean;
    width?: string | number;
    height?: string | number;
    size?: ModalSize;
    centered?: boolean;
    fullScreen?: boolean;
    zIndex?: number;
    okText?: string;
    cancelText?: string;
    okType?: ButtonType;
    hasCancel?: boolean;
    confirmLoading?: boolean;
    cancelLoading?: boolean;
    bodyStyle?: Record<string, any>;
    style?: Record<string, any>;
    class?: string;
    'aria-label'?: string;
}

const SIZE_WIDTH: Record<ModalSize, string> = {
    small: '448px',
    medium: '684px',
    large: '920px',
    'full-width': 'calc(100vw - 64px)',
};

export function Modal(&{
    visible = false,
    title,
    header,
    footer,
    children,
    onOk,
    onCancel,
    afterClose,
    closable = true,
    closeOnEsc = true,
    maskClosable = true,
    mask = true,
    width,
    height,
    size = 'small',
    centered = false,
    fullScreen = false,
    zIndex = 1000,
    okText,
    cancelText,
    okType = 'primary',
    hasCancel = true,
    confirmLoading,
    cancelLoading,
    bodyStyle,
    style,
    class: className,
    'aria-label': ariaLabel,
}: ModalProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<ModalState>(initialModalState(untrack(() => visible)));

    const foundation = new ModalFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<ModalState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let &[contentNode] = track<HTMLDivElement | null>(null);
    let prevFocusElement: HTMLElement | null = null;

    effect(() => {
        if (visible) {
            untrack(() => foundation.handleShow());
        }
    });

    // body 滚动锁定：对齐 Semi Modal 的 disabledBodyScroll/enabledBodyScroll
    // 行为——Modal 本身没有像 SideSheet 那样暴露 disableScroll 开关 prop
    // （核对一手来源 semi-ui/modal/Modal.tsx 确认 Semi Modal 就是打开必锁、
    // 关闭必解，不可配置），打开即锁定。与 SideSheet 共用同一个
    // base/scroll-lock 模块的引用计数器，避免"Modal 打开 → SideSheet 打开
    // → 其中一个关闭"这种跨组件嵌套场景下错误地提前解锁。
    effect(() => {
        if (!visible) return;
        lockBodyScroll();
        return () => unlockBodyScroll();
    });

    // 打开时记录触发前的焦点元素并把焦点移入对话框（对齐 Semi ModalContent.componentDidMount：
    // 已在对话框内则不动，否则聚焦第一个可聚焦元素，都没有则聚焦对话框容器本身）。
    // 依赖响应式的 contentNode（而非 visible）触发：@if(shouldRender) 分支渲染出真实 DOM、
    // ref 回调写入 contentNode 是在 visible 变 true 之后的下一步，用 visible 做依赖会在
    // container 还是 null 时就跑完这个 effect，永远聚焦不到内容。
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
            // 焦点归还发生在动画结束、真正从 DOM 卸载（shouldRender 变 false）之前，
            // 对齐 Semi ModalContentFoundation.destroy 在组件卸载时归还焦点的时机。
            prevFocusElement?.focus({ preventScroll: true });
            afterClose?.();
        }
    }

    function handleOk(event: MouseEvent) {
        const result = onOk?.(event);
        foundation.invokeOk(result);
    }

    function handleCancel(event: MouseEvent) {
        const result = onCancel?.(event);
        foundation.invokeCancel(result);
    }

    function handleMaskClick(event: MouseEvent) {
        if (!maskClosable) return;
        const target = event.target as HTMLElement;
        if (target.classList.contains('lotus-modal-content') || target.closest('.lotus-modal-content')) return;
        handleCancel(event);
    }

    effect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!closeOnEsc) return;
            if (!untrack(() => visible)) return;
            if (event.key === 'Escape') handleCancel(event as unknown as MouseEvent);
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    let &[shouldRender] = track<boolean>(() => visible || !state.displayNone);

    let &[maskClasses] = track<string>(() =>
        ['lotus-modal-mask', visible ? 'lotus-modal-mask-visible' : ''].filter(Boolean).join(' '),
    );

    let &[contentClasses] = track<string>(() =>
        [
            'lotus-modal-content',
            visible ? 'lotus-modal-content-visible' : '',
            centered ? 'lotus-modal-centered' : '',
            fullScreen ? 'lotus-modal-fullscreen' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    let &[contentStyle] = track<Record<string, any>>(() => ({
        ...style,
        width: fullScreen ? '100%' : (width ?? SIZE_WIDTH[size]),
        height: fullScreen ? '100%' : height,
    }));

    let &[okLoading] = track<boolean>(() => confirmLoading ?? state.onOkStatus === 'pending');
    let &[cancelBtnLoading] = track<boolean>(() => cancelLoading ?? state.onCancelStatus === 'pending');

    let &[hasHeader] = track<boolean>(() => header !== undefined || title !== undefined);

    <>
        @if (shouldRender) {
            <Portal target={typeof document !== 'undefined' ? document.body : null}>
                @if (mask) {
                    <div class={maskClasses} style={{ zIndex }} onClick={handleMaskClick} />
                }
                <div class="lotus-modal-wrapper" style={{ zIndex: zIndex + 1 }} onClick={handleMaskClick}>
                    <div
                        class={contentClasses}
                        style={contentStyle}
                        role="dialog"
                        aria-modal="true"
                        aria-label={ariaLabel}
                        tabIndex={-1}
                        onClick={(e: MouseEvent) => e.stopPropagation()}
                        onTransitionEnd={handleContentTransitionEnd}
                        onKeyDown={handleContentKeyDown}
                        ref={(node: HTMLDivElement | null) => { contentNode = node; }}
                    >
                        @if (hasHeader && header !== undefined) {
                            <div class="lotus-modal-header">{header}</div>
                        }
                        @if (hasHeader && header === undefined) {
                            <div class="lotus-modal-header">
                                <div class="lotus-modal-title">{title}</div>
                            </div>
                        }
                        @if (closable) {
                            <button type="button" class="lotus-modal-close" aria-label="关闭" onClick={handleCancel}>
                                <IconClose />
                            </button>
                        }

                        <div class="lotus-modal-body" style={bodyStyle}>
                            {children}
                        </div>

                        @if (footer !== undefined) {
                            <div class="lotus-modal-footer">{footer}</div>
                        }
                        @if (footer === undefined) {
                            <div class="lotus-modal-footer">
                                @if (hasCancel) {
                                    <Button theme="light" type="tertiary" loading={cancelBtnLoading} onClick={handleCancel}>
                                        {cancelText ?? locale.Modal.cancelText}
                                    </Button>
                                }
                                <Button theme="solid" type={okType} loading={okLoading} onClick={handleOk}>
                                    {okText ?? locale.Modal.okText}
                                </Button>
                            </div>
                        }
                    </div>
                </div>
            </Portal>
        }

        <style>
            .lotus-modal-mask {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.6);
                opacity: 0;
                transition: opacity 0.2s ease;
            }

            .lotus-modal-mask-visible {
                opacity: 1;
            }

            .lotus-modal-wrapper {
                position: fixed;
                inset: 0;
                overflow-y: auto;
                display: flex;
                justify-content: center;
                padding: var(--lotus-spacing-extra-loose) 0;
            }

            .lotus-modal-content {
                position: relative;
                display: flex;
                flex-direction: column;
                margin: auto;
                background: var(--lotus-color-bg-1);
                border-radius: var(--lotus-border-radius-medium);
                box-shadow: var(--lotus-shadow-elevated);
                opacity: 0;
                transform: scale(0.9);
                transition: opacity 0.2s ease, transform 0.2s ease;
                max-height: calc(100vh - 64px);
            }

            .lotus-modal-content-visible {
                opacity: 1;
                transform: scale(1);
            }

            .lotus-modal-centered {
                margin-top: auto;
                margin-bottom: auto;
            }

            .lotus-modal-fullscreen {
                max-height: 100%;
                border-radius: 0;
            }

            .lotus-modal-header {
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                padding-right: calc(var(--lotus-spacing-base-loose) + 32px);
            }

            .lotus-modal-title {
                font-size: var(--lotus-font-h5-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-modal-close {
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

            .lotus-modal-close:hover {
                background: var(--lotus-color-fill-0);
            }

            .lotus-modal-body {
                flex: 1;
                overflow-y: auto;
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                color: var(--lotus-color-text-0);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-modal-footer {
                display: flex;
                justify-content: flex-end;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
            }
        </style>
    </>
}
