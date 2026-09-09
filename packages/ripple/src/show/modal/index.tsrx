import { track, effect, untrack, Portal } from 'ripple';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';
import { ConfigContext } from '../../other/config-provider/config-context.js';
import { ModalFoundation, initialModalState, type ModalState } from '@lotus/foundation/show/modal';
import { getFocusableElements, resolveTabWrapTarget } from '@lotus/foundation/base/focus-trap';
import { lockBodyScroll, unlockBodyScroll } from '@lotus/foundation/base/scroll-lock';
import { Button, type ButtonType, type ButtonProps } from '../../basic/button/index.tsrx';
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
    /** 自定义标题旁的图标（对齐 Semi icon）。 */
    icon?: any;
    /** 自定义关闭按钮图标（对齐 Semi closeIcon），默认 IconClose。 */
    closeIcon?: any;
    /** 浮层挂载的目标容器，不传则读取 ConfigProvider 全局默认值，最终兜底 document.body（对齐 Semi getPopupContainer）。 */
    getPopupContainer?: () => HTMLElement;
    /** 遮罩自定义样式（对齐 Semi maskStyle）。 */
    maskStyle?: Record<string, any>;
    /** getPopupContainer 挂载到非 document.body 容器时，遮罩/内容是否仍固定定位（对齐 Semi maskFixed）。 */
    maskFixed?: boolean;
    /** 对话框内容容器的自定义类名（对齐 Semi modalContentClass），与顶层 class 分开——
     * class 落在遮罩+内容的外层 wrapper，modalContentClass 只落在内容 div 本身。 */
    modalContentClass?: string;
    /** 展开/收起是否带过渡动画（对齐 Semi motion，默认开启）。 */
    motion?: boolean;
    /** 关闭时是否保留内部 DOM 不销毁（对齐 Semi keepDOM）。 */
    keepDOM?: boolean;
    /** 配合 keepDOM 使用，为 true 时挂载时不立即渲染内容，等首次展开后才渲染（对齐 Semi lazyRender，默认 true）。 */
    lazyRender?: boolean;
    /** 聚焦时是否阻止浏览器自动滚动到视口（对齐 Semi preventScroll），作用于组件内部的 focus 调用。 */
    preventScroll?: boolean;
    /** 底部确认/取消按钮是否撑满容器宽度（对齐 Semi footerFill）。 */
    footerFill?: boolean;
    /** 透传给取消按钮的额外 props（对齐 Semi cancelButtonProps）。 */
    cancelButtonProps?: Partial<ButtonProps>;
    /** 透传给确认按钮的额外 props（对齐 Semi okButtonProps）。 */
    okButtonProps?: Partial<ButtonProps>;
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
    icon,
    closeIcon,
    getPopupContainer,
    maskStyle,
    maskFixed = false,
    modalContentClass,
    motion = true,
    keepDOM = false,
    lazyRender = true,
    preventScroll,
    footerFill = false,
    cancelButtonProps,
    okButtonProps,
    'aria-label': ariaLabel,
}: ModalProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);
    const configTracked = ConfigContext.get();

    let &[state] = track<ModalState>(initialModalState(untrack(() => visible)));

    const foundation = new ModalFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<ModalState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    let &[hasRenderedOnce] = track<boolean>(false);

    function resolvePortalTarget(): HTMLElement | null {
        const configured = getPopupContainer ?? configTracked?.value.getPopupContainer;
        if (configured) return configured();
        return typeof document !== 'undefined' ? document.body : null;
    }

    // 挂载到非 document.body 容器时，Semi 默认让遮罩/内容改用 position:absolute
    // 相对该容器定位（而非覆盖全视口）；maskFixed=true 时强制保持 position:fixed。
    function usesNonBodyContainer(): boolean {
        const container = resolvePortalTarget();
        return !!container && container !== (typeof document !== 'undefined' ? document.body : null);
    }

    let &[contentNode] = track<HTMLDivElement | null>(null);
    let prevFocusElement: HTMLElement | null = null;

    effect(() => {
        if (visible) {
            untrack(() => { foundation.handleShow(); hasRenderedOnce = true; });
        } else if (!motion) {
            // 无动画时不会触发 onTransitionEnd，直接同步走完“动画结束”状态迁移
            // （对齐 Semi CSSAnimation 在 motion=false 时同步调用 onAnimationEnd）。
            untrack(() => foundation.handleAnimationEnd(false));
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
        (focusable[0] ?? container).focus({ preventScroll: preventScroll ?? true });
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
        console.log('[Modal debug] handleContentTransitionEnd, visible=', visible);
        if (!visible) {
            foundation.handleAnimationEnd(false);
            // 焦点归还发生在动画结束、真正从 DOM 卸载（shouldRender 变 false）之前，
            // 对齐 Semi ModalContentFoundation.destroy 在组件卸载时归还焦点的时机。
            prevFocusElement?.focus({ preventScroll: preventScroll ?? true });
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

    // 对齐 Semi renderDialog 的 shouldRender 判断：受控 visible 为 true 时始终渲染；
    // keepDOM 时按 lazyRender 决定是否要求"已经展开过一次"才提前渲染；否则退化为
    // "还在播放关闭动画（displayNone 还没置 true）就先别卸载"（motion=false 时
    // displayNone 会同步置 true，等价于 visible 一变 false 就立即卸载）。
    let &[shouldRender] = track<boolean>(() => visible || (keepDOM && (!lazyRender || hasRenderedOnce)) || (motion && !state.displayNone));

    let &[keptButHidden] = track<boolean>(() => keepDOM && !visible && state.displayNone);

    let &[maskClasses] = track<string>(() =>
        [
            'lotus-modal-mask',
            visible ? 'lotus-modal-mask-visible' : '',
            motion ? '' : 'lotus-modal-no-motion',
            keptButHidden ? 'lotus-modal-displaynone' : '',
        ].filter(Boolean).join(' '),
    );

    let &[wrapperClasses] = track<string>(() => {
        const nonBody = usesNonBodyContainer();
        return [
            'lotus-modal-wrapper',
            nonBody && !maskFixed ? 'lotus-modal-wrapper-popup' : '',
            maskFixed ? 'lotus-modal-wrapper-fixed' : '',
            keptButHidden ? 'lotus-modal-displaynone' : '',
        ].filter(Boolean).join(' ');
    });

    let &[contentClasses] = track<string>(() =>
        [
            'lotus-modal-content',
            visible ? 'lotus-modal-content-visible' : '',
            centered ? 'lotus-modal-centered' : '',
            fullScreen ? 'lotus-modal-fullscreen' : '',
            icon ? 'lotus-modal-content-with-icon' : '',
            motion ? '' : 'lotus-modal-no-motion',
            // keepDOM 关闭动画播放完毕（displayNone=true）后不卸载 DOM，但要真正
            // 从视觉/布局上隐藏（对齐 Semi `.dialog-displayNone { display: none }`），
            // 否则元素仍占据文档流、Playwright/屏幕阅读器都会判定为可见。
            keptButHidden ? 'lotus-modal-displaynone' : '',
            className ?? '',
            modalContentClass ?? '',
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
            <Portal target={resolvePortalTarget()}>
                @if (mask) {
                    <div class={maskClasses} style={{ zIndex, ...maskStyle }} onClick={handleMaskClick} />
                }
                <div class={wrapperClasses} style={{ zIndex: zIndex + 1 }} onClick={handleMaskClick}>
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
                        @if (icon) {
                            <span class="lotus-modal-icon">{icon}</span>
                        }
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
                                {closeIcon ?? <IconClose />}
                            </button>
                        }

                        <div class="lotus-modal-body" style={bodyStyle}>
                            {children}
                        </div>

                        @if (footer !== undefined) {
                            <div class="lotus-modal-footer">{footer}</div>
                        }
                        @if (footer === undefined) {
                            <div class={['lotus-modal-footer', footerFill ? 'lotus-modal-footer-fill' : ''].filter(Boolean).join(' ')}>
                                @if (hasCancel) {
                                    <Button theme="light" type="tertiary" block={footerFill} loading={cancelBtnLoading} onClick={handleCancel} {...(cancelButtonProps ?? {})}>
                                        {cancelText ?? locale.Modal.cancelText}
                                    </Button>
                                }
                                <Button theme="solid" type={okType} block={footerFill} loading={okLoading} onClick={handleOk} {...(okButtonProps ?? {})}>
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

            .lotus-modal-mask.lotus-modal-no-motion {
                transition: none;
            }

            /* 用 !important 而非单类选择器覆盖 .lotus-modal-content/-wrapper/-mask
               的 display 声明——同优先级选择器的胜负取决于源码书写顺序，容易在
               后续维护中被意外颠倒，!important 才是确定性的覆盖手段。 */
            .lotus-modal-displaynone {
                display: none !important;
            }

            .lotus-modal-wrapper {
                position: fixed;
                inset: 0;
                overflow-y: auto;
                display: flex;
                justify-content: center;
                padding: var(--lotus-spacing-extra-loose) 0;
            }

            /* getPopupContainer 挂载到非 document.body 容器且未强制 maskFixed 时，
               遮罩/内容改为相对该容器定位（对齐 Semi .dialog-popup），而非覆盖全视口。 */
            .lotus-modal-wrapper-popup {
                position: absolute;
                overflow: hidden;
            }

            .lotus-modal-wrapper-fixed {
                position: fixed;
                overflow: hidden;
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

            .lotus-modal-content.lotus-modal-no-motion {
                transition: none;
            }

            .lotus-modal-content-visible {
                opacity: 1;
                transform: scale(1);
            }

            .lotus-modal-content-with-icon {
                padding-left: calc(var(--lotus-spacing-base-loose) + 28px);
            }

            .lotus-modal-icon {
                position: absolute;
                top: var(--lotus-spacing-base);
                left: var(--lotus-spacing-base-loose);
                display: flex;
                align-items: center;
                color: var(--lotus-color-warning);
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

            .lotus-modal-footer-fill {
                justify-content: stretch;
            }

            .lotus-modal-footer-fill > :global(.lotus-button) {
                flex: 1;
            }
        </style>
    </>
}
