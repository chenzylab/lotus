import { track } from 'ripple';
import { ButtonFoundation } from '@lotus/foundation/basic/button';

export type ButtonType = 'primary' | 'secondary' | 'tertiary' | 'warning' | 'danger';
export type ButtonTheme = 'solid' | 'borderless' | 'light' | 'outline';
export type ButtonSize = 'large' | 'default' | 'small';
export type ButtonIconPosition = 'left' | 'right';
export type ButtonHtmlType = 'button' | 'reset' | 'submit';

export interface ButtonProps {
    children?: any;
    type?: ButtonType;
    theme?: ButtonTheme;
    size?: ButtonSize;
    icon?: any;
    iconPosition?: ButtonIconPosition;
    block?: boolean;
    disabled?: boolean;
    loading?: boolean;
    htmlType?: ButtonHtmlType;
    onClick?: (event: MouseEvent) => void;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

/** 转圈 loading 图标：配合 `stroke-dasharray`/`stroke-dashoffset` + CSS `rotate` 动画实现
 *  圆环转圈效果，与 `@lotus/icons` 的 `IconSpin`（静态多彩风车图标，无环形描边、非转圈语义）
 *  设计意图不同，不能等价替换，保留内联实现。 */
function SpinnerIcon() {
    return <svg viewBox="0 0 16 16" width="14" height="14" class="lotus-button-spinner" aria-hidden={true}>
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

export function Button(&{
    children,
    type = 'primary',
    theme = 'light',
    size = 'default',
    icon,
    iconPosition = 'left',
    block = false,
    disabled = false,
    loading = false,
    htmlType = 'button',
    onClick,
    'aria-label': ariaLabel,
    style,
    class: className,
}: ButtonProps) @{
    const foundation = new ButtonFoundation({
        getState: () => ({ disabled, loading }),
        setState: () => {},
    });

    const isIconOnly = !!icon && !children;

    // classes 必须是派生 track——loading/disabled 由外部 props 直接读取本身是安全的
    // （见 specs/cross-cutting/foundation-adapter-pattern.md 关于"只读 props 的 const 安全"
    // 的判断准则），但此处仍用派生 track 是因为该判断准则本身依赖 props 不含内部 track 状态；
    // Button 无内部可变 UI 状态，class 实际上不会响应式变化，用 const 也可以，这里统一用
    // track 只是与 Switch/Tag/Tabs 保持写法一致，便于未来若引入内部状态时不必重构。
    let &[classes] = track<string>(() =>
        [
            'lotus-button',
            `lotus-button-${type}`,
            `lotus-button-theme-${theme}`,
            `lotus-button-size-${size}`,
            block ? 'lotus-button-block' : '',
            isIconOnly ? 'lotus-button-icon-only' : '',
            loading ? 'lotus-button-loading' : '',
            disabled ? 'lotus-button-disabled' : '',
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
                <span class="lotus-button-icon lotus-button-icon-left"><SpinnerIcon /></span>
            } @else {
                @if (icon && iconPosition === 'left') {
                    <span class="lotus-button-icon lotus-button-icon-left">{icon}</span>
                }
            }
            @if (children) {
                <span class="lotus-button-content">{children}</span>
            }
            @if (!loading && icon && iconPosition === 'right') {
                <span class="lotus-button-icon lotus-button-icon-right">{icon}</span>
            }
        </button>

        <style>
            .lotus-button {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                box-sizing: border-box;
                height: var(--lotus-height-control-default);
                padding: 0 var(--lotus-spacing-base);
                border: var(--lotus-border-width-control) solid transparent;
                border-radius: var(--lotus-border-radius-small);
                background: transparent;
                font-family: var(--lotus-font-family);
                font-size: var(--lotus-font-body-size);
                font-weight: var(--lotus-font-weight-semibold);
                line-height: 1;
                white-space: nowrap;
                cursor: pointer;
                transition: background-color 0.2s ease, border-color 0.2s ease, color 0.2s ease;
            }

            .lotus-button-size-large {
                height: var(--lotus-height-control-large);
                padding: 0 var(--lotus-spacing-base);
                font-size: var(--lotus-font-body-size);
            }

            .lotus-button-size-small {
                height: var(--lotus-height-control-small);
                padding: 0 var(--lotus-spacing-tight);
                font-size: var(--lotus-font-label-size);
            }

            .lotus-button-block {
                display: flex;
                width: 100%;
            }

            .lotus-button-icon-only {
                gap: 0;
                padding: 0;
                width: var(--lotus-height-control-default);
            }

            .lotus-button-icon-only.lotus-button-size-large {
                width: var(--lotus-height-control-large);
            }

            .lotus-button-icon-only.lotus-button-size-small {
                width: var(--lotus-height-control-small);
            }

            .lotus-button-icon {
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            /* ---- solid：实心背景，白字，語義色三態直接映射 hover/active ---- */
            .lotus-button-theme-solid.lotus-button-primary {
                background: var(--lotus-color-primary);
                color: #ffffff;
            }
            .lotus-button-theme-solid.lotus-button-primary:hover:not(:disabled) {
                background: var(--lotus-color-primary-hover);
            }
            .lotus-button-theme-solid.lotus-button-primary:active:not(:disabled) {
                background: var(--lotus-color-primary-active);
            }

            .lotus-button-theme-solid.lotus-button-secondary {
                background: var(--lotus-color-secondary);
                color: #ffffff;
            }
            .lotus-button-theme-solid.lotus-button-secondary:hover:not(:disabled) {
                background: var(--lotus-color-secondary-hover);
            }
            .lotus-button-theme-solid.lotus-button-secondary:active:not(:disabled) {
                background: var(--lotus-color-secondary-active);
            }

            .lotus-button-theme-solid.lotus-button-tertiary {
                background: var(--lotus-color-tertiary);
                color: #ffffff;
            }
            .lotus-button-theme-solid.lotus-button-tertiary:hover:not(:disabled) {
                background: var(--lotus-color-tertiary-hover);
            }
            .lotus-button-theme-solid.lotus-button-tertiary:active:not(:disabled) {
                background: var(--lotus-color-tertiary-active);
            }

            .lotus-button-theme-solid.lotus-button-warning {
                background: var(--lotus-color-warning);
                color: #ffffff;
            }
            .lotus-button-theme-solid.lotus-button-warning:hover:not(:disabled) {
                background: var(--lotus-color-warning-hover);
            }
            .lotus-button-theme-solid.lotus-button-warning:active:not(:disabled) {
                background: var(--lotus-color-warning-active);
            }

            .lotus-button-theme-solid.lotus-button-danger {
                background: var(--lotus-color-danger);
                color: #ffffff;
            }
            .lotus-button-theme-solid.lotus-button-danger:hover:not(:disabled) {
                background: var(--lotus-color-danger-hover);
            }
            .lotus-button-theme-solid.lotus-button-danger:active:not(:disabled) {
                background: var(--lotus-color-danger-active);
            }

            /* ---- light：中性浅底 + 語義色文字，背景与 type 无关，仅取 fill 阶梯 ---- */
            .lotus-button-theme-light {
                background: var(--lotus-color-fill-0);
            }
            .lotus-button-theme-light:hover:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-button-theme-light:active:not(:disabled) {
                background: var(--lotus-color-fill-2);
            }
            .lotus-button-theme-light.lotus-button-primary { color: var(--lotus-color-primary); }
            .lotus-button-theme-light.lotus-button-secondary { color: var(--lotus-color-secondary); }
            .lotus-button-theme-light.lotus-button-tertiary { color: var(--lotus-color-tertiary); }
            .lotus-button-theme-light.lotus-button-warning { color: var(--lotus-color-warning); }
            .lotus-button-theme-light.lotus-button-danger { color: var(--lotus-color-danger); }

            /* ---- borderless：透明底 + 語義色文字，hover/active 借用中性 fill 阶梯 ---- */
            .lotus-button-theme-borderless {
                background: transparent;
            }
            .lotus-button-theme-borderless:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
            }
            .lotus-button-theme-borderless:active:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-button-theme-borderless.lotus-button-primary { color: var(--lotus-color-primary); }
            .lotus-button-theme-borderless.lotus-button-secondary { color: var(--lotus-color-secondary); }
            .lotus-button-theme-borderless.lotus-button-tertiary { color: var(--lotus-color-tertiary); }
            .lotus-button-theme-borderless.lotus-button-warning { color: var(--lotus-color-warning); }
            .lotus-button-theme-borderless.lotus-button-danger { color: var(--lotus-color-danger); }

            /* ---- outline：透明底 + 語義色边框与文字，hover/active 借用中性 fill 阶梯 ---- */
            .lotus-button-theme-outline {
                background: transparent;
            }
            .lotus-button-theme-outline:hover:not(:disabled) {
                background: var(--lotus-color-fill-0);
            }
            .lotus-button-theme-outline:active:not(:disabled) {
                background: var(--lotus-color-fill-1);
            }
            .lotus-button-theme-outline.lotus-button-primary { color: var(--lotus-color-primary); border-color: var(--lotus-color-border); }
            .lotus-button-theme-outline.lotus-button-secondary { color: var(--lotus-color-secondary); border-color: var(--lotus-color-secondary); }
            .lotus-button-theme-outline.lotus-button-tertiary { color: var(--lotus-color-tertiary); border-color: var(--lotus-color-border); }
            .lotus-button-theme-outline.lotus-button-warning { color: var(--lotus-color-warning); border-color: var(--lotus-color-warning); }
            .lotus-button-theme-outline.lotus-button-danger { color: var(--lotus-color-danger); border-color: var(--lotus-color-danger); }

            /* ---- disabled：统一读中性 disabled token，与 type/theme 无关（light 主题背景例外沿用浅底） ---- */
            .lotus-button-disabled,
            .lotus-button:disabled {
                cursor: not-allowed;
                color: var(--lotus-color-disabled-text);
                border-color: transparent;
            }
            .lotus-button-theme-solid.lotus-button-disabled,
            .lotus-button-theme-solid:disabled {
                background: var(--lotus-color-disabled-bg);
            }
            .lotus-button-theme-light.lotus-button-disabled,
            .lotus-button-theme-light:disabled {
                background: var(--lotus-color-fill-0);
            }
            .lotus-button-theme-borderless.lotus-button-disabled,
            .lotus-button-theme-borderless:disabled,
            .lotus-button-theme-outline.lotus-button-disabled,
            .lotus-button-theme-outline:disabled {
                background: transparent;
                border-color: var(--lotus-color-disabled-border);
            }

            .lotus-button-loading {
                pointer-events: none;
                cursor: not-allowed;
            }

            .lotus-button-spinner {
                animation: lotus-button-spin 0.8s linear infinite;
            }

            @keyframes lotus-button-spin {
                to {
                    transform: rotate(360deg);
                }
            }
        </style>
    </>
}

export interface ButtonGroupProps {
    children?: any;
    'aria-label'?: string;
    style?: Record<string, any>;
    class?: string;
}

/**
 * 按钮组：仅提供视觉分组容器（相邻按钮方形拼接、圆角只保留两端）。
 * Semi 的 ButtonGroup 靠 React.cloneElement 把 disabled/size/theme 强制注入每个子 Button——
 * Ripple 没有 children 反射/克隆能力，做不到这种"父层批量下发 props"，因此 lotus 版
 * ButtonGroup 退化为纯 CSS 容器：size/disabled/theme 等仍需在每个子 Button 上显式设置，
 * 这是在 Ripple 约束下的诚实设计取舍，而非简化阉割。
 */
export function ButtonGroup(&{ children, 'aria-label': ariaLabel, style, class: className }: ButtonGroupProps) @{
    const classes = ['lotus-button-group', className ?? ''].filter(Boolean).join(' ');

    <>
        <div class={classes} style={style} role="group" aria-label={ariaLabel}>
            {children}
        </div>

        <style>
            .lotus-button-group {
                display: inline-flex;
            }

            .lotus-button-group :global(.lotus-button) {
                border-radius: 0;
            }

            .lotus-button-group :global(.lotus-button:not(:last-child)) {
                border-right-width: 0;
            }

            .lotus-button-group :global(.lotus-button-theme-outline:not(:last-child)) {
                margin-right: -1px;
                border-right-width: var(--lotus-border-width-control);
            }

            .lotus-button-group :global(.lotus-button:first-child) {
                border-top-left-radius: var(--lotus-border-radius-small);
                border-bottom-left-radius: var(--lotus-border-radius-small);
            }

            .lotus-button-group :global(.lotus-button:last-child) {
                border-top-right-radius: var(--lotus-border-radius-small);
                border-bottom-right-radius: var(--lotus-border-radius-small);
                border-right-width: var(--lotus-border-width-control);
            }
        </style>
    </>
}
