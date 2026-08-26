import { track, effect, untrack, Portal } from 'ripple';
import { ContainerFoundation, initialContainerState, type ContainerState } from '@lotus/foundation/show/sidebar';
import { ResizableFoundation, type ResizableState, type ResizableConstraints } from '@lotus/foundation/basic/resizable';
import { IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export interface ContainerProps {
    title?: any;
    visible?: boolean;
    resizable?: boolean;
    minWidth?: number;
    maxWidth?: number;
    defaultWidth?: number;
    showClose?: boolean;
    /** Esc 或关闭按钮触发；对齐 chenzy.design 的增强，Semi 源码 `closeOnEsc` 是未暴露的死 prop，本次主动补齐。 */
    onCancel?: (event: MouseEvent | KeyboardEvent) => void;
    afterVisibleChange?: (visible: boolean) => void;
    header?: any;
    children?: any;
    class?: string;
    style?: Record<string, any>;
}

/**
 * Sidebar.Container：贴视口右侧的可伸缩浮层壳。resize 拖拽只复用
 * `ResizableFoundation` 的方向-delta 算法（单向 left），不套用完整的
 * `<Resizable>` 组件外壳——该组件的 `<style>` scoped 到自身文件，且其
 * `height: ${state.height}px` 会覆盖 `height:100%` 导致高度塌陷，两者都会
 * 让 Container 的背景色/阴影样式无法命中、浮层视觉上完全消失（真机验证
 * 阶段发现的真实坑）。显隐动画时序对齐 Modal 的 ContainerFoundation 同构模式。
 */
export function Container(&{
    title,
    visible = false,
    resizable = true,
    minWidth = 150,
    maxWidth = 800,
    defaultWidth = 360,
    showClose = true,
    onCancel,
    afterVisibleChange,
    header,
    children,
    class: className,
    style,
}: ContainerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<ContainerState>(initialContainerState(untrack(() => visible)));

    const foundation = new ContainerFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<ContainerState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    effect(() => {
        if (visible) {
            untrack(() => foundation.handleShow());
        }
    });

    let &[resizeState] = track<ResizableState>({ width: defaultWidth, height: 0, isResizing: false, direction: null });
    const resizeFoundation = new ResizableFoundation({
        getState: () => untrack(() => resizeState),
        setState: (patch: Partial<ResizableState>) => { resizeState = { ...untrack(() => resizeState), ...patch }; },
    });
    const resizeConstraints: ResizableConstraints = { minWidth, minHeight: 0, maxWidth, maxHeight: Infinity, lockAspectRatio: false };

    function handleResizeHandleDown(event: MouseEvent) {
        event.preventDefault();
        // 容器贴视口的"逻辑末尾"（LTR 下是右边，RTL 下镜像到左边），resize 手柄
        // 贴容器的"逻辑起始"边缘（LTR 下手柄在容器左边缘，RTL 下镜像到容器右边缘）。
        // ResizableFoundation 的 'left'/'right' 是物理方向常量，往哪边拖动增大宽度
        // 完全取决于手柄相对容器的物理位置，必须跟随 dir 镜像传参，否则 RTL 下拖拽
        // 方向会和视觉手柄位置对不上（拖不动或者反向变化）。
        resizeFoundation.onResizeStart(locale.dir === 'rtl' ? 'right' : 'left', event.clientX, event.clientY);
    }

    effect(() => {
        const handlePointerMove = (event: MouseEvent) => {
            const current = untrack(() => resizeState);
            if (!current.isResizing) return;
            resizeFoundation.onResize(event.clientX, event.clientY, resizeConstraints);
        };
        const handlePointerUp = () => {
            const current = untrack(() => resizeState);
            if (!current.isResizing) return;
            resizeFoundation.onResizeEnd();
        };
        document.addEventListener('mousemove', handlePointerMove);
        document.addEventListener('mouseup', handlePointerUp);
        return () => {
            document.removeEventListener('mousemove', handlePointerMove);
            document.removeEventListener('mouseup', handlePointerUp);
        };
    });

    function handleContentTransitionEnd() {
        if (!visible) {
            foundation.handleAnimationEnd(false);
            afterVisibleChange?.(false);
        } else {
            afterVisibleChange?.(true);
        }
    }

    function handleCancel(event: MouseEvent | KeyboardEvent) {
        onCancel?.(event);
    }

    effect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!untrack(() => visible)) return;
            if (event.key === 'Escape') handleCancel(event);
        };
        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    });

    let &[shouldRender] = track<boolean>(() => visible || !state.displayNone);

    let &[wrapperClasses] = track<string>(() =>
        ['lotus-sidebar-container-wrapper', visible ? 'lotus-sidebar-container-wrapper-visible' : ''].filter(Boolean).join(' '),
    );

    let &[contentClasses] = track<string>(() =>
        [
            'lotus-sidebar-container',
            visible ? 'lotus-sidebar-container-visible' : '',
            resizeState.isResizing ? 'lotus-sidebar-container-resizing' : '',
            className ?? '',
        ].filter(Boolean).join(' '),
    );

    // translateX 无法用 CSS 逻辑属性表达方向，必须显式按 locale.dir 取反——
    // LTR 下面板贴视口右侧、从右侧滑入用 translateX(100%)；RTL 下面板贴视口
    // 左侧（inset-inline-end 会自动镜像成 left:0），滑入方向也要跟着镜像成
    // translateX(-100%)，否则会出现"面板位置已经镜像到左边，但打开动画却从
    // 右边滑入"的方向不一致。
    let &[hiddenTransform] = track<string>(() => (locale.dir === 'rtl' ? 'translateX(-100%)' : 'translateX(100%)'));
    let &[contentStyle] = track<Record<string, any>>(() => ({
        ...style,
        width: `${resizeState.width}px`,
        ...(visible ? {} : { transform: hiddenTransform }),
    }));

    let &[hasHeader] = track<boolean>(() => header !== undefined);

    <>
        @if (shouldRender) {
            <Portal target={typeof document !== 'undefined' ? document.body : null}>
                <div class={wrapperClasses}>
                    <div class={contentClasses} style={contentStyle}>
                        @if (resizable) {
                            <div class="lotus-sidebar-container-resize-handle" onMouseDown={handleResizeHandleDown} />
                        }
                        <div class="lotus-sidebar-container-inner" onTransitionEnd={handleContentTransitionEnd}>
                            <div class="lotus-sidebar-container-header-slot">{header}</div>
                            @if (!hasHeader) {
                                <div class="lotus-sidebar-container-header">
                                    <div class="lotus-sidebar-container-title">{title}</div>
                                    @if (showClose) {
                                        <button type="button" class="lotus-sidebar-container-close" aria-label={locale.Sidebar.close} onClick={handleCancel}>
                                            <IconClose />
                                        </button>
                                    }
                                </div>
                            }
                            <div class="lotus-sidebar-container-body">
                                {children}
                            </div>
                        </div>
                    </div>
                </div>
            </Portal>
        }

        <style>
            .lotus-sidebar-container-wrapper {
                position: fixed;
                inset: 0;
                pointer-events: none;
                z-index: var(--lotus-z-modal, 1000);
            }

            .lotus-sidebar-container {
                position: absolute;
                top: 0;
                inset-inline-end: 0;
                height: 100%;
                pointer-events: auto;
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
                opacity: 0;
                transition: transform 0.25s ease, opacity 0.25s ease;
            }

            .lotus-sidebar-container-visible {
                transform: translateX(0);
                opacity: 1;
            }

            .lotus-sidebar-container-resizing {
                transition: none;
                user-select: none;
            }

            .lotus-sidebar-container-resize-handle {
                position: absolute;
                top: 0;
                inset-inline-start: -3px;
                width: 6px;
                height: 100%;
                cursor: ew-resize;
                z-index: 1;
            }

            .lotus-sidebar-container-inner {
                display: flex;
                flex-direction: column;
                height: 100%;
            }

            .lotus-sidebar-container-header-slot:empty {
                display: none;
            }

            .lotus-sidebar-container-header {
                position: relative;
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: var(--lotus-spacing-base) var(--lotus-spacing-base-loose);
                flex-shrink: 0;
            }

            .lotus-sidebar-container-title {
                font-size: var(--lotus-font-h5-size);
                font-weight: 600;
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-container-close {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                border-radius: var(--lotus-border-radius-small);
                border: none;
                background: transparent;
                color: var(--lotus-color-text-2);
                cursor: pointer;
                flex-shrink: 0;
            }

            .lotus-sidebar-container-close:hover {
                background: var(--lotus-color-fill-0);
                color: var(--lotus-color-text-0);
            }

            .lotus-sidebar-container-body {
                flex: 1;
                overflow: auto;
                padding: 0 var(--lotus-spacing-base-loose) var(--lotus-spacing-base-loose);
            }
        </style>
    </>
}
