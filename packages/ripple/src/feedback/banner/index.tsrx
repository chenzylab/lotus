import { track, untrack } from 'ripple';
import { BannerFoundation, type BannerState, type BannerType } from '@lotus/foundation/feedback/banner';
import { IconButton } from '../../basic/icon-button/index.tsrx';
import { IconClose, IconAlertTriangle, IconTickCircle, IconInfoCircle, IconAlertCircle } from '@lotus/icons';
import { zhCN } from '@lotus/locale';
import { LocaleContext } from '../../other/config-provider/locale-context.js';

export type { BannerType };

export interface BannerProps {
    children?: any;
    type?: BannerType;
    fullMode?: boolean;
    title?: any;
    description?: any;
    icon?: any;
    closeIcon?: any;
    bordered?: boolean;
    style?: Record<string, any>;
    class?: string;
    onClose?: (event: MouseEvent) => void;
}

const DEFAULT_ICONS: Record<BannerType, any> = {
    warning: <IconAlertTriangle />,
    success: <IconTickCircle />,
    info: <IconInfoCircle />,
    danger: <IconAlertCircle />,
};

/**
 * Banner：通栏提示。极简状态机（只有"关闭"一个动作），关闭按钮复用
 * 已有的 IconButton 组件，四种类型的默认图标来自 `@lotus/icons`。
 */
export function Banner(&{
    children,
    type = 'info',
    fullMode = true,
    title,
    description,
    icon,
    closeIcon,
    bordered = false,
    style,
    class: className,
    onClose,
}: BannerProps) @{
    const localeTracked = LocaleContext.get();
    let &[locale] = track(() => localeTracked?.value ?? zhCN);

    let &[state] = track<BannerState>({ visible: true });

    const foundation = new BannerFoundation({
        getState: () => untrack(() => state),
        setState: (patch: Partial<BannerState>) => { state = { ...untrack(() => state), ...patch }; },
    });

    function handleClose(event: MouseEvent) {
        foundation.close(() => onClose?.(event));
    }

    let &[classes] = track<string>(() =>
        [
            'lotus-banner',
            `lotus-banner-${type}`,
            fullMode ? 'lotus-banner-full' : 'lotus-banner-in-container',
            !fullMode && bordered ? 'lotus-banner-bordered' : '',
            className ?? '',
        ]
            .filter(Boolean)
            .join(' '),
    );

    const resolvedIcon = icon !== undefined ? icon : DEFAULT_ICONS[type];

    <>
        @if (state.visible) {
            <div class={classes} style={style} role="alert">
                <div class="lotus-banner-content-wrapper">
                    <div class="lotus-banner-content">
                        @if (resolvedIcon) {
                            <div class="lotus-banner-icon">{resolvedIcon}</div>
                        }
                        <div class="lotus-banner-content-body">
                            @if (title) {
                                <div class="lotus-banner-title">{title}</div>
                            }
                            @if (description) {
                                <div class="lotus-banner-description">{description}</div>
                            }
                        </div>
                    </div>
                    @if (closeIcon !== null) {
                        <IconButton
                            class="lotus-banner-close"
                            icon={closeIcon ?? <IconClose />}
                            theme="borderless"
                            size="small"
                            type="tertiary"
                            aria-label={locale.Banner.close}
                            onClick={handleClose}
                        />
                    }
                </div>
                @if (children != null) {
                    <div class="lotus-banner-extra">{children}</div>
                }
            </div>
        }

        <style>
            .lotus-banner {
                display: flex;
                flex-direction: column;
                gap: var(--lotus-spacing-tight);
                padding: var(--lotus-spacing-base);
                background: var(--lotus-color-bg-1);
            }

            .lotus-banner-in-container {
                border-radius: var(--lotus-border-radius-small);
            }

            .lotus-banner-bordered {
                border: var(--lotus-border-width-control) solid var(--lotus-color-border);
            }

            .lotus-banner-content-wrapper {
                display: flex;
                align-items: flex-start;
                justify-content: space-between;
                gap: var(--lotus-spacing-tight);
            }

            .lotus-banner-content {
                display: flex;
                align-items: flex-start;
                gap: var(--lotus-spacing-tight);
                flex: 1;
                min-width: 0;
            }

            .lotus-banner-icon {
                display: flex;
                align-items: center;
                flex-shrink: 0;
                font-size: 20px;
            }

            .lotus-banner-content-body {
                display: flex;
                flex-direction: column;
                gap: 4px;
                min-width: 0;
            }

            .lotus-banner-title {
                font-size: var(--lotus-font-body-size);
                font-weight: var(--lotus-font-weight-semibold);
                color: var(--lotus-color-text-0);
            }

            .lotus-banner-description {
                font-size: var(--lotus-font-body-size);
                color: var(--lotus-color-text-1);
            }

            .lotus-banner-close {
                flex-shrink: 0;
            }

            .lotus-banner-extra {
                padding-inline-start: calc(20px + var(--lotus-spacing-tight));
            }

            .lotus-banner-info {
                background: var(--lotus-color-info-light-default);
            }
            .lotus-banner-info .lotus-banner-icon {
                color: var(--lotus-color-info);
            }

            .lotus-banner-success {
                background: var(--lotus-color-success-light-default);
            }
            .lotus-banner-success .lotus-banner-icon {
                color: var(--lotus-color-success);
            }

            .lotus-banner-warning {
                background: var(--lotus-color-warning-light-default);
            }
            .lotus-banner-warning .lotus-banner-icon {
                color: var(--lotus-color-warning);
            }

            .lotus-banner-danger {
                background: var(--lotus-color-danger-light-default);
            }
            .lotus-banner-danger .lotus-banner-icon {
                color: var(--lotus-color-danger);
            }
        </style>
    </>
}
