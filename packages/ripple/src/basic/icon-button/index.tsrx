import { track } from 'ripple';
import { ButtonFoundation } from '@lotus/foundation/basic/button';
import type { ButtonType, ButtonTheme, ButtonSize, ButtonHtmlType } from '../button/index.tsrx';

export type { ButtonType as IconButtonType, ButtonTheme as IconButtonTheme, ButtonSize as IconButtonSize };

export interface IconButtonProps {
    icon: any;
    type?: ButtonType;
    theme?: ButtonTheme;
    size?: ButtonSize;
    disabled?: boolean;
    loading?: boolean;
    htmlType?: ButtonHtmlType;
    onClick?: (event: MouseEvent) => void;
    'aria-label': string;
    style?: Record<string, any>;
    class?: string;
}

/** 复用 Button 的转圈 loading 图标实现，语义与视觉保持完全一致。 */
function SpinnerIcon() {
    return <svg viewBox="0 0 16 16" width="14" height="14" class="lotus-icon-button-spinner" aria-hidden={true}>
        <circle
            cx="8"
            cy="8"
            r="6.5"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-dasharray="28"
            stroke-dashoffset="10"
        />
    </svg>;
}

/**
 * IconButton：纯图标按钮，是 Button 的语义化封装（正方形、无 children、强制 aria-label）。
 * 不新建 Foundation——点击拦截逻辑与 Button 完全相同，直接复用 ButtonFoundation。
 */
export function IconButton(&{
    icon,
    type = 'primary',
    theme = 'borderless',
    size = 'default',
    disabled = false,
    loading = false,
    htmlType = 'button',
    onClick,
    'aria-label': ariaLabel,
    style,
    class: className,
}: IconButtonProps) @{
    // 直接实时读 prop（非函数字面量 track() 会在挂载时固化快照，disabled/loading
    // 运行时变化后 ButtonFoundation.handleClick 读到的判断依据会永远是挂载时刻
    // 的旧值——同一根因已在 Button 组件排查确认，详见 specs 踩坑 #94）。
    const foundation = new ButtonFoundation({
        getState: () => ({ disabled, loading }),
        setState: () => {},
    });

    let &[classes] = track<string>(() =>
        [
            'lotus-icon-button',
            `lotus-icon-button-${type}`,
            `lotus-icon-button-theme-${theme}`,
            `lotus-icon-button-size-${size}`,
            loading ? 'lotus-icon-button-loading' : '',
            disabled ? 'lotus-icon-button-disabled' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    <>
        <button
            type={htmlType}
            class={classes}
            style={style}
            disabled={disabled}
            aria-label={ariaLabel}
            aria-busy={loading}
            onClick={(event: MouseEvent) => foundation.handleClick(() => onClick?.(event))}
        >
            @if (loading) {
                <span class="lotus-icon-button-icon"><SpinnerIcon /></span>
            }
            @if (!loading) {
                <span class="lotus-icon-button-icon">{icon}</span>
            }
        </button>

        <style>
            .lotus-icon-button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                box-sizing: border-box;
                width: var(--lotus-height-control-default);
                height: var(--lotus-height-control-default);
                padding: 0;
                border: var(--lotus-border-width-control) solid transparent;
                border-radius: var(--lotus-border-radius-small);
                background: transparent;
                cursor: pointer;
                transition: background-color 0.2s ease, border-color 0.2s ease, color 0.2s ease;
            }

            .lotus-icon-button-size-large {
                width: var(--lotus-height-control-large);
                height: var(--lotus-height-control-large);
            }

            .lotus-icon-button-size-small {
                width: var(--lotus-height-control-small);
                height: var(--lotus-height-control-small);
            }

            .lotus-icon-button-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            /* ---- solid：实心背景，白字，語義色三態直接映射 hover/active ---- */
            .lotus-icon-button-theme-solid.lotus-icon-button-primary {
                background: var(--lotus-color-primary);
                color: #ffffff;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-primary:hover:not(:disabled) {
                background: var(--lotus-color-primary-hover);
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-primary:active:not(:disabled) {
                background: var(--lotus-color-primary-active);
            }

            .lotus-icon-button-theme-solid.lotus-icon-button-secondary {
                background: var(--lotus-color-secondary);
                color: #ffffff;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-secondary:hover:not(:disabled) {
                background: var(--lotus-color-secondary-hover);
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-secondary:active:not(:disabled) {
                background: var(--lotus-color-secondary-active);
            }

            .lotus-icon-button-theme-solid.lotus-icon-button-tertiary {
                background: var(--lotus-color-tertiary);
                color: #ffffff;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-tertiary:hover:not(:disabled) {
                background: var(--lotus-color-tertiary-hover);
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-tertiary:active:not(:disabled) {
                background: var(--lotus-color-tertiary-active);
            }

            .lotus-icon-button-theme-solid.lotus-icon-button-warning {
                background: var(--lotus-color-warning);
                color: #ffffff;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-warning:hover:not(:disabled) {
                background: var(--lotus-color-warning-hover);
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-warning:active:not(:disabled) {
                background: var(--lotus-color-warning-active);
            }

            .lotus-icon-button-theme-solid.lotus-icon-button-danger {
                background: var(--lotus-color-danger);
                color: #ffffff;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-danger:hover:not(:disabled) {
                background: var(--lotus-color-danger-hover);
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-danger:active:not(:disabled) {
                background: var(--lotus-color-danger-active);
            }

            /* ---- light：中性浅底 + 語義色文字 ---- */
            .lotus-icon-button-theme-light {
                background: var(--lotus-color-fill-0);
            }
            .lotus-icon-button-theme-light:hover:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-icon-button-theme-light:active:not(:disabled) {
                background: var(--lotus-color-fill-2);
            }
            .lotus-icon-button-theme-light.lotus-icon-button-primary { color: var(--lotus-color-primary); }
            .lotus-icon-button-theme-light.lotus-icon-button-secondary { color: var(--lotus-color-secondary); }
            .lotus-icon-button-theme-light.lotus-icon-button-tertiary { color: var(--lotus-color-tertiary); }
            .lotus-icon-button-theme-light.lotus-icon-button-warning { color: var(--lotus-color-warning); }
            .lotus-icon-button-theme-light.lotus-icon-button-danger { color: var(--lotus-color-danger); }

            /* ---- borderless：透明底 + 語義色文字，hover/active 借用中性 fill 阶梯 ---- */
            .lotus-icon-button-theme-borderless {
                background: transparent;
            }
            .lotus-icon-button-theme-borderless:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
            }
            .lotus-icon-button-theme-borderless:active:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-icon-button-theme-borderless.lotus-icon-button-primary { color: var(--lotus-color-primary); }
            .lotus-icon-button-theme-borderless.lotus-icon-button-secondary { color: var(--lotus-color-secondary); }
            .lotus-icon-button-theme-borderless.lotus-icon-button-tertiary { color: var(--lotus-color-tertiary); }
            .lotus-icon-button-theme-borderless.lotus-icon-button-warning { color: var(--lotus-color-warning); }
            .lotus-icon-button-theme-borderless.lotus-icon-button-danger { color: var(--lotus-color-danger); }

            /* ---- outline：透明底 + 語義色边框与文字 ---- */
            .lotus-icon-button-theme-outline {
                background: transparent;
            }
            .lotus-icon-button-theme-outline:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
            }
            .lotus-icon-button-theme-outline:active:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-icon-button-theme-outline.lotus-icon-button-primary { color: var(--lotus-color-primary); border-color: var(--lotus-color-border); }
            .lotus-icon-button-theme-outline.lotus-icon-button-secondary { color: var(--lotus-color-secondary); border-color: var(--lotus-color-secondary); }
            .lotus-icon-button-theme-outline.lotus-icon-button-tertiary { color: var(--lotus-color-tertiary); border-color: var(--lotus-color-border); }
            .lotus-icon-button-theme-outline.lotus-icon-button-warning { color: var(--lotus-color-warning); border-color: var(--lotus-color-warning); }
            .lotus-icon-button-theme-outline.lotus-icon-button-danger { color: var(--lotus-color-danger); border-color: var(--lotus-color-danger); }

            /* ---- disabled：统一读中性 disabled token ---- */
            .lotus-icon-button-disabled,
            .lotus-icon-button:disabled {
                cursor: not-allowed;
                color: var(--lotus-color-disabled-text);
                border-color: transparent;
            }
            .lotus-icon-button-theme-solid.lotus-icon-button-disabled,
            .lotus-icon-button-theme-solid:disabled {
                background: var(--lotus-color-disabled-bg);
            }
            .lotus-icon-button-theme-light.lotus-icon-button-disabled,
            .lotus-icon-button-theme-light:disabled {
                background: var(--lotus-color-fill-0);
            }
            .lotus-icon-button-theme-borderless.lotus-icon-button-disabled,
            .lotus-icon-button-theme-borderless:disabled,
            .lotus-icon-button-theme-outline.lotus-icon-button-disabled,
            .lotus-icon-button-theme-outline:disabled {
                background: transparent;
                border-color: var(--lotus-color-disabled-border);
            }

            .lotus-icon-button-loading {
                pointer-events: none;
                cursor: not-allowed;
            }

            .lotus-icon-button-spinner {
                animation: lotus-icon-button-spin 0.8s linear infinite;
            }

            @keyframes lotus-icon-button-spin {
                to {
                    transform: rotate(360deg);
                }
            }
        </style>
    </>
}
