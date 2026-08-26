import { mount, track } from 'ripple';
import { NotificationListFoundation, groupByPosition, type NotificationItem, type NotificationType, type NotificationPosition } from '@lotus/foundation/feedback/notification';
import { IconTickCircle, IconAlertTriangle, IconAlertCircle, IconInfoCircle, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { NotificationType, NotificationItem, NotificationPosition };

export interface NotificationOptions {
    content?: any;
    title?: any;
    id?: string;
    duration?: number;
    showClose?: boolean;
    icon?: any;
    position?: NotificationPosition;
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
}

/**
 * NotificationListRoot：命令式挂载的唯一渲染入口，结构对齐 Toast 的
 * ToastListRoot（同一套已验证的全局命令式 API 模式：track() 不能在
 * 模块顶层使用，组件内部创建状态 + 回调反向暴露更新函数）。核心差异
 * 是按 6 个 position 分组渲染，每个 position 一个独立定位容器。
 */
export function NotificationListRoot(&{ registerController }: NotificationListRootProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[list] = track<Array<NotificationItem>>([]);
    registerController((next: NotificationItem[]) => { list = next; });

    function handleClose(id: string) {
        notificationFoundation?.remove(id);
    }

    let &[groups] = track<Record<NotificationPosition, NotificationItem[]>>(() => groupByPosition(list));

    <>
        @for (const position of POSITIONS; index posIndex; key position) {
            @if (groups[position].length > 0) {
                <div class={`lotus-notification-wrapper lotus-notification-wrapper-${position}`}>
                    @for (const item of groups[position]; index i; key item.id) {
                        <div class={['lotus-notification', `lotus-notification-${item.type}`].filter(Boolean).join(' ')} role="alert">
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
                                <button type="button" class="lotus-notification-close" aria-label={locale.Notification.close} onClick={() => handleClose(item.id)}>
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

let mounted = false;
let unmountFn: (() => void) | null = null;
let pushUpdate: NotificationUpdateFn | null = null;
let notificationFoundation: NotificationListFoundation | null = null;

function ensureMounted(): void {
    if (mounted) return;
    const container = document.createElement('div');
    container.className = 'lotus-notification-root';
    document.body.appendChild(container);
    notificationFoundation = new NotificationListFoundation((list) => pushUpdate?.(list));
    unmountFn = mount(NotificationListRoot as any, {
        target: container,
        props: { registerController: (fn: NotificationUpdateFn) => { pushUpdate = fn; } },
    });
    mounted = true;
}

function open(type: NotificationType, opts: NotificationOptions): string {
    ensureMounted();
    const id = opts.id ?? nextId();
    notificationFoundation?.add({
        id,
        title: opts.title,
        content: opts.content,
        type,
        position: opts.position ?? 'topRight',
        duration: opts.duration ?? 3,
        showClose: opts.showClose ?? true,
        icon: opts.icon,
    });
    return id;
}

export const Notification = {
    open: (opts: NotificationOptions) => open('default', opts),
    info: (opts: NotificationOptions) => open('info', opts),
    success: (opts: NotificationOptions) => open('success', opts),
    warning: (opts: NotificationOptions) => open('warning', opts),
    error: (opts: NotificationOptions) => open('error', opts),
    close: (id: string) => notificationFoundation?.remove(id),
    destroyAll: () => {
        notificationFoundation?.destroyAll();
        if (unmountFn) {
            unmountFn();
            unmountFn = null;
            mounted = false;
            pushUpdate = null;
            notificationFoundation = null;
            document.querySelector('.lotus-notification-root')?.remove();
        }
    },
};
