import { mount, track } from 'ripple';
import { ToastListFoundation, type ToastItem, type ToastType } from '@lotus/foundation/feedback/toast';
import { IconTickCircle, IconAlertTriangle, IconAlertCircle, IconInfoCircle, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ToastType, ToastItem };

export interface ToastOptions {
    content: any;
    id?: string;
    duration?: number;
    showClose?: boolean;
    icon?: any;
    stack?: boolean;
}

const DEFAULT_ICONS: Record<ToastType, any> = {
    success: <IconTickCircle />,
    warning: <IconAlertTriangle />,
    error: <IconAlertCircle />,
    info: <IconInfoCircle />,
    default: <IconInfoCircle />,
};

let toastIdCounter = 0;
function nextId(): string {
    return `lotus-toast-${++toastIdCounter}`;
}

type ToastUpdateFn = (list: ToastItem[]) => void;

interface ToastListRootProps {
    registerController: (fn: ToastUpdateFn) => void;
}

let mounted = false;
let unmountFn: (() => void) | null = null;
let pushUpdate: ToastUpdateFn | null = null;
let toastFoundation: ToastListFoundation | null = null;

/**
 * ToastListRoot：命令式挂载的唯一渲染入口，内部创建 track() 状态，
 * 通过 registerController 回调把"更新函数"反向暴露给模块作用域——
 * track() 不能在模块顶层直接使用，这是已验证可行的全局命令式 API 模式
 * （见 specs/cross-cutting/foundation-adapter-pattern.md 的验证记录）。
 */
export function ToastListRoot(&{ registerController }: ToastListRootProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[list] = track<Array<ToastItem>>([]);
    let &[stackHovered] = track<boolean>(false);
    registerController((next: ToastItem[]) => { list = next; });

    function handleClose(id: string) {
        toastFoundation?.remove(id);
    }

    let &[hasStack] = track<boolean>(() => list.some((item) => item.stack));
    let &[classes] = track<string>(() =>
        ['lotus-toast-wrapper', stackHovered ? 'lotus-toast-wrapper-expanded' : ''].filter(Boolean).join(' '),
    );

    <>
        <div
            class={classes}
            onMouseEnter={() => { stackHovered = true; }}
            onMouseLeave={() => { stackHovered = false; }}
        >
            @for (const item of list; index i; key item.id) {
                <div
                    class={[
                        'lotus-toast',
                        `lotus-toast-${item.type}`,
                        hasStack && !stackHovered && i < list.length - 1 ? 'lotus-toast-collapsed' : '',
                    ].filter(Boolean).join(' ')}
                    style={{ '--lotus-toast-stack-depth': `${list.length - 1 - i}` }}
                    role="alert"
                >
                    <span class="lotus-toast-icon">{item.icon ?? DEFAULT_ICONS[item.type]}</span>
                    <div class="lotus-toast-content">{item.content}</div>
                    @if (item.showClose) {
                        <button type="button" class="lotus-toast-close" aria-label={locale.Toast.close} onClick={() => handleClose(item.id)}>
                            <IconClose />
                        </button>
                    }
                </div>
            }
        </div>

        <style>
            .lotus-toast-wrapper {
                position: fixed;
                top: 24px;
                left: 50%;
                transform: translateX(-50%);
                z-index: var(--lotus-z-toast);
                display: flex;
                flex-direction: column;
                gap: var(--lotus-spacing-tight);
                align-items: center;
            }

            .lotus-toast {
                display: flex;
                align-items: center;
                gap: 8px;
                min-width: 280px;
                max-width: 480px;
                padding: 12px 16px;
                border-radius: var(--lotus-border-radius-medium);
                background: var(--lotus-color-bg-1);
                box-shadow: var(--lotus-shadow-elevated);
                transition: transform 0.2s ease, opacity 0.2s ease, margin-top 0.2s ease;
            }

            /* stack 折叠态：非最新的通知向上叠放收拢（层叠深度越大偏移越多、
               略微缩小并降低透明度），hover 容器时展开（见 .lotus-toast-wrapper-expanded 重置）。 */
            .lotus-toast-collapsed {
                margin-top: calc(var(--lotus-toast-stack-depth, 0) * -44px);
                transform: scale(calc(1 - var(--lotus-toast-stack-depth, 0) * 0.05));
                opacity: calc(1 - var(--lotus-toast-stack-depth, 0) * 0.15);
            }

            .lotus-toast-wrapper-expanded .lotus-toast-collapsed {
                margin-top: 0;
                transform: none;
                opacity: 1;
            }

            .lotus-toast-icon {
                display: flex;
                align-items: center;
                flex-shrink: 0;
                font-size: 18px;
            }

            .lotus-toast-success .lotus-toast-icon { color: var(--lotus-color-success); }
            .lotus-toast-warning .lotus-toast-icon { color: var(--lotus-color-warning); }
            .lotus-toast-error .lotus-toast-icon { color: var(--lotus-color-danger); }
            .lotus-toast-info .lotus-toast-icon,
            .lotus-toast-default .lotus-toast-icon { color: var(--lotus-color-primary); }

            .lotus-toast-content {
                flex: 1;
                min-width: 0;
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-0);
            }

            .lotus-toast-close {
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

function ensureMounted(): void {
    if (mounted) return;
    const container = document.createElement('div');
    container.className = 'lotus-toast-root';
    document.body.appendChild(container);
    toastFoundation = new ToastListFoundation((list) => pushUpdate?.(list));
    unmountFn = mount(ToastListRoot as any, {
        target: container,
        props: { registerController: (fn: ToastUpdateFn) => { pushUpdate = fn; } },
    });
    mounted = true;
}

function open(type: ToastType, opts: ToastOptions | string): string {
    ensureMounted();
    const resolved: ToastOptions = typeof opts === 'string' ? { content: opts } : opts;
    const id = resolved.id ?? nextId();
    toastFoundation?.add({
        id,
        content: resolved.content,
        type,
        duration: resolved.duration ?? 3,
        showClose: resolved.showClose ?? false,
        icon: resolved.icon,
        stack: resolved.stack ?? false,
    });
    return id;
}

export const Toast = {
    info: (opts: ToastOptions | string) => open('info', opts),
    success: (opts: ToastOptions | string) => open('success', opts),
    warning: (opts: ToastOptions | string) => open('warning', opts),
    error: (opts: ToastOptions | string) => open('error', opts),
    close: (id: string) => toastFoundation?.remove(id),
    destroyAll: () => {
        toastFoundation?.destroyAll();
        if (unmountFn) {
            unmountFn();
            unmountFn = null;
            mounted = false;
            pushUpdate = null;
            toastFoundation = null;
            document.querySelector('.lotus-toast-root')?.remove();
        }
    },
};
