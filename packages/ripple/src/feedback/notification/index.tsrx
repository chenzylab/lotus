import { mount, track } from 'ripple';
import { NotificationListFoundation, groupByPosition, type NotificationItem, type NotificationType, type NotificationPosition, type NotificationTheme, type NotificationGlobalConfig } from '@lotus/foundation/feedback/notification';
import { IconTickCircle, IconAlertTriangle, IconAlertCircle, IconInfoCircle, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { NotificationType, NotificationItem, NotificationPosition, NotificationTheme, NotificationGlobalConfig };

export interface NotificationOptions {
    content?: any;
    title?: any;
    id?: string;
    duration?: number;
    showClose?: boolean;
    icon?: any;
    position?: NotificationPosition;
    theme?: NotificationTheme;
    zIndex?: number;
    getPopupContainer?: () => HTMLElement;
    onClick?: (event: MouseEvent) => void;
    onClose?: () => void;
    onCloseClick?: (id: string) => void;
}

const DEFAULT_ICONS: Record<NotificationType, any> = {
    success: <IconTickCircle />,
    warning: <IconAlertTriangle />,
    error: <IconAlertCircle />,
    info: <IconInfoCircle />,
    default: <IconInfoCircle />,
};

const POSITIONS: NotificationPosition[] = ['top', 'bottom', 'topLeft', 'topRight', 'bottomLeft', 'bottomRight'];

let notificationIdCounter = 0;
function nextId(): string {
    return `lotus-notification-${++notificationIdCounter}`;
}

type NotificationUpdateFn = (list: NotificationItem[]) => void;

interface NotificationListRootProps {
    registerController: (fn: NotificationUpdateFn) => void;
    positionOverride: NotificationGlobalConfig;
    foundation: NotificationListFoundation;
}

function resolveWrapperStyle(position: NotificationPosition, zIndex: number | undefined, override: NotificationGlobalConfig): Record<string, any> {
    const style: Record<string, any> = {};
    if (zIndex !== undefined) style.zIndex = zIndex;
    const isLeftSide = position === 'topLeft' || position === 'bottomLeft';
    const isRightSide = position === 'topRight' || position === 'bottomRight';
    const isTopSide = position === 'top' || position === 'topLeft' || position === 'topRight';
    const isBottomSide = position === 'bottom' || position === 'bottomLeft' || position === 'bottomRight';
    if (isLeftSide && override.left !== undefined) style.left = override.left;
    if (isRightSide && override.right !== undefined) style.right = override.right;
    if (isTopSide && override.top !== undefined) style.top = override.top;
    if (isBottomSide && override.bottom !== undefined) style.bottom = override.bottom;
    return style;
}

/**
 * NotificationListRoot：命令式挂载的唯一渲染入口，结构对齐 Toast 的
 * ToastListRoot（同一套已验证的全局命令式 API 模式：track() 不能在
 * 模块顶层使用，组件内部创建状态 + 回调反向暴露更新函数）。核心差异
 * 是按 6 个 position 分组渲染，每个 position 一个独立定位容器。
 */
export function NotificationListRoot(&{ registerController, positionOverride, foundation }: NotificationListRootProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[list] = track<Array<NotificationItem>>([]);
    registerController((next: NotificationItem[]) => { list = next; });

    function handleCloseClick(id: string) {
        foundation.closeByClick(id);
    }

    let &[groups] = track<Record<NotificationPosition, NotificationItem[]>>(() => groupByPosition(list));

    <>
        @for (const position of POSITIONS; index posIndex; key position) {
            @if (groups[position].length > 0) {
                <div class={`lotus-notification-wrapper lotus-notification-wrapper-${position}`} style={resolveWrapperStyle(position, groups[position][0]?.zIndex, positionOverride)}>
                    @for (const item of groups[position]; index i; key item.id) {
                        <div
                            class={['lotus-notification', `lotus-notification-${item.type}`, `lotus-notification-theme-${item.theme}`].filter(Boolean).join(' ')}
                            role="alert"
                            onClick={(event: MouseEvent) => item.onClick?.(event)}
                        >
                            <span class="lotus-notification-icon">{item.icon ?? DEFAULT_ICONS[item.type]}</span>
                            <div class="lotus-notification-body">
                                @if (item.title) {
                                    <div class="lotus-notification-title">{item.title}</div>
                                }
                                @if (item.content) {
                                    <div class="lotus-notification-content">{item.content}</div>
                                }
                            </div>
                            @if (item.showClose) {
                                <button type="button" class="lotus-notification-close" aria-label={locale.Notification.close} onClick={(event: MouseEvent) => { event.stopPropagation(); handleCloseClick(item.id); }}>
                                    <IconClose />
                                </button>
                            }
                        </div>
                    }
                </div>
            }
        }

        <style>
            .lotus-notification-wrapper {
                position: fixed;
                z-index: var(--lotus-z-notification);
                display: flex;
                flex-direction: column;
                gap: var(--lotus-spacing-tight);
                width: 320px;
            }

            .lotus-notification-wrapper-topRight,
            .lotus-notification-wrapper-bottomRight {
                right: 24px;
                align-items: flex-end;
            }

            .lotus-notification-wrapper-topLeft,
            .lotus-notification-wrapper-bottomLeft {
                left: 24px;
                align-items: flex-start;
            }

            .lotus-notification-wrapper-top,
            .lotus-notification-wrapper-bottom {
                left: 50%;
                transform: translateX(-50%);
                align-items: center;
            }

            .lotus-notification-wrapper-top,
            .lotus-notification-wrapper-topLeft,
            .lotus-notification-wrapper-topRight {
                top: 24px;
            }

            .lotus-notification-wrapper-bottom,
            .lotus-notification-wrapper-bottomLeft,
            .lotus-notification-wrapper-bottomRight {
                bottom: 24px;
            }

            .lotus-notification {
                display: flex;
                align-items: flex-start;
                gap: 10px;
                width: 100%;
                padding: 14px 16px;
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
                box-sizing: border-box;
            }

            .lotus-notification-icon {
                display: flex;
                align-items: center;
                flex-shrink: 0;
                margin-top: 2px;
                font-size: 20px;
            }

            .lotus-notification-success .lotus-notification-icon { color: var(--lotus-color-success); }
            .lotus-notification-warning .lotus-notification-icon { color: var(--lotus-color-warning); }
            .lotus-notification-error .lotus-notification-icon { color: var(--lotus-color-danger); }
            .lotus-notification-info .lotus-notification-icon,
            .lotus-notification-default .lotus-notification-icon { color: var(--lotus-color-primary); }

            /* ---- theme=light：各语义色浅底 + 同色边框（对齐 Semi） ---- */
            .lotus-notification-theme-light.lotus-notification-success {
                background: var(--lotus-color-success-light-default);
                border: 1px solid var(--lotus-color-success);
            }
            .lotus-notification-theme-light.lotus-notification-warning {
                background: var(--lotus-color-warning-light-default);
                border: 1px solid var(--lotus-color-warning);
            }
            .lotus-notification-theme-light.lotus-notification-error {
                background: var(--lotus-color-danger-light-default);
                border: 1px solid var(--lotus-color-danger);
            }
            .lotus-notification-theme-light.lotus-notification-info,
            .lotus-notification-theme-light.lotus-notification-default {
                background: var(--lotus-color-info-light-default);
                border: 1px solid var(--lotus-color-primary);
            }

            .lotus-notification-body {
                flex: 1;
                min-width: 0;
                display: flex;
                flex-direction: column;
                gap: 4px;
            }

            .lotus-notification-title {
                font-size: var(--lotus-font-body-size);
                font-weight: var(--lotus-font-weight-semibold);
                color: var(--lotus-color-text-0);
            }

            .lotus-notification-content {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-notification-close {
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                width: 20px;
                height: 20px;
                padding: 0;
                border: none;
                background: transparent;
                color: var(--lotus-color-text-1);
                cursor: pointer;
            }
        </style>
    </>
}

interface NotificationMountEntry {
    unmountFn: () => void;
    pushUpdate: NotificationUpdateFn | null;
    foundation: NotificationListFoundation;
    container: HTMLElement;
}

// getPopupContainer 不同的调用方各自独立挂载一套渲染 root，key 用容器元素
// 本身（document.body 场景下 Map 只会有一个 entry，与之前全局单例行为一致）。
const mounts = new Map<HTMLElement, NotificationMountEntry>();
let globalConfig: NotificationGlobalConfig = {};
// 按 id 记录该通知挂载在哪个 entry，close()/handleClose 需要据此定位 foundation。
const idToContainer = new Map<string, HTMLElement>();

function ensureMounted(getPopupContainer?: () => HTMLElement): NotificationMountEntry {
    const parent = getPopupContainer?.() ?? document.body;
    const existing = mounts.get(parent);
    if (existing) return existing;

    const container = document.createElement('div');
    container.className = 'lotus-notification-root';
    parent.appendChild(container);
    let pushUpdate: NotificationUpdateFn | null = null;
    const foundation = new NotificationListFoundation((list) => pushUpdate?.(list));
    const unmountFn = mount(NotificationListRoot as any, {
        target: container,
        props: {
            registerController: (fn: NotificationUpdateFn) => { pushUpdate = fn; },
            positionOverride: globalConfig,
            foundation,
        },
    });
    const entry: NotificationMountEntry = { unmountFn, pushUpdate, foundation, container };
    mounts.set(parent, entry);
    return entry;
}

function open(type: NotificationType, opts: NotificationOptions): string {
    const entry = ensureMounted(opts.getPopupContainer);
    const id = opts.id ?? nextId();
    idToContainer.set(id, entry.container.parentElement ?? document.body);
    entry.foundation.add({
        id,
        title: opts.title,
        content: opts.content,
        type,
        position: opts.position ?? globalConfig.position ?? 'topRight',
        duration: opts.duration ?? globalConfig.duration ?? 3,
        showClose: opts.showClose ?? true,
        icon: opts.icon,
        theme: opts.theme ?? 'normal',
        zIndex: opts.zIndex ?? globalConfig.zIndex,
        onClick: opts.onClick,
        onClose: opts.onClose,
        onCloseClick: opts.onCloseClick,
    });
    return id;
}

function findFoundationById(id: string): NotificationListFoundation | undefined {
    const parent = idToContainer.get(id);
    if (!parent) return undefined;
    for (const entry of mounts.values()) {
        if (entry.container.parentElement === parent) return entry.foundation;
    }
    return undefined;
}

export const Notification = {
    open: (opts: NotificationOptions) => open('default', opts),
    info: (opts: NotificationOptions) => open('info', opts),
    success: (opts: NotificationOptions) => open('success', opts),
    warning: (opts: NotificationOptions) => open('warning', opts),
    error: (opts: NotificationOptions) => open('error', opts),
    close: (id: string) => { findFoundationById(id)?.remove(id); idToContainer.delete(id); },
    /** 全局默认配置，未来 open() 调用若未显式指定对应字段则回退到这里（对齐 Semi `Notification.config`）。 */
    config: (config: NotificationGlobalConfig) => { globalConfig = { ...globalConfig, ...config }; },
    destroyAll: () => {
        for (const entry of mounts.values()) {
            entry.foundation.destroyAll();
            entry.unmountFn();
            entry.container.remove();
        }
        mounts.clear();
        idToContainer.clear();
    },
};
