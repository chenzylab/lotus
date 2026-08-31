import { mount, track } from 'ripple';
import { ToastListFoundation, type ToastItem, type ToastType, type ToastTheme, type ToastGlobalConfig } from '@lotus/foundation/feedback/toast';
import { IconTickCircle, IconAlertTriangle, IconAlertCircle, IconInfoCircle, IconClose } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { ToastType, ToastItem, ToastTheme, ToastGlobalConfig };

export interface ToastOptions {
    content: any;
    id?: string;
    duration?: number;
    showClose?: boolean;
    icon?: any;
    stack?: boolean;
    theme?: ToastTheme;
    textMaxWidth?: number | string;
    zIndex?: number;
    top?: number | string;
    bottom?: number | string;
    left?: number | string;
    right?: number | string;
    getPopupContainer?: () => HTMLElement;
    onClose?: () => void;
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
type ToastConfigUpdateFn = (config: ToastGlobalConfig) => void;

interface ToastListRootProps {
    registerController: (fn: ToastUpdateFn) => void;
    registerConfigController: (fn: ToastConfigUpdateFn) => void;
    initialConfig: ToastGlobalConfig;
    foundation: ToastListFoundation;
}

interface ToastMountEntry {
    unmountFn: () => void;
    foundation: ToastListFoundation;
    container: HTMLElement;
}

// getPopupContainer 不同的调用方各自独立挂载一套渲染 root，与 Notification
// 同一套架构（Map<HTMLElement, entry>）；document.body 场景下只会有一个 entry，
// 与之前的全局单例行为一致。
const mounts = new Map<HTMLElement, ToastMountEntry>();
let globalConfig: ToastGlobalConfig = {};
const idToContainer = new Map<string, HTMLElement>();
// 每个已挂载 root 的配置更新函数——存函数引用本身而非塞进 entry 对象属性，
// 后者会在 mount() 尚未同步执行完 registerConfigController 前就拷贝走
// 当时仍是 null 的值（对齐 pushUpdate 现有模式：闭包变量才是唯一可信来源）。
const configSetters = new Set<ToastConfigUpdateFn>();

/** Toast.config() 之后，把最新配置实时推送给所有已挂载的 root（对齐 Semi
 * 每次 render 都重新读配置的天然响应式行为——lotus 命令式单例架构下，
 * 已挂载的 props 是一次性快照，需要这条通道才能不重新挂载也生效）。 */
function broadcastConfig(): void {
    for (const setter of configSetters) setter(globalConfig);
}

function resolveWrapperStyle(override: ToastGlobalConfig): Record<string, any> {
    const style: Record<string, any> = {};
    if (override.top !== undefined) style.top = override.top;
    if (override.bottom !== undefined) { style.bottom = override.bottom; style.top = 'auto'; }
    if (override.left !== undefined) { style.left = override.left; style.transform = 'none'; }
    if (override.right !== undefined) { style.right = override.right; style.left = 'auto'; style.transform = 'none'; }
    if (override.zIndex !== undefined) style.zIndex = override.zIndex;
    return style;
}

/**
 * ToastListRoot：命令式挂载的唯一渲染入口，内部创建 track() 状态，
 * 通过 registerController 回调把"更新函数"反向暴露给模块作用域——
 * track() 不能在模块顶层直接使用，这是已验证可行的全局命令式 API 模式
 * （见 specs/cross-cutting/foundation-adapter-pattern.md 的验证记录）。
 */
export function ToastListRoot(&{ registerController, registerConfigController, initialConfig, foundation }: ToastListRootProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[list] = track<Array<ToastItem>>([]);
    let &[stackHovered] = track<boolean>(false);
    let &[config] = track<ToastGlobalConfig>(initialConfig);
    registerController((next: ToastItem[]) => { list = next; });
    registerConfigController((next: ToastGlobalConfig) => { config = next; });

    function handleClose(id: string) {
        foundation.remove(id);
    }

    let &[hasStack] = track<boolean>(() => list.some((item) => item.stack));
    let &[classes] = track<string>(() =>
        ['lotus-toast-wrapper', stackHovered ? 'lotus-toast-wrapper-expanded' : ''].filter(Boolean).join(' '),
    );

    <>
        <div
            class={classes}
            style={resolveWrapperStyle(config)}
            onMouseEnter={() => { stackHovered = true; }}
            onMouseLeave={() => { stackHovered = false; }}
        >
            @for (const item of list; index i; key item.id) {
                <div
                    class={[
                        'lotus-toast',
                        `lotus-toast-${item.type}`,
                        `lotus-toast-theme-${item.theme}`,
                        hasStack && !stackHovered && i < list.length - 1 ? 'lotus-toast-collapsed' : '',
                    ].filter(Boolean).join(' ')}
                    style={{ '--lotus-toast-stack-depth': `${list.length - 1 - i}`, maxWidth: typeof item.textMaxWidth === 'number' ? `${item.textMaxWidth}px` : (item.textMaxWidth ?? '') }}
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

            /* ---- theme=light：各语义色浅底 + 同色边框（对齐 Semi，与 Notification 同一处理） ---- */
            .lotus-toast-theme-light.lotus-toast-success {
                background: var(--lotus-color-success-light-default);
                border: 1px solid var(--lotus-color-success);
            }
            .lotus-toast-theme-light.lotus-toast-warning {
                background: var(--lotus-color-warning-light-default);
                border: 1px solid var(--lotus-color-warning);
            }
            .lotus-toast-theme-light.lotus-toast-error {
                background: var(--lotus-color-danger-light-default);
                border: 1px solid var(--lotus-color-danger);
            }
            .lotus-toast-theme-light.lotus-toast-info,
            .lotus-toast-theme-light.lotus-toast-default {
                background: var(--lotus-color-info-light-default);
                border: 1px solid var(--lotus-color-primary);
            }

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

function ensureMounted(getPopupContainer?: () => HTMLElement): ToastMountEntry {
    const parent = getPopupContainer?.() ?? document.body;
    const existing = mounts.get(parent);
    if (existing) return existing;

    const container = document.createElement('div');
    container.className = 'lotus-toast-root';
    parent.appendChild(container);
    let pushUpdate: ToastUpdateFn | null = null;
    const foundation = new ToastListFoundation((list) => pushUpdate?.(list));
    const unmountFn = mount(ToastListRoot as any, {
        target: container,
        props: {
            registerController: (fn: ToastUpdateFn) => { pushUpdate = fn; },
            registerConfigController: (fn: ToastConfigUpdateFn) => { configSetters.add(fn); },
            initialConfig: globalConfig,
            foundation,
        },
    });
    const entry: ToastMountEntry = { unmountFn, foundation, container };
    mounts.set(parent, entry);
    return entry;
}

function open(type: ToastType, opts: ToastOptions | string): string {
    const resolved: ToastOptions = typeof opts === 'string' ? { content: opts } : opts;
    // Semi 文档："Toast Options 支持以下 API 及 Config 中的 API"——位置/zIndex
    // 这类字段在单次调用里传入时，等价于临时更新一次全局配置（因为所有 Toast
    // 共享同一个 wrapper 容器，不存在"每条各自独立位置"的概念）。
    const positionOverride: ToastGlobalConfig = {};
    if (resolved.top !== undefined) positionOverride.top = resolved.top;
    if (resolved.bottom !== undefined) positionOverride.bottom = resolved.bottom;
    if (resolved.left !== undefined) positionOverride.left = resolved.left;
    if (resolved.right !== undefined) positionOverride.right = resolved.right;
    if (resolved.zIndex !== undefined) positionOverride.zIndex = resolved.zIndex;
    if (Object.keys(positionOverride).length > 0) {
        globalConfig = { ...globalConfig, ...positionOverride };
        broadcastConfig();
    }

    const entry = ensureMounted(resolved.getPopupContainer);
    const id = resolved.id ?? nextId();
    idToContainer.set(id, entry.container.parentElement ?? document.body);
    entry.foundation.add({
        id,
        content: resolved.content,
        type,
        duration: resolved.duration ?? globalConfig.duration ?? 3,
        showClose: resolved.showClose ?? false,
        icon: resolved.icon,
        stack: resolved.stack ?? false,
        theme: resolved.theme ?? globalConfig.theme ?? 'normal',
        textMaxWidth: resolved.textMaxWidth,
        onClose: resolved.onClose,
    });
    return id;
}

function findToastFoundationById(id: string): ToastListFoundation | undefined {
    const parent = idToContainer.get(id);
    if (!parent) return undefined;
    for (const entry of mounts.values()) {
        if (entry.container.parentElement === parent) return entry.foundation;
    }
    return undefined;
}

export const Toast = {
    info: (opts: ToastOptions | string) => open('info', opts),
    success: (opts: ToastOptions | string) => open('success', opts),
    warning: (opts: ToastOptions | string) => open('warning', opts),
    error: (opts: ToastOptions | string) => open('error', opts),
    close: (id: string) => { findToastFoundationById(id)?.remove(id); idToContainer.delete(id); },
    /** 全局默认配置，未来 open() 调用若未显式指定对应字段则回退到这里（对齐 Semi `Toast.config`）。
     * 已挂载的容器也会实时更新（broadcastConfig），不需要 destroyAll() 重新挂载才生效。 */
    config: (config: ToastGlobalConfig) => { globalConfig = { ...globalConfig, ...config }; broadcastConfig(); },
    destroyAll: () => {
        for (const entry of mounts.values()) {
            entry.foundation.destroyAll();
            entry.unmountFn();
            entry.container.remove();
        }
        mounts.clear();
        idToContainer.clear();
        configSetters.clear();
    },
};
